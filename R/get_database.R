#' Returns a database as a data.frame
#'
#' Query a database in Notion with desired filters and get a database as a data.frame in R.
#'
#' @details This is actually a POST request as per Notions API: https://developers.notion.com/reference/post-database-query
#'
#' @author Eduardo Flores
#' @return data.frame
#'
#' @param secret Notion API token
#' @param database Notion database ID
#' @param filters A list built with filter operators (see filters) to query database
#' @param rollup_return return "ids" or "names" in rollup properties (if allowed, i.e., is not a number)?
#'
#' @examples
#' \dontrun{
#' my_db <- "database_id"
#' my_secret <- "NOTION API Secret"
#' my_query <- notion_or(add_checkbox_filter("tu}s", TRUE),
#'                       add_checkbox_filter("YiIx", FALSE)) %>% notion_filter()
#' my_db_data <- get_database(secret = my_secret, database = my_db, filters = my_query)
#' }
#'
#' @importFrom httr POST
#' @importFrom httr content
#' @export
<<<<<<< HEAD
get_database <- function(secret, database, filters, rollup_return = "id"){
=======
get_database <- function(secret, database, filters){
>>>>>>> a4937a13a0f5bdda873c31d6feada82de05acae6
  auth_secret <- paste0("Bearer ", secret)

  headers = c(
    `Authorization` = auth_secret,
    `Notion-Version` = '2021-05-13',
    `Content-Type` = 'application/json' )

  res <- httr::POST(url = paste0('https://api.notion.com/v1/databases/', database, '/query'),
                    httr::add_headers(.headers = headers),
                    body = filters,
                    encode = "json")

  d <- httr::content(res)

  d <- .flatten_database(d, meta = get_database_metadata(secret = secret,
                                                         database = database),
                            rollup_return = rollup_return)

  return(d)
}
#' @export
.flatten_database <- function(d, meta, rollup_return){
  rown <- length(d$results)
  coln <- length(meta$name)+3

  df <- data.frame(matrix(ncol = coln, nrow = rown))
  names(df) <- c("page_id", "created_time", "edited_time", meta$name )

  for(i in 1:rown){
    this_row <- d$results[i][[1]]

    page_id <- this_row$id
    create_time <- this_row$created_time
    edit_time <- this_row$last_edited_time

    df[i, 1] <- page_id
    df[i, 2] <- create_time
    df[i, 3] <- edit_time

    print(i)
      for(j in 1:length(this_row$properties)){

        if(this_row$properties[[j]]$type == "relation"){
          # do nothing!
          # for now, I do not know how to handle relations as they are not in table
          # metadata results! Hence, skipping.

        }else{
          col_index <- match(this_row$properties[[j]]$id, meta$id)+3
          df[i, col_index] <- .get_by_type(type = this_row$properties[[j]]$type,
                                           props = this_row$properties[[j]],
                                           rollup_return = rollup_return)
        } # end of if condition
      } # end of property for
  }
  return(df)
}
#' @export
.get_by_type <- function(type, props, rollup_return){

  if(type == "formula"){
    if(props$formula$type == "number"){
      e <- as.numeric(props$formula$number)
    }else{
      stop("type of formula not supported... yet")
    }

  }
  if(type == "checkbox"){
    e <- props$checkbox
  }

  if(type == "date"){
    e <- as.Date(props$date$start)
    warning("Only start date extracted, end date not supported... yet")
  }

  if(type == "title"){
    e <- as.character(props$title[[1]]$text$content)
  }

  if(type == "number"){
    e <- as.numeric(props$number)
  }

  if(type == "relation"){
    e <- paste(unlist(props$relation), collapse = "|")
  }

  if(type == "rollup"){
    e <- .rollup_get(rollup_scope = props$rollup,
                     rollup_return = rollup_return)
  }

  if(exists("e")){
    return(e)
  }else{
    print(type)
    stop("type not supported... yet")
  }

}


.rollup_get <- function(rollup_scope, rollup_return){
  rollup_type <- rollup_scope$type

  if(rollup_type == "array"){
    if(rollup_scope$array[[1]]$type == "select"){
      if(rollup_return == "id" & "id" %in% names(rollup_scope$array[[1]]$select) ){
        e <- rollup_scope$array[[1]]$select$id
      }else{
        e <- rollup_scope$array[[1]]$select$name
      }
    }
  } # end of array ---

  if(rollup_type == "number"){
    e <- rollup_scope$number
    print(e)
    rm(e)
  }

  if(exists("e")){
    return(e)
  }else{
    stop("rollup type not supported yet... ")
  }

}
