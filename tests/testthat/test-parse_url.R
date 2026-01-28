# Test 1: Normal use case - full API URL from Dewey website
test_that("parse_url extracts folder ID from full URL", {
  url <- "https://api.deweydata.io/api/v1/external/data/prj_evgjik8m__fldr_9awifji8cxi9ey77m"

  result <- parse_url(url)

  # Should extract everything after "/data/"
  expect_equal(result, "prj_evgjik8m__fldr_9awifji8cxi9ey77m")
})

# Test 2: User already has the folder ID - don't break it
test_that("parse_url returns already-parsed folder ID unchanged", {
  folder_id <- "prj_evgjik8m__fldr_xagc4dttgm4rh93ad"

  result <- parse_url(folder_id)

  # Should recognize it starts with "prj_" and return as-is
  expect_equal(result, folder_id)
})

# Test 3: Another pre-parsed ID - ensure consistency
test_that("parse_url handles another pre-parsed folder ID", {
  folder_id <- "prj_evgjik8m__fldr_8rfd7cg4js37vydsw"

  result <- parse_url(folder_id)

  # Should also recognize this starts with "prj_" and return unchanged
  expect_equal(result, folder_id)
})

# Test 4: Shortened/alternate URL format - still works
test_that("parse_url handles shortened URL format", {
  url <- "https://deweydata.io/data/prj_test__fldr_test123"

  result <- parse_url(url)

  # Should work with different domain as long as "/data/" pattern exists
  expect_equal(result, "prj_test__fldr_test123")
})

# Test 5: Completely wrong URL - should fail gracefully
test_that("parse_url errors on invalid URL without data/", {
  invalid_url <- "https://example.com/invalid"

  # Should throw error because no "/data/" found and doesn't start with "prj_"
  expect_error(
    parse_url(invalid_url),
    "Could not extract folder ID"
  )
})

# Test 6: Malformed but parseable URL - extract what we can
test_that("parse_url handles malformed URL", {
  invalid_url <- "aaaaaaaaaaaaaaa/data/prj_evgjik8m__fldr_9awifji8cxi9ey77"

  result <- parse_url(invalid_url)

  # Should still extract the folder ID after "/data/" even if URL is weird
  expect_equal(result, "prj_evgjik8m__fldr_9awifji8cxi9ey77")
})

# Test 7: URL with no valid folder ID - should fail
test_that("parse_url errors when extraction fails", {
  invalid_url <- "https://example.com/no-folder-id-here"

  # Should error because extracted result doesn't start with "prj_"
  expect_error(
    parse_url(invalid_url),
    "Could not extract folder ID"
  )
})
