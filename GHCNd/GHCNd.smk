import os

# Directory to store GHCNd data.
# This is where all downloaded and processed GHCNd files will be saved.
GHCND_DATA_DIR = os.path.join(DATADIR, "GHCNd")


# Rule: Download the GHCNd .tar.gz file.
# This rule downloads the latest daily summaries archive.
rule download_ghcnd:
    output:
        temp(os.path.join(GHCND_DATA_DIR, "daily-summaries-latest.tar.gz")),
    shell:
        "curl -o {output} https://www.ncei.noaa.gov/data/global-historical-climatology-network-daily/archive/daily-summaries-latest.tar.gz"


# Rule: Download additional GHCNd text files.
# This rule downloads metadata files such as stations, inventory, and countries.
rule download_ghcnd_textfile:
    output:
        os.path.join(GHCND_DATA_DIR, "ghcnd-{name}.txt"),
    shell:
        "curl -o {output} https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-{wildcards.name}.txt"


# Rule: Download GHCNd documentation.
# This rule downloads the official documentation PDF for GHCNd data.
rule download_ghcnd_docs:
    output:
        os.path.join(GHCND_DATA_DIR, "ghcnd-documentation.pdf"),
    shell:
        "curl -o {output} https://www.ncei.noaa.gov/data/global-historical-climatology-network-daily/doc/GHCND_documentation.pdf"


# Rule: Unzip the GHCNd .tar.gz file.
# This rule extracts the daily summaries archive into a directory.
rule unzip_ghcnd:
    input:
        os.path.join(GHCND_DATA_DIR, "daily-summaries-latest.tar.gz"),
    output:
        directory(os.path.join(GHCND_DATA_DIR, "daily-summaries")),
    shell:
        "mkdir -p {output} && tar -xzf {input} -C {output}"


# Define all GHCNd files to be created by the `ghcnd` rule.
all_ghcnd_files = [
    os.path.join(GHCND_DATA_DIR, "ghcnd-{name}.txt").format(name=name)
    for name in ["stations", "inventory", "countries"]
] + [
    os.path.join(GHCND_DATA_DIR, "ghcnd-documentation.pdf"),
    os.path.join(GHCND_DATA_DIR, "daily-summaries"),
]


# Rule: Combine all GHCNd tasks.
# This rule ensures all required GHCNd files are downloaded and processed.
rule ghcnd:
    input:
        all_ghcnd_files,
