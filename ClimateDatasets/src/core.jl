using Dates
using OrderedCollections: OrderedDict

import Base: string
using Base.Threads

"""
    AbstractClimateDataset

Abstract type representing a climate dataset.
"""
abstract type AbstractDataset end

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
        valid_types = Union{Date,DateTime,AbstractFloat,AbstractString,Int}
        if !(isa(min, valid_types) && isa(max, valid_types))
            throw("Bound must be of type $valid_types")
        end
        return new{T}(min, max)
    end
end

"""
string(bound::Bound)

Converts a Bound instance to a string.
"""
function string(bound::Bound)
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
function parse_bound(bound_str::AbstractString)
    n_dashes = sum([char == '-' for char in bound_str])
    if n_dashes >= 2
        try
            return DateTime(bound_str, Dates.ISODateTimeFormat)
        catch
            try
                return Date(bound_str, Dates.ISODateFormat)
            catch
                pass
            end
        end
    end

    try
        return parse(Int, bound_str)
    catch
        try
            return parse(Float64, bound_str)
        catch
            return bound_str
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
    info(dataset::AbstractDataset)::Dict{Symbol, String}

Returns a dictionary providing metadata about the dataset
"""
info(dataset::AbstractDataset)::Dict{Symbol,String} = error("Not Implemented")

"""
    file_extension(dataset::AbstractDataset)

Return the file extension for the given dataset.
"""
file_extension(::AbstractDataset) = error("Not Implemented")

"""
    directory(dataset::AbstractDataset)::AbstractString

Returns the directory where the dataset files are stored.
"""
directory(::AbstractDataset) = error("Not Implemented")

"""
    dims(dataset::AbstractDataset)::Vector{Symbol}

Returns the dimensions along which the data is subset.
"""
dims(::AbstractDataset)::Vector{Symbol} = error("Not Implemented")

"""
    bounds(dataset::AbstractDataset)::Dict{Symbol, Bound}

Returns the bounds for each dimension of the data.
"""
bounds(::AbstractDataset)::Dict{Symbol,Bound} = error("Not Implemented")

"""
    file_bounds(dataset::AbstractDataset)::Vector{Dict{Symbol, Bound}}

Returns a collection of file-specific bounds for the given dataset.
"""
file_bounds(::AbstractDataset)::Vector{Dict{Symbol,Bound}} = error("Not Implemented")

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
function bounds_to_filename(dataset::AbstractDataset, file_bounds::Dict{Symbol,Bound})
    
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
function get_filename(dataset::AbstractDataset, file_bound::Dict{Symbol,Bound})
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
    download_file(dataset::AbstractDataset, filename::AbstractString)

Downloads a file with the given filename to the dataset directory. 
The filename encodes the file bounds information.
"""
download_file(::AbstractDataset, ::AbstractString) = error("Not Implemented")

"""
    build(dataset::AbstractDataset; parallel::Bool=true)

Builds the complete dataset, downloading any missing files. This function can run in 
multithreaded mode if the `parallel` argument is set to true.
"""
function build(dataset::AbstractDataset; parallel::Bool=true)
    files = get_file_list(dataset)
    if parallel
        @threads for filename in files
            if !check_file_existence(dataset, filename)
                download_file(dataset, filename)
            end
        end
    else
        for filename in files
            if !check_file_existence(dataset, filename)
                download_file(dataset, filename)
            end
        end
    end
end
