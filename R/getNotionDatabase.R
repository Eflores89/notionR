#' Returns a database as a data.frame
#'
#' Query a database in Notion with desired filters and get a database as a data.frame in R or download the entire database (all pages).
#'
#' @details This is actually a POST request as per Notions API: https://developers.notion.com/reference/post-database-query
#'
#' @author Eduardo Flores
#' @return data.frame
#'
#' @param secret Notion API token
#' @param database Notion database ID. Use normalizeChromaPageIds if using directly from browser.
#' @param filters A list built with filter operators (see filters) to query database. If NULL will query everything.
#' @param show_progress show prints of progress?
#' @param all_pages download all pages (loop thru paginations)?
#'
#'
#' @importFrom httr POST
#' @importFrom httr content
#' @importFrom tibble enframe
#' @importFrom dplyr %>%
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom tidyr pivot_wider
#' @importFrom dplyr bind_rows
#' @export
getNotionDatabase <- function(secret, database, filters = NULL, show_progress = FALSE, all_pages = TRUE){
  options(dplyr.summarise.inform = FALSE) # to supress all the grouping warnings!

  # +++++++++ construct headers
  headers = c(`Authorization` = secret, `Notion-Version` = '2022-02-22', `Content-Type` = 'application/json' )

  # +++++++++ api call -------------------------------------------------------------
  callAPI <- function(database, headers, filters, cursor){
    res <- httr::POST(url = paste0('https://api.notion.com/v1/databases/', database, '/query'),
                      httr::add_headers(.headers = headers),
                      body = list("filters" = filters,
                                  "start_cursor" = cursor),
                      # start_cursor = cursor,
                      encode = "json")
    if(show_progress){ print(paste0("!! API Call: https://api.notion.com/v1/databases/", database, "/query")) }

    return( httr::content(res) )
  }

  # +++++++++ this function "flattens" the results into a usable data.frame with 1 row per page (like the real database)
  getItemsAndFlattenIntoDataFrame <- function(results){
    if(show_progress){ print(paste0("- flattening into data.frame")) }

    # the results (i.e., rows) are extracted into a simple data.frame with value being a list of each item's properties and id's
    items <- tibble::enframe(results)

    # now, for each item, we will extract a tidy data.frame where we have all of the columns
    dd <- NULL
    for(i in 1:nrow(items)){
      # this is a tidy dataset with column 1 = name (i.e., value.object.type, etc) and col2 = value (i.e,. d3f0ee76-fc3b-426c-8d23-cff84800b0d6)
      tmp <- tibble::enframe(unlist(items[[i, 2]]))

      # to avoid duplicates, (such as two relationships tied to a page) I will condense them into 1 separated by a pipe
      tmp <- tmp %>%
        group_by(name) %>%
        summarise("value" = paste(value, collapse = " | "))

      # now, I want to keep this as 1 row in a big data set, so I will pivot_wider
      tmp <- tidyr::pivot_wider(tmp)

      # now, I will create one big dataset, I will use dplyr in case columns are not exactly the same, which could be the case if one or various of the properties are missing
      dd <- dplyr::bind_rows(dd, tmp)
    }

    return(dd)
  }

  if(all_pages){
    if(show_progress){ print(paste0("++++ PAGINATING CALLS: ")) }

    # if using all_pages, I will run all of the pagination available.
    new_cursor <- TRUE
    dd <- NULL
    cursor <- NULL

    while( new_cursor ){
      if(show_progress){ print(paste0("- cursor: ", cursor, " / new_cursor: ", new_cursor )) }

      r <- callAPI(database = database,
                   headers = headers,
                   filters = filters,
                   cursor = cursor)

      new_cursor <- r$has_more
      cursor <- r$next_cursor

      # stack the data.frames together
      tmp <- getItemsAndFlattenIntoDataFrame( r$results )

      dd <- dplyr::bind_rows(dd, tmp)

      if(show_progress){ print(paste0("- nrow of downloads: ", nrow(dd) )) }
    }
  }else{
    # no pagination, just the top 100
    if(show_progress){ print(paste0("++++ NO PAGINATION: ")) }
    cursor <- NULL
    r <- callAPI(database = database,
                 headers = headers,
                 filters = filters,
                 cursor = cursor)

    dd <- getItemsAndFlattenIntoDataFrame( r$results )
  }

  return(dd)
}
