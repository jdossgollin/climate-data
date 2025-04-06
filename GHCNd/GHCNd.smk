import os

# Directory to store GHCNd data
GHCND_DATA_DIR = os.path.join(DATADIR, "GHCNd")


# Rule to download the GHCNd .tar.gz file
rule download_ghcnd:
    output:
        temp(os.path.join(GHCND_DATA_DIR, "daily-summaries-latest.tar.gz")),
    shell:
        "curl -o {output} https://www.ncei.noaa.gov/data/global-historical-climatology-network-daily/archive/daily-summaries-latest.tar.gz"


# Rule to download additional text files
rule download_ghcnd_textfile:
    output:
        os.path.join(GHCND_DATA_DIR, "ghcnd-{name}.txt"),
    shell:
        "curl -o {output} https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-{wildcards.name}.txt"


rule download_ghcnd_docs:
    output:
        os.path.join(GHCND_DATA_DIR, "ghcnd-documentation.pdf"),
    shell:
        "curl -o {output} https://www.ncei.noaa.gov/data/global-historical-climatology-network-daily/doc/GHCND_documentation.pdf"


# Rule to unzip the .tar.gz file
rule unzip_ghcnd:
    input:
        temp(os.path.join(GHCND_DATA_DIR, "daily-summaries-latest.tar.gz")),
    output:
        directory(os.path.join(GHCND_DATA_DIR, "daily-summaries")),
    shell:
        "mkdir -p {output} && tar -xzf {input} -C {output}"


# Rule to combine all GHCNd tasks
rule ghcnd:
    input:
        expand(
            os.path.join(GHCND_DATA_DIR, "ghcnd-{name}.txt"),
            name=["stations", "inventory", "countries"],
        ),
        os.path.join(GHCND_DATA_DIR, "ghcnd-documentation.pdf"),
        os.path.join(GHCND_DATA_DIR, "daily-summaries"),
