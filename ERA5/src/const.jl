using Dates
using ClimateDatasets: Bound

# ERA5 covers Jan 1940 to Present
const ERA5_START_DATE = Dates.DateTime(1940, 1, 1, 0)
const ERA5_END_DATE = Dates.now() - Dates.Day(7) # lag time, it may be larger in reality

# default longitude and latitude bounds are for CONUS
struct BoundingBox{T} where T <: Real
    lon_min::T
    lon_max::T
    lat_min::T
    lat_max::T
end
const CONUS_BBOX = BoundingBox(-125.0, -65.0, 25.0, 50.0)
