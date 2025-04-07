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
    """Download pressure level ERA5 data for a given year, variable and pressure level.
    
    Args:
        year: The year to download data for
        variable: The ERA5 variable name
        pressure_level: The pressure level in hPa
        outfile: Path to save the downloaded data
    """
    dataset = "reanalysis-era5-pressure-levels"
    product_type = "reanalysis"
    months = [f"{month:02d}" for month in range(1, 13)]  # 01, 02, ..., 12
    days = [f"{day}" for day in np.arange(1, 32)]  # 1, 2, ..., 31
    hours = [f"{hour:02d}:00" for hour in range(24)]  # 00:00, 01:00, ... 23:00

    request = {
        "product_type": product_type,
        "data_format": "netcdf",
        "variable": variable,
        "pressure_level": [pressure_level],
        "year": [year],
        "month": months,
        "day": days,
        "time": hours,
    }

    c = cdsapi.Client()
    r = c.retrieve(dataset, request)
    r.download(outfile)

if __name__ == "__main__":
    # parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--outfile", type=str)
    parser.add_argument("--variable", type=str)
    parser.add_argument("--pressure_level", type=float)
    parser.add_argument("--year", type=int)
    args = parser.parse_args()

    # call the function
    download_era5_pressure(
        year=args.year,
        variable=args.variable,
        pressure_level=args.pressure_level,
        outfile=args.outfile,
    )
