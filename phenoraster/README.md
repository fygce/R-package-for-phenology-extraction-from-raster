# phenoraster

`phenoraster` is an R package for extracting vegetation phenology metrics (Start of Season, SOS; End of Season, EOS; Peak of Season, POS) from raster time series, either globally or regionally.

## Features

- Read monthly/temporal raster stacks as `SpatRaster` objects.
- Fit double-logistic (DL) curves for each pixel.
- Calculate a robust relative amplitude threshold for phenology extraction.
- Extract SOS, POS, EOS for each pixel and each year.
- Export results as single-band TIFF files per year.

## Installation

```r
# Install the development version from GitHub
# install.packages("remotes")
remotes::install_github("fygce/phenoraster")




library(phenoraster)
library(terra)
library(raster)
library(phenofit)

# Load example raster data included in the package
indir <- system.file("extdata/cmip6_gpp/historical/ACCESS-ESM1-5/tif_lon180",
                     package = "phenoraster")

# Define output folder in temporary directory
outdir <- file.path(tempdir(), "pheno_output")
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

# Read raster time series
ts <- read_raster_ts(indir)
r <- ts$raster
dates <- ts$dates

years <- as.integer(format(dates, "%Y"))
doy   <- as.numeric(format(dates, "%j"))

# Single-pixel DL fit test (randomly selected)
set.seed(123)
vals <- values(r)
good_pixels <- which(rowSums(!is.na(vals) & vals != 0) > 0)
pixel_index <- sample(good_pixels, 1)
v_all <- vals[pixel_index, ]

fits <- fit_pixel_DL_yearly(v_all, doy, years)
thr <- calc_relative_threshold_pixel(fits, threshold = 0.5)
pheno_pixel <- t(sapply(fits, extract_pheno_DL_year, thr = thr))

# Global phenology extraction for a subset of years
test_years <- 2000:2001
res <- global_pheno_extraction(r, doy, years, outdir, threshold = 0.5, years_sel = test_years)

cat("Phenology extraction finished. Results saved to:", outdir, "\n")


