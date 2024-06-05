# R/visualizations/plots.R
create_activity_plot <- function(data, output_filename) {
  activity_data <- melt(data, id.vars = c("date", "time", "timestamp"), measure.vars = c("off_s", "sitting_s", "standing_s", "walking_s", "cycling_s", "high_intensity_s"))
  activity_data$variable <- as.character(activity_data$variable)
  
  activity_data <- activity_data %>%
    dplyr::mutate(variable = case_when(
      variable == "off_s" ~ "Off",
      variable == "sitting_s" ~ "Sitting",
      variable == "standing_s" ~ "Standing",
      variable == "walking_s" ~ "Walking",
      variable == "cycling_s" ~ "Cycling",
      variable == "high_intensity_s" ~ "High-intensity",
      TRUE ~ variable
    ))

  activity_data$variable <- factor(activity_data$variable, levels = c("Off", "Sitting", "Standing", "Walking", "Cycling", "High-intensity"))

  plot_activity_stacked <- ggplot() +
    geom_col(data=activity_data, aes(x = timestamp, y = value, fill = variable)) +
    geom_segment(data = data_acc_slnw, aes(x = from, xend = to, y = -5, yend = -5), color = "red") +
    scale_x_datetime(labels = function(x) format(x, "%H:%M"), date_breaks = "2 hours") +
    labs(title = "Activity Overview on Valid Waking Hours", x = "Date and Time", y = "Duration within one minute window (s)") +
    theme_minimal() +
    theme(axis.text.x = element_text(hjust = 1), legend.position = "right") +
    facet_wrap(~date, ncol=1, scales="free_x") +
    scale_fill_manual(values = c(
      "Off" = "#F2F2F2",
      "Sitting" = "#EF4DB7",
      "Standing" = "#19D5FD",
      "Walking" = "#3399FF",
      "Cycling" = "#264FCD",
      "High-intensity" = "#333399"
    ))
  
  ggsave(filename = output_filename, plot = plot_activity_stacked, width = 10, height = 30, units = "in", dpi = 300)
}
