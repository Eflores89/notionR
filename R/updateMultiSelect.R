#' Updates a Select Property
#'
#'  Id refers to a page in a database, and should be normalized using normalizeChromeId().
#'  @param secret API token
#'  @param id Page id to be updated
#'  @param property_name name of property to update (should be a multiselect type property)
#'  @param value value(s) to update. Could be 1 value or multiple, created with c().
#'
#'  @details This will rewrite whatever is already in the property. It will NOT append another select.
#'
#' @importFrom httr PATCH
#' @export
updateMultiSelect <- function(secret, id, property_name, value){

  if(length(value) == 1){
    payload  <- sprintf(
      "{\"properties\":{\"%s\":{\"multi_select\":[{\"name\":\"%s\"}]}}}",
      property_name, value
    )
  }else{
    options <- paste0('{\"name\":\"',value,'\"}', collapse = ",")
    payload  <- paste0(
      '{\"properties\":{\"', property_name,'\":{\"multi_select\":[', options, ']}}}'
    )
  }

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
