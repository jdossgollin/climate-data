"""
This script will download ONE YEAR OF ERA5 HOURLY REANALYSIS DATA.
Storing one year of data in one file makes it easier to work with
and more resilient to errors in downloading.

You need to specify the year, the output file name, and the variable.

The variable should follow the ERA5 documentation. Some common ones: 
- 2m_temperature
- u_component_of_wind

To access the data you will need a password saved in a local file. See CDASAPI
documentation for details!

ADDITIONAL DOCUMENTATION:

ERA5 documentation: https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation
cdsapi documentation: https://cds.climate.copernicus.eu/api-how-to
"""

import argparse
import cdsapi
import numpy as np


def download_era5_single_level(
    year: int,
    variable: str,
    outfile: str,
) -> None:
    """Download a single level of ERA5 data for a given year and variable.

    Args:
        year (int): The year to download data for.
        variable (str): The ERA5 variable name.
        outfile (str): Path to save the downloaded data.

    Returns:
        None

    Example:
        download_era5_single_level(2020, "2m_temperature", "/path/to/output.nc")
    """
    dataset = "reanalysis-era5-single-levels"
    product_type = "reanalysis"
    months = [f"{month:02d}" for month in range(1, 13)]  # 01, 02, ..., 12
    days = [f"{day}" for day in np.arange(1, 32)]  # 1, 2, ..., 31
    hours = [f"{hour:02d}:00" for hour in range(24)]  # 00:00, 01:00, ... 23:00

    request = {
        "product_type": product_type,
        "variable": variable,
        "year": [year],
        "month": months,
        "day": days,
        "time": hours,
        "data_format": "netcdf",
        "download_format": "unarchived",
    }

    c = cdsapi.Client()
    r = c.retrieve(dataset, request)
    r.download(outfile)


if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Download ERA5 single level data.")
    parser.add_argument(
        "-o", "--outfile", type=str, required=True, help="Output file path."
    )
    parser.add_argument(
        "--variable", type=str, required=True, help="ERA5 variable name."
    )
    parser.add_argument(
        "--year", type=int, required=True, help="Year to download data for."
    )
    args = parser.parse_args()

    # Call the function
    download_era5_single_level(
        year=args.year,
        variable=args.variable,
        outfile=args.outfile,
    )
