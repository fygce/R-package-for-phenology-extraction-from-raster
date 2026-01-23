#' Extract phenology for one pixel using TIMESAT method 1 (dynamic threshold)
#'
#' @param fits List of yearly DL fits (output of fit_pixel_DL_yearly)
#' @param threshold Numeric, relative amplitude fraction
#' @return Matrix with rows = years, cols = SOS/EOS/POS
#' @export
extract_pheno_pixel_TS1 <- function(
    fits, threshold = 0.5, years_sel = NULL) {

  if (is.null(years_sel))
    years_sel <- as.integer(names(fits))

  pheno <- matrix(
    NA_real_,
    nrow = length(years_sel),
    ncol = 3,
    dimnames = list(years_sel, c("SOS","EOS","POS"))
  )

  for (yr in years_sel) {
    fit_year <- fits[[as.character(yr)]]
    if (is.null(fit_year)) next

    thr_year <- calc_dynamic_threshold_year(fit_year, threshold)
    if (is.na(thr_year)) next

    pheno[as.character(yr), ] <-
      extract_pheno_DL_year(fit_year, thr = thr_year)
  }

  pheno
}

