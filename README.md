# R-package-for-phenology-from-raster

`phenoraster` is an R package for extracting vegetation phenology metrics from raster time series.
The package currently supports two phenology threshold strategies, both based on
Double-Logistic (DL) curve fitting, but differing in how the phenological threshold is defined.

## Installation

install.packages("remotes")

remotes::install_github("fygce/phenoraster")

## Supported Phenology Threshold Methods
1. Relative Threshold Method (Multi-year Climatological Threshold)

The original implementation of phenoraster is inspired by the relative amplitude method
from TIMESAT 3.3.

For each pixel, a single threshold is calculated from the full multi-year time series
(i.e. the climatological growth curve). The start of season (SOS) and end of season (EOS)
are identified when the fitted Double-Logistic (DL) curve reaches a specified fraction
of this threshold. While following the same conceptual logic as TIMESAT, the implementation
is specific to this R package.

Advantages

This approach reflects the climatological background of each pixel and offers several advantages:

The threshold is robust to noise and inter-annual variability, because it is derived from the full time series rather than a single year.

Extreme values in individual years (e.g., an unusually high seasonal peak) do not distort the threshold, avoiding bias in SOS/EOS extraction.

Each pixel has a local threshold, preserving spatial heterogeneity while maintaining consistency across years.

Because the threshold is climatology-based, phenological metrics from different years are directly comparable, facilitating inter-annual analysis.

The method is flexible and can be applied to any regularly sampled raster time series, not limited to CMIP6 GPP data.

Important Note on Usage

Important:
Because the relative threshold is defined from the multi-year growth curve,
the entire time series must be provided as input in a single run.

Running the extraction on subsets of years separately will result in different thresholds.

This will lead to artificial discontinuities in the extracted phenology time series (SOS/EOS).

Therefore, this method is not suitable for segmented or incremental processing unless the
threshold is fixed beforehand using the full temporal record.

2. Dynamic Threshold Method (Year-specific Threshold)

In addition to the relative threshold approach, phenoraster now supports a dynamic threshold method,
which is more widely used in phenology studies.

In this approach, the threshold is calculated independently for each year, based on the
pixel-specific annual growth curve. SOS and EOS are determined when the yearly fitted
DL curve reaches a given fraction of that year’s amplitude.

Advantages

The dynamic threshold method offers complementary strengths:

The threshold is adapted to the inter-annual variability of each pixel.

Phenological metrics are directly linked to the actual growth conditions of each year.

The method is well suited for detecting year-to-year phenological shifts, especially under climate variability and extremes.

It allows segmented or year-by-year processing, making it more flexible for large datasets or incremental analyses.

This method is particularly useful when the research focus is on annual phenological responses
rather than long-term climatological comparisons.

## Scripts and Workflows

The package provides both functions and executable scripts for phenology extraction.

Relative threshold workflows are implemented using functions operating on the full time series：fit_DL_pipeline_seed_pixel.R

Dynamic threshold workflows can be executed directly using the script: fit_DL_pipeline_seed_pixel_TS1_NH.R

## Development Status and Extensibility

phenoraster is primarily developed for extracting vegetation phenology metrics from
raster time series.

While the current implementation focuses on Double-Logistic (DL) fitting, the package
is designed to be extensible. Future versions may include:

Parallel processing

Additional curve fitting methods

Alternative phenology definitions

Contributions are welcome via GitHub Pull Requests.
For major changes or new methodological extensions, users are encouraged to contact the
package author for discussion.
