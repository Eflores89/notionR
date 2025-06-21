#' Returns a vector of the available multi-select options in a field
#'
#' For a given column in a database field, creates a vector of all entries. See parameters for options.
#'
#'
#' @details does NOT call API.
#'
#' @author Eduardo Flores
#' @return vector
#'
#' @param column vector of column in data.frame (usually, after using getNotionDatabase, in form db$column_name )
#' @param strip_string String by which we should strip >1 selects in a single database row. Defaults to "|", as this is the default behaviour in getNotionDatabase().
#' @param no_na Strip all NA's? Defaults to TRUE.
#' @param only_unique Export only unique values in vector? Defaults to TRUE.
#' @param show_progress Print the count of values? Defaults to TRUE.
#'
#' @importFrom stringi stri_split_regex
#' @export
getMultiSelectValues <- function(column, strip_string = "\\|", no_na = TRUE, only_unique = TRUE, show_progress = TRUE){
  l1 <- length(column)

  # strip NA's
  if(no_na){
    b <- column[!is.na(column)]
    l2 <- length(b)
  }

  # unique workflow
  if(only_unique){
    l <- ifelse(no_na, l2, l1)
    if(exists("b")){
      c2 <- b
    }else{
      c2 <- column
    }

    c3 <- NULL
    for(i in 1:l ){
      tmp <- as.vector(stringi::stri_split_regex(c2[i], pattern = strip_string)[[1]] )
      tmp <- tmp[tmp != "|"]

      c3 <- c(c3, tmp)
    }

    c3 <- unique(c3)
    l3 <- length(c3)
  } # ends unique workflow

  # progress prints
  if(show_progress){
    if(only_unique|no_na){
      print(paste0("Vector from ", l1, " to ", ifelse(exists("l3"), l3, l2)))
    }else{
      print(paste0("Vector length ", l1))
    }
  }

  r <- ifelse(exists("c3"), c3, ifelse(exists("b"), b, column))
  if(exists("c3")){
    r <- c3
  }else{
    if(exists("b")){
      r <- b
    }else{
      r <- column
      warning("Nothing has changed in column, as both no_na and only_unique are FALSE.")
    }
  }
  return(r)
}
