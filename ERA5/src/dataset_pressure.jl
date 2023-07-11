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


struct ERA5PressureVariable <: ClimateDatasets.AbstractDataset
    directory::String
    bounds::Dict{Symbol,ClimateDatasets.Bound}

    function ERA5PressureVariable(
        directory::String;
        start_date::Dates.DateTime,
        end_date::Dates.DateTime,
        variable::String,
        pressure_level::Real,
        bbox::BoundingBox=CONUS_BBOX,
        resolution::Real=0.25,
    )

        # initialize
        bounds = Dict{Symbol,ClimateDatasets.Bound}()

        # make sure the start and end dates are valid, then save them
        assert_valid_dates(start_date, end_date)
        bounds[:time] = ClimateDatasets.Bound(start_date, end_date)

        # make sure the longitude and latitude bounds are valid, then save them
        assert_valid_bbox(bbox)
        bounds[:longitude] = ClimateDatasets.Bound(bbox.lon_min, bbox.lon_max)
        bounds[:latitude] = ClimateDatasets.Bound(bbox.lat_min, bbox.lat_max)

        # save the resolution
        bounds[:resolution] = ClimateDatasets.Bound(resolution)

        # if this variable uses pressure coordinates, make sure the pressure level is valid
        assert_valid_level(pressure_level)
        bounds[:pressure_level] = ClimateDatasets.Bound(pressure_level)

        # the name of the dataset is based on the variable and pressure level
        dataset_name = get_dataset_name(variable, pressure_level)

        !isdir(directory) && mkpath(directory)
        return new(directory, bounds, dataset_name)
    end
end

"""ClimateDatasets requires this to be implemented"""
file_extension(dataset::ERA5PressureVariable) = ".nc"

dims(dataset::ERA5PressureVariable) = [:time, :longitude, :latitude, :resolution, :pressure_level]

function info(dataset::ERA5PressureVariable)::OrderedDict{Symbol,String}
    return OrderedDict{Symbol,String}(
        :name => "ERA5PressureVariable",
        :long_name => "ERA5 Pressure Variable",
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
    file_bounds(dataset::ERA5PressureVariable) -> Vector{Dict{Symbol, ClimateDatasets.Bound}}

Return the file bounds for the given `ERA5PressureVariable`.
"""
function file_bounds(dataset::ERA5PressureVariable)
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
    download_file(dataset::ERA5PressureVariable, filename::AbstractString)

Download the file with the given filename for the given `ERA5PressureVariable`.
"""
function download_file(dataset::ERA5PressureVariable, filename::AbstractString)
    bounds = ClimateDatasets.filename_to_bounds(dataset, filename)
    snapshot_time = bounds[:time].min
    absolute_file_name = joinpath(dataset.directory, filename)
    return produce_snapshot(dataset, snapshot_time, absolute_file_name)
end
