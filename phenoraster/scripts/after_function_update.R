# ============================================================
# Reinstall phenoraster after source code updates
# ============================================================

# --------- 1. Set package root path ---------
pkg_path <- "E:/GlobalFromWhiteToGreen/phenoraster"

stopifnot(dir.exists(pkg_path))
setwd(pkg_path)

cat("Working directory set to:\n", pkg_path, "\n")

# --------- 2. Regenerate documentation & NAMESPACE ---------
cat("Running devtools::document() ...\n")
devtools::document()

# --------- 3. Install updated package ----------------------
cat("Installing updated phenoraster ...\n")
devtools::install(pkg_path, upgrade = "never")

# --------- 4. Load and verify -------------------------------
library(phenoraster)

cat("Installed phenoraster version:\n")
print(packageVersion("phenoraster"))

cat("Available exported functions:\n")
print(ls("package:phenoraster"))

cat("Reinstall finished successfully.\n")
