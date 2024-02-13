#' Updates (adds) a relationship to a page id
#'
#'  Id refers to a page in a database, and should be normalized using normalizeChromeId().
#'  @param secret API token
#'  @param id Page id to be updated
#'  @param property_name name of property to update (should be a relationship type property)
#'  @param value value to update (should be a unique page id)
#'
#' @importFrom httr PATCH
#' @export
updateRelationship <- function(secret, id, property_name, value){

  payload  <- sprintf(
    "{\"properties\":{\"%s\":{\"relation\":[{\"id\":\"%s\"}]}}}",
    property_name, value
  )


  if(length(value) == 1){
    payload  <- sprintf(
      "{\"properties\":{\"%s\":{\"relation\":[{\"id\":\"%s\"}]}}}",
      property_name, value
    )
  }else{
    options <- paste0('{\"id\":\"',value,'\"}', collapse = ",")
    payload  <- paste0(
      '{\"properties\":{\"', property_name,'\":{\"relation\":[', options, ']}}}'
    )
  }



  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2022-06-28',
    `Content-Type` = 'application/json' )

  res <- httr::PATCH(url = paste0('https://api.notion.com/v1/pages/', id),
                     httr::add_headers(.headers = headers),
                     body = payload,
                     encode = "json")
  d <- httr::content(res)
  return(d)

}
