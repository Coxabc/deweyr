#' Install the deweypy Python Package
#'
#' @description
#' Installs the `deweypy` Python package using pip. This function locates the
#' Python executable and installs deweypy into the Python environment.
#'
#' @param upgrade Logical; if `TRUE`, upgrades deweypy to the latest version
#'   if it is already installed. Default is `FALSE`.
#'
#' @return Invisibly returns the exit status of the installation command.
#'   A return value of `0` indicates successful installation.
#'
#' @details
#' This function uses `system2()` to call pip via the Python executable found
#' by `find_python()`. The installation is performed using the command:
#' \code{python -m pip install deweypy}
#'
#' If the installation fails, check that:
#' \itemize{
#'   \item Python is properly installed and accessible
#'   \item pip is installed in your Python environment
#'   \item You have the necessary permissions to install Python packages
#' }
#'
#' @note
#' This function assumes that `find_python()` is available and returns a valid
#' path to a Python executable. The Python environment used will depend on the
#' implementation of `find_python()`.
#'
#' @examples
#' \dontrun{
#' # Install deweypy
#' install_deweypy()
#'
#' # Install or upgrade deweypy to the latest version
#' install_deweypy(upgrade = TRUE)
#' }
#'
#' @seealso
#' \code{\link{find_python}} for locating the Python executable
#'
#' @export
install_deweypy <- function(upgrade = FALSE) {

  python_path <- find_python()
  
  args <- c("-m", "pip", "install")
  
  if (upgrade) {
    args <- c(args, "--upgrade")
  }
  
  args <- c(args, "deweypy")
  
  result <- system2(
    command = python_path,
    args = args
  )
  
  invisible(result)
}