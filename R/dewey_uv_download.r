#' Run Dewey Download Using UV
#'
#' Downloads files from a Dewey folder using uvx to run deweypy without requiring
#' a local Python installation or manual package management. This function automatically
#' handles uv installation if needed and executes the download in an isolated environment.
#'
#' @param api_key Character string with the API key for deweypy authentication
#' @param folder_id Character string with the Dewey folder ID or URL to download from
#' @param download_path Character string specifying where to download files.
#'   Default is a "dewey-downloads" folder in the current working directory.
#' @param python_version Character string specifying the Python version to use.
#'   Default is "3.13". Must be a valid Python version supported by uv.
#'
#' @details
#' This function uses \href{https://docs.astral.sh/uv/}{uv} (a fast Python package installer)
#' to run deweypy without requiring you to manage Python environments manually.
#' 
#' The function performs the following steps:
#' \itemize{
#'   \item Checks if uv is installed, and installs it if needed
#'   \item Creates the download directory if it doesn't exist
#'   \item Executes deweypy's speedy-download command via uvx in an isolated environment
#' }
#' 
#' @section Note on UV Installation:
#' If uv needs to be installed, you may see a message recommending you restart your
#' terminal for optimal performance in future runs. The function will work without
#' restarting, but subsequent runs may be faster after a restart.
#'
#' @return A character vector containing the stdout and stderr output from the download command
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic usage with default settings
#' dewey_uv_download(
#'   api_key = "your-api-key",
#'   folder_id = "folder123"
#' )
#' 
#' # Specify custom download location
#' dewey_uv_download(
#'   api_key = "your-api-key",
#'   folder_id = "folder123",
#'   download_path = "C:/my-data"
#' )
#' 
#' # Use a different Python version
#' dewey_uv_download(
#'   api_key = "your-api-key",
#'   folder_id = "folder123",
#'   python_version = "3.12"
#' )
#' }
dewey_uv_download <- function(api_key,
                               folder_id,
                               download_path = file.path(getwd(), "dewey-downloads"),
                               python_version = "3.13" # DON'T PUT 3.14!!!!!
) {
  
  # Ensure download folder exists
  if (!dir.exists(download_path)) {
    dir.create(download_path, recursive = TRUE)
  }
  
  # step 1: check for uv
  
  if (! has_uv())
  {
    install_uv()
    print("Restarting the terminal will increase speed of future runs")
  }
  
  
  
  # Step 2: Run Dewey download
  result <- system2(
    "uvx",
    args = c("--python", python_version,
             "--from", "deweypy", "dewey",
             "--api-key", api_key,
             "--download-directory", download_path,
             "speedy-download", folder_id),
    stdout = TRUE,
    stderr = TRUE
  )
  
  return(result)
}