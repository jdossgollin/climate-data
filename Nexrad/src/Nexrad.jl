module Nexrad

using ClimateDatasets: build

include("const.jl")
include("naming.jl")
include("core.jl")
include("dataset.jl")

export NexradDataset, build, info

end # module nexrad
