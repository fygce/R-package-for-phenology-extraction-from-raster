# R-package-for-extracting-vegetation-phenology-metrics-from-raster-time-series
phenoraster is an R package for extracting vegetation phenology metrics (Start of Season, Peak of Season, End of Season) from raster time series, either globally or regionally. Example workflows are provided using CMIP6 GPP data, but the package works for any regularly sampled raster time series. 

### Method Overview
`phenoraster` is inspired by the **relative amplitude method** from Timesat. 
For each pixel, a threshold is calculated from the full time series, and SOS/EOS are 
determined when the fitted **Double-Logistic (DL) curve** reaches a specified fraction of this threshold. 
While following the same logic, the implementation is specific to this R package.

