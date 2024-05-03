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
  
  response <- httr::VERB("GET", url, add_headers(Notion_Version = "2022-02-22", 
                                                 Authorization = paste0("Bearer ", secret)), content_type("application/octet-stream"), 
                         accept("application/json"))
  r <- content(response)
  r
}
