# Sentinel-1 Precise Orbit Downloader
Joaquin Escayo Menendez j.escayo@csic.es

This is a very simple script to download all orbit files and antenna calibration files for Sentinel-1.
It runs in any modern Linux distribution and uses bash and other command line tools.
Download folder must be configured before executing it, edit sentinel1_orbit_downloader.sh and modify DOWN_DIR variable.
It's intended for use within cron daemon, so no output by default to avoid spam on the email.

## Installation:
1. Copy the file "sentinel1_orbit_downloader.sh" to anywhere in your system (recommended /usr/local/bin).

2. Give execution permissions to the file: chmod +x /path/to/sentinel1_orbit_downloader.sh (change /path/to/ with the path in your system)

3. Edit sentilel1_orbit_downloader.sh and modify the download directories (if CAL_DIR is not set no AUX_CAL data will be downloaded).

4. If you are running the program for the first time is recommended to increase the numer of pages to check to download the complete archive (like 100 pages). Modify the varaible PAGES.

5. Run the program by executing it in bash.

6. (optional) Add a line in crontab to run the program automatically, for example run "crontab -e" and add the following line: 
"15 6 3,17 * * /path/to/sentinel1_orbit_downloader.sh"
Will run the program each day 3th and 17th of the month at 6:15 AM.


## Version history:
v 1.0 - Initial release

v 2.0 - Included the download of Antenna calibration files (AUX_CAL)

v 2.1 - Minor revision, now download of AUX_CAL data is optional, directory must be set to download. (19/10/2016)

v 3.0 - Fixed the problem with ESA changes in the html format from mid 2018. Some code cleanup and translation (6/3/2019).

Your comments and suggestions are welcome, please let me know if you find out this script useful.
