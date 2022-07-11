#' Updates an Emoji Property of a page
#'
#'  Id refers to a page in a database, and should be normalized using normalizeChromeId().
#'  @param secret API token
#'  @param id Page id to be updated
#'  @param emoji emoji to update to
#'
#' @importFrom httr PATCH
#' @export
updateEmoji <- function(secret, id, emoji){

  patch <- list("icon" = list("type" = "emoji", "emoji" = emoji))

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2021-05-13',
    `Content-Type` = 'application/json' )

  res <- httr::PATCH(url = paste0('https://api.notion.com/v1/pages/', id),
                     httr::add_headers(.headers = headers),
                     body = patch,
                     encode = "json")
  d <- httr::content(res)
  return(d)
}
