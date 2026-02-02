# ==============================================================
# phenoraster_example_D2_NH.R
# Second-derivative (D2) phenology extraction
# For GIMMS / MODIS NDVI (16-day)
#
# SOS definition:
# SOS is defined as the first local maximum of the second-order
# derivative of the fitted double-logistic curve during DOY <= 182
#
# Northern Hemisphere only (lat >= 0)
# ==============================================================

# -------------------------------
# Step 0: Load packages
# -------------------------------
library(phenoraster)
library(terra)
library(phenofit)

# -------------------------------
# Step 1: Define input/output paths
# -------------------------------
indir  <- "E:/GlobalFromWhiteToGreen/gimms3gplus_phen/North_corre/tifs_min500_05deg"
outdir <- "E:/GlobalFromWhiteToGreen/gimms3gplus_phen/1_Phen/GUD/gud_d2"

if (!dir.exists(outdir))
  dir.create(outdir, recursive = TRUE)

# -------------------------------
# Step 2: Read raster time series (DOY-based)
# -------------------------------
ts <- read_raster_ts_doy(indir)

r     <- ts$raster
years <- ts$years
doy   <- ts$doy
dates <- ts$dates

cat("Original raster:",
    ncell(r), "pixels,",
    length(dates), "layers\n")

# -------------------------------
# Step 2.5: Crop + mask to Northern Hemisphere (only if needed)
# -------------------------------
ext_r <- ext(r)

if (ymin(ext_r) < 0) {
  cat("Applying NH crop & mask...\n")

  e_nh <- ext_r
  ymin(e_nh) <- 0
  r <- crop(r, e_nh)

  lat <- init(r, "y")
  r <- mask(r, lat >= 0)
} else {
  cat("Raster already in Northern Hemisphere. Skip masking.\n")
}

cat("Current raster extent:", as.character(ext(r)), "\n")
cat("Number of pixels after NH processing:", ncell(r), "\n")

# -------------------------------
# -------------------------------
# Step 3: Single pixel test (D2)
# -------------------------------
set.seed(123)

candidate_pixels <- sample(ncell(r), 500)

pixel_index <- NA
for (i in candidate_pixels) {
  v <- as.numeric(values(r[i, drop = FALSE]))
  if (sum(!is.na(v) & v > 0) > 0.5 * length(v) &&
      (quantile(v, 0.9, na.rm = TRUE) -
       quantile(v, 0.1, na.rm = TRUE)) > 0.2) {
    pixel_index <- i
    break
  }
}

stopifnot(!is.na(pixel_index))
cat("Selected seasonal test pixel:", pixel_index, "\n")

v_all <- as.numeric(values(r[pixel_index, drop = FALSE]))
v_all[v_all <= 0] <- NA

test_years <- sort(unique(years))[1:2]

fits <- fit_pixel_DL_yearly(
  y_all       = v_all,
  doy_all     = doy,
  year_vec    = years,
  years_sel   = test_years,
  pixel_index = pixel_index
)

# ---- Extract phenology (D2) ----
pheno_pixel_D2 <- extract_pheno_pixel_D2(fits)
print(pheno_pixel_D2)

if (nrow(pheno_pixel_D2) > 0) {
  yr <- rownames(pheno_pixel_D2)[1]
  fit_year <- fits[[yr]]

  plot(fit_year$t_dense, fit_year$fhat,
       type = "l", lwd = 2, col = "red",
       main = paste("Pixel", pixel_index, "Year", yr, "(D2)"),
       xlab = "DOY", ylab = "NDVI")

  points(fit_year$t_obs, fit_year$y_obs,
         pch = 19, col = "blue")

  abline(v = pheno_pixel_D2[yr, "SOS"], col = "green", lwd = 2)
  abline(v = pheno_pixel_D2[yr, "POS"], col = "red",   lwd = 2)
  abline(v = pheno_pixel_D2[yr, "EOS"], col = "brown", lwd = 2)
} else {
  message("No valid D2 phenology found for test pixel.")
}

# -------------------------------
# Step 4: Global phenology extraction (D2)
# -------------------------------
# 推荐：先跑一段年份测试
years_sel <- sort(unique(years))
years_sel <- 1982:1983   # ← 如需分段跑，直接打开这一行

cat("Running global D2 extraction (NH only)...\n")

res_D2 <- global_pheno_extraction_D2(
  r         = r,
  doy       = doy,
  years     = years,
  outdir    = outdir,
  years_sel = years_sel
)

cat("D2 phenology extraction finished.\n")
cat("Results saved to:", outdir, "\n")
