# ClimateDatasets

## Using

Use this structure to add new datasets to our collection.
To create a concrete subtype of `AbstractClimateDataset`, the following methods must be implemented:

- `directory(dataset::YourDatasetType)`: This method should return a string representing the directory path where the dataset files are stored.

    Example:

    ```julia
    function directory(dataset::YourDatasetType)
        return "/path/to/your/dataset"
    end
    ```

- `dims(dataset::YourDatasetType)`: This method should return a vector of symbols representing the dimensions along which the data is subset.

    Example:

    ```julia
    function dims(dataset::YourDatasetType)
        return [:time, :latitude, :longitude]
    end
    ```

- `bounds(dataset::YourDatasetType)`: This method should return a dictionary mapping symbols (representing dimensions) to `Bound` objects (representing the bounds for each dimension).

    Example:

    ```julia
    function bounds(dataset::YourDatasetType)
        return Dict(:time => Bound(Date(2001,1,1), Date(2010,12,31)), :latitude => Bound(-90.0, 90.0), :longitude => Bound(-180.0, 180.0))
    end
    ```

- `file_bounds(dataset::YourDatasetType)`: This method should return a vector of dictionaries, each representing the bounds of a specific file in the dataset.

    Example:

    ```julia
    function file_bounds(dataset::YourDatasetType)
        return [Dict(:time => Bound(Date(2001,1,1), Date(2001,12,31)), :latitude => Bound(-90.0, 90.0), :longitude => Bound(-180.0, 180.0)), Dict(:time => Bound(Date(2002,1,1), Date(2002,12,31)), :latitude => Bound(-90.0, 90.0), :longitude => Bound(-180.0, 180.0))]
    end
    ```

- `download_file(dataset::YourDatasetType, filename::AbstractString)`: This method should handle the downloading of a file, given by its filename, to the dataset directory.

    Example:

    ```julia
    function download_file(dataset::YourDatasetType, filename::AbstractString)
        # Your download logic here
    end
    ```

- `info(dataset::YourDatasetType)`: This method provides a `Dict` containing useful information about your dataset

    Example:

    ```julia
    function info(dataset::YourDatasetType)
        Dict(
            :name => "Your Dataset Name",
            :long_name => "Your Dataset Long Name",
            :description => "Your Dataset Description",
        )
    end
    ```
