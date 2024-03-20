# include("D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\File_Search.jl")
Pkg.activate("D:\\UTD\\UTDSpring2024\\Temporal_Variograms")
using CSV,DataFrames,Dates,Impute, Statistics,OrderedCollections, Glob


df_pm_list = []
df_wind_list = []
df_tph_list = []
n_days = nrow( df_pm_csv)# 3 # We are only filtering out first 3 days  of January 2023

k=[]



n_days = 1# since we are only processing one day
for i in 1:n_days
    error_dict = Dict() # Dictionary to store error rows by date
    println(i)
    df = CSV.read("D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\GeorgeTown\\2024\\01\\01\\MINTS_001e06305a57_IPS7100_2024_01_01.csv", DataFrame)[:, 1:15]
    push!(df_pm_list, df)

    # Initialize an empty DateTime array
    dateTimeArray = DateTime[]


    # Check if the dateTime column might not be empty, proceed if not
    if isempty(df.dateTime)
        continue # Skip to the next iteration if dateTime is empty
    end

    for j in 1:length(df.dateTime)
        try
            # Convert each string to DateTime and add to the array
            push!(dateTimeArray, DateTime(df.dateTime[j][1:19], "yyyy-mm-dd HH:MM:SS"))
        catch e1
            # Check if the key exists, if not, initialize it with an empty list
            if !haskey(error_dict, i)
                error_dict[i] = []
            end
            push!(error_dict[i], j) # Record the dataframe number and the row number with error
        end
    end
    for (key,val) in error_dict
        deleteat!(df_pm_list[key],val[1])
    end
    # After processing, replace the original column with the new DateTime array
    # This will effectively change the column type to DateTime
    if !isempty(dateTimeArray)
        # println(df_pm_list[i].dateTime)
        df_pm_list[i].dateTime = dateTimeArray
    else
        # Handle case where all conversions failed or dateTime was initially empty
        # This avoids replacing the column with an empty array, which might not be intended
        println("All dateTime conversions failed or dateTime was empty for DataFrame $i")
    end
end

println(describe(df_pm_list[1])) #Looks good so need of cleaning much
CSV.write("")

# monthly_data_frames = Dict()

# for df in df_pm_list
#     # Ensure there is at least one dateTime to work with
#     if isempty(df.dateTime) || size(df, 1) == 0
#         continue
#     end
    
#     # Extract year and month from the first dateTime entry as a representative
#     representative_date = DateTime(df.dateTime[1][1:19], "yyyy-mm-dd HH:MM:SS")
#     year_month_key = (year(representative_date), month(representative_date))
    
#     # Check if the key exists in the dictionary, if not, initialize it
#     if !haskey(monthly_data_frames, year_month_key)
#         monthly_data_frames[year_month_key] = []
#     end
    
#     # Append the current DataFrame to the array for its year and month
#     push!(monthly_data_frames[year_month_key], df)
# end

dfs_by_month =  OrderedDict()

for df in df_pm_list
    # Assuming the dateTime column is in a standard format and the first row is representative for the whole DataFrame
    if !isempty(df.dateTime)
        month_key = Dates.format(df.dateTime[1],"yyyy-mm") # Format: "YYYY-MM"
        if haskey(dfs_by_month, month_key)
            push!(dfs_by_month[month_key], df)
        else
            dfs_by_month[month_key] = [df]
        end
    end
end
dfs_by_month_combined = OrderedDict()
# Step 2: For each month, concatenate the DataFrames and save to CSV
for (month, dfs) in dfs_by_month
    combined_df = vcat(dfs...) # Concatenate all DataFrames in the list for the month
    csv_filename = "D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\Julia_csv\\george_town_before_cleaning\\data_$month.csv" # Name the file using the month
    CSV.write(csv_filename, combined_df) # Save the combined DataFrame to a CSV file
    if !haskey(dfs_by_month_combined, month)
        dfs_by_month_combined[month] = combined_df
    end
    println("Saved: $csv_filename")
end
df_pm_list = nothing
dfs_by_month =  nothing

# data_frame_pm_combined = reduce(vcat,df_pm_list)
# data_frame_wind_combined = reduce(vcat,df_wind_list)
# data_frame_tph_combined = reduce(vcat,df_tph_list)

