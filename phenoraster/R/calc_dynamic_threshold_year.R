#' Calculate dynamic relative amplitude threshold for one year (TIMESAT method 1)
#'
#' @param fit_year List, single year DL fit
#' @param threshold Fraction of amplitude (default 0.5)
#' @return Numeric threshold for this year
#' @export
calc_dynamic_threshold_year <- function(fit_year, threshold = 0.5) {
  
  if (is.null(fit_year) || is.null(fit_year$fhat))
    return(NA_real_)
  
  f <- fit_year$fhat
  f <- f[is.finite(f)]
  if (length(f) < 10) return(NA_real_)
  
  # Robust base / max (TIMESAT-style)
  f_sorted <- sort(f)
  n <- length(f_sorted)
  m <- max(1, floor(n * 0.1))
  
  base <- mean(f_sorted[1:m])
  maxv <- mean(f_sorted[(n - m + 1):n])
  
  if (!is.finite(base) || !is.finite(maxv) || maxv <= base)
    return(NA_real_)
  
  base + (maxv - base) * threshold
}
