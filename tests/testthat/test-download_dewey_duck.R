# Tests for download_dewey_duck()'s batched download loop.
#
# Background: download_dewey_duck() used to hand DuckDB the entire file manifest
# in one read_parquet([...all urls...]) call. For large, unpartitioned datasets
# (e.g. Veraset Visits, ~16 TB / thousands of files) that fires thousands of
# near-simultaneous requests at the Dewey download API and triggers HTTP 500s.
# The fix processes the manifest in batches of `batch_size` files, writing each
# batch with a unique FILENAME_PATTERN so batches don't overwrite one another.
#
# These tests run the REAL function against LOCAL parquet files, stubbing only
# the network call get_dewey_urls() via local_mocked_bindings(.package="deweyr").
# The headline assertion is "no data lost across batches": every source file
# tags its rows with a unique city, so an overwriting bug would drop the
# distinct-city count below the number of source files.

# ---- helpers -----------------------------------------------------------------

# Create `n` local parquet files. Each file's rows carry the file index in the
# `city` value so we can detect any batch silently clobbering another's output.
# Columns: city, naics_code, state, caid  (caid exists to prove SELECT drops it).
make_source_files <- function(dir, n = 7) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  for (i in seq_len(n)) {
    f <- file.path(dir, sprintf("file_%02d.parquet", i))
    DBI::dbExecute(con, glue::glue(
      "COPY (SELECT * FROM (VALUES
         ('GA_522_{i}', '522110', 'GA', 'caid'),
         ('NY_522_{i}', '522110', 'NY', 'caid'),
         ('GA_541_{i}', '541110', 'GA', 'caid'),
         ('NY_111_{i}', '111111', 'NY', 'caid')
       ) t(city, naics_code, state, caid))
       TO '{f}' (FORMAT PARQUET)"
    ))
  }
  sort(list.files(dir, pattern = "\\.parquet$", full.names = TRUE))
}

# A get_dewey_urls() stand-in that points the function at local files.
fake_get_dewey_urls <- function(urls) {
  function(api_key, data_id, file_name = NULL, preview = FALSE, ...) {
    list(
      urls            = if (isTRUE(preview)) urls[[1]] else urls,
      parent_folder   = "visits-duckdb",
      file_extension  = ".snappy.parquet",          # -> read_parquet
      partition_key   = "state",
      file_size_bytes = 0,
      cols            = c("city", "naics_code", "state", "caid")
    )
  }
}

# ---- partitioned download ----------------------------------------------------

test_that("batched, partitioned download keeps every batch's rows (no overwrite)", {
  skip_on_cran()  # loads the httpfs DuckDB extension; not for CRAN's offline runs

  src <- tempfile("dwsrc")
  out <- tempfile("dwout")
  on.exit(unlink(c(src, out), recursive = TRUE), add = TRUE)
  urls <- make_source_files(src, n = 7)

  local_mocked_bindings(get_dewey_urls = fake_get_dewey_urls(urls), .package = "deweyr")

  path <- download_dewey_duck(
    api_key   = "k",
    data_id   = "prj_x__fldr_y",
    output_dir = out,
    partition = "state",
    where     = "naics_code = '522110'",
    select    = c("city", "naics_code", "state"),
    batch_size = 3                              # 7 files -> batches of 3, 3, 1
  )

  expect_true(dir.exists(path))

  # Three batches each wrote one uniquely-named file per partition -> 3 files,
  # none overwriting the others.
  ga_files <- list.files(file.path(path, "state=GA"), pattern = "\\.parquet$")
  ny_files <- list.files(file.path(path, "state=NY"), pattern = "\\.parquet$")
  expect_equal(length(ga_files), 3)
  expect_equal(length(ny_files), 3)
  expect_equal(length(unique(ga_files)), 3)   # unique {uuid} names, no clobber
  expect_true(all(grepl("^batch", ga_files)))

  df <- read_dewey_duck(path)

  expect_equal(nrow(df), 14)                          # 2 matching rows x 7 files
  expect_equal(length(unique(df$city)), 14)           # every file's rows survived
  expect_equal(sort(unique(df$naics_code)), "522110") # WHERE applied
  expect_setequal(names(df), c("city", "naics_code", "state"))  # SELECT dropped caid
  expect_equal(as.integer(table(df$state)[c("GA", "NY")]), c(7L, 7L))
})

test_that("a single batch (batch_size >= file count) still works", {
  skip_on_cran()

  src <- tempfile("dwsrc")
  out <- tempfile("dwout")
  on.exit(unlink(c(src, out), recursive = TRUE), add = TRUE)
  urls <- make_source_files(src, n = 4)

  local_mocked_bindings(get_dewey_urls = fake_get_dewey_urls(urls), .package = "deweyr")

  path <- download_dewey_duck(
    api_key = "k", data_id = "prj_x__fldr_y", output_dir = out,
    partition = "state", where = "naics_code = '522110'",
    select = c("city", "naics_code", "state"), batch_size = 100
  )

  df <- read_dewey_duck(path)
  expect_equal(nrow(df), 8)
  expect_equal(length(unique(df$city)), 8)
  expect_equal(length(list.files(file.path(path, "state=GA"), pattern = "\\.parquet$")), 1)
})

# ---- unpartitioned download --------------------------------------------------

test_that("batched, unpartitioned download writes one file per batch and loses nothing", {
  skip_on_cran()

  src <- tempfile("dwsrc")
  out <- tempfile("dwout")
  on.exit(unlink(c(src, out), recursive = TRUE), add = TRUE)
  urls <- make_source_files(src, n = 7)

  local_mocked_bindings(get_dewey_urls = fake_get_dewey_urls(urls), .package = "deweyr")

  path <- download_dewey_duck(
    api_key = "k", data_id = "prj_x__fldr_y", output_dir = out,
    partition = NULL,                                   # single-file-per-batch path
    where = "naics_code = '522110'",
    select = c("city", "naics_code", "state"),
    batch_size = 3
  )

  data_files <- list.files(path, pattern = "^data_batch\\d+\\.parquet$")
  expect_equal(length(data_files), 3)                  # one parquet per batch

  df <- read_dewey_duck(path)
  expect_equal(nrow(df), 14)
  expect_equal(length(unique(df$city)), 14)
  expect_setequal(names(df), c("city", "naics_code", "state"))
})
