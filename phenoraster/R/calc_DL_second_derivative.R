#' Calculate second-order derivative of fitted DL curve
#'
#' @param fhat Numeric vector, fitted values on dense grid
#' @param t_dense Numeric vector, DOY corresponding to fhat
#' @return Numeric vector, second derivative
calc_DL_second_derivative <- function(fhat, t_dense) {
  
  dt <- mean(diff(t_dense))
  
  # first derivative
  d1 <- diff(fhat) / dt
  
  # second derivative (length = n - 2)
  d2 <- diff(d1) / dt
  
  # align to t_dense (centered)
  d2_full <- rep(NA_real_, length(fhat))
  d2_full[2:(length(fhat) - 1)] <- d2
  
  d2_full
}
