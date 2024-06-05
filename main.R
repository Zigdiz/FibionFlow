# main.R

# Load setup and utility functions
source("R/setup.R")
source("R/utils.R")

# Load algorithm scripts
source("R/algorithms/sleep_nonwear_detection.R")

# Load visualization scripts
source("R/visualizations/plots.R")

# Set the working directory
set_working_directory()

# Function to run all analyses
run_all_analyses <- function() {
  # List of CSV files to process
  fibionfiles <- list.files(path = file.path(here::here(), "data/Example data"), pattern = "\\.(CSV|csv)$", recursive = TRUE, full.names = TRUE)
  
  # Run sleep/nonwear detection analysis
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
  
  # Run custom events-based analysis
  event_file <- file.path(here::here(), "data/Example data/events.xlsx")
  
  for (file in fibionfiles) {
    data <- run_event_analysis(file, event_file)
    
    # Extract filename without extension
    filename <- sub("\\.CSV$", "", basename(file), ignore.case = TRUE)
    
    # Save results
    save_results(data, filename)
  }
}

# Run all analyses
run_all_analyses()
