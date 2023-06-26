module ClimateDatasets

include("core.jl")

export AbstractDataset,
    Bound,
    directory,
    dims,
    bounds,
    file_bounds,
    filename_to_bounds,
    bounds_to_filename,
    get_filename,
    get_file_list,
    check_file_existence,
    download_file,
    build,
    info

end
# module ClimateDatasets
