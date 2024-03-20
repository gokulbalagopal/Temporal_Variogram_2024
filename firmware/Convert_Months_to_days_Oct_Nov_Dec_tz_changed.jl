using Pkg
Pkg.activate("D:\\UTD\\UTDSpring2024\\Temporal_Variograms")
#using DelimitedFiles
using CSV,DataFrames,Dates,Statistics

file_path = ["D:/UTD/UTDFall2023/Temporal_Variograms/firmware/data/R_csv/Joppa_updated_cleaned_tz_changed_Oct_2023.csv",
             "D:/UTD/UTDFall2023/Temporal_Variograms/firmware/data/R_csv/Joppa_updated_cleaned_tz_changed_Nov_2023.csv",
             "D:/UTD/UTDFall2023/Temporal_Variograms/firmware/data/R_csv/Joppa_updated_cleaned_tz_changed_Dec_2023.csv"]



df_october = DataFrame(CSV.File(file_path[1]))
df_november = DataFrame(CSV.File(file_path[2]))
df_december = DataFrame(CSV.File(file_path[3]))


function unique_days_per_month(df)
    df.date = Date.(df.dateTime)
    unique_days = unique(df.date)

    # Loop through each day, filter the DataFrame, and save to CSV
    for day in unique_days
        df_day = filter(row -> row.date == day, df)[:,1:15]

        # Format the day for the filename (YYYY-MM-DD)
        formatted_day = Dates.format(day, "yyyy-mm-dd")
        output_file_path = "D:/UTD/UTDFall2023/Temporal_Variograms/firmware/data/pm_cleaned_and_cst_tz/data_$(formatted_day).csv"
        CSV.write(output_file_path, df_day)
    end
end
unique_days_per_month(df_october)
unique_days_per_month(df_november)
unique_days_per_month(df_december)



# Set the directory path containing your CSV files
directory_path = "D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\pm_cleaned_and_cst_tz"

# Function to process and average data for each file
function process_file(file_path)
    df = CSV.File(file_path) |> DataFrame
    
    # Convert the DateTime column to DateTime type (adjust format as necessary)
    #df.DateTime = DateTime.(df.dateTime, "yyyy-mm-dd HH:MM:SS")
    
    # Group by minute
    transform!(df, :dateTime => (x -> floor.(x, Dates.Minute)) => :Minute)
    grouped_df = groupby(df, :Minute)
    
    # Calculate the mean for each minute for all columns
    # avg_df = DataFrames.combine(grouped_df, names(df) .=> mean .=> names(df))
    avg_df = DataFrames.combine(DataFrames.groupby(df, :Minute), names(df)[2:end-1] .=> mean .=> names(df)[2:15])
    return avg_df 
end

# Get list of all CSV files in the directory
files = filter(x -> occursin(r"\.csv$", x), readdir(directory_path, join=true))

# Process each file and store the result in a list
dfs = [process_file(file) for file in files]

# Combine all dataframes into one
combined_df = vcat(dfs...)
combined_df  = rename!(combined_df,:Minute => :dateTime)
# Save the combined dataframe to a new CSV file
output_file_path = "D:/UTD/UTDSpring2024/Temporal_Variograms/firmware/data/pm_cleaned_and_cst_tz_minutes/combined_df_minutes.csv"
CSV.write(output_file_path, combined_df)

# Print the output path
println("Combined data saved to: ", output_file_path)
