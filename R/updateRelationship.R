#' Updates (adds) a relationship to a page id
#'
#' Id refers to a page in a database, and should be normalized using normalizeChromeId().
#'
#' @param secret API token
#' @param id Page id to be updated
#' @param property_name name of property to update (should be a relationship type property)
#' @param value value to update (should be a unique page id)
#'
#' @return list
#'
#' @importFrom httr PATCH
#' @export
updateRelationship <- function(secret, id, property_name, value){

  payload  <- sprintf(
    "{\"properties\":{\"%s\":{\"relation\":[{\"id\":\"%s\"}]}}}",
    property_name, value
  )

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2022-02-22',
    `Content-Type` = 'application/json' )

  res <- httr::PATCH(url = paste0('https://api.notion.com/v1/pages/', id),
                     httr::add_headers(.headers = headers),
                     body = payload,
                     encode = "json")
  d <- httr::content(res)
  return(d)
}
