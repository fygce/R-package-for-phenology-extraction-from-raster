# ==============================================================
# phenoraster_example_TS1.R
# Example workflow for extracting SOS / EOS / POS
# using TIMESAT Method 1 (dynamic relative threshold)
# ==============================================================


# -------------------------------
# Step 0: Load packages
# -------------------------------
library(phenoraster)   # your package
library(terra)
library(phenofit)

# -------------------------------
# Step 1: Define input/output paths
# -------------------------------
indir  <- "H:/cmip6_gpp/historical/ACCESS-ESM1-5/tif_lon180"
outdir <- "H:/cmip6_gpp/output_pheno_TS1/historical/ACCESS-ESM1-5"

if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

# -------------------------------
# Step 2: Read raster time series
# -------------------------------
ts <- read_raster_ts(indir)
r <- ts$raster
dates <- ts$dates

years <- as.integer(format(dates, "%Y"))
doy   <- as.numeric(format(dates, "%j"))

cat("Raster stack loaded:",
    ncell(r), "pixels,",
    length(dates), "layers\n")

# -------------------------------
# Step 3: Single pixel test (TIMESAT method 1)
# -------------------------------
set.seed(123)

vals <- values(r)

# Select pixels with valid data
good_pixels <- which(rowSums(!is.na(vals) & vals != 0) > 0)

manual_pixel_index <- NULL   # e.g. 1222, or NULL for random
pixel_index <- if (!is.null(manual_pixel_index)) {
  manual_pixel_index
} else {
  sample(good_pixels, 1)
}

cat("Selected test pixel index:", pixel_index, "\n")

v_all <- vals[pixel_index, ]

# ---- DL fitting (yearly) ----
fits <- fit_pixel_DL_yearly(
  y_all = v_all,
  doy_all = doy,
  year_vec = years,
  pixel_index = pixel_index   # enables per-year plots
)

# ---- Extract phenology using TS1 ----
pheno_pixel_TS1 <- extract_pheno_pixel_TS1(
  fits,
  threshold = 0.5
)

print(pheno_pixel_TS1)

# ---- Plot one example year ----
yr <- rownames(pheno_pixel_TS1)[1]
fit_year <- fits[[yr]]

thr_year <- calc_dynamic_threshold_year(
  fit_year,
  threshold = 0.5
)

plot(fit_year$t_dense, fit_year$fhat,
     type = "l", lwd = 2, col = "red",
     main = paste("Pixel", pixel_index, "Year", yr, "(TS1)"),
     xlab = "DOY", ylab = "GPP")

points(fit_year$t_obs, fit_year$y_obs,
       pch = 19, col = "blue")

abline(h = thr_year, lty = 2, col = "grey40")
abline(v = pheno_pixel_TS1[yr, "SOS"], col = "green", lwd = 2)
abline(v = pheno_pixel_TS1[yr, "POS"], col = "red",   lwd = 2)
abline(v = pheno_pixel_TS1[yr, "EOS"], col = "brown", lwd = 2)

legend("topleft",
       legend = c("DL fit", "Original", "Dynamic threshold",
                  "SOS", "POS", "EOS"),
       col = c("red", "blue", "grey40",
               "green", "red", "brown"),
       lty = c(1, NA, 2, 1, 1, 1),
       pch = c(NA, 19, NA, NA, NA, NA),
       bty = "n")

# -------------------------------
# Step 4: Global phenology extraction (TIMESAT method 1)
# -------------------------------

test_years <- 1950:1951   # subset for testing

cat("Running global TS1 extraction...\n")

res_TS1 <- global_pheno_extraction_TS1(
  r = r,
  doy = doy,
  years = years,
  outdir = outdir,
  threshold = 0.5,
  years_sel = test_years
)

cat("TS1 phenology extraction finished.\n")
cat("Results saved to:", outdir, "\n")
