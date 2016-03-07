#!/bin/bash
################################################
#      Sentinel-1 Precise Orbit downloader
#     Joaquin Escayo 2016 j.escayo@csic.es
###############################################
# Version 1.0
# Requisites: bash, wget, sed, sort (preinstalled)
# Recommended use of cron to schedule the execution
# TO-DO:
# 1. Detection of corrupted files (incompleted downloads)

###############################
#  CONFIGURATION PARAMETERS   #
###############################
# Download directory:
# Uncomment this line and set the correct directory
DOWN_DIR="."
# number of pages to check
PAGES=20

###############################
#        TEMPORAL FILES       #
###############################
# lista de archivos a descargar
list=$(mktemp /tmp/s1list.XXXXX)
# índice html
index=$(mktemp /tmp/s1index.XXXXX)
# lista de archivos en el servidor
remote_files=$(mktemp /tmp/s1remote.XXXXX)
# lista de archivos a descargar
dw_list=$(mktemp /tmp/s1dw.XXXXX)
# lista de archivos previamente descargados
local_files=$(mktemp /tmp/s1no.XXXXX)

###############################
#      SCRIPT EXECUTION       #
###############################

# check if download directory is set
if [ -z ${DOWN_DIR+x} ]; then
    echo "#######################################################"
    echo "You must set download directory before use this program"
    echo "Edit sentinel1_orbit_downloader.sh and set the value of"
    echo "DOWN_DIR variable"
    echo "#######################################################"
    exit
fi

for i in $(eval echo "{1..$PAGES}")
do
	wget --quiet -O - --no-check-certificate https://qc.sentinel1.eo.esa.int/aux_poeorb/?page=$i >> $index
done

# Generando la lista de ficheros a descargar
# Me quedo sólo con el nombre de los ficheros
grep -o '<a .*href=.*>' $index | grep 'EOF' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | sort -u > $remote_files

# compruebo que se haya generado correctamente la lista de archivos a descargar:
if ! [ -s $remote_files ]
then
    echo "ERROR OCURRED, NO REMOTE FILES FOUND"
    # cleanup
    rm $list
    rm $index
    rm $remote_files
    rm $dw_list
    rm $local_files
    exit
fi

# Elimino de la lista los archivos ya descargados

if [ "$(ls -A $DOWN_DIR)" ]; then
    ls $DOWN_DIR > $local_files
    awk 'NR==FNR{a[$0]=1;next}!a[$0]' $local_files $remote_files > $dw_list
else
    dw_list=$remote_files
fi

#Generando los enlaces
sed -i 's/^/https:\/\/qc.sentinel1.eo.esa.int\/aux_poeorb\//' $dw_list

wget --quiet --no-check-certificate -P $DOWN_DIR -i $dw_list

###############################
#          CLEANUP            #
###############################
rm $list
rm $index
rm $remote_files
rm $dw_list
rm $local_files




