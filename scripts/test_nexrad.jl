using Revise
using Nexrad

using Dates

dt = Dates.DateTime(2021, 12, 31, 4)
Nexrad.produce_file(dt, "demo.nc")
