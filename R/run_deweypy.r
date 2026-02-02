#' Execute Deweypy System Command
#'
#' Internal function to run the deweypy Python module with specified parameters
#'
#' @param python_path Character string path to Python executable
#' @param api_key Character string with deweypy API key
#' @param download_path Character string with download destination directory
#' @param folder_id Character string with Dewey folder ID
#'
#' @keywords internal
run_deweypy <- function(python_path, api_key, download_path, folder_id) {
  system2(
    command = python_path,
    args = c(
      "-m", "deweypy",
      "--api-key", api_key,
      "--download-directory", download_path,
      "speedy-download", folder_id
    )
  )
}