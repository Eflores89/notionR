#' Get a Page with it's Content
#'
#' Gets a Notion Page and the content inside it. Works with nested blocks too, as a page is also a block.
#'
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
getNotionPageContent <- function(secret, id){

  url <- paste0("https://api.notion.com/v1/blocks/", id, "/children?page_size=100")

  response <- httr::VERB("GET", url,
                         add_headers(Notion_Version = notionVersion, Authorization = paste0('Bearer ', secret)),
                         content_type("application/octet-stream"),
                         accept("application/json"))

  # r <- content(response, "text")
  response
}
