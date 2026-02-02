#' Read raster time series with YYYY_DOY naming
#'
#' @param indir Character, folder containing TIFFs named as *_YYYY_DDD.tif
#' @param pattern Regex pattern to select files
#'
#' @return A list with raster, dates, years, doy
#'
#' @export
read_raster_ts_doy <- function(indir, pattern="\\.tif$") {
  
  library(terra)
  
  files <- list.files(indir, pattern = pattern, full.names = TRUE)
  stopifnot(length(files) > 0)
  
  files <- sort(files)
  
  bn <- basename(files)
  nums <- gsub("\\D", "", bn)
  
  if (any(nchar(nums) < 7))
    stop("Filename must contain YYYYDDD (year + doy).")
  
  years <- as.integer(substr(nums, 1, 4))
  doy   <- as.integer(substr(nums, 5, 7))
  
  if (any(doy < 1 | doy > 366))
    stop("Invalid DOY detected in filenames.")
  
  dates <- as.Date(paste0(years, "-01-01")) + doy - 1
  
  r <- rast(files)
  crs(r) <- "EPSG:4326"
  
  list(
    raster = r,
    dates  = dates,
    years  = years,
    doy    = doy
  )
}
