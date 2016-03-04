#!/bin/bash

##########################################################
#
# Domains config file for DynHover
# https://github.com/twiztedindian/hover-dyn-dns
# By: Vernon "Twizted" Gibson
#
##########################################################

GLOBIGNORE="*"

# Import configs
source $(pwd)/config.cfg

# Set variable for CRON job
CRON=$(pwd)/run.sh
# Choose the interval in config
# Default: Run every 15 minutes
JOB="0,15,30,45 * * * *	$CRON"

# The following will as a yes|no question if you want to install the CRON job or not
# If you select yes, the script will look to see if the command already exists, then
# it will omit it in the re-write of the crontab
read -p "Install Dynamic Hover CRON job? (y/n)?" choice
case "$choice" in
  y|Y ) echo "Writing new CRON job!" && cat <(fgrep -i -v "$CRON" <(crontab -l)) <(echo "$JOB") | crontab -;;
  n|N ) echo "Aborting script.\n Please run this script again if you want to install the CRON job for Dynamic Hover." \
        && echo "Alternatively, you can add the CRON job manually through crontab -e" \
        && echo "And append the following line to the end of the file" \
        && echo " " \
        && echo $JOB \
        && echo " " \
        && echo "Exiting Script!"
        exit;;
  * ) echo "Invalid option, aborting script!" && exit;;
esac
