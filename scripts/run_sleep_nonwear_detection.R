# scripts/run_sleep_nonwear_detection.R
source("R/setup.R")
source("R/algorithms/sleep_nonwear_detection.R")
source("R/visualizations/plots.R")

set_working_directory()
fibionfiles <- list.files(path = file.path(here::here(), "data/Example data"), pattern = "\\.(CSV|csv)$", recursive = TRUE, full.names = TRUE)

for (file in fibionfiles) {
  data <- run_sleep_nonwear_detection(file)
  
  # Extract filename without extension
  filename <- sub("\\.CSV$", "", basename(file), ignore.case = TRUE)
  
  # Generate plot and save
  plot_filename <- file.path(here::here(), "data/output", paste0("Summaryplot_algorithm_", filename, ".pdf"))
  create_activity_plot(data, plot_filename)
  
  # Save results
  save_results(data, filename)
}

