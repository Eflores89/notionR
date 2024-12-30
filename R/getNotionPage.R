#' Get a Page
#'
#' Gets a Notion Page
#'
#' @author Eduardo Flores
#' @return list of response
#'
#' @param secret Notion API token
#' @param id page id
#'
#'
#' @importFrom httr PATCH
#' @importFrom httr content
#' @importFrom httr content_type
#' @export
getNotionPage <- function(secret, id){

  url <- paste0("https://api.notion.com/v1/pages/", id)

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2022-02-22',
    `Content-Type` = 'application/json' )

  response <- httr::VERB("GET", url,
                         httr::add_headers(.headers = headers),
                         content_type("application/octet-stream"),
                         accept("application/json"))

  r <- content(response)
  r
}




