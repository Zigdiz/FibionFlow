# R/algorithms/sleep_nonwear_detection.R
source("R/utils.R")

preprocess_data <- function(data) {
  setnames(data, old = c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13"), 
                 new = c("timestamp", "off_s", "sitting_s", "standing_s", "walking_s", "cycling_s", "high_intensity_s", "off_met100", "sitting_met100", "standing_met100", "walking_met100", "cycling_met100", "high_intensity_met100"))
  
  metadata_row <- which(data$timestamp == "[METADATA]")
  if (length(metadata_row) > 0) {
    data <- data[1:(metadata_row - 1)]
  }
  
  data[, timestamp := as.POSIXct(timestamp)]
  data[, time := format(timestamp, "%H:%M")]
  data[, date := as.Date(format(timestamp, "%Y-%m-%d"))]
  data[, c("weekday", "week_weekend") := list(weekdays(date), ifelse(weekdays(date) %in% c("Saturday", "Sunday"), "weekendday", "weekday"))]
  setcolorder(data, c("timestamp", "date", "time", "weekday", "week_weekend", names(data)[!(names(data) %in% c("timestamp", "date", "time", "weekday", "week_weekend"))]))
  cols_to_convert <- names(data)[grepl("_s$", names(data))]
  data[, (cols_to_convert) := lapply(.SD, as.numeric), .SDcols = cols_to_convert]
  data[, rowsum_s := rowSums(.SD, na.rm = TRUE), .SDcols = patterns("_s$")]
  return(data)
}

calculate_mets <- function(data) {
  all_types <- c("off", "sitting", "standing", "walking", "cycling", "high_intensity")
  activity_types <- c("standing", "walking", "cycling", "high_intensity")
  
  for (activity in all_types) {
    met_col <- paste0(activity, "_met100")
    time_col <- paste0(activity, "_s")
    metmin_col <- paste0(activity, "_METmin")
    data[, (metmin_col) := get(met_col) / 100 * get(time_col) / 60]
  }
  
  for (activity in activity_types) {
    met_col <- paste0(activity, "_met100")
    time_col <- paste0(activity, "_s")
    metmin_col <- paste0(activity, "_METmin")
    light_col <- paste0(activity, "_light_min")
    mpa_col <- paste0(activity, "_mpa_min")
    vpa_col <- paste0(activity, "_vpa_min")
    
    data[, (light_col) := fifelse(get(met_col)/100 < 3, get(time_col) / 60, 0)]
    data[, (mpa_col) := fifelse(get(met_col)/100 >= 3 & get(met_col)/100 < 6, get(time_col) / 60, 0)]
    data[, (vpa_col) := fifelse(get(met_col)/100 >= 6, get(time_col) / 60, 0)]
  }
  
  all_metmin_cols <- paste0(all_types, "_METmin")
  data[, all_METmin := rowSums(.SD, na.rm = TRUE), .SDcols = all_metmin_cols]
  activity_metmin_cols <- paste0(activity_types, "_METmin")
  data[, activity_METmin := rowSums(.SD, na.rm = TRUE), .SDcols = activity_metmin_cols]
  all_activity_cols <- paste0(activity_types, "_s")
  data[, activity_min := rowSums(.SD, na.rm = TRUE)/60, .SDcols = all_activity_cols]
  walking_METthreshold <- sum(data$walking_METmin, na.rm = TRUE) / sum(data$walking_s / 60, na.rm = TRUE)
  
  for (activity in activity_types) {
    met_col <- paste0(activity, "_met100")
    time_col <- paste0(activity, "_s")
    data[, (paste0(activity, "_below_threshold_min")) := fifelse(get(met_col)/100 < walking_METthreshold, get(time_col) / 60, 0)]
    data[, (paste0(activity, "_above_threshold_min")) := fifelse(get(met_col)/100 >= walking_METthreshold, get(time_col) / 60, 0)]
  }
  
  data[, duration_below_walkingMETs_min := rowSums(.SD, na.rm = TRUE), .SDcols = patterns("_below_threshold_min")]
  data[, duration_above_walkingMETs_min := rowSums(.SD, na.rm = TRUE), .SDcols = patterns("_above_threshold_min")]
  return(data)
}

identify_segments <- function(data, off_window_length, break_window_length, activity_threshold, variability_threshold) {
  off_window_width <- off_window_length * 60
  break_window_width <- break_window_length * 60

  data[, off_sum := rollapplyr(Off, width = off_window_width, FUN = sum, fill = NA, align = "center")]
  data[, activity_sum_next := shift(rollapplyr(Activity, width = break_window_width, FUN = sum, fill = NA, align = "center"), n = -1, fill = NA)]
  data[, roll_variability := rollapplyr(all_METmin, width = off_window_width, FUN = function(x) max(x, na.rm = TRUE) - min(x, na.rm = TRUE), fill = NA, align = "center")]

  data[, off_segment := off_sum > 30 & (activity_sum_next / break_window_width <= activity_threshold * break_window_width)]
  data[, low_variability := roll_variability < variability_threshold]
  data[, SLNW := ifelse(off_segment | low_variability, "SLNW", "Wake")]

  return(data)
}

run_sleep_nonwear_detection <- function(filepath) {
  data <- load_data(filepath)
  data <- preprocess_data(data)
  data <- calculate_mets(data)
  data <- identify_segments(data, 2, 1, 0.10, 0.8) # Example params
  return(data)
}
