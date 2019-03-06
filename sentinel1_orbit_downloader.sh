#!/bin/bash
################################################
#      Sentinel-1 Precise Orbit downloader
#     Joaquin Escayo 2019 j.escayo@csic.es
###############################################
# Version 3.0
# Requisites: bash, wget, sed, sort (preinstalled)
# Recommended use of cron to schedule the execution
# Version History:
# v 1.0 - Initial release
# v 2.0 - Now it also download EAP Phase calibration files. Bugfixes. (18/10/2016)
# v 3.0 - Fixed the problem with ESA changes in the html format from mid 2018. Some code cleanup and translation (6/3/2019)
# TO-DO:
# 1. Detection of corrupted files (incompleted downloads)

###############################
#  CONFIGURATION PARAMETERS   #
###############################
# Download directory:
# Uncomment this line and set the correct directory
DOWN_DIR="/home/subsidence/sar-db2/sentinel_precise_orbits/" # directory for store precise orbits files
CAL_DIR="/home/subsidence/sar-db2/sentinel_aux_cal/" # directory for store AUX_CAL files, uncomment if you want to download this data or leave it commented to skip aux_cal data.
# number of pages to check
PAGES=20 # Pages for precise orbits. Increase to a big number for the first run, after that lower to 10-20 for faster execution
CAL_PAGES=4 # Calibration pages, as March 2019 there are only 4 pages.
DEBUG=false # Set to true to copy temporal files into the download directory

###############################
#        TEMPORAL FILES       #
###############################
# HTML index from ESA server
index=$(mktemp /tmp/s1index.XXXXX)
# Remote files without filtering
remote_files=$(mktemp /tmp/s1remote.XXXXX)
# Files to download
dw_list=$(mktemp /tmp/s1dw.XXXXX)
# Already downloaded orbit files
local_files=$(mktemp /tmp/s1no.XXXXX)

###############################
#      SCRIPT EXECUTION       #
###############################
# Cleanup function to remove temporal files
function cleanup {
    rm $index
    rm $remote_files
    rm $dw_list
    rm $local_files
}

# check if download directory is set
if [ -z ${DOWN_DIR+x} ]; then
    echo "#######################################################"
    echo "You must set download directory before use this program"
    echo "Edit sentinel1_orbit_downloader.sh and set the value of"
    echo "DOWN_DIR and CAL_DIR variables"
    echo "#######################################################"
    cleanup
    exit
fi

# check if CAL_DIR exists
if [ ! -d "$CAL_DIR" ] && [ ! -z "$CAL_DIR" ]; then
  mkdir $CAL_DIR
fi

# Orbits download

for i in $(eval echo "{1..$PAGES}")
do
	wget --quiet -O - --no-check-certificate https://qc.sentinel1.eo.esa.int/aux_poeorb/?page=$i >> $index
done
# Generate a file list to download
# The address of the file is filtered
cat $index | grep EOF | sed -e 's/.*href="\(.*\)\".*/\1/' > $remote_files # Improved url detection

# Check that the remote_files file is not empty
if ! [ -s $remote_files ]
then
    echo "ERROR OCURRED, NO REMOTE FILES FOUND"
    cleanup
    exit
fi

# Removal of the already downloaded files

if [ "$(ls -A $DOWN_DIR)" ]; then
    find $DOWN_DIR/*.EOF -printf "%f\n" > $local_files
    grep -vf $local_files $remote_files > $dw_list
else
  cp $remote_files $dw_list
fi

# File download
wget --quiet --no-check-certificate -P $DOWN_DIR -i $dw_list

if $DEBUG; then
    cp $index POEORB_index
    cp $remote_files POEORB_remote_files
    cp $dw_list POEORB_dw_list
    cp $local_files POEORB_local_files
fi

# Cleaning of the temporal files
cat /dev/null > $index
cat /dev/null > $remote_files
cat /dev/null > $dw_list
cat /dev/null > $local_files

#####################
# Calibration files #
#####################

if [ -z "$CAL_DIR" ]; then
    cleanup
    exit
fi

for i in $(eval echo "{1..$CAL_PAGES}")
do
	wget --quiet -O - --no-check-certificate https://qc.sentinel1.eo.esa.int/aux_cal/?page=$i >> $index
done

# Generating Remote file-list 
cat $index | grep SAFE.TGZ | sed -e 's/.*href="\(.*\)\".*/\1/' > $remote_files

# Test for empty $remote_files file
if ! [ -s $remote_files ]
then
    echo "ERROR OCURRED, NO REMOTE FILES FOUND"
    cleanup
    exit
fi

# removal of the already downloaded files

if [ "$(ls -A $CAL_DIR)" ]; then
    find $CAL_DIR/*.TGZ -printf "%f\n" > $local_files
    grep -vf $local_files $remote_files > $dw_list
else
    cp $remote_files $dw_list
fi

# DEBUG OF FILES
if $DEBUG; then
    cp $index AUXCAL_index
    cp $remote_files AUXCAL_remote_files
    cp $dw_list AUXCAL_dw_list
    cp $local_files AUXCAL_local_files
fi

# Data downloading
wget --quiet --no-check-certificate -P $CAL_DIR -i $dw_list


###############################
#          CLEANUP            #
###############################
cleanup




