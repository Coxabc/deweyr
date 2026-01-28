#' Parse Dewey Data Folder ID from URL
#'
#' Extracts the folder ID from a Dewey Data API URL or returns the folder ID
#' unchanged if already parsed. Folder IDs always start with "prj_".
#'
#' @param url Character string containing either:
#'   \itemize{
#'     \item A full Dewey Data API URL (e.g., "https://api.deweydata.io/api/v1/external/data/prj_xxx__fldr_yyy")
#'     \item An already-parsed folder ID (e.g., "prj_xxx__fldr_yyy")
#'   }
#'
#' @return A character string containing the folder ID (starting with "prj_")
#'
#' @examples
#' # From full URL
#' parse_url("https://api.deweydata.io/api/v1/external/data/prj_evgjik8m__fldr_9awifji8cxi9ey77m")
#' # Returns: "prj_evgjik8m__fldr_9awifji8cxi9ey77m"
#'
#' # Already-parsed folder ID (returns unchanged)
#' parse_url("prj_evgjik8m__fldr_xagc4dttgm4rh93ad")
#' # Returns: "prj_evgjik8m__fldr_xagc4dttgm4rh93ad"
#'
#' @export
parse_url <- function(url) {
    # If already a folder ID (starts with prj_), return as-is
    if (grepl("^prj_", url)) {
        return(url)
    }

    # Extract folder ID from URL
    folder_id <- sub(".*data/", "", url)

    # Validate extraction worked
    if (folder_id == url || !grepl("^prj_", folder_id)) {
        stop(
            "Could not extract folder ID. Please use the copy button from the Dewey Data website, ",
            "or provide a folder ID starting with 'prj_'."
        )
    }

    folder_id
}
