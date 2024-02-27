#' Archive a Page
#'
#' Archive's a notion page.
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
archivePage <- function(secret, id){

  value <- "true"

  payload  <- sprintf(
    "{\"archived\":%s}",
    value
  )

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = notionVersion,
    `Content-Type` = 'application/json' )

  res <- httr::PATCH(url = paste0('https://api.notion.com/v1/pages/', id),
                     httr::add_headers(.headers = headers),
                     body = payload,
                     encode = "json")
  d <- httr::content(res)
  return(d)
}
