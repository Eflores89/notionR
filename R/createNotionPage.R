#' Create a Page
#'
#' Silent Return
#'
#' @author Eduardo Flores
#'
#' @param secret API token
#' @param parent_id database id where page will be created or page under which it will nest
#' @param title_property name of the title property
#' @param title title of the new page
#' @return list
#'
#' @importFrom stringi stri_split_regex
#' @export
createNotionPage <- function(secret, parent_id, title_property, title = "untitled"){

  if(is.null(title_property)){stop("Please add name of title property.")}

  details <- paste0(
    '{ "parent": { "database_id": "', parent_id, '" },
    "properties": {"', title_property,
    '": { "title" : [ { "type":"text", "text": { "content" : "', title, '"} }]}}
    }')

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2021-08-16',
    `Content-Type` = 'application/json' )

  res <- httr::POST(url = paste0('https://api.notion.com/v1/pages'),
                    httr::add_headers(.headers = headers),
                    body = details)
  d <- httr::content(res)

  print("Notion Page added details below: ")
  return(d)
}
