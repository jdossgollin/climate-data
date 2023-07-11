using Dates
using OrderedCollections: OrderedDict

import ClimateDatasets:
    info,
    file_extension,
    directory,
    bounds,
    file_bounds,
    download_file,
    AbstractDataset,
    Bound

"""
    check_valid_dates(start_date::DateTime, end_date::DateTime)

Check whether the start and end dates are valid:
- They should have year, month, day, and hour but the minute, second, etc should be zero.
- Start date should not be before GAUGECORR_BEGINTIME.
- End date should be at least 14 days before today.
"""
function check_valid_dates(start_date::DateTime, end_date::DateTime)
    if start_date < GAUGECORR_BEGINTIME
        error("Start date should not be before $GAUGECORR_BEGINTIME.")
    end

    if end_date > Dates.now() - Day(14)
        error("End date should be at least 14 days before today.")
    end

    if Dates.minute(start_date) != 0 ||
        Dates.second(start_date) != 0 ||
        Dates.minute(end_date) != 0 ||
        Dates.second(end_date) != 0
        error(
            "Start and end dates should only have year, month, day, and hour. Minute, second, etc should be zero.",
        )
    end
end

"""
    NexradDataset(directory::String, start_date::DateTime, end_date::DateTime)

Create a new `NexradDataset` object with the given directory, start date, end date.
"""
struct NexradDataset <: ClimateDatasets.AbstractDataset
    directory::String
    bounds::Dict{Symbol,ClimateDatasets.Bound}

    function NexradDataset(
        directory::String,
        start_date::DateTime=GAUGECORR_BEGINTIME,
        end_date::DateTime=Dates.DateTime(Dates.today()) - Day(14),
    )
        check_valid_dates(start_date, end_date)

        bounds = Dict{Symbol,ClimateDatasets.Bound}()
        bounds[:time] = ClimateDatasets.Bound(start_date, end_date)

        !isdir(directory) && mkpath(directory)
        return new(directory, bounds)
    end
end

"""
    file_extension(dataset::NexradDataset) -> AbstractString

Return the file extension for the given `NexradDataset`.
"""
file_extension(dataset::NexradDataset) = ".nc"

"""
    dims(dataset::NexradDataset) -> Vector{Symbol}

Return the dimensions of the given `NexradDataset`.
"""
dims(dataset::NexradDataset) = [:time, :longitude, :latitude]


"""
    info(dataset::NexradDataset) -> Dict{Symbol,String}

Return a dictionary containing information about the `NexradDataset`.
"""
function info(dataset::NexradDataset)::OrderedDict{Symbol,String}
    return OrderedDict{Symbol,String}(
        :name => "NEXRAD",
        :long_name => "Next-Generation Weather Radar",
        :description => join(
            [
                "Precipitation in millimeters (cumulative for one hour).",
                "Data comes from the MultiSensor_QPE_01H_Pass2 datsaet after $MULTISENSOR_BEGINTIME,",
                "and GaugeCorr_QPE_01H from $GAUGECORR_BEGINTIME;",
                "this is a gauge-corrected radar dataset.",
            ],
            " ",
        ),
        :directory => directory(dataset),
        :start_date => string(dataset.bounds[:time].min),
        :end_date => string(dataset.bounds[:time].max),
    )
end

"""
    file_bounds(dataset::NexradDataset) -> Vector{Dict{Symbol, ClimateDatasets.Bound}}

Return the file bounds for the given `NexradDataset`.
"""
function file_bounds(dataset::NexradDataset)
    start_time = dataset.bounds[:time].min
    end_time = dataset.bounds[:time].max
    snapshots = collect(start_time:Dates.Hour(1):end_time)
    file_bounds = []
    for snapshot in snapshots
        if snapshot ∉ MISSING_SNAPSHOTS
            push!(file_bounds, Dict(:time => ClimateDatasets.Bound(snapshot)))
        end
    end
    return file_bounds
end

"""
    download_file(dataset::NexradDataset, filename::AbstractString)

Download the file with the given filename for the given `NexradDataset`.
"""
function download_file(dataset::NexradDataset, filename::AbstractString)
    bounds = ClimateDatasets.filename_to_bounds(dataset, filename)
    snapshot_time = bounds[:time].min
    absolute_file_name = joinpath(dataset.directory, filename)
    return produce_snapshot(dataset, snapshot_time, absolute_file_name)
end
