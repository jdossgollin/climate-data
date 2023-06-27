using Revise
using Nexrad

using Dates

RDF_FOLDER = "data" # only the Doss-Gollin Group will be able to access this!

datasets = [
    NexradDataset(joinpath(RDF_FOLDER, "NEXRAD")),
]

for ds in datasets
    display(info(ds))
    #buidl(ds; parallel=false)
end

