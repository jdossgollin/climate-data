"""
This script will download ERA5 orography data.

Details: see
https://confluence.ecmwf.int/pages/viewpage.action?pageId=228854952
"""

import argparse
import cdsapi


def download_era5_orography(outfile: str) -> None:
    """Download ERA5 orography data.

    Args:
        outfile (str): Path to save the downloaded data.

    Returns:
        None

    Example:
        download_era5_orography("/path/to/output.nc")
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
        "download_format": "unarchived",
    }

    c = cdsapi.Client()
    r = c.retrieve(dataset, request)
    r.download(outfile)


if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Download ERA5 orography data.")
    parser.add_argument(
        "-o", "--outfile", type=str, required=True, help="Output file path."
    )
    args = parser.parse_args()

    # Call the function
    download_era5_orography(outfile=args.outfile)
