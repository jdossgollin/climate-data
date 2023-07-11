using Revise
using Nexrad

using Dates

<<<<<<< HEAD
# this is the path to a directory available only to Doss-Gollin group members
RDF_FOLDER = "/home/jd82/RDF/jd82"
||||||| b3c9d71
RDF_FOLDER = "/home/jd82/RDF/jd82" # only the Doss-Gollin Group will be able to access this!
=======
# only the Doss-Gollin Group will be able to access this particular folder
DATA_FOLDER = "/home/jd82/RDF/jd82"
>>>>>>> b16fcd80661a1a68f2e62ce6f487a5fe9f734cb8

# define the datasets to use
datasets = [NexradDataset(joinpath(DATA_FOLDER, "NEXRAD"))]

# loop through each dataset
res = [build(ds) for ds in datasets]

# this lists all the filenames we weren't able to build
[res_i for res_i in res]
