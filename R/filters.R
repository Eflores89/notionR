#' Filter Operators
#'
#' Helps you build a database filter call with human-readable intuition. You must finish (if using pipes) with notion_filter().
#'
#' @details Still WIP, only a few operators are currently available.
#'
#' @author Eduardo Flores
#' @return list
#'
#' @param . List of filter conditions
#' @param sort List of sort conditions. NULL by default.
#'
#'
#' @examples
#' \dontrun{
#' # to create an OR filter on two checkbox columns with id's "tus" and "YiIx"...
#' my_query <- notion_or(add_checkbox_filter("tus", TRUE),
#'                       add_checkbox_filter("YiIx", FALSE)) %>% notion_filter()
#'  }
#' @name filters
NULL

#' @export
#' @rdname filters
notion_filter <- function(., sort = NULL){
  if(is.null(sort)){
    f <- list("filter" = . )
  } else {
    f <- list("filter" = . ,
              "sorts" = sort)
  }
  return(f)
}


#' @export
#' @rdname filters
notion_or <- function(...){
  f <- list("or" = list(...))
  return(f)
}

#' Checkbox Filter
#'
#' Adds a checkbox filter condition.
#'
#' @param property name or id of property (column) in database
#' @param equals TRUE (default) or FALSE condition to meet in checkbox. Equals (contains) for select filter.
#'
#' @author Eduardo Flores
#' @return list
#'
#' @examples
#' # add a condition where checkbox should be checked
#' add_checkbox_filter("id_column")
#' # add a condition where checkbox should NOT be checked
#' add_checkbox_filter("id_column", FALSE)
#' @name filters
NULL

#' @export
#' @rdname filters
add_checkbox_filter <- function(property, equals = TRUE){
  list("property" = property,
       "checkbox" = list("equals" = equals))
}

#' @export
#' @rdname filters
add_select_filter <- function(property, equals){
    list(property = property, select = list(equals = equals))
}
