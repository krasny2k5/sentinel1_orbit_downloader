# Sentinel-1 Precise Orbit Downloader
Joaquin Escayo Menendez j.escayo@csic.es

This is a very simple script to download all orbit files and antenna calibration files for Sentinel-1.
It runs in any modern Linux distribution and uses bash and other command line tools.
Download folder must be configured before executing it, edit sentinel1_orbit_downloader.sh and modify DOWN_DIR variable.
It's intended for use within cron daemon, so no output by default to avoid spam on the email.

Note: I found out that some orbits from March 2015 are missing in Sentinels-1 QC, so I uploaded and can be downloaded from my GitHub repo, https://github.com/krasny2k5/sentinel1_orbit_downloader

Version history:
v 1.0 - Initial release
v 2.0 - Included the download of Antenna calibration files (AUX_CAL)

Your comments and suggestions are welcome
