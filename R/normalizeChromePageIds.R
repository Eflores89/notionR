#' Returns a page id from a copy-paste page id in browser
#'
#'
#' @author Eduardo Flores
#' @return character
#'
#' @param x page id in format: 1f4c70197b0e4589902d371adc1dbd9a
#' @export
normalizeChromePageIds <- function(x){
  paste0(substr(x, 1,8), "-",
         substr(x, 9,12), "-",
         substr(x, 13,16), "-",
         substr(x, 17,20), "-",
         substr(x, 21, 36))
}
