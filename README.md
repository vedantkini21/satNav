# Satellite Navigation - Android GNSS Analysis

A collection of MATLAB and Python tools, Android GNSS measurements, RINEX
navigation files, and processed results created for the **Satellite Navigation
(AE60002)** course at **IIT Kharagpur**.

The project uses raw measurements recorded by Android devices to study GNSS
signal quality, pseudoranges, receiver clock effects, satellite geometry, and
position/velocity errors. It builds on Google's
[GPS Measurement Tools](https://github.com/google/gps-measurement-tools) and
adds coursework-specific analysis scripts, datasets, preprocessing utilities,
and a RINEX ephemeris downloader.

## What this repository contains

- Static and dynamic Android GNSS datasets collected in different environments
- MATLAB processing of raw GNSS measurements and weighted least-squares PVT
- Comparison of calculated and phone-reported pseudorange rates
- ECEF and NED position-error analysis
- NED velocity-error analysis
- C/N0, pseudorange, pseudorange-rate, PVT, and ADR plots
- A Python utility for filtering low-quality or unwanted raw measurements
- A Windows utility for downloading and extracting BKG broadcast ephemeris
- The GNSS Analysis App installer, manual, and generated KML/NMEA results

## Repository structure

```text
satNav/
|-- gps-measurement-tools-master/
|   |-- opensource/                 # MATLAB GNSS processing and coursework scripts
|   |-- GNSSLogger/                 # Android GNSS Logger source
|   `-- NmeaUtils/                  # NMEA parsing and error-analysis utilities
|-- GNSSAnalysisFiles/              # Input datasets, RINEX files, and app outputs
|-- customBKGEphemerisDownloader/   # BKG RINEX downloader and GFZRNX executable
|-- cleanRaw.py                     # Raw GNSS log filtering utility
|-- Project_for_Satellite_Navigation_Class_2026.pdf
`-- LICENSE
```

The main files added in the coursework are:

- `gps-measurement-tools-master/opensource/Task4_Task_5.m`
- `gps-measurement-tools-master/opensource/Task7_Task8_Task9_Task10.m`

These were custom scripts written to calculate and plot the required things mentioned in the course project.

## Analysis performed

### Pseudorange-rate analysis

`Task4_Task_5.m`:

1. Computes satellite elevation angles for each valid epoch.
2. Selects the GPS satellite with the highest median elevation.
3. Calculates pseudorange rate by differencing consecutive pseudoranges.
4. Removes receiver clock drift estimated by the WLS solution.
5. Compares the result with the phone-reported pseudorange rate.

### Position and velocity errors

`Task7_Task8_Task9_Task10.m`:

1. Converts the estimated positions from LLA to ECEF coordinates.
2. Uses the mean ECEF position as the reference position.
3. Transforms ECEF errors into the local NED frame.
4. Plots east-versus-north position error and height error over time.
5. Produces equivalent plots and spread measurements for NED velocity.

## Requirements

### MATLAB workflow

- MATLAB
- The repository's `gps-measurement-tools-master/opensource` directory on the
  MATLAB path
- An Android GNSS log in the format produced by Google's GNSS Logger
- Matching broadcast ephemeris files in the same directory as the log

### Python package to download ephemeris files

- Python 3 is required
- Internet access is required when using the BKG downloader
- The BKG downloader was written by my friend Dheeraj, to download the missing ephemeris files from the JPL website.
- Some of the files could not be downloaded manually from the website so this was required to automatically extract the required files
- No third-party Python packages are required.

## Steps to use the repository

### 1. Clone the repository

```bash
git clone https://github.com/vedantkini21/satNav.git
cd satNav
```

### 2. Configure MATLAB

Open MATLAB and add the processing directory:

```matlab
addpath('C:\path\to\satNav\gps-measurement-tools-master\opensource');
```

Open
`gps-measurement-tools-master/opensource/ProcessGnssMeasScript.m`, then update:

```matlab
prFileName = 'your_gnss_log.txt';
dirName = 'C:\path\to\the\folder\containing\your\log';
```

The data directory should contain the GNSS log and its corresponding RINEX
navigation files. If the reference position is known, set:

```matlab
param.llaTrueDegDegM = [latitudeDeg, longitudeDeg, altitudeM];
```

Run the script:

```matlab
ProcessGnssMeasScript
```

It reads and filters the measurements, obtains ephemeris data, computes
pseudoranges, solves position/velocity/time using weighted least squares, runs
the coursework analyses, and generates the available plots.

> **Note:** `ProcessGnssMeasScript.m` currently contains a machine-specific
> Windows path. Replace `dirName` before running it on another computer.

## Filter a raw GNSS log (This file can be ignored)

`cleanRaw.py` keeps:

- GPS (`ConstellationType = 1`)
- BeiDou (`ConstellationType = 5`)
- Galileo (`ConstellationType = 6`)
- Measurements with `C/N0 >= 20 dB-Hz`

All non-`Raw` metadata lines are preserved.

Run:

```bash
python cleanRaw.py
```

Enter the absolute path to the input log when prompted. The filtered file is
written beside it with a `cleaned_` prefix.

> The current path handling in this utility is intended for Windows paths.

## Download BKG broadcast ephemeris

Use this when the GNSS Analysis App reports that a required BKG RINEX file is
missing:

```bash
cd customBKGEphemerisDownloader
python customBKGEphemerisDownloader.py
```

Enter one or more `.rnx.gz` filenames separated by spaces, commas, or newlines,
then enter `-1` to finish. For example:

```text
BRDC00WRD_R_20261090000_01D_EN.rnx.gz
BRDC00WRD_R_20261090000_01D_CN.rnx.gz
-1
```

The script downloads the mixed broadcast file from the
[BKG GNSS Data Center](https://igs.bkg.bund.de/), extracts it, and uses the
included Windows `gfzrnx.exe` binary to generate constellation-specific RINEX
files. Copy the generated files into the directory containing the GNSS log
being analysed.

## Example datasets

`GNSSAnalysisFiles/` contains several ready-to-inspect cases. These were collected in and around the campus of IIT Kharagpur.

- Static open-sky measurements
- Dynamic measurements
- Helipad measurement sessions
- Morning/afternoon comparison data
- Accumulated Delta Range (ADR) demonstration data
- Stationary examples with and without local ephemeris files

Many dataset directories include:

- Original or cleaned Android GNSS logs
- RINEX navigation files
- `raw.csv` exports
- Generated NMEA tracks
- Generated KML tracks
- MATLAB parameter files

These files are generated after runnning the GNSS Analysis App for that dataset

## GNSS Analysis App

A Windows build and installation manual are available under
`GNSSAnalysisFiles/`. The app can process raw Android GNSS measurements,
visualize measurement quality, and export NMEA/KML results.

The included executable requires the MATLAB Runtime. See:

- `GNSSAnalysisFiles/Installation and User Manual, GNSS Analysis App.pdf`
- `GNSSAnalysisFiles/for_redistribution_files_only/readme_instructions_windows.txt`

## Data and reproducibility notes

- Results depend on the phone, antenna orientation, environment, satellite
  visibility, duty cycling, multipath, and available ephemeris.
- File paths and input filenames in the MATLAB driver must be changed for each
  dataset.
- Some tools and binaries included here are Windows-specific.
- The repository contains large raw and generated data files, so cloning may
  take longer than a typical source-only project.

## Acknowledgements

- [Google GPS Measurement Tools](https://github.com/google/gps-measurement-tools)
  provides the core Android logger and MATLAB GNSS processing code included in
  this repository.
- The project was completed for the **AE60002 Satellite Navigation** course at
  the **Indian Institute of Technology Kharagpur**.
- Broadcast ephemeris data is obtained from the
  [BKG GNSS Data Center](https://igs.bkg.bund.de/).

The bundled Google source files retain their original Apache 2.0 notices. See
`gps-measurement-tools-master/LICENSE.txt` for the upstream license.

## License

The original work in this repository is available under the
[MIT License](LICENSE). Third-party code and binaries remain subject to their
respective licenses.
