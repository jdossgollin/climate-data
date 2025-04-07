ERA5_DATA_DIR = os.path.join(DATADIR, "ERA5")  # where the data goes
ERA5_SRC_DIR = os.path.join(HOMEDIR, "era5")  # this folder

configfile: os.path.join(ERA5_SRC_DIR, "era5_config.yml")

era5_env = os.path.join(ERA5_SRC_DIR, "era5_env.yml")

rule era5_elevation:
    input:
        os.path.join(ERA5_SRC_DIR, "download_era5_orography.py"),
    output:
        os.path.join(ERA5_DATA_DIR, "single_level", "elevation.nc"),
    log:
        os.path.join(LOGS, "era5_elevation.log"),
    conda:
        era5_env
    shell:
        "python {input} --outfile {output} {params.bounds}"

# Get any variable on pressure levels
rule era5_pressure:
    input:
        os.path.join(ERA5_SRC_DIR, "download_era5_pressure.py"),
    output:
        os.path.join(ERA5_DATA_DIR, "pressure_level", "{variable}_{pressure}_{year}.nc"),
    log:
        os.path.join(LOGS, "era5_pressure", "{variable}_{pressure}_{year}.log"),
    conda:
        era5_env
    shell:
        "python {input} --outfile {output} --variable {wildcards.variable} --pressure {wildcards.pressure} --year {wildcards.year}"

# Get any variable on a single level
rule era5_single_level:
    input:
        os.path.join(ERA5_SRC_DIR, "download_era5_single_level.py"),
    output:
        os.path.join(ERA5_DATA_DIR, "single_level", "{variable}_{year}.nc"),
    log:
        os.path.join(LOGS, "era5_single_level", "{variable}_{year}.log"),
    conda:
        era5_env
    shell:
        "python {input} --outfile {output} --variable {wildcards.variable} --year {wildcards.year}"

# Get all the ERA5 data
era5_years = range(config["era5"]["first_year"], config["era5"]["last_year"] + 1)

# Specify the files to download
pressure_files = []
single_level_files = []

# Add pressure level files
for year in era5_years:
    for var in config["era5"]["vars"]["pressure_level"]:
        varname = var["name"]
        levels = var["levels"]
        for level in levels:
            pressure_files.append(
                os.path.join(ERA5_DATA_DIR, "pressure_level", f"{varname}_{level}_{year}.nc")
            )

# Add single level files
for year in era5_years:
    for var in config["era5"]["vars"]["single_level"]:
        single_level_files.append(
            os.path.join(ERA5_DATA_DIR, "single_level", f"{var}_{year}.nc")
        )

# Explicitly list the files to download
elevation_file = [os.path.join(ERA5_DATA_DIR, "single_level", "elevation.nc")]
all_reanalysis_files = elevation_file + pressure_files + single_level_files

# The rule to download all the ERA5 data
rule ERA5:
    input:
        #all_reanalysis_files,
        single_level_files[0:1]
