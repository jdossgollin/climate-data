"""Make sure that the given start and end dates are valid for the ERA5 dataset."""
function assert_valid_dates(start_date::Dates.DateTime, end_date::Dates.DateTime)
    @assert end_date >= start_date, "end_date must be after start_date"
    @assert end_date <= ERA5_END_DATE, "end_date must be on or before $ERA5_END_DATE"
    @assert start_date >= ERA5_START_DATE, "start_date must be on or after $ERA5_START_DATE"
end

"""Make sure that the given longitude and latitude bounds are valid for the ERA5 dataset."""
function assert_valid_bbox(bb::BoundingBox)
    @assert bb.lon_min <= bb.lon_max, "lon_min must be less than or equal to lon_max"
    @assert bb.lon_min >= -180 bb.lon_max <= 180, "lon must be between -180 and 180"
    @assert bb.lat_min <= bb.lat_max, "lat_min must be less than or equal to lat_max"
    @assert bb.lat_min >= -90 bb.lat_max <= 90, "lat must be between -90 and 90"
end

"""Make sure that the pressure level (in hPa) is valid"""
function assert_valid_level(level::Real)
    valid_levels = [1000, 975, 950, 925, 900, 875, 850, 825, 800, 775, 750, 700, 650, 600, 550, 500, 450, 400, 350, 300, 250, 225, 200, 175, 150, 125, 100, 70, 50, 30, 20, 10, 7, 5, 3, 2, 1]
    @assert level in valid_levels, "level must be one of: $valid_levels"
end
