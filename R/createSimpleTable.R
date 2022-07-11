#### WIP
# createSimpleTable <- function(){
#    library(httr)
#
#   url <- paste0("https://api.notion.com/v1/blocks/", notionR::normalizeChromePageIds("751bbfe32d5140569e116951c7a4bbb3"),"/children")
#   payload = '{
#   "type": "table",
#   "table": {
#     "table_width": 1,
#     "has_column_header": false,
#     "has_row_header": false,
#     "children": [
#       {
#         "type": "table_row",
#         "table_row": {
#           "cells": [
#             [
#               {
#                 "type": "text",
#                 "text": {
#                   "content": "column 1 content"
#                 },
#                 "plain_text": "column 1 content"
#               }
#             ]
#           ]
#         }
#       }
#     ]
#   }
# }'
#
#   payload <- '{
#   "type": "paragraph",
#   "paragraph": {
#     "rich_text": [{
#       "type": "text",
#       "text": {
#         "content": "Lacinato kale"
#       }
#     }]
#   }
# }'
#   "{\"properties\":{\"%s\":{\"relation\":[{\"id\":\"%s\"}]}}}",
#
#   headers = c(
#     `Authorization` = 'Bearer secret_vxCZixTbzZn3eZzyk7QivNp8Si6nd1BHaVixHoKPX7U',
#     `Notion-Version` = '2022-02-22',
#     `Content-Type` = 'application/json' )
#
#   res <- httr::PATCH(url = paste0("https://api.notion.com/v1/blocks/", notionR::normalizeChromePageIds("751bbfe32d5140569e116951c7a4bbb3"),"/children"),
#                      httr::add_headers(.headers = headers),
#                      body = payload,
#                      content_type("application/octet-stream"),
#                      accept("application/json"),
#                      encode = "json")
#   d <- httr::content(res)
#
# }
#
#
#
# payload <- '{"children":[{
#   "type": "paragraph",
#   "paragraph": {
#     "rich_text": [{
#       "type": "text",
#       "text": {
#         "content": "Lacinato kale"
#       }
#     }]
#   }
# }]}'
#
#
#
# library(httr)
#
# url <- "https://api.notion.com/v1/blocks/123123123123/children"
#
# response <- VERB("PATCH", url, add_headers('Notion-Version' = '2022-02-22'), content_type("application/octet-stream"), accept("application/json"))
#
# content(response, "text")
