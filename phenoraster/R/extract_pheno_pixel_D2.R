#' Extract phenology for one pixel using second-derivative method
#'
#' @param fits List of yearly DL fits
#' @param years_sel Optional integer vector
#' @param spring_end DOY defining first half year (default 182)
#' @export
extract_pheno_pixel_D2 <- function(
    fits,
    years_sel = NULL,
    spring_end = 182
) {
  
  if (is.null(years_sel))
    years_sel <- as.integer(names(fits))
  
  pheno <- matrix(
    NA_real_,
    nrow = length(years_sel),
    ncol = 3,
    dimnames = list(years_sel, c("SOS","POS","EOS"))
  )
  
  for (yr in years_sel) {
    
    fit_year <- fits[[as.character(yr)]]
    if (is.null(fit_year)) next
    
    t <- fit_year$t_dense
    f <- fit_year$fhat
    
    d2 <- calc_DL_second_derivative(f, t)
    
    # ---- SOS: first local max of d2 in first half year ----
    idx_spring <- which(t <= spring_end)
    idx_local  <- find_first_local_max(d2[idx_spring])
    
    if (!is.na(idx_local)) {
      pheno[as.character(yr), "SOS"] <- t[idx_spring][idx_local]
    }
    
    # ---- POS: max NDVI ----
    pheno[as.character(yr), "POS"] <- t[which.max(f)]
    
    # ---- EOS: symmetric definition (optional,保守做法) ----
    idx_fall <- which(t > spring_end)
    idx_fall_local <- find_first_local_max(-d2[idx_fall])
    
    if (!is.na(idx_fall_local)) {
      pheno[as.character(yr), "EOS"] <- t[idx_fall][idx_fall_local]
    }
  }
  
  pheno
}
