#' Returns a block
#'
#' Query API with a block ID and retrieve JSON format (for now)
#'
#'
#' @author Eduardo Flores
#' @return JSON
#'
#' @param secret Notion API token
#' @param id Notion block ID.
#'
#' @importFrom httr GET
#' @importFrom httr content
#' @export
getBlock <- function(secret, id) {
  url <- paste0("https://api.notion.com/v1/blocks/", id)

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2022-02-22',
    `Content-Type` = 'application/json' )

  response <- httr::VERB("GET", url,httr::add_headers(.headers = headers),
                         content_type("application/octet-stream"),
                         accept("application/json"))
  r <- content(response)
  r
}
