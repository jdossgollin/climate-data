"""
Here we keep track of how the Iowa State archive names its files.
"""

using Dates

"""
    get_varname(dt::DateTime) -> AbstractString

Get the variable name for a particular date-time snapshot.
"""
function get_varname(dt::DateTime)::AbstractString
    if dt >= MULTISENSOR_BEGINTIME
        var = "MultiSensor_QPE_01H_Pass2"
    elseif GAUGECORR_BEGINTIME <= dt < MULTISENSOR_BEGINTIME
        var = "GaugeCorr_QPE_01H"
    else
        dt_str = Dates.format(dt, Dates.ISODateTimeFormat)
        throw(ArgumentError("No data for $dt_str"))
    end
    return var
end

"""
    get_fname_base(dt::DateTime) -> AbstractString

Get the base filename for a particular date-time snapshot (no extension).
"""
function get_fname_base(dt::DateTime)::AbstractString
    vn = get_varname(dt)
    dt_str = Dates.format(dt, DT_FORMAT)
    fname = "$(vn)_00.00_$(dt_str)"
    return fname
end

"""
    get_url(dt::DateTime) -> AbstractString

Get the URL of the file for a particular date-time snapshot.
"""
function get_url(dt::DateTime)::AbstractString
    date_str = Dates.format(dt, "yyyy/mm/dd")
    fname = get_fname_base(dt) * ".grib2.gz"
    varname = get_varname(dt)
    return "https://mtarchive.geol.iastate.edu/$date_str/mrms/ncep/$varname/$fname"
end
