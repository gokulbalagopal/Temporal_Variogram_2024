using Pkg
Pkg.activate("D:\\UTD\\UTDSpring2024\\Temporal_Variograms")
using CSV,Statistics
using DataFrames
using Dates


# Assuming combined_df is already in your workspace
# If you need to read from a CSV:
combined_df = CSV.read("D:/UTD/UTDSpring2024/Temporal_Variograms/firmware/data/pm_cleaned_and_cst_tz_minutes/combined_df_minutes.csv", DataFrame)

# Ensure DateTime is of type DateTime
# combined_df.dateTime = DateTime.(combined_df.dateTime, "yyyy-mm-dd HH:MM:SS")


# Assuming the CSV has been read into combined_df and initial transformations have been done
# Create a new column for YearMonth
combined_df.YearMonth = Dates.format.(combined_df.dateTime, "yyyy-mm")

# Create a new column for Date (without time)
combined_df.date = Dates.Date.(combined_df.dateTime)

# Calculate the average PM2.5 concentration for each day
daily_avg_pm25 = combine(groupby(combined_df, :date), :pm2_5 => mean => :AvgPM2_5)

daily_avg_pm25.YearMonth = Dates.format.(daily_avg_pm25.date, "yyyy-mm")

# Step 2 & 3: Group by YearMonth and find the maximum AvgPM2_5 for each month
max_daily_avg_per_month = combine(groupby(daily_avg_pm25, :YearMonth), :AvgPM2_5 => maximum)

# Rename columns for clarity and joining
rename!(max_daily_avg_per_month, :AvgPM2_5_maximum => :MaxAvgPM2_5)

# Step 4: Join back to get the dates
# We need an intermediate DataFrame that includes dates, YearMonth, and AvgPM2_5
# This is because we want to match not just the maximum average, but also ensure we're within the correct month
pm2_5_daily_average_across_year = innerjoin(daily_avg_pm25, max_daily_avg_per_month, on = [:YearMonth, :AvgPM2_5 => :MaxAvgPM2_5])
pm2_5_daily_average_across_year.AvgPM2_5 = round.(pm2_5_daily_average_across_year.AvgPM2_5 , digits = 2)
CSV.write("D:/UTD/UTDSpring2024/Temporal_Variograms/firmware/data/Analysis/daily_average_across_year.csv",pm2_5_daily_average_across_year)

# The result is a DataFrame with the dates and AvgPM2_5 values of the peak days for each month























daily_max_pm25 = combine(groupby(combined_df, :date), :pm2_5 => maximum => :MaxPM2_5)

# Merge daily max with original to get YearMonth back
daily_max_pm25 = leftjoin(daily_max_pm25, select(combined_df, :date, :YearMonth), on=:date)

# Now, find the day with the highest PM2.5 concentration for each month
peak_days_each_month = combine(groupby(daily_max_pm25, :YearMonth), :MaxPM2_5 => maximum => :MaxPM2_5)
peak_days_each_month.MaxPM2_5 = round.(peak_days_each_month.MaxPM2_5,digits = 2)
println(peak_days_each_month)

CSV.write("D:/UTD/UTDSpring2024/Temporal_Variograms/firmware/data/Analysis/peak_days_each_month.MaxPM2_5.csv",peak_days_each_month)
# To get the exact days, we need to join back on the daily_max_pm25
peak_days = innerjoin(peak_days_each_month, daily_max_pm25, on=[:YearMonth, :MaxPM2_5], makeunique=true)

# Select relevant columns to display
final_peak_days = select(peak_days, :YearMonth, :Date, :MaxPM2_5)

# This final DataFrame contains the year-month, the exact date of the peak PM2.5, and the peak PM2.5 concentration
E