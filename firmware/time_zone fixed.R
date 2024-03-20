# library(openair)
# library(dplyr)
# library(openairmaps)
# library(latex2exp)
# library(lubridate)
# 
# # #Convert data to Central Time
# #
# # ############# Converting PM Time Series Data ################
# pm_raw_data = read.csv("D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\Julia_csv\\george_town_after_cleaning\\data_2023-12.csv")
# # # wind_raw_data = read.csv("D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\Julia_csv\\Joppa_raw_wind_data_combined_Jan_2023.csv")
# # # tph_raw_data = read.csv("D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\Julia_csv\\Joppa_raw_tph_data_combined_Jan_2023.csv")
# #
# time_zone_shifting = function (raw_data)
# {
#   # Create a POSIXct object representing a UTC time
#   utc_time <- ymd_hms(raw_data$dateTime, tz = "UTC")
# 
#   # Convert the UTC time to Central Time
#   central_time <- with_tz(utc_time, tzone = "America/Chicago")
# 
#   raw_data$dateTime =  central_time
# 
#   return (raw_data)
# }
# 
# write.csv(time_zone_shifting(pm_raw_data), "D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\R_csv\\george_town_tz_changed\\data_2023-12.csv", row.names=FALSE)
# # write.csv(time_zone_shifting(wind_raw_data), "D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\R_csv\\tz_shifted_Joppa_raw_wind_data_Jan_2023.csv", row.names=FALSE)
# # write.csv(time_zone_shifting(tph_raw_data), "D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\R_csv\\tz_shifted_Joppa_raw_tph_data_Jan_2023.csv", row.names=FALSE)



library(openair)
library(dplyr)
library(openairmaps)
library(latex2exp)
library(lubridate)

# Function to convert the time zone of the data
time_zone_shifting <- function(raw_data) {
  # Create a POSIXct object representing a UTC time
  utc_time <- ymd_hms(raw_data$dateTime, tz = "UTC")
  
  # Convert the UTC time to Central Time
  central_time <- with_tz(utc_time, tzone = "America/Chicago")
  
  raw_data$dateTime = central_time
  
  return (raw_data)
}

# Specify the directory containing the CSV files
input_directory <- "D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\Julia_csv\\george_town_after_cleaning"
output_directory <- "D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\R_csv\\george_town_tz_changed"

# Fetch all CSV files in the directory
file_list <- list.files(path = input_directory, pattern = "*.csv", full.names = TRUE)

# Loop through each file, process it, and write the output
for(file_path in file_list) {
  #print file path
  print(file_path)
  # Extract the file name without extension
  file_name <- basename(file_path)
  
  # Read the CSV file
  raw_data <- read.csv(file_path)
  
  # Convert time zones
  processed_data <- time_zone_shifting(raw_data)
  
  # Construct the output file path
  output_file_path <- file.path(output_directory, gsub("raw", "tz_shifted", file_name))
  
  # Write the processed data to a new CSV file
  write.csv(processed_data, output_file_path, row.names = FALSE)
}

df1 = read.csv("D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\R_csv\\george_town_tz_changed\\data_2023-12.csv")
df2 = read.csv("D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\R_csv\\george_town_tz_changed\\2024-01-01.csv")
combined_df <- bind_rows(df1, df2)
write.csv(combined_df, "D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\R_csv\\george_town_tz_changed\\data_2023-12.csv", row.names = FALSE)
