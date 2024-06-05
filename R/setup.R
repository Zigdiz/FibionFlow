# R/setup.R
required_packages <- c("zoo", "plyr", "tidyverse", "readxl", "writexl", "data.table", "here")

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}
