#' Download Files Using Deweypy
#'
#' Downloads all files from a Dewey folder using the deweypy Python package.
#' This function interfaces with the Dewey file management system to batch download
#' files from a specified folder to your local machine.
#'
#' @param api_key Character string with the API key for deweypy authentication
#' @param folder_id Character string with the Dewey folder ID or URL to download from
#' @param download_path Character string specifying where to download files.
#'   If NULL (default), uses the default directory from \code{get_download_dir()}
#' @param python_path Character string specifying the path to Python executable. 
#'   If NULL (default), will automatically search for Python on the system.
#'
#' @details
#' The function performs the following steps:
#' \itemize{
#'   \item Locates Python executable (auto-detect or use provided path)
#'   \item Validates the folder ID/URL
#'   \item Creates download directory if it doesn't exist
#'   \item Executes deweypy's speedy-download command
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Auto-detect Python path, default download location
#' dewey_download(api_key = "your-api-key", folder_id = "folder123")
#' 
#' # Specify custom download path
#' dewey_download(
#'   api_key = "your-api-key", 
#'   folder_id = "folder123",
#'   download_path = "C:/Downloads/my-files"
#' )
#' 
#' # Specify Python path manually
#' dewey_download(
#'   api_key = "your-api-key", 
#'   folder_id = "folder123",
#'   python_path = "C:/Python313/python.exe"
#' )
#' }
dewey_download <- function(api_key, folder_id, download_path = NULL, python_path = NULL) {
  
  # If python_path is NULL, auto-detect it
  if (is.null(python_path)) {
    python_path <- find_python()
  }
  
  # Validate that python_path exists
  if (!file.exists(python_path)) {
    stop("Python executable not found at: ", python_path)
  }

  # Validate folder_id
  folder_id <- parse_url(folder_id)

  
  # Set default download path if not provided
  if (is.null(download_path)) {
    download_path <- get_download_dir(create = TRUE)
  } else {
    # If custom path provided, ensure it exists
    if (!dir.exists(download_path)) {
      dir.create(download_path, recursive = TRUE)
    }
  }
  # Execute deweypy download command
  run_deweypy(
    python_path = python_path,
    api_key = api_key,
    download_path = download_path,
    folder_id = folder_id
  )
}