using MustImplement

abstract type AbstractDataset end
abstract type AbstractDataFile end
abstract type AbstractDomainSpec end
struct Data_Manager
    datasets::Dict{String,AbstractDataset}
end

#! format: off
@mustimplement "AbstractDataset" info(::AbstractDataset) = Dict() # metadata about the dataset
@mustimplement "AbstractDataset" folder(::AbstractDataset) = "" # folder where the dataset is stored
@mustimplement "AbstractDataset" files(::AbstractDataset) = AbstractDataFile[] # all files in the dataset 
@mustimplement "AbstractDataset" files(::AbstractDataset, ::AbstractDomainSpec) = AbstractDataFile[]
@mustimplement "AbstractDataset" ensure_files(::AbstractDataset, ::AbstractDomainSpec) = AbstractDataFile[]
@mustimplement "AbstractDataset" read(::AbstractDataset, ::AbstractDomainSpec) = nothing # read the data for a given domain

@mustimplement "AbstractDataFile" domain(::AbstractDataFile) = nothing # domain of the data file
@mustimplement "AbstractDataFile" read(::AbstractDataFile) = nothing # return all data for the file
@mustimplement "AbstractDataFile" filename(::AbstractDataFile) = "" # return all data for the file
#! format: on

get_dataset(manager::Data_Manager, name::String) = manager.datasets[name]

function get_data(manager::Data_Manager, name::String, domain_specs::AbstractDomainSpec)
    dataset = get_dataset(manager, name)
    files = files_for_domain(dataset, domain_specs)
    data = [read_data(file) for file in files]
    return data
end
