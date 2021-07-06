#' Returns the database metadata as a data.frame
#'
#' Retrieve a database's metadata as referenced in Notion API: https://developers.notion.com/reference/get-database
#'
#' @author Eduardo Flores
#' @return data.frame
#'
#' @param secret Notion API token
#' @param database Notion database ID
#' @param raw if TRUE will not flatten into a data.frame
#'
#' @examples
#' \dontrun{
#' my_db <- "database_id"
#' my_secret <- "NOTION API Secret"
#'
#' my_db_data <- get_database_metadata(secret = my_secret, database = my_db)
#' }
#'
#' @importFrom httr GET
#' @importFrom httr content
#'
#' @name get_database_metadata
NULL

#' @export
#' @rdname get_database_metadata
get_database_metadata <- function(secret, database, raw = FALSE){
  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2021-05-13'
  )

  res <- httr::GET(url = paste0('https://api.notion.com/v1/databases/', database),
                   httr::add_headers(.headers = headers))

  d <- httr::content(res)

  print(paste0("Database: ", d$title[[1]]$plain_text, " [id: ", d$id, "]", ". Last edited on: ", d$last_edited_time))

  if(!raw){ .flatten_database_metadata(d) }else{d}
}

#' @export
#' @rdname get_database_metadata
.flatten_database_metadata <- function(d){
  n <- length(d$properties)

  cols <- NULL
  for(i in 1:n){
    col_name <- names(d$properties[i])[1]
    col_id <- d$properties[[i]]$id[1]
    col_type <- d$properties[[i]]$type[1]

    tmp <- data.frame("name" = col_name,
                      "id" = col_id,
                      "type" = col_type
                      )

    cols <- rbind.data.frame(tmp, cols)
  }

  cols
}

