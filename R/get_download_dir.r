#' Get Default Dewey Download Directory
#'
#' Returns the absolute path to the default download directory for Dewey data,
#' which is a "dewey-downloads" folder in the current working directory.
#'
#' @param create Logical. If TRUE, creates the directory if it doesn't exist.
#'   Default is TRUE.
#'
#' @return A character string containing the absolute path to the download directory
#'
#' @examples
#' # Get default download path (creates if doesn't exist)
#' get_download_dir()
#'
#' # Get path without creating directory
#' get_download_dir(create = FALSE)
#'
#' @export
get_download_dir <- function(create = TRUE) {
    download_path <- file.path(getwd(), "dewey-downloads")

    if (create && !dir.exists(download_path)) {
        dir.create(download_path, recursive = TRUE)
        message("Created download directory: ", download_path)
    }

    download_path
}
