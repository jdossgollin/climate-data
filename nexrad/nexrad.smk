# Import necessary modules
import os
from datetime import timedelta, datetime
import pandas as pd

# Local packages to handle naming conventions
from nexrad_utils.nexrad import TimeRange
from nexrad_utils.const import GAUGECORR_BEGINTIME, MISSING_SNAPSHOTS
from nexrad_utils.namingconventions import get_nc_fname, fname2url, get_grib2_fname

# Specify directories to save the data
NEXRAD_DATA_DIR = os.path.join(DATADIR, "NEXRAD")  # Final data storage directory
NEXRAD_SRC_DIR = os.path.join(HOMEDIR, "nexrad")  # Source directory for scripts


# Load the configuration file for NEXRAD
configfile: os.path.join(NEXRAD_SRC_DIR, "nexrad_config.yml")


# Define the time range for data processing
# Default: All available datetimes up to 10 days before the current date
current_date = datetime.now().date()
ENDTIME = datetime.combine(
    current_date - timedelta(days=10), datetime.min.time()
) + timedelta(hours=23)
trange = TimeRange(GAUGECORR_BEGINTIME, ENDTIME)

# Example: Process data for August 17, 2017
# Uncomment the following lines to override the default time range
# t0 = datetime(2017, 8, 17, 0)
# t1 = datetime(2017, 8, 17, 23)
# trange = TimeRange(t0, t1)

t_nonmissing = [t for t in trange.dt_valid if t not in MISSING_SNAPSHOTS]


# Rule: Download and unzip GRIB2 files
# Downloads using curl and unzips using gunzip
rule download_unzip:
    output:
        os.path.join(NEXRAD_DATA_DIR, "{fname}.grib2"),
    conda:
        os.path.join(NEXRAD_SRC_DIR, "download_unzip.yml")
    params:
        url=lambda wildcards: fname2url(wildcards.fname),
    log:
        os.path.join(LOGS, "download_unzip", "{fname}.log"),
    shell:
        "curl -L {params.url} | gunzip > {output}"


# Generate a list of all GRIB2 filenames for valid datetimes
all_nexrad_grib2_files = [
    get_grib2_fname(dt, dirname=NEXRAD_DATA_DIR) for dt in t_nonmissing
]

# Access bounding boxes from the configuration
bounding_boxes = config["bounding_boxes"]

# Define NetCDF4 output files for each bounding box and GRIB2 file combination
all_nexrad_nc_files = [
    get_nc_fname(dt, dirname=NEXRAD_DATA_DIR, bbox_name=bbox["name"])
    for dt in t_nonmissing
    for bbox in bounding_boxes
]


# Rule: Convert GRIB2 files to NetCDF4 format
rule grib2_to_netcdf4:
    input:
        script=os.path.join(NEXRAD_SRC_DIR, "grib2_to_netcdf4.py"),
        grib2_file=os.path.join(
            NEXRAD_DATA_DIR, "{year}", "{month}", "{day}", "{fname}.grib2"
        ),
    output:
        nc_file=os.path.join(
            NEXRAD_DATA_DIR, "{bbox_name}", "{year}", "{month}", "{day}", "{fname}.nc"
        ),
    params:
        lon_min=lambda wildcards: next(
            bbox["lon_min"]
            for bbox in config["bounding_boxes"]
            if bbox["name"] == wildcards.bbox_name
        ),
        lon_max=lambda wildcards: next(
            bbox["lon_max"]
            for bbox in config["bounding_boxes"]
            if bbox["name"] == wildcards.bbox_name
        ),
        lat_min=lambda wildcards: next(
            bbox["lat_min"]
            for bbox in config["bounding_boxes"]
            if bbox["name"] == wildcards.bbox_name
        ),
        lat_max=lambda wildcards: next(
            bbox["lat_max"]
            for bbox in config["bounding_boxes"]
            if bbox["name"] == wildcards.bbox_name
        ),
    conda:
        os.path.join(NEXRAD_SRC_DIR, "grib2_to_netcdf4.yml")
    shell:
        "python {input.script} --input {input.grib2_file} --output {output.nc_file} --lonmin {params.lon_min} --lonmax {params.lon_max} --latmin {params.lat_min} --latmax {params.lat_max}"


# Rule: Clean up temporary files
rule clean_nexrad:
    shell:
        f"rm -f {NEXRAD_DATA_DIR}/*/*/*/*.idx"


# Rule: Main rule to process all NEXRAD data
rule nexrad:
    input:
        all_nexrad_grib2_files,
        all_nexrad_nc_files,
