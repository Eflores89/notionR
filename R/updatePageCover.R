#' Updates a Page Cover
#'
#' Updates a page cover to the url specified
#'
#'
#' @author Eduardo Flores
#' @return list of response
#'
#' @param secret Notion API token
#' @param id page id to be updated
#' @param cover_url url of cover to be update
#'
#'
#' @importFrom httr PATCH
#' @importFrom httr content
#' @export
updatePageCover <- function(secret, id, cover_url){
  patch <- list("cover" = list("type" = "external",
                               "external" = list( "url" = cover_url)))

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = notionVersion,
    `Content-Type` = 'application/json' )

  res <- httr::PATCH(url = paste0('https://api.notion.com/v1/pages/', id),
                     httr::add_headers(.headers = headers),
                     body = patch,
                     encode = "json")
  d <- httr::content(res)
  return(d)
}
