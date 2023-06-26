# Climate Data Repository

This is the code used to generate and maintain the Doss-Gollin Group's climate data repository.
While the code is open-access and anyone can use this code to reproduce our data repository, the data itself is stored on a server not made available to the public.

## How to use the datasets

You don't need to worry about this code to use the datasets.

### Which datasets are included?

- Nexrad

## How to add new datasets

### Specs

Your task is to help me design an abstract, high-level interface for a climate dataset manager. The climate datasets my team uses are all publicly available and can be downloaded through APIs, but we want to store all the data we use in a singe location for easy sharing. Moreover, we want to put datasets in a standard format to facilitate interoperability.

We are currently designing the high-level interface, which will be implemented as a Julia package called ClimateDatasets. Each dataset we use will be implemented as its own package.

Each dataset is split across multiple files. Each file corresponds to a specific subset of the data. This subsetting is done along a specific dimension of the data -- most often time, but sometimes other dimensions (e.g., pressure level for 3D atmospheric variables)

A desired high-level interface looks like:

```julia
t0 = Dates.DateTime(2020, 1, 1, 1)
t1 = Dates.DateTime(2020, 12, 31, 23)
date0 = Dates.Date(t0)
date1 = Dates.Date(t1)
d1 = ERA5PressureVar(directory=path_1, start_time=t0, end_time=t1, pressure_level=500.0, varname="uwnd")
d2 = ERA5PressureVar(directory=path_2, start_time=t0, end_time=t1, pressure_level=500.0, varname="vwnd")
d3 = ERA5SingleLevelVar(directory=path_3, start_time=t0, end_time=t1, varname="2m_temperature")
d4 = Nexrad(directory=path_4, start_time=date1, end_time=date1)
for dataset in [d1, d2, d3, d4]
     build(dataset)
end
```

Based on this we can see that `ERA5PressureVar`, `ERA5SingleLevelVar`, and `Nexrad` are classes that implement some abstract dataset type, which has a `build` method. Every instance of this abstract dataset type has a `directory` field, which is the path to the directory where the data is stored. There are also various arguments that are specific to the particular dataset. For example, all these datasets have a `start_time` and `end_time` argument, but only the `ERA5PressureVar` datasets have a `pressure_level` argument. Additionally, the ERA5 data is hourly, so the start_time and end_time arguments are `DateTime` objects, while the Nexrad data is daily, so the start_time and end_time arguments are `Date` objects.

When the `Dataset()` method is called (dg, when d1, d2, d3, and d4 are defined) the program should:

1. Verify that the directory exists and can be written to
2. Verify that the bounds of the dataset are valid (e.g., the start_time and end_time arguments are within the bounds of the dataset which is known by the dataset class)

When the `build` method is called, the program should:

1. Get a list of all the files that would comprise the dataset
2. For each file in the list of all files from #3, check whether it exists and, if not, download it

To begin, list using bullet points the names of all data types and methods that we will need to implement in the ClimateDatasets package.
