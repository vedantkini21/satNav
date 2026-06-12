WARNING: This script is only for downloading the ephemeris form the "BKG server", 
         not for the NASA Server (CD... something). Read the Error message in "GNSS Analysis Tools" closely

Steps to download the correct ephemeris files:
-> Run the "customBKGEphemerisDownloader.py" File.
-> Enter the file names that are required (i.e. the error is coming from absence of the particular files)
    in the comma(",") separated or space separated fashion or just paste the file name and enter the again paste the file name and enter. when you have to terminate the list enter the last filename "-1".
    Example: 
    1. BRDC00WRD_R_20261090000_01D_EN.rnx.gz, BRDC00WRD_R_20261090000_01D_CN.rnx.gz, -1
    2. BRDC00WRD_R_20261090000_01D_EN.rnx.gz BRDC00WRD_R_20261090000_01D_CN.rnx.gz -1
    3. BRDC00WRD_R_20261090000_01D_EN.rnx.gz
       BRDC00WRD_R_20261090000_01D_CN.rnx.gz
       -1
    etc.

-> After entering the filenames correctly. The script will download and generate the required ephemeris files
    in the same folder as the script location.
-> copy those ephemeris files from here and paste in to your analysis files folder (i.e. where your raw data file from the GNSSLogger is selected.)

Voila!!
Now hopefully the Error message will be gone and you will see the nice plots that you are waiting for.

Made by Dheeraj. (By considering your and my dukh dard peeda. 😂❤️)