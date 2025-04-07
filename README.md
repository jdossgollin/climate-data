# Climate Data Repository

Welcome to our Climate Data Repository! This repository is actively maintained to download, process, and manage our internal climate data database. While it is designed for our internal use, it is public so others can reproduce our datasets or extract specific data they need. If you add new datasets, we encourage you to submit a pull request to share your contributions with the community.

## Available Datasets

This repository provides access to the following datasets:

1. **NEXRAD Radar Precipitation Data**: Radar-based precipitation data over the continental United States.
2. **ERA5 Reanalysis Data**: High-resolution reanalysis data, including:
   - Pressure-level variables (e.g., wind components at 500 hPa).
   - Single-level variables (e.g., 2m temperature).
   - Orography (elevation data).
3. **GHCNd Daily Summaries**: Global Historical Climatology Network daily summaries, including station metadata and documentation.

We are open to adding more datasets in the future. If you have suggestions, feel free to contribute!

## Running the Code

### Prerequisites

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/climate-data.git
   cd climate-data
   ```

2. **Install the Conda Environment**:
   ```bash
   conda env create -f environment.yml
   conda activate climate-data
   ```

### Updating Datasets

To update the datasets without adding new ones, run the following command:

```bash
snakemake --use-conda --cores all
```

For long-running processes, especially on remote machines, use:

```bash
nohup snakemake all --use-conda --cores all --rerun-incomplete --keep-going &
```

#### Explanation of Flags:
- `nohup`: Keeps the process running even if the SSH connection closes.
- `--use-conda`: Ensures the correct Conda environment is used for each rule.
- `--cores all`: Utilizes all available CPU cores.
- `--rerun-incomplete`: Retries incomplete jobs to avoid errors.
- `--keep-going`: Continues running other jobs even if some fail.

### Specific Instructions for Rice RDF

If you are working on the Rice Research Data Facility (RDF), ensure the `datadir` in `config.yaml` points to the mounted RDF directory. For example:

```yaml
datadir:
  linux: /path/to/mounted/rdf
```

To mount the RDF on Linux, use the following command:

```bash
sudo mount.cifs -o username=<your_username>,domain=ADRICE,mfsymlinks,rw,vers=3.0,sign,uid=<your_username> //smb.rdf.rice.edu/research $HOME/RDF
```

Replace `<your_username>` with your actual username. Ensure the `uid` matches your username.

## Developer Guide

We welcome contributions to this repository! Here are some guidelines for developers:

### Docstring Style

Use [Google-style docstrings](https://sphinxcontrib-napoleon.readthedocs.io/en/latest/example_google.html) for all Python functions and classes.
This ensures clarity and consistency.

### Code Formatting

- Use `black` for code formatting.
- Use `snakefmt` for formatting Snakemake files.

### Submitting Changes

1. Fork the repository and create a new branch for your changes.
2. Ensure all tests pass and the code is properly formatted.
3. Submit a pull request with a clear description of your changes.

We look forward to your contributions!

