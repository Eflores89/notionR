#'  Adds a Paragraph Block to a Page
#'
#'  Id refers to a page id, content should be only text. HTML will export to text.
#'  @param secret API token
#'  @param id Page id where block will be appended
#'  @param content content to append
#'
#' @importFrom httr PATCH
#' @export
addBlockParagraph <- function(secret, id, content){

  payload <- paste0('{"children":[{
    "type": "paragraph",
    "paragraph": {
      "rich_text": [{
        "type": "text",
        "text": {
          "content": "', content, '",
          "link": null
        }
      }],
      "color": "default"
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
