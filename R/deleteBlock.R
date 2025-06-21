#' Delete a Block
#'
#' Deletes a block
#'
#'
#' @author Eduardo Flores
#' @return list of response
#'
#' @param secret Notion API token
#' @param id block id
#' @return list
#'
#'
#' @importFrom httr PATCH content content_type add_headers accept
#' @export
deleteBlock <- function(secret, id){

  url <- paste0("https://api.notion.com/v1/blocks/", id)

  response <- httr::VERB("DELETE", url,
                         add_headers(Notion_Version = '2022-06-28', Authorization = paste0('Bearer ', secret)),
                         content_type("application/octet-stream"),
                         accept("application/json"))

  d <- httr::content(response)

  print(paste0("Notion Block ",id," Deleted."))
  return(d)
}
