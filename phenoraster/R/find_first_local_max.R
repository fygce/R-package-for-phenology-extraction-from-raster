#' Find first local maximum
#'
#' @param x Numeric vector
#' @return Index of first local maximum, or NA
find_first_local_max <- function(x) {
  
  if (length(x) < 5) return(NA_integer_)
  
  dx1 <- diff(x)
  sign_change <- diff(sign(dx1))
  
  # local max: + -> -
  idx <- which(sign_change == -2) + 1
  
  if (length(idx) == 0) return(NA_integer_)
  idx[1]
}
