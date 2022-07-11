#' Updates a Date property
#'
#'  Id refers to a page in a database, and should be normalized using normalizeChromeId().
#'  @param secret API token
#'  @param id Page id to be updated
#'  @param property_name name of property to update (should be a date type property)
#'  @param value value to update
#'
#' @importFrom httr PATCH
#' @export
updateDate <- function(secret, id, property_name, value){

  payload  <- sprintf(
    "{\"properties\":{\"%s\":{\"date\":{\"start\":\"%s\"}}}}",
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
