using Dates
using OrderedCollections: OrderedDict
using ProgressMeter

import Base: string
using Base.Threads

"""
    AbstractClimateDataset

Abstract type representing a climate dataset.
"""
abstract type AbstractDataset end

const BOUND_TYPES = Union{Date,DateTime,AbstractFloat,AbstractString,Int}

"""
    Bound{T}

A generic type representing the bound of a dimension in a dataset. 
The bound is represented by a minimum and maximum value of type `T`.
"""
struct Bound{T}
    min::T
    max::T

    function Bound(min::T, max=nothing) where {T}
        if isnothing(max)
            max = min
        end
        if !(isa(min, BOUND_TYPES) && isa(max, BOUND_TYPES))
            throw("Bound must be of type $valid_types")
        end
        return new{T}(min, max)
    end
end

"""
string(bound::Bound)::String

Converts a Bound instance to a string.
"""
function string(bound::Bound)::String
    if bound.min == bound.max
        return string(bound.min)
    else
        return string(bound.min) * "_to_" * string(bound.max)
    end
end

"""
    parse_bound(bound_str::AbstractString)

Tries to parse bound_str into a DateTime, Date, Int, Float64 or leaves it as a String.
Returns the parsed value and the original string representation.
"""
function parse_bound(bound_str::AbstractString)::BOUND_TYPES
    n_dashes = sum([char == '-' for char in bound_str])

    # if there are dashes, it's probably a date
    if n_dashes >= 2
        try
            # try a Date first
            return Date(bound_str, Dates.ISODateFormat)
        catch
            try
                # if that doesn't work, try a DateTime
                return DateTime(bound_str, Dates.ISODateTimeFormat)
            catch
                # if that doesn't work, default to a string
                return bound_str
            end
        end
    else
        try
            # if there aren't dashes, try an integer
            return parse(Int, bound_str)
        catch
            try
                # if that doesn't work, try a float
                return parse(Float64, bound_str)
            catch
                # finally, assume a string
                return bound_str
            end
        end
    end
end

"""
    Bound(bound_str::AbstractString)

Parses a string representation of a bound into a Bound instance.
"""
function Bound(bound_str::AbstractString)
    if occursin("_to_", bound_str)
        min_max = split(bound_str, "_to_")
        min_bound = parse_bound(min_max[1])
        max_bound = parse_bound(min_max[2])
        return Bound(min_bound, max_bound)
    else
        bound = parse_bound(bound_str)
        return Bound(bound)
    end
end

"""
    directory(dataset::AbstractDataset)::AbstractString

Returns the directory where the dataset files are stored. If
it does not exist, builds the directory.
"""
function directory(ds::AbstractDataset)
    dirname = getproperty(ds, :datadir)
    !isdir(dirname) && mkpath(dirname)
    return dirname
end

"""
    info(dataset::AbstractDataset)::OrderedDict{Symbol, String}

Returns a dictionary providing metadata about the dataset
"""
info(dataset::AbstractDataset) = OrderedDict{Symbol,String}()

"""
    file_extension(dataset::AbstractDataset)

Return the file extension for the given dataset.
"""
file_extension(::AbstractDataset) = error("Not Implemented")

"""
    bounds(dataset::AbstractDataset)::Dict{Symbol, Bound}

Returns the bounds for each dimension of the data.
"""
bounds(::AbstractDataset) = error("Not Implemented")

"""
    file_bounds(dataset::AbstractDataset)::Vector{Dict{Symbol, Bound}}

Returns a collection of file-specific bounds for the given dataset.
"""
file_bounds(::AbstractDataset) = error("Not Implemented")

"""
    download_file(dataset::AbstractDataset, filename::AbstractString)::Bool

Downloads a file with the given filename to the dataset directory. 
The filename encodes the file bounds information.
"""
download_file(::AbstractDataset, ::AbstractString)::Bool = error("Not Implemented")

