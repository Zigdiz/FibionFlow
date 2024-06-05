# scripts/run_event_analysis.R
source("R/setup.R")
source("R/utils.R")

run_event_analysis <- function(filepath, event_file) {
  data_acc <- load_data(filepath)
  data_acc <- preprocess_data(data_acc)
  data_acc <- calculate_mets(data_acc)

  events <- read_excel(event_file, sheet = sub("\\.CSV$", "", basename(filepath), ignore.case = TRUE))
  setDT(events)
  events <- events %>%
    mutate(from = as.POSIXct(from, format = "%d.%m.%Y %H:%M"),
           to = as.POSIXct(to, format = "%d.%m.%Y %H:%M"))

  data_acc[, event := NA_character_]
  for (i in seq_len(nrow(events))) {
    data_acc[timestamp >= events$from[i] & timestamp <= events$to[i], event := events$event[i]]
  }
  data_acc_filtered <- data_acc[!is.na(event), ]

  activitysummary_events <- data_acc_filtered[, .(
    off_min = sum(off_s, na.rm = TRUE)/60,
    sitting_min = sum(sitting_s, na.rm = TRUE)/60,
    standing_min = sum(standing_s, na.rm = TRUE)/60,
    walking_min = sum(walking_s, na.rm = TRUE)/60,
    cycling_min = sum(cycling_s, na.rm = TRUE)/60,
    high_intensity_min = sum(high_intensity_s, na.rm = TRUE)/60,
    activity_min = sum(activity_min, na.rm=T),
    duration_min = .N,
    off_METmin = sum(off_METmin, na.rm = TRUE),
    sitting_METmin = sum(sitting_METmin, na.rm = TRUE),
    standing_METmin = sum(standing_METmin, na.rm = TRUE),
    walking_METmin = sum(walking_METmin, na.rm = TRUE),
    cycling_METmin = sum(cycling_METmin, na.rm = TRUE),
    high_intensity_METmin = sum(high_intensity_METmin, na.rm = TRUE),
    all_METmin = sum(all_METmin, na.rm = TRUE),
    activity_METmin = sum(activity_METmin, na.rm = TRUE),
    light_min = sum(standing_light_min, walking_light_min, cycling_light_min, high_intensity_light_min, na.rm = TRUE),
    mpa_min = sum(standing_mpa_min, walking_mpa_min, cycling_mpa_min, high_intensity_mpa_min, na.rm = TRUE),
    vpa_min = sum(standing_vpa_min, walking_vpa_min, cycling_vpa_min, high_intensity_vpa_min, na.rm = TRUE),
    mvpa_min = sum(standing_mpa_min, walking_mpa_min, cycling_mpa_min, high_intensity_mpa_min, standing_vpa_min, walking_vpa_min, cycling_vpa_min, high_intensity_vpa_min, na.rm = TRUE),
    duration_below_walkingMETs_min = sum(duration_below_walkingMETs_min, na.rm = TRUE),
    duration_above_walkingMETs_min = sum(duration_above_walkingMETs_min, na.rm=TRUE)
  ), by = .(date, event)]

  activitysummary_events[, `:=` (
    off_percent = off_min / duration_min * 100,
    sitting_percent = sitting_min / duration_min * 100,
    standing_percent = standing_min / duration_min * 100,
    walking_percent = walking_min / duration_min * 100,
    cycling_percent = cycling_min / duration_min * 100,
    high_intensity_percent = high_intensity_min / duration_min * 100,
    activity_percent = activity_min / duration_min * 100,
    light_percent = light_min / duration_min * 100,
    mpa_percent = mpa_min / duration_min * 100,
    vpa_percent = vpa_min / duration_min * 100,
    mvpa_percent = mvpa_min / duration_min * 100,
    duration_below_walkingMETs_percent = duration_below_walkingMETs_min / duration_min * 100,
    duration_above_walkingMETs_percent = duration_above_walkingMETs_min / duration_min * 100
  )]

  activitysummary_events[, `:=` (
    off_METs = off_METmin / off_min,
    sitting_METs = sitting_METmin / sitting_min,
    standing_METs = standing_METmin / standing_min,
    walking_METs = walking_METmin / walking_min,
    cycling_METs = cycling_METmin / cycling_min,
    high_intensity_METs = high_intensity_METmin / high_intensity_min,
    all_METs = all_METmin / duration_min,
    activity_METs = activity_METmin / duration_min
  )]

  return(activitysummary_events)
}

set_working_directory()
fibionfiles <- list.files(path = file.path(here::here(), "data/Example data"), pattern = "\\.(CSV|csv)$", recursive = TRUE, full.names = TRUE)
event_file <- file.path(here::here(), "data/Example data/events.xlsx")

for (file in fibionfiles) {
  data <- run_event_analysis(file, event_file)
  
  # Extract filename without extension
  filename <- sub("\\.CSV$", "", basename(file), ignore.case = TRUE)
  
  # Save results
  save_results(data, filename)
}
