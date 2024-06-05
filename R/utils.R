# R/utils.R
set_working_directory <- function() {
  here::set_here()
}

load_data <- function(filepath) {
  data <- fread(filepath, sep = ";", fill = TRUE)
  return(data)
}

save_results <- function(data, filename, output_dir = "data/output") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  write.table(data, file.path(output_dir, paste0(filename, ".txt")), sep = "\t", row.names = FALSE, col.names = TRUE)
  write_xlsx(data, file.path(output_dir, paste0(filename, ".xlsx")))
}
