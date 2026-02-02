#' Global phenology extraction using second-derivative (D2) method
#'
#' @param r SpatRaster, NDVI time series
#' @param doy Numeric vector, day-of-year for each layer
#' @param years Integer vector, year for each layer
#' @param outdir Character, output directory
#' @param years_sel Optional integer vector, subset of years
#' @param min_n Integer, minimum valid observations per year
#'
#' @return A list with SOS, POS, EOS matrices (invisible)
#' @export
global_pheno_extraction_D2 <- function(
    r, doy, years, outdir,
    years_sel = NULL,
    min_n = 10
) {

  library(terra)
  library(utils)

  if (is.null(years_sel))
    years_sel <- sort(unique(years))

  nyear <- length(years_sel)
  ncell_total <- ncell(r)

  cat("Total pixels:", ncell_total, "\n")
  cat("Years:", paste(years_sel, collapse = ", "), "\n")

  # output matrices
  SOS_mat <- matrix(NA_real_, ncell_total, nyear)
  POS_mat <- matrix(NA_real_, ncell_total, nyear)
  EOS_mat <- matrix(NA_real_, ncell_total, nyear)

  # terra block structure
  bs <- blocks(r)

  pb <- txtProgressBar(min = 0, max = ncell_total, style = 3)

  cell_global <- 0

  for (b in seq_len(bs$n)) {

    # ---- read one block (rows × layers) ----
    v_block <- values(
      r,
      row   = bs$row[b],
      nrows = bs$nrows[b]
    )

    if (is.null(v_block))
      next

    for (i in seq_len(nrow(v_block))) {

      cell_global <- cell_global + 1

      # full time series for ONE pixel
      y_all <- as.numeric(v_block[i, ])
      y_all[y_all <= 0] <- NA

      if (sum(!is.na(y_all)) < min_n) {
        setTxtProgressBar(pb, cell_global)
        next
      }

      # ---- DL fitting (yearly) ----
      fits <- fit_pixel_DL_yearly(
        y_all       = y_all,
        doy_all     = doy,
        year_vec    = years,
        years_sel   = years_sel,
        pixel_index = NULL   # global mode: no plotting
      )

      if (length(fits) == 0) {
        setTxtProgressBar(pb, cell_global)
        next
      }

      # ---- D2 phenology extraction ----
      ph <- extract_pheno_pixel_D2(
        fits,
        years_sel = years_sel
      )

      if (!is.null(ph) && nrow(ph) > 0) {
        SOS_mat[cell_global, ] <- ph[, "SOS"]
        POS_mat[cell_global, ] <- ph[, "POS"]
        EOS_mat[cell_global, ] <- ph[, "EOS"]
      }

      if (cell_global %% 500 == 0 || cell_global == ncell_total)
        setTxtProgressBar(pb, cell_global)
    }
  }

  close(pb)

  # -------------------------------
  # Write outputs
  # -------------------------------
  if (!dir.exists(outdir))
    dir.create(outdir, recursive = TRUE)

  for (j in seq_along(years_sel)) {
    yr <- years_sel[j]

    for (v in c("SOS", "POS", "EOS")) {

      out_r <- rast(
        nrows = nrow(r),
        ncols = ncol(r),
        ext   = ext(r),
        crs   = crs(r)
      )

      values(out_r) <- get(paste0(v, "_mat"))[, j]

      writeRaster(
        out_r,
        filename = file.path(outdir, paste0(v, "_", yr, "_D2.tif")),
        overwrite = TRUE
      )
    }
  }

  cat("\nSecond-derivative (D2) phenology saved to:", outdir, "\n")

  invisible(list(
    SOS = SOS_mat,
    POS = POS_mat,
    EOS = EOS_mat
  ))
}
