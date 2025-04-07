"""
Subset a GRIB2 file and save it as a NetCDF4 file.

This script allows you to extract a specific geographical region from a GRIB2 file
and save the subset as a NetCDF4 file for further analysis.

Example:
    python grib2_to_netcdf4.py --input input.grib2 --output output.nc \
        --lonmin -125 --lonmax -66 --latmin 24 --latmax 50
"""

import argparse
import xarray as xr
import os


def subset_and_convert(
    input_file: str,
    output_file: str,
    lon_min: float,
    lon_max: float,
    lat_min: float,
    lat_max: float,
) -> None:
    """Subset a GRIB2 file and save it as a NetCDF4 file.

    Args:
        input_file (str): Path to the input GRIB2 file.
        output_file (str): Path to the output NetCDF4 file.
        lon_min (float): Minimum longitude of the bounding box.
        lon_max (float): Maximum longitude of the bounding box.
        lat_min (float): Minimum latitude of the bounding box.
        lat_max (float): Maximum latitude of the bounding box.

    Returns:
        None

    Example:
        subset_and_convert("input.grib2", "output.nc", -125, -66, 24, 50)
    """
    # Open the GRIB2 file
    ds = xr.open_dataarray(input_file, engine="cfgrib", decode_timedelta=False)
    ds.name = "precipitation"
    ds.attrs = {"units": "mm"}

    # Subset the data
    ds_subset = ds.sel(
        longitude=slice(lon_min, lon_max), latitude=slice(lat_max, lat_min)
    )

    # Save the subset as a NetCDF4 file
    ds_subset.to_netcdf(output_file, format="NETCDF4")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Subset a GRIB2 file and save as NetCDF4."
    )
    parser.add_argument("--input", required=True, help="Path to the input GRIB2 file.")
    parser.add_argument(
        "--output", required=True, help="Path to the output NetCDF4 file."
    )
    parser.add_argument(
        "--lonmin",
        type=float,
        required=True,
        help="Minimum longitude of the bounding box.",
    )
    parser.add_argument(
        "--lonmax",
        type=float,
        required=True,
        help="Maximum longitude of the bounding box.",
    )
    parser.add_argument(
        "--latmin",
        type=float,
        required=True,
        help="Minimum latitude of the bounding box.",
    )
    parser.add_argument(
        "--latmax",
        type=float,
        required=True,
        help="Maximum latitude of the bounding box.",
    )

    args = parser.parse_args()

    subset_and_convert(
        input_file=args.input,
        output_file=args.output,
        lon_min=args.lonmin,
        lon_max=args.lonmax,
        lat_min=args.latmin,
        lat_max=args.latmax,
    )
