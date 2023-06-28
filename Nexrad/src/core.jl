using Dates
using GZip
using GRIBDatasets
using NCDatasets

using ClimateDatasets

"""
    gunzip_file(input_file::AbstractString, output_file::AbstractString)

Unzip a gzipped file and save it with the given filename.

# Arguments
- `input_file`: The name of the gzipped input file.
- `output_file`: The name of the output file to save the unzipped data to.
"""
function gunzip_file(input_file::AbstractString, output_file::AbstractString)
    isfile(output_file) && rm(output_file)
    GZip.open(input_file, "r") do io
        open(output_file, "w") do out
            write(out, GZip.read(io))
        end
    end
end

"""
    get_gz_file(dt::Dates.DateTime, fname::AbstractString) -> Bool

Download a gzipped file for the given `DateTime` and save it with the given filename.
"""
function get_gz_file(dt::Dates.DateTime, fname::AbstractString)
    url = get_url(dt)
    !isfile(fname) && download(url, fname)
    return true
end

"""
    parse_grib2(grib2_fname::AbstractString) -> Tuple{Array{Float64, 3}, Array{Float64, 1}, Array{Float64, 1}, Array{Dates.DateTime, 1}}

Parse a GRIB2 file and return the precipitation data, longitude, latitude, and time.
"""
function parse_grib2(grib2_fname::AbstractString)
    gribds = GRIBDataset(grib2_fname)
    precip = gribds["unknown"][:, :, :]
    lon = gribds["lon"][:]
    lat = gribds["lat"][:]
    time = gribds["valid_time"][:]
    return precip, lon, lat, time
end

"""
    grib2_to_nc(grib2_fname::AbstractString, nc_fname::AbstractString) -> Bool

Convert a GRIB2 file to a netCDF file and save it with the given filename.
"""
function grib2_to_nc(grib2_fname::AbstractString, nc_fname::AbstractString)

    # parse the input file
    precip, lon, lat, time = parse_grib2(grib2_fname)

    # Create the netCDF4 file
    ds = NCDatasets.Dataset(nc_fname, "c")

    # Define the dimensions of the netCDF4 file
    nc_lon = defDim(ds, "lon", length(lon))
    nc_lat = defDim(ds, "lat", length(lat))
    nc_time = defDim(ds, "time", length(time))

    # add the precipitation data
    nc_prcp = defVar(
        ds,
        "precip",
        Float64,
        ("lon", "lat", "time");
        attrib=Dict(
            "long_name" => "Precipitation",
            "units" => "Millimeters per Hour",
            "Source" => Nexrad.get_varname(first(time)),
        ),
    )

    # assign the variables
    nc_prcp[:, :, :] = precip
    nc_lon = lon
    nc_lat = lat
    nc_time = time

    # Close the netCDF4 file
    return close(ds)
end

"""
    produce_snapshot(ds::NCDatasets.Dataset, dt::Dates.DateTime, nc_fname::AbstractString) -> Bool

Produce a snapshot of the given `Dataset` at the given `DateTime` and save it as a netCDF file with the given filename.
"""
function produce_snapshot(ds::AbstractDataset, dt::Dates.DateTime, nc_fname::AbstractString)

    # get the filenames
    tmpdir = joinpath(directory(ds), Dates.format(dt, Dates.ISODateTimeFormat))
    mkpath(tmpdir)
    gz_fname = joinpath(tmpdir, "data.grib2.gz")
    grib2_fname = joinpath(tmpdir, "data.grib2")

    # Download the file
    try
        get_gz_file(dt, gz_fname)
    catch e
        rm(tmpdir; recursive=true)
        return false
    end

    # Unzip the file
    try
        gunzip_file(gz_fname, grib2_fname)
    catch e
        rm(tmpdir; recursive=true)
        return false
    end

    # Convert to netCDF
    try
        grib2_to_nc(grib2_fname, nc_fname)
    catch e
        rm(tmpdir; recursive=true)
        return false
    end

    # cleanup
    rm(tmpdir; recursive=true)

    return true
end
