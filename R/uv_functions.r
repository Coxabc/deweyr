#' Check if UV is installed
#'
#' Checks whether the UV Python package manager is available on the system PATH.
#'
#' @return A logical value: `TRUE` if UV is found on the system PATH, `FALSE` otherwise.
#'
#' @details
#' This function uses `Sys.which()` to search for the UV executable in the system's
#' PATH environment variable. UV is a fast Python package installer and resolver
#' written in Rust.
#'
#' @examples
#' if (has_uv()) {
#'   message("UV is installed")
#' } else {
#'   message("UV is not installed")
#' }
#'
#' @seealso \code{\link{install_uv}} for installing UV if it's not present
#'
#' @export
has_uv <- function() {
  Sys.which("uv") != ""
}

#' Install UV Python package manager
#'
#' Downloads and installs UV, a fast Python package installer and resolver.
#' The installation is skipped if UV is already present on the system.
#'
#' @return Invisibly returns `TRUE` on successful installation or if UV is already installed.
#'
#' @details
#' This function automatically detects the operating system and uses the appropriate
#' installation method:
#' \itemize{
#'   \item \strong{Windows}: Uses PowerShell to download and execute the install script
#'   \item \strong{Linux/macOS}: Uses curl to download and execute the shell script
#' }
#'
#' The function will skip installation if UV is already available on the system PATH.
#'
#' @section Installation Sources:
#' The installation scripts are fetched from the official UV repository at
#' \url{https://astral.sh/uv/}
#'
#' @note
#' \itemize{
#'   \item On Windows, this requires PowerShell execution policy to allow script execution
#'   \item On Linux/macOS, this requires curl to be installed
#'   \item If automatic installation fails, users should install UV manually from
#'         \url{https://docs.astral.sh/uv/}
#' }
#'
#' @examples
#' \dontrun{
#' # Install UV if not already present
#' install_uv()
#'
#' # Check if installation was successful
#' if (has_uv()) {
#'   message("UV installation successful!")
#' }
#' }
#'
#' @seealso \code{\link{has_uv}} to check if UV is already installed
#'
#' @export
install_uv <- function() {
  if (Sys.which("uv") != "") {
    return(invisible(TRUE))
  }
  
  os <- Sys.info()["sysname"]
  
  if (os == "Windows") {
    install_script <- "powershell -ExecutionPolicy ByPass -c \"irm https://astral.sh/uv/install.ps1 | iex\""
  } else if (os %in% c("Linux", "Darwin")) {
    install_script <- "curl -LsSf https://astral.sh/uv/install.sh | sh"
  } else {
    stop("Unsupported operating system: Install UV manually here: https://docs.astral.sh/uv/", os)
  }
  
  result <- system(install_script, intern = FALSE)
  
  if (result != 0) {
    stop("uv installation failed. Install manually here: https://docs.astral.sh/uv/")
  }
  
  invisible(TRUE)
}