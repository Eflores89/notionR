#'  Adds an H1 (heading one) Block to a Page
#'
#'  Id refers to a page id, content should be only text.
#'  @param secret API token
#'  @param id Page id where block will be appended
#'  @param content content to append as H1
#'  @param toggle defaults to FALSE. If TRUE, will create an H1 Toggle.
#'
#' @importFrom httr PATCH
#' @export
addBlockH1 <- function(secret, id, content, toggle = FALSE){

  toggle_to_lowercase <- ifelse(toggle, "true", "false")

  payload <- paste0('{"children":[{
    "type": "heading_1",
    "heading_1": {
      "rich_text": [{
        "type": "text",
        "text": {
          "content": "', content, '",
          "link": null
        }
      }],
      "color": "default",
      "is_toggleable": ', toggle_to_lowercase,'
      }
  }]}')

  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = notionVersion,
    `Content-Type` = 'application/json' )

  res <- httr::PATCH(url = paste0('https://api.notion.com/v1/blocks/', id, '/children'),
                     httr::add_headers(.headers = headers),
                     body = payload,
                     encode = "json")
  d <- httr::content(res)
  return(d)
}
