using Revise
using Nexrad

using Dates

# only the Doss-Gollin Group will be able to access this particular folder
DATA_FOLDER = "/home/jd82/RDF/jd82"

# define the datasets to use
datasets = [NexradDataset(joinpath(DATA_FOLDER, "NEXRAD"))]

for ds in datasets
    @info "Building dataset..."
    display(info(ds))
    build(ds)
end
