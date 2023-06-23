"""
Keep track of how the Iowa State archive names files
"""

using Dates

"""Get the variable name for a particular date-time snapshot"""
function get_varname(dt::DateTime)::String
    if dt >= MULTISENSOR_BEGINTIME
        var = "MultiSensor_QPE_01H_Pass2"
    elseif GAUGECORR_BEGINTIME <= dt < MULTISENSOR_BEGINTIME
        var = "GaugeCorr_QPE_01H"
    else
        dt_str = Dates.format(dt, DT_FORMAT)
        throw(ArgumentError("No data for $dt_str"))
    end
    return var
end

"""Get the base filename for a particular date-time snapshot (no extension)"""
function get_fname_base(dt::DateTime)
    vn = get_varname(dt)
    dt_str = Dates.format(dt, DT_FORMAT)
    fname = "$(vn)_00.00_$(dt_str)"
    return fname
end

"""Get the filename of the `.grib2.gz` file."""
function get_gz_fname(dt::DateTime)
    return get_fname_base(dt) * ".grib2.gz"
end

"""Get the local .grib2 filename for a given date time"""
function get_grib2_fname(dt::DateTime)
    return get_fname_base(dt) * ".grib2"
end

"""Get the local .netcdf4 filename for a given date time"""
function get_nc_fname(dt::DateTime)
    return get_fname_base(dt) * ".nc"
end

"""Get the URl of the file for a particular date-time snapshot"""
function get_url(dt::DateTime)
    date_str = Dates.format(dt, "yyyy/mm/dd")
    fname = get_gz_fname(dt)
    varname = get_varname(dt)
    return "https://mtarchive.geol.iastate.edu/$date_str/mrms/ncep/$varname/$fname"
end

function fname2dt(fname::String)
    """
    Parse a filename to get the corresponding datetime
    """
    dt_str = split(fname, "_00.00_")[2]
    dt_str = split(dt_str, ".")[1]
    return Dates.DateTime(dt_str, DT_FORMAT)
end

function fname2url(fname::String)
    """
    Given the filename, get the corresponding
    """
    dt = fname2dt(fname)
    return get_url(dt)
end
