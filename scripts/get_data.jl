using Revise
using Nexrad

using Dates

RDF_FOLDER = "/home/jd82/RDF/jd82" # only the Doss-Gollin Group will be able to access this!

# define the datasets to use
datasets = [NexradDataset(joinpath(RDF_FOLDER, "NEXRAD")]

for ds in datasets
    @info "Building dataset..."
    display(info(ds))
    build(ds)
end
