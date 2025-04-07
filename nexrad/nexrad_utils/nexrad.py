"""
Utility functions and classes for handling NEXRAD data.

This module provides tools for validating datetime objects and managing time ranges
with additional checks for missing snapshots.
"""

from datetime import datetime
from tqdm import tqdm

import pandas as pd

from .const import MISSING_SNAPSHOTS
from .namingconventions import *


def assert_valid_datetime(dt: datetime) -> None:
    """Validate a datetime object for NEXRAD data.

    Args:
        dt (datetime): The datetime object to validate.

    Raises:
        AssertionError: If the datetime is invalid or corresponds to missing data.

    Example:
        assert_valid_datetime(datetime(2025, 4, 7, 12, 0, 0))
    """
    dt_str = dt.strftime("%Y%m%d-%H%M%S")
    assert dt >= GAUGECORR_BEGINTIME, f"Data is not available for {dt_str}"
    assert dt.minute == 0
    assert dt.second == 0
    assert dt.microsecond == 0
    assert dt not in MISSING_SNAPSHOTS, f"Data is missing for {dt_str}"


class TimeRange:
    """Wrapper for pandas.date_range with additional checks for NEXRAD data.

    Attributes:
        stime (datetime): Start time of the range.
        etime (datetime): End time of the range.
        dt_all (pd.DatetimeIndex): All datetime objects in the range.
        dt_valid (list[datetime]): Valid datetime objects excluding missing snapshots.
    """

    def __init__(self, stime: datetime, etime: datetime) -> None:
        """Initialize a TimeRange object.

        Args:
            stime (datetime): Start time of the range.
            etime (datetime): End time of the range.

        Raises:
            AssertionError: If the start or end time is invalid.
        """
        assert_valid_datetime(stime)
        assert_valid_datetime(etime)
        self.stime = stime
        self.etime = etime
        self.dt_all = pd.date_range(self.stime, self.etime, freq="h")
        self.dt_valid = [dt for dt in self.dt_all if dt not in MISSING_SNAPSHOTS]

    def printbounds(self) -> str:
        """Return a string representation of the time range bounds.

        Returns:
            str: The start and end time of the range in a formatted string.

        Example:
            "2025-04-07 00:00:00 to 2025-04-07 12:00:00"
        """
        fmt = "%Y-%m-%d %H:%M:%S"
        return self.stime.strftime(fmt) + " to " + self.etime.strftime(fmt)
