

createSimpleTable <- function(){
  library(httr)

  url <- paste0("https://api.notion.com/v1/blocks/", notionR::normalizeChromePageIds("488c739030274bf0b525e0367c92ea13"),"/children")
  payload = '{
  "type": "table",
  "table": {
    "table_width": 1,
    "has_column_header": false,
    "has_row_header": false,
    "children": [
      {
        "type": "table_row",
        "table_row": {
          "cells": [
            [
              {
                "type": "text",
                "text": {
                  "content": "column 1 content"
                },
                "plain_text": "column 1 content"
              }
            ]
          ]
        }
      }
    ]
  }
}'
  payload = '{
  "type": "heading_1",
  "heading_1": {
    "rich_text": [{
      "type": "text",
      "text": {
        "content": "Lacinato kale",
        "link": null
      }
    }],
    "color": "default"
  }
}'
  response <- httr::VERB("PATCH", url,
                         add_headers(Notion_Version = '2022-02-22',
                                     Authorization = 'Bearer secret_vxCZixTbzZn3eZzyk7QivNp8Si6nd1BHaVixHoKPX7U'),
                         body = payload,
                         content_type("application/octet-stream"), accept("application/json"))

  content(response, "text")
}


library(httr)

url <- "https://api.notion.com/v1/blocks/page-id/children"

response <- VERB("PATCH", url, add_headers(Notion_Version = '2022-02-22Authorization = 'Bearer 1231412312'), content_type("application/octet-stream"), accept("application/json"))

content(response, "text")




payload <- "{\"children\":[\"something in this page!\"],\"parent\":12313412,\"properties\":\"\\\"name\\\" = nameofpage\"}"

encode <- "json"

response <- VERB("POST", url,
                 body = payload,










{
  "type": "table",
  "table": {
    "table_width": 1,
    "has_column_header": false,
    "has_row_header": false,
    "children": [
      {
        "type": "table_row",
        "table_row": {
          "cells": [
            [
              {
                "type": "text",
                "text": {
                  "content": "column 1 content"
                },
                "plain_text": "column 1 content"
              }
            ]
          ]
        }
      }
    ]
  }
}
