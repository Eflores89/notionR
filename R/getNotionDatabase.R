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
#' @param cover_icon also include cover and icon metadata?
#'
#'
#' @importFrom tibble enframe
#' @importFrom dplyr %>%
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom tidyr pivot_wider
#' @importFrom dplyr bind_rows
#' @importFrom httr2 request req_url_path req_headers req_body_json req_perform
#' @importFrom httr2 resp_status_desc resp_body_json
#' @export
getNotionDatabase <- function(secret, database, filters = NULL, show_progress = FALSE, all_pages = TRUE, cover_icon = FALSE){
  options(dplyr.summarise.inform = FALSE) # to supress all the grouping warnings!

  # +++++++++ api call -------------------------------------------------------------
  callAPI_httr2 <- function(database, filters, cursor, page_size = 100, secret, show_progress) {
    if (!is.numeric(page_size) || page_size < 1 || page_size > 100) {
      stop("page_size should be a numeric between 1 and 100")
    }

    # data to send
    data_to_send <- list(
      "filter" = filters,
      # "sorts" = sorts, # not implemented
      "start_cursor" = cursor,
      # There must be at least one not NULL in the list, hence page_size
      "page_size" = page_size
    )
    # Remove NULL to avoid bad request
    data_to_send[sapply(data_to_send, is.null)] <- NULL

    # add data to the request
    the_req <- request("https://api.notion.com/") %>%
      req_url_path(paste0("/v1/databases/", database, "/query")) %>%
      req_headers("Authorization" = paste("Bearer" , secret)) %>%
      req_headers("Content-Type" = "application/json") %>%
      req_headers("Notion-Version" = "2022-06-28") %>%
      req_body_json(data = data_to_send)

    # Perform the request
    resp <- req_perform(the_req)
    # Check if ok
    resp_status_desc(resp)

    # Get response as list
    res <- resp_body_json(resp)

    if(show_progress){
      print(paste0("!! API Call: https://api.notion.com/v1/databases/", database, "/query"))
    }

    return(res)
  }

  # +++++++++ this function "flattens" the results into a usable data.frame with 1 row per page (like the real database)
  getItemsAndFlattenIntoDataFrame <- function(results, cover_and_icon = cover_icon){
    if(show_progress){ print(paste0("- flattening into data.frame")) }

    # adding error-catching when the results are none (i.e., a filter w no results)
    if(length(results) < 1 ){
      dd <- data.frame("results" = "none")
      warning("There are no results from the query. Check your filters. A data.frame will still be exported, with col_name = results and row1 = none")

    }else{
      # the results (i.e., rows) are extracted into a simple data.frame with value being a list of each item's properties and id's
      items <- tibble::enframe(results)

      # now, for each item, we will extract a tidy data.frame where we have all of the columns
      dd <- NULL
      for(i in 1:nrow(items)){
        ## before we tidy up,
        ## add NA's if there is no cover or icon AND we want to based on the option in the parameters of the function

        if(cover_and_icon){
          if(is.null(  items[[2]][[i]][["cover"]] )){
            items[[2]][[i]][["cover"]] <- as.logical("FALSE")
          }
          if(is.null( items[[2]][[i]][["icon"]] )){
            items[[2]][[i]][["icon"]] <- as.logical("FALSE")
          }
        }

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

      # r <- callAPI(database = database,
      #              headers = headers,
      #              filters = filters,
      #              cursor = cursor)
      #
      r <- callAPI_httr2(database = database,
                         filters = filters,
                         cursor = cursor,
                         secret = secret,
                         show_progress = show_progress)

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
    # r <- callAPI(database = database,
    #              headers = headers,
    #              filters = filters,
    #              cursor = cursor)

    r <- callAPI_httr2(database = database,
                       filters = filters,
                       cursor = cursor,
                       secret = secret,
                       show_progress = show_progress)

    dd <- getItemsAndFlattenIntoDataFrame( r$results )
  }

  return(dd)
}
