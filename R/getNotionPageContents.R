#' Get Page Contents
#'
#' Retrieves all children blocks (contents) of a Notion page and returns them as a list.
#'
#' @details This calls the Notion API endpoint GET /v1/blocks/{id}/children.
#' Only the first level of children is returned per call. If a child block itself has children
#' (i.e., \code{has_children = TRUE}), you would need to call this function again with that
#' block's ID to retrieve its nested children.
#'
#' See: \url{https://developers.notion.com/reference/get-block-children}
#'
#' @author Eduardo Flores
#' @return list of block objects (children of the page)
#'
#' @param secret Notion API token
#' @param id Notion page ID (or any block ID that supports children). Use normalizeChromePageIds if using directly from browser.
#' @param show_progress show prints of progress?
#' @param all_pages download all pages (loop thru paginations)?
#'
#' @importFrom dplyr %>%
#' @importFrom httr2 request req_url_path req_url_query req_headers req_perform
#' @importFrom httr2 resp_status_desc resp_body_json
#' @export
#'
#' @examples
#' \dontrun{
#' my_secret <- "secret_xxxx"
#' page_id <- "your-page-id"
#' contents <- getNotionPageContents(secret = my_secret, id = page_id)
#' }
#'
getNotionPageContents <- function(secret, id, show_progress = FALSE, all_pages = TRUE){

  # +++++++++ api call -------------------------------------------------------------
  callAPI_httr2 <- function(id, cursor, page_size = 100, secret, show_progress) {

    the_req <- request("https://api.notion.com/") %>%
      req_url_path(paste0("/v1/blocks/", id, "/children")) %>%
      req_url_query(page_size = page_size, start_cursor = cursor) %>%
      req_headers("Authorization" = paste("Bearer", secret)) %>%
      req_headers("Content-Type" = "application/json") %>%
      req_headers("Notion-Version" = "2022-06-28")

    # Perform the request
    resp <- req_perform(the_req)
    # Check if ok
    resp_status_desc(resp)

    # Get response as list
    res <- resp_body_json(resp)

    if(show_progress){
      print(paste0("!! API Call: https://api.notion.com/v1/blocks/", id, "/children"))
    }

    return(res)
  }

  if(all_pages){
    if(show_progress){ print(paste0("++++ PAGINATING CALLS: ")) }

    new_cursor <- TRUE
    all_results <- list()
    cursor <- NULL

    while( new_cursor ){
      if(show_progress){ print(paste0("- cursor: ", cursor, " / new_cursor: ", new_cursor )) }

      r <- callAPI_httr2(id = id,
                         cursor = cursor,
                         secret = secret,
                         show_progress = show_progress)

      new_cursor <- r$has_more
      cursor <- r$next_cursor

      # append results
      all_results <- c(all_results, r$results)

      if(show_progress){ print(paste0("- blocks retrieved so far: ", length(all_results) )) }
    }
  }else{
    # no pagination, just the first page of results
    if(show_progress){ print(paste0("++++ NO PAGINATION: ")) }

    r <- callAPI_httr2(id = id,
                       cursor = NULL,
                       secret = secret,
                       show_progress = show_progress)

    all_results <- r$results
  }

  return(all_results)
}
