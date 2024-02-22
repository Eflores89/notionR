#' Is the database output empty ?
#'
#' @param dataframe The database output
#'
#' @export
isEmptyNotionDatabaseExport <- function(dataframe){
  isTRUE(nrow(dataframe) == 1 &
       names(dataframe)[1] == "results" &
       dataframe[1,1] == "none")
}
