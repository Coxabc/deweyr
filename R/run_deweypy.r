#' Execute Deweypy System Command
#'
#' Internal function to run the deweypy Python module with specified parameters.
#' Constructs and executes the command-line call to deweypy's speedy-download.
#'
#' @param python_path Character string path to Python executable
#' @param api_key Character string with deweypy API key
#' @param download_path Character string with download destination directory
#' @param folder_id Character string with Dewey folder ID
#' @param num_workers Integer specifying number of workers for multi-threaded downloads.
#'   If NULL (default), deweypy uses its default of 8 workers.
#' @param partition_key_before Character string in YYYY-MM-DD format for partition filtering.
#'   If provided, includes all partitions up to and including this date.
#' @param partition_key_after Character string in YYYY-MM-DD format for partition filtering.
#'   If provided, includes all partitions from and including this date onward.
#'
#' @return The exit status from \code{system2()}, invisibly
#'
#' @keywords internal
run_deweypy <- function(python_path, 
                        api_key, 
                        download_path, 
                        folder_id,
                        num_workers = NULL,
                        partition_key_before = NULL,
                        partition_key_after = NULL) {
  
  # Build base arguments
  args <- c(
    "-m", "deweypy",
    "--api-key", api_key,
    "--download-directory", download_path,
    "speedy-download", folder_id
  )
  
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
    command = python_path,
    args = args
  )
}