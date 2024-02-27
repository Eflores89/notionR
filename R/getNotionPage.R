#' Get a Page
#'
#' Gets a Notion Page
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
getNotionPage_WIP <- function(secret, id){

  url <- paste0("https://api.notion.com/v1/pages/", id)

  response <- httr::VERB("GET", url,
                         add_headers(Notion_Version = notionVersion, Authorization = paste0('Bearer ', secret)),
                         content_type("application/octet-stream"),
                         accept("application/json"))

  r <- content(response, "text")
  r
}




