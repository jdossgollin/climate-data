"""
This script will download ONE YEAR OF ERA5 HOURLY REANALYSIS DATA.
Storing one year of data in one file makes it easier to work with
and more resilient to errors in downloading.

You need to specify the year, the output file name, the variable, and the pressure level.

The variable should follow the ERA5 documentation. Some common ones: 
- temperature
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


def download_era5_pressure(
    year: int,
    variable: str,
    pressure_level: float,
    outfile: str,
) -> None:
    """Download pressure level ERA5 data for a given year, variable, and pressure level.

    Args:
        year (int): The year to download data for.
        variable (str): The ERA5 variable name.
        pressure_level (float): The pressure level in hPa.
        outfile (str): Path to save the downloaded data.

    Returns:
        None

    Example:
        download_era5_pressure(2020, "temperature", 500, "/path/to/output.nc")
    """
    dataset = "reanalysis-era5-pressure-levels"
    months = [f"{month:02d}" for month in range(1, 13)]  # 01, 02, ..., 12
    days = [f"{day}" for day in np.arange(1, 32)]  # 1, 2, ..., 31
    hours = [f"{hour:02d}:00" for hour in range(24)]  # 00:00, 01:00, ... 23:00

    request = {
        "product_type": ["reanalysis"],
        "variable": variable,
        "pressure_level": [pressure_level],
        "year": [year],
        "month": months,
        "day": days,
        "time": hours,
        "data_format": "netcdf",
        "download_format": "unarchived",
    }

    print(request)

    c = cdsapi.Client()
    r = c.retrieve(dataset, request)
    r.download(outfile)


if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Download ERA5 pressure level data.")
    parser.add_argument(
        "-o", "--outfile", type=str, required=True, help="Output file path."
    )
    parser.add_argument(
        "--variable", type=str, required=True, help="ERA5 variable name."
    )
    parser.add_argument(
        "--pressure_level", type=float, required=True, help="Pressure level in hPa."
    )
    parser.add_argument(
        "--year", type=int, required=True, help="Year to download data for."
    )
    args = parser.parse_args()

    # Call the function
    download_era5_pressure(
        year=args.year,
        variable=args.variable,
        pressure_level=args.pressure_level,
        outfile=args.outfile,
    )