"""
    remove_file_extension(filename::AbstractString)

Removes the file extension from the given filename.
"""
function remove_file_extension(filename::AbstractString)
    pieces = split(filename, ".")[1:(end - 1)]  # remove the file extension
    return join(pieces, ".")
end

"""
    filename_to_bounds(dataset::AbstractDataset, filename::AbstractString)::Dict{Symbol,Bound}

Takes in the filename and returns the bounds of the file. 
Throws an error if the filename contains an invalid string.
"""
function filename_to_bounds(
    dataset::AbstractDataset, filename::AbstractString
)::Dict{Symbol,Bound}
    filename_clean = remove_file_extension(filename)
    bounds = Dict{Symbol,Bound}()
    dimensions = split(filename_clean, "__") # split different dimensinos
    for dimension in dimensions
        dim_bound = split(dimension, "=")
        dim_name = Symbol(dim_bound[1])
        bound_str = dim_bound[2]
        bounds[dim_name] = Bound(bound_str)
    end
    return bounds
end

"""
    bounds_to_filename(dataset::AbstractDataset, file_bounds::Dict{Symbol, Bound})

Takes in the bounds of the file and returns the filename.
"""
function bounds_to_filename(
    dataset::AbstractDataset, file_bounds::Dict{Symbol,Bound{T}}
) where {T}
    dimension_strs = String[]

    # we have to sort the bounds so that the filename is always the same
    file_bounds = sort(OrderedDict(file_bounds))

    for (dim, bound) in file_bounds
        part = string(dim) * "=" * string(bound)
        push!(dimension_strs, part)
    end
    return join(dimension_strs, "__") * file_extension(dataset)
end

"""
    get_filename(dataset::AbstractDataset, file_bound::Dict{Symbol, Bound})::AbstractString

Generates a filename based on the dataset's specific file bound.
"""
function get_filename(dataset::AbstractDataset, file_bound::Dict{Symbol,Bound{T}}) where {T}
    return bounds_to_filename(dataset, file_bound)
end

"""
    get_file_list(dataset::AbstractDataset)::Vector{AbstractString}

Returns a list of files that comprise the data subset, given the dataset's bounds.
"""
function get_file_list(dataset::AbstractDataset)::Vector{AbstractString}
    all_files = []
    for file_bound in file_bounds(dataset)
        filename = get_filename(dataset, file_bound)
        push!(all_files, filename)
    end
    return all_files
end

"""
    check_file_existence(dataset::AbstractDataset, filename::AbstractString)::Bool

Checks whether a file exists in the dataset directory.
"""
function check_file_existence(dataset::AbstractDataset, filename::AbstractString)::Bool
    return isfile(joinpath(directory(dataset), filename))
end

"""
    build(dataset::AbstractDataset; verbose::Bool=true, parallel::Bool=true)

Builds the complete dataset, downloading any missing files. This function can run in 
multithreaded mode if the `parallel` argument is set to true.
"""
function build(dataset::AbstractDataset; verbose::Bool=true)

    # get all the file names for the dataset
    if verbose
        @info "Building dataset"
        display(info(dataset))
    end
    filenames = Set(get_file_list(dataset))
    N = length(filenames)

    # get the filenames we don't yet have
    if verbose
        @info "Checking which files are already available..."
        p = Progress(N)
    end
    filenames_needed = String[]
    for filename in filenames
        if !check_file_existence(dataset, filename)
            push!(filenames_needed, filename)
        end
        verbose && next!(p)
    end

    N_need = length(filenames_needed)
    if verbose
        @info "Out of $N total files, $(N - N_need) are available"
    end

    # loop through and download all the files we're missing
    successes = [false for fn in filenames_needed]
    if N_need >= 1
        if verbose
            @info "Downloading $N_need files..."
            p = Progress(N_need)
        end
        for (i, filename) in enumerate(filenames_needed)
            successes[i] = download_file(dataset, filename)
            verbose && next!(p)
        end
    end

    # return the filenames that were NOT returned successfully
    fn_unsuccessful = [fn for (fn, s) in zip(filenames_needed, successes) if !s]
    return fn_unsuccessful
end
