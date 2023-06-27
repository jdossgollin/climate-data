# ClimateDatasets

## Using

To create a custom dataset, you need to define your dataset as a subtype of `AbstractDataset` and import the following functions:

```julia
import ClimateDatasets: AbstractDataset, info, file_extension, bounds, file_bounds, download_file

struct MyDataset <: AbstractDataset
    # ...
end
```

Then you need to define the following methods:

```julia
"""
    info(dataset::AbstractDataset)::Dict{Symbol, String}

Returns a dictionary providing metadata about the dataset
"""
info(dataset::AbstractDataset) = Dict{Symbol, String}()
```

```julia
"""
    file_extension(dataset::AbstractDataset)::AbstractString

Return the file extension for the given dataset.
"""
file_extension(::AbstractDataset) = error("Not Implemented")
```

```julia
"""
    bounds(dataset::AbstractDataset)::Dict{Symbol, Bound}

Returns the bounds for each dimension of the data.
"""
bounds(::AbstractDataset) = error("Not Implemented")
```

```julia
"""
    file_bounds(dataset::AbstractDataset)::Vector{Dict{Symbol, Bound}}

Returns a collection of file-specific bounds for the given dataset.
"""
file_bounds(::AbstractDataset) = error("Not Implemented")
```

```julia
"""
    download_file(dataset::AbstractDataset, filename::AbstractString)::Bool

Downloads a file with the given filename to the dataset directory. 
The filename encodes the file bounds information.
"""
download_file(::AbstractDataset, ::AbstractString) = error("Not Implemented")
```
