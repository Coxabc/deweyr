#' Execute Deweypy via UVX
#'
#' Internal function to run deweypy using uvx in an isolated environment.
#' Constructs and executes the command-line call to deweypy's speedy-download.
#'
#' @param api_key Character string with deweypy API key
#' @param download_path Character string with download destination directory
#' @param folder_id Character string with Dewey folder ID
#' @param python_version Character string specifying the Python version to use.
#'   Default is "3.13".
#' @param num_workers Integer specifying number of workers for multi-threaded downloads.
#'   If NULL (default), deweypy uses its default of 8 workers.
#' @param partition_key_before Character string in YYYY-MM-DD format for partition filtering.
#'   If provided, includes all partitions up to and including this date.
#' @param partition_key_after Character string in YYYY-MM-DD format for partition filtering.
#'   If provided, includes all partitions from and including this date onward.
#'
#' @return A character vector containing the stdout and stderr output from the download command
#'
#' @keywords internal
#' @noRd
run_deweypy_uv <- function(api_key,
                            download_path,
                            folder_id,
                            python_version = "3.13",
                            num_workers = NULL,
                            partition_key_before = NULL,
                            partition_key_after = NULL) {
  
  # Build base arguments
  args <- c(
    "--python", python_version,
    "--from", "deweypy", "dewey",
    "--api-key", api_key,
    "--download-directory", download_path
  )
  
  # Add speedy-download command and folder_id
  args <- c(args, "speedy-download", folder_id)
  
  # Add optional arguments only if provided
  if (!is.null(num_workers)) {
    args <- c(args, "--num-workers", as.character(num_workers))
  }
  
  if (!is.null(partition_key_before)) {
    args <- c(args, "--partition-key-before", partition_key_before)
  }
  
  if (!is.null(partition_key_after)) {
    args <- c(args, "--partition-key-after", partition_key_after)
  }
  
  # Execute command
  system2(
    "uvx",
    args = args
  )
}