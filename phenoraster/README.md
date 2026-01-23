# phenoraster

`phenoraster` is an R package for extracting vegetation phenology metrics  
(Start of Season, SOS; End of Season, EOS; Peak of Season, POS)  
from raster time series, either globally or regionally.

The package is designed for large-scale datasets such as **CMIP6 GPP**,  
but is flexible enough to handle any regularly sampled raster time series.

---

## Features

- Read monthly or regular-temporal raster stacks as `SpatRaster` objects.
- Fit **double-logistic (DL)** curves for each pixel.
- Support **two phenology extraction strategies**:
  - **Relative threshold method** (climatology-based)
  - **Dynamic threshold method** (year-specific)
- Extract SOS, POS, EOS for each pixel and each year.
- Support global-scale processing with optional parallel computation.
- Export results as single-band GeoTIFF files per year.

---

## Phenology Extraction Methods

### 1. Relative Threshold Method (Climatological)

In this method, the threshold is calculated from the **full multi-year time series**  
of each pixel and represents its **long-term climatological growth pattern**.  
SOS and EOS are identified when the fitted DL curve reaches a fixed fraction  
of this climatological amplitude.

**Key characteristics:**

- Thresholds are **robust to noise and inter-annual variability**.
- Extreme values in individual years do not distort phenology detection.
- Phenological metrics are **directly comparable across years**.
- Preserves spatial heterogeneity by using pixel-wise thresholds.

**Important note**  
Because the threshold is defined from the **entire time series**,  
**all years must be provided at once** when using this method.  
Extracting phenology in separate temporal subsets will lead to  
different thresholds and may cause **temporal discontinuities**  
in the resulting phenology series.

---

### 2. Dynamic Threshold Method (Year-specific)

The dynamic threshold method calculates thresholds **independently for each year**,  
based solely on the **annual growth curve of that pixel**.

**Key characteristics:**

- Thresholds adapt to **inter-annual variability**.
- Suitable for applications focusing on **year-to-year phenological responses**.
- Widely used in traditional TIMESAT-style analyses.
- Avoids dependence on long-term climatology.

This method is particularly useful when:
- Long time series are not available, or
- Strong inter-annual variability is of primary interest.

---

## Installation

```r
# Install the development version from GitHub
# install.packages("remotes")
remotes::install_github("fygce/phenoraster")