# pc0_1 = Int64[]
# pc0_3 = Int64[]
# pc0_5 = Int64[]
# pc1_0 = Int64[]
# pc2_5 = Int64[]
# pc5_0 = Int64[]
# pc10_0 = Int64[]
# pm0_1 = Float64[]
# pm0_3 = Float64[]
# pm0_5 = Float64[]
# pm1_0 = Float64[]
# pm2_5 = Float64[]
# pm5_0 = Float64[]
# pm10_0 = Float64[]



path = "D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\Julia_csv\\george_town_before_cleaning\\"

function extract_date_key(filename::String)
    # Assuming the file name format includes yyyy-mm directly,
    # Adjust the regex as necessary based on your actual file name format
    m = match(r"(\d{4}-\d{2})", filename)
    return m !== nothing ? m.match : error("Date format not found in file name")
end

# Initialize an empty dictionary to store the DataFrames
df_dict = OrderedDict{String, DataFrame}()

# Iterate over CSV files in the path
for file in glob("*.csv", path)
    println(file)
    # Extract the yyyy-mm part from the file name
    date_key = extract_date_key(file)
    
    # Read the CSV file into a DataFrame
    df = CSV.read(file, DataFrame)

    # Add the DataFrame to the dictionary with yyyy-mm as the key
    df_dict[date_key] = df
end



# function convert_column!(df, col_name, target_type, key)
#     column_data = df[:, col_name]
#     println(key)
#     println(col_name)
#     new_column_data = similar(column_data, target_type)
    
#     for (i, x) in enumerate(column_data)
#         try
#             if target_type == DateTime
#                 new_column_data[i] = DateTime(x)
#             elseif target_type <: Union{Int64, Float64}
#                 new_column_data[i] = parse(target_type, x)
#             else
#                 println("yaya")
#                 new_column_data[i] = convert(target_type, x)

#             end
#         catch e
#             # println("$key: Error converting row $i in column $col_name to $target_type: ", e)
#             new_column_data[i] = missing # Assign a missing value or handle as needed
#         end
#     end
    
#     df[!, col_name] = new_column_data
# end

# # Iterate over your dictionary of DataFrames to adjust their column types and update them
# for (key, df) in df_dict
#     template_types = eltype.(eachcol(df_dict["2023-01"])) # Using "2023-01" as your template
    
#     for (col_name, col_type) in zip(names(df), template_types)
#         convert_column!(df, col_name, col_type, key)
#     end
    
#     df_dict[key] = df # Update the dictionary with the modified DataFrame
# end

error_feature = Dict()
# template_types = eltype.(eachcol(df_dict["2023-01"])) # there are many options here which will make things complicated like Int64, Union{Missing,Int64},Float64, Union{Missing,Float64}
for (key,value) in df_dict
    for col in names(df_dict[key])
        if !(eltype(df_dict[key][!,col]) in [DateTime,Int64, Union{Missing,Int64},Float64, Union{Missing,Float64}]  )
            if !haskey(error_feature,key)
                error_feature[key] = [col]
            else
                push!(error_feature[key],col)
            end
        end
    end
end

error_val = OrderedDict()
correct_val = OrderedDict()
for (key, feat) in error_feature
    println("Processing ", key)
    for f in feat
        println("Feature: ", f)
        # Determine the target type based on the feature name
        target_type = f in ["pc0_1", "pc0_3", "pc0_5", "pc1_0", "pc2_5", "pc5_0", "pc10_0"] ? Int64 : Float64
        
        # Initialize an array to hold the parsed or missing values
        f_array = []
        
        for value in df_dict[key][!, f]
            try
                # Attempt to parse the value as the target type
                parsed_value = parse(target_type, string(value))
                push!(f_array, parsed_value)
            catch
                println("ya")
                # If parsing fails, push a missing value
                push!(f_array, missing)
            end
        end
        
        # Update the DataFrame column with the new array of values
        df_dict[key][!, f] = f_array
    end
end



cleaned_df_dict = OrderedDict()
for (key,values) in df_dict
    cleaned_df_dict[key] = dropmissing(df_dict[key])
end
#Before Parsing
for (key,values) in df_dict
    println(describe(cleaned_df_dict[key]))
end

