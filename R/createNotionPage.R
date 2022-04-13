#' Create a Page
#'
#' Silent Return
#'
#' @author Eduardo Flores
#'
#' @param parent
#'
#'
#' @importFrom stringi stri_split_regex
#' @export
createNotionPage <- function(parent, children){

}


library(httr)

url <- "https://api.notion.com/v1/pages"

library(httr)

url <- "https://api.notion.com/v1/pages"

payload <- "{\"children\":[\"something in this page!\"],\"parent\":12313412,\"properties\":\"\\\"name\\\" = nameofpage\"}"

encode <- "json"

response <- VERB("POST", url,
                 body = payload,
                 add_headers(Notion_Version = '2022-02-22Authorization = Bearer 1312311'), content_type("application/json"), accept("application/json"), encode = encode)

content(response, "text")
