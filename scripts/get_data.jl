using Revise
using Nexrad

using Dates

# this is the path to a directory available only to Doss-Gollin group members
RDF_FOLDER = "/home/jd82/RDF/jd82"

# define the datasets to use
datasets = [NexradDataset(joinpath(RDF_FOLDER, "NEXRAD"))]

# loop through each dataset
res = [build(ds) for ds in datasets]

# this lists all the filenames we weren't able to build
[res_i for res_i in res]