cleaned_df_dict_before_parsing = cleaned_df_dict
for (key,value) in error_feature
    for val in value
        println(key,":", val)
        col_type = val in ["pc0_1", "pc0_3", "pc0_5", "pc1_0", "pc2_5", "pc5_0", "pc10_0"] ? "Int64" : "Float64"
        if val == "Int64"
            cleaned_column = map(value -> isa(value, Int64) ? value : try parse(Int64, string(value)) catch _ missing end, cleaned_df_dict[key][!, val])
        else
            cleaned_column = map(value -> isa(value, Float64) ? value : try parse(Float64, string(value)) catch _ missing end, cleaned_df_dict[key][!, val])
        end
    # Update the DataFrame column with potentially cleaned values
        cleaned_df_dict[key][!, val] = cleaned_column
    end
end

#After Parsing
for (key,values) in df_dict
    println(describe(cleaned_df_dict[key]))
end

for (month, df) in cleaned_df_dict
    csv_filename = "D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\Julia_csv\\george_town_after_cleaning\\data_$month.csv" # Name the file using the month
    CSV.write(csv_filename, df) # Save the combined DataFrame to a CSV file
    println("Saved: $csv_filename")
end

function data_cleaning( data_frame,sensor_type) 
    if(sensor_type == "IPS7100")
        cols = propertynames(data_frame)
    elseif(sensor_type == "WIMDA")
        cols = [:dateTime,:windDirectionTrue,:windSpeedMetersPerSecond,:airTemperature,:dewPoint,:relativeHumidity]
    elseif (sensor_type == "BME680")
        cols = [:dateTime,:temperature,:pressure,:humidity]
    # elseif (sensor_type == "SCD30")
    #     cols = [:dateTime,:c02]
    end 
    # println(first(data_frame,5) )
    # data_frame.dateTime = DateTime.(data_frame.dateTime)
    #data_frame.dateTime = Array(data_frame.dateTime)
    # k=[]
    # i_val =[]
    # for i in 1:1:length(data_frame.dateTime)
    #     # println(i)
    #     # println(data_frame.dateTime[i])
    #     try
    #     push!(k,DateTime(data_frame.dateTime[i][1:19],"yyyy-mm-dd HH:MM:SS")) 
    #     catch e2
    #         push!(i_val,i)
    #     end
    # end
    # for r in i_val
    #     deleteat!(data_frame,r)
    # end
    # data_frame.dateTime = k 
    # data_frame.dateTime = data_frame.dateTime + data_frame.ms
    #data_frame = select!(data_frame, Not(:ms))


    # for col_name in names(data_frame)
    #     col_type = eltype(data_frame[!, col_name])
    #     println("$col_name is of type $col_type")
    # end
    data_frame = data_frame[:,cols]
    col_symbols = Symbol.(names(data_frame))
    data_frame = DataFrames.combine(groupby(data_frame, :dateTime), 
    [col => mean => col for col in names(data_frame)[2:end]])
    return data_frame,col_symbols
end
# dfs_by_month_combined = df_dict
for (key , value) in dfs_by_month_combined
    println(key)
    data_frame_pm,cols_pm = data_cleaning(dfs_by_month_combined[key],"IPS7100")
    
    println(cols_pm)
end

DateTime.(dfs_by_month_combined["2023-02"].dateTime)
data_frame_pm,cols_pm = data_cleaning(data_frame_pm_combined,"IPS7100")



# CSV.write("D:\\UTD\\UTDSpring2024\\Temporal_Variograms\\firmware\\data\\Julia_csv\\GT_raw_pm_data_combined.csv",data_frame_pm_combined)

CSV.write("D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\Julia_csv\\Joppa_raw_pm_data_combined_Jan_2023.csv",data_frame_pm_combined)
CSV.write("D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\Julia_csv\\Joppa_raw_wind_data_combined_Jan_2023.csv",data_frame_wind_combined)
CSV.write("D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\Julia_csv\\Joppa_raw_tph_data_combined_Jan_2023.csv",data_frame_tph_combined)

data_frame_pm_combined = CSV.read("D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\R_csv\\tz_shifted_Joppa_raw_pm_data_Jan_2023.csv", DataFrame)
data_frame_wind_combined = CSV.read("D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\R_csv\\tz_shifted_Joppa_raw_wind_data_Jan_2023.csv", DataFrame)
data_frame_tph_combined = CSV.read("D:\\UTD\\UTDFall2023\\Temporal_Variograms\\firmware\\data\\R_csv\\tz_shifted_Joppa_raw_tph_data_Jan_2023.csv", DataFrame)

