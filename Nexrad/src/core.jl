using Dates
using GZip
using GRIBDatasets
using NCDatasets
using DataStructures

using ClimateDatasets

# things to overwrite
import ClimateDatasets:
    info,
    folder,
    files,
    files,
    ensure_files,
    read,
    domain,
    read,
    filename,
    get_dataset,
    get_data

struct TimeDomainSpec <: AbstractDomainSpec
    time::Dates.DateTime
end

struct TimeRangeDomainSpec <: AbstractDomainSpec
    start_time::Dates.DateTime
    end_time::Dates.DateTime
end

struct NexradDataFile <: AbstractDataFile
    domain::TimeDomainSpec
    filename::String
end

struct NexradDataset <: AbstractDataset
    folder::String
    function NexradDataset(folder::String)
        if !isdir(folder)
            mkpath(folder)  # creates the directory if it doesn't exist
        end
        return new(folder)
    end
end

function info(ds::NexradDataset)
    return Dict(:name => "Next-Generation Weather Radar (NEXRAD)")
end

function files(ds::NexradDataset)
    return [
        NexradDataFile(TimeDomainSpec(time), joinpath(folder(ds), get_nc_filename(time)))
        for time in time_range()
    ]
end

function files(ds::NexradDataset, domain_spec::TimeRangeDomainSpec)
    valid_files = NexradDataFile[]
    for time in (domain_spec.start_time):Dates.Hour(1):(domain_spec.end_time)
        if time in MISSING_SNAPSHOTS
            @warn "No data available for the specified time: $(time)"
        else
            push!(
                valid_files,
                NexradDataFile(
                    TimeDomainSpec(time), joinpath(ds.folder, get_filename(time))
                ),
            )
        end
    end
    return valid_files
end

function get_gz_file(dt::DateTime, fname::AbstractString)
    url = get_url(dt)
    !isfile(fname) && download(url, fname)
    return true
end

function parse_grib2(grib2_fname::String)
    gribds = GRIBDataset(grib2_fname)
    prcp = gribds["unknown"][:, :, :]
    lon = gribds["lon"][:]
    lat = gribds["lat"][:]
    time = gribds["valid_time"][:]
    return prcp, lon, lat, time
end

function build_nc_file(
    fname::String,
    prcp::AbstractArray,
    lon::AbstractVector,
    lat::AbstractVector,
    time::AbstractVector,
)

    # Create the netCDF4 file
    ds = NCDatasets.Dataset(fname, "c")

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
        attrib=OrderedDict(
            "long_name" => "Precipitation",
            "units" => "Millimeters per Hour",
            "Source" => Nexrad.get_varname(first(time)),
        ),
    )

    # assign the variables
    nc_prcp[:, :, :] = prcp
    nc_lon = lon
    nc_lat = lat
    nc_time = time

    # Close the netCDF4 file
    return close(ds)
end

function produce_file(dt::DateTime, fname::AbstractString)
    
    # get the filenames
    path = Dates.format(dt, "yyyymmdd-H-M")
    mkpath(path)
    gz_fname = joinpath(path, get_gz_fname(dt))
    grib2_fname = joinpath(path, get_grib2_fname(dt))

    # produce the file
    get_gz_file(dt, gz_fname)

    # unzip
    gunzip_file(gz_fname, grib2_fname)

    # parse
    prcp, lon, lat, time = parse_grib2(grib2_fname)

    # convert to netcdf
    build_nc_file(fname, prcp, lon, lat, time)

    # cleanup
    rm(path, recursive=true)

    return true
end

function ensure_files(ds::NexradDataset, domain_spec::TimeRangeDomainSpec)
    needed_files = files(ds, domain_spec)
    for file in needed_files
        if !isfile(file.file_path)
            produce_file(get_url(file.domain.time), file.file_path)
        end
    end
    return needed_files
end

function read(ds::NexradDataset, domain_spec::TimeRangeDomainSpec)
    files = files(ds, domain_spec)
    return [read_data(file) for file in files]
end

domain(file::NexradDataFile) = file.domain
read(file::NexradDataFile) = read_data(file.file_path)
