"""
This script will download ERA5 orography data.

Details: see
https://confluence.ecmwf.int/pages/viewpage.action?pageId=228854952
"""

import argparse
import cdsapi

def download_era5_orography(
    outfile: str,
) -> None:
    """Download ERA5 orography data.
    
    Args:
        outfile: Path to save the downloaded data
    """
    dataset = "reanalysis-era5-single-levels"
    request = {
        "product_type": "reanalysis",
        "variable": "geopotential",
        "year": "2018",
        "month": "01",
        "day": "01",
        "time": "00:00",
        "data_format": "netcdf",
    }

    c = cdsapi.Client()
    r = c.retrieve(dataset, request)
    r.download(outfile)

if __name__ == "__main__":
    # parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--outfile", type=str)
    args = parser.parse_args()

    # call the function
    download_era5_orography(
        outfile=args.outfile,
    )
