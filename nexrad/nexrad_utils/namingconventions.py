"""
Keep track of how the Iowa State archive names files.

This module provides functions to generate filenames, URLs, and parse datetime objects
for NEXRAD data based on the Iowa State archive naming conventions.
"""

from datetime import datetime
import os

from .const import *


def get_varname(dt: datetime) -> str:
    """Get the variable name for a particular date-time snapshot.

    Args:
        dt (datetime): The datetime object for which to get the variable name.

    Returns:
        str: The variable name corresponding to the datetime.

    Raises:
        ValueError: If no data is available for the given datetime.

    Example:
        get_varname(datetime(2025, 4, 7, 12, 0, 0))
    """
    if dt >= MULTISENSOR_BEGINTIME:
        var = "MultiSensor_QPE_01H_Pass2"
    elif GAUGECORR_BEGINTIME <= dt < MULTISENSOR_BEGINTIME:
        var = "GaugeCorr_QPE_01H"
    else:
        dt_str = dt.strftime(DT_FORMAT)
        raise ValueError(f"No data for {dt_str}")
    return var


def get_fname_base(dt: datetime, dirname: str = None) -> str:
    """Get the base filename for a particular date-time snapshot (no extension).

    Args:
        dt (datetime): The datetime object for which to generate the filename.
        dirname (str, optional): The directory path to prepend to the filename.

    Returns:
        str: The base filename with optional directory path.

    Example:
        get_fname_base(datetime(2025, 4, 7, 12, 0, 0), dirname="/data")
    """
    varname = get_varname(dt)
    dt_str = dt.strftime(DT_FORMAT)
    dt_year = dt.strftime("%Y")
    dt_month = dt.strftime("%m")
    dt_day = dt.strftime("%d")
    dt_fname = f"{varname}_00.00_{dt_str}"

    # Generate the nested path
    fname = os.path.join(dt_year, dt_month, dt_day, dt_fname)
    if dirname:
        fname = os.path.join(dirname, fname)

    return fname


def get_gz_fname(dt: datetime, dirname: str = None) -> str:
    """Get the filename of the `.grib2.gz` file.

    Args:
        dt (datetime): The datetime object for which to generate the filename.
        dirname (str, optional): The directory path to prepend to the filename.

    Returns:
        str: The `.grib2.gz` filename with optional directory path.

    Example:
        get_gz_fname(datetime(2025, 4, 7, 12, 0, 0), dirname="/data")
    """
    return get_fname_base(dt=dt, dirname=dirname) + ".grib2.gz"


def get_grib2_fname(dt: datetime, dirname: str = None) -> str:
    """Get the local `.grib2` filename for a given datetime.

    Args:
        dt (datetime): The datetime object for which to generate the filename.
        dirname (str, optional): The directory path to prepend to the filename.

    Returns:
        str: The `.grib2` filename with optional directory path.

    Example:
        get_grib2_fname(datetime(2025, 4, 7, 12, 0, 0), dirname="/data")
    """
    return get_fname_base(dt=dt, dirname=dirname) + ".grib2"


def get_nc_fname(dt: datetime, dirname: str = None, bbox_name: str = None) -> str:
    """Get the local `.netcdf4` filename for a given datetime.

    Args:
        dt (datetime): The datetime object for which to generate the filename.
        dirname (str): The directory path to prepend to the filename.
        bbox_name (str, optional): The bounding box name to include in the filename.

    Returns:
        str: The `.netcdf4` filename with optional directory path and bounding box name.

    Raises:
        ValueError: If `dirname` is not provided.

    Example:
        get_nc_fname(datetime(2025, 4, 7, 12, 0, 0), dirname="/data", bbox_name="bbox1")
    """
    if dirname is None:
        raise ValueError("dirname must be provided")
    if bbox_name is None:
        return get_fname_base(dt=dt, dirname=dirname) + ".nc"
    else:
        return get_fname_base(dt=dt, dirname=os.path.join(dirname, bbox_name)) + f".nc"


def get_url(dt: datetime) -> str:
    """Get the URL of the file for a particular date-time snapshot.

    Args:
        dt (datetime): The datetime object for which to generate the URL.

    Returns:
        str: The URL corresponding to the datetime.

    Example:
        get_url(datetime(2025, 4, 7, 12, 0, 0))
    """
    date_str = dt.strftime("%Y/%m/%d")
    fname = get_gz_fname(dt)

    # Drop the folder structure
    fname = fname.split("/")[-1]

    varname = get_varname(dt)
    return f"https://mtarchive.geol.iastate.edu/{date_str}/mrms/ncep/{varname}/{fname}"


def fname2dt(fname: str) -> datetime:
    """Parse a filename to get the corresponding datetime.

    Args:
        fname (str): The filename to parse.

    Returns:
        datetime: The datetime object corresponding to the filename.

    Example:
        fname2dt("MultiSensor_QPE_01H_Pass2_00.00_20250407-120000.grib2")
    """
    # Extract the filename part, ignoring the directory structure
    basename = os.path.basename(fname)

    # Extract the datetime string from the basename
    dt_str = basename.split("_00.00_")[1].split(".")[0]

    # Parse the datetime string to a datetime object
    return datetime.strptime(dt_str, DT_FORMAT)


def fname2url(fname: str) -> str:
    """Get the URL corresponding to a given filename.

    Args:
        fname (str): The filename for which to generate the URL.

    Returns:
        str: The URL corresponding to the filename.

    Example:
        fname2url("MultiSensor_QPE_01H_Pass2_00.00_20250407-120000.grib2")
    """
    dt = fname2dt(fname)
    return get_url(dt)
