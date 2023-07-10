# Climate Data Repository

This is the code used to generate and maintain the Doss-Gollin Group's climate data repository.
While the code is open-access and anyone can use this code to reproduce our data repository, the data itself is stored on a server not made available to the public.

## Using the data

## Running codes

This is for you if you want to leverage this package to update or reproduce our climate data repository.

### Installing

1. `git clone` this repository
1. Make sure you have a recent version of Julia, ideally 1.9, installed. Juliaup is recommended.
1. Open Julia and instantiate the environment (`] instantiate` or `using Pkg; Pkg.instantiate()`)

### How to run 

From the command line:

```bash
julia --project -t 12 scripts/get_data.jl
```

where `-t 12` sets Julia to use 12 threads; replace with your desired number or delete for single-threading.

From Julia:

```julia
include("scripts/get_data.jl")
```

## Modifying the codes
