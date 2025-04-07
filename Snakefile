from datetime import datetime, timedelta
import platform
import os

################################################################################
# CONFIGURE DATA / FILE STORAGE LOCATIONS
################################################################################

# This section sets up paths for data storage based on the operating system.
# The `DATADIR` variable points to the appropriate directory for storing data.


configfile: "config.yaml"


HOMEDIR = os.path.abspath(".")  # most stuff should be stored locally

# store the data on a remote location
# at present I am saving to Rice RDF -- see https://kb.rice.edu/page.php?id=108256
system = platform.system()
if system == "Darwin":
    DATADIR = os.path.abspath(config["datadir"]["osx"])
elif system == "Linux":
    DATADIR = os.path.abspath(config["datadir"]["linux"])
elif system == "Windows":
    DATADIR = os.path.abspath(config["datadir"]["windows"])
else:
    raise ValueError("Unsupported platform")

# we can use these paths as variables below
LOGS = os.path.join(HOMEDIR, "logs")


# Include sub-Snakefiles for modular workflow management.
# Each sub-Snakefile handles a specific dataset or workflow.
include: "nexrad/nexrad.smk"
include: "era5/era5.smk"  # Include the ERA5 Snakemake file
include: "GHCNd/GHCNd.smk"  # Include the GHCNd Snakemake file


# Default rule to run all workflows.
rule all:
    input:
        all_nexrad_grib2_files,  # Input files for NEXRAD workflow
        all_era5_files,  # Input files for ERA5 workflow
        all_ghcnd_files,  # Input files for GHCNd workflow
