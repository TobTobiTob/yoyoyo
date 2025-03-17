# dependencies.R
# This script checks for required packages and installs any that are missing.

required_packages <- c("shiny", "quantmod")

installed <- installed.packages()[, "Package"]
for (pkg in required_packages) {
  if (!(pkg %in% installed)) {
    install.packages(pkg, dependencies = TRUE)
  }
}