#delete!(data_frame_wind_combined, [298953,321329])

function data_cleaning( data_frame,sensor_type) 
    if(sensor_type == "IPS7100")
        cols = propertynames(data_frame)
    elseif(sensor_type == "WIMDA")
        cols = [:dateTime,:windDirectionTrue,:windSpeedMetersPerSecond,:airTemperature,:dewPoint,:relativeHumidity]
    elseif (sensor_type == "BME680")
        cols = [:dateTime,:temperature,:pressure,:humidity]
    # elseif (sensor_type == "SCD30")
    #     cols = [:dateTime,:c02]
    end 

    data_frame.dateTime = Array(data_frame.dateTime)
    k=[]
    for i in 1:1:length(data_frame.dateTime)
        #println(i)
        push!(k,DateTime(data_frame.dateTime[i],"yyyy-mm-dd HH:MM:SS")) 
    end
    data_frame.dateTime = k 
    #data_frame.dateTime = data_frame.dateTime + data_frame.ms
    #data_frame = select!(data_frame, Not(:ms))

    data_frame = data_frame[:,cols]
    col_symbols = Symbol.(names(data_frame))
    data_frame = DataFrames.combine(DataFrames.groupby(data_frame, :dateTime), col_symbols[2:end] .=> mean)
    return data_frame,col_symbols
end
data_frame_pm,cols_pm = data_cleaning(data_frame_pm_combined,"IPS7100")
data_frame_wind,cols_wind = data_cleaning(data_frame_wind_combined,"WIMDA")
data_frame_tph,cols_tph = data_cleaning(data_frame_tph_combined,"BME680")



function dataframe_updates(data_frame,cols)
    data_frame = data_frame_wind
    sensor_type = "WIMDA"
    cols = cols_wind 
    duration = Second(data_frame.dateTime[end]-data_frame.dateTime[1]).value
    time_to_round = Int(floor(duration/size(data_frame)[1]))
    if (sensor_type == "WIMDA")
        time_to_round = 10
    data_frame.dateTime = round.(data_frame.dateTime, Dates.Second(time_to_round))
    
    ###################  imputation logic may be fixed  ###################### 
    df = DataFrame()
    df.dateTime = collect(data_frame.dateTime[1]:Second(time_to_round):data_frame.dateTime[end]-Second(1))
    df = outerjoin( df,data_frame, on = :dateTime)
    sort!(df, (:dateTime))
    unique!(df, :dateTime)
    println(cols)
    df = DataFrames.rename!(df, cols)
    df_sensor = Impute.locf(df)|>Impute.nocb()
    
    df_sensor = DataFrames.combine(DataFrames.groupby(df_sensor, :dateTime), cols[2:end] .=> mean)
    df_sensor = DataFrames.rename!(df_sensor, cols)
    return df_sensor
end
df_pm_updated = dataframe_updates(data_frame_pm, cols_pm)
df_wind_updated = dataframe_updates(data_frame_wind, cols_wind)
df_tph_updated = dataframe_updates(data_frame_tph,cols_tph)
#df_co2 = dataframe_updates(data_frame_c02,cols_c02,"SCD30")


function date_based_data_filtering(df, start_date, end_date)
    df[DateTime(start_date) .<= df.dateTime .< DateTime(end_date), :] #filtering out data based on start and end date
end
start_date = "2023-01-02"
end_date = "2023-01-03"

df_pm_filtered = date_based_data_filtering(df_pm_updated,start_date,end_date)
df_wind_filtered = date_based_data_filtering(df_wind_updated,start_date,end_date)
df_tph_filtered = date_based_data_filtering(df_tph_updated,start_date,end_date)

function is_foggy(dewpoint, temperature, humidity, air_pressure)
    dewpoint_depression = abs(dewpoint - temperature)
    
    # Check for foggy conditions based on thresholds
    if dewpoint_depression <= 2 && humidity >= 90 && air_pressure >= 1000
        return true
    else
        return false
    end
end

df_wind_filtered.temp_difference = abs.(df_wind_filtered.airTemperature  - df_wind_filtered.dewPoint)
indices = findall(x-> x <= 2, df_wind_filtered.temp_difference)
date_time_values = df_wind_filtered.dateTime[indices]