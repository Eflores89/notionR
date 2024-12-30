#' Get a Page with it's Content
#'
#' Gets a Notion Page and the content inside it. Does not structure (yet) and instead provides a list of blocks and content.
#'
#'
#' @author Eduardo Flores
#' @return list of response with blocks and content
#'
#' @param secret Notion API token
#' @param id page id
#'
#'
#' @importFrom httr PATCH
#' @importFrom httr content
#' @importFrom httr content_type
#' @export
getNotionPageContent <- function(secret, id){

  url <- paste0("https://api.notion.com/v1/blocks/", id, "/children?page_size=100")

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2022-06-28',
    `Content-Type` = 'application/json' )

  response <- httr::VERB("GET", url,
                         httr::add_headers(.headers = headers),
                         content_type("application/octet-stream"),
                         accept("application/json"))

  r <- content(response)
  r
}
