#!/bin/bash

##########################################################
#
# Domains config file for DynHover
# https://github.com/twiztedindian/hover-dyn-dns
# By: Vernon "Twizted" Gibson 
#
##########################################################

# Setup PATH environment variable for program binaries
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

# Import configs
source $(pwd)/config.cfg

# Setup usage prompt if incomplete command is used.
[[ $# -lt 5 ]] && echo "Usage: $0 USERNAME PASSWORD DOMAIN HOST_TYPE DNS_ID" && exit

# Create variables for command line arguments
USERNAME=${1}
PASSWORD=${2}
DOMAIN=${3}
HOST_TYPE=${4}
DNS_ID=${5}

# Create a variable for your current public IP address
# -m sets the max time in seconds before the request times out
# -s makes curl show an error message if it fails
ip=$(curl $cfg_ip -m 30 -s)

# This is where the magic happens!
# Here we have the function for making the curl call to Hover.com 
# which will set our IP for the selected DNS record and also store 
# the request response from the server for use later in the script.
curlDO() {
        curl "https://www.hover.com/api/dns/${DNS_ID}"  \
                -X PUT                                  \
                -d "content=${ip}"                      \
                -m 60                                   \
                -s                                      \
                -b <(curl "https://www.hover.com/signin"\
                        -X POST                         \
                        -G                              \
                        -d "username=${USERNAME}"       \
                        -d "password=${PASSWORD}"       \
                        -s                              \
                        -o /dev/null                    \
                        -c -)
}

# Setup email function in the event of an unsuccessful
# resonse from the server i.e. FALSE or Login Failure
# so we can send out an email to let someone know.
notify() {
    # Create a timestamp variable.
    timestamp=$( date +"%r on %m-%d-%Y" )

    # Send the email!
    sendemail \
	-f "$cfg_emailfrom" \
	-t "$cfg_emailto" \
	-u "DNS Update Failure: $DOMAIN" \
	-m "The DNS $HOST_TYPE host record for $DOMAIN failed at $timestamp\\n\\nIP Response: $ip\\n\\nHover API Response: $cURL" \
	-s "$cfg_emailsmtp" \
	-o "$cfg_emailsecurity" \
	-xu "$cfg_emailsmtpuser" \
	-xp "$cfg_emailsmtppass" \
	-l sendemail.log \
	-q
}

# Make the initial curl request and store the response in the $cURL variable
cURL=$(curlDO)

# Check to see if retry on error is configured to run and do it
if [[ "$cfg_curlretry" == "true" ]]; then
	RETRY=0

	# Setup WHILE loop to send curl request to Hover API
	# which will loop up to the configured amount of times
	# before aborting the script and sending notification email.
	while [[ $cURL != *"true"* && $RETRY -lt $cfg_curlretrys ]]
	do
	  # If we get a login error right off the bat we don't want 
	  # to keep trying and lock out our login credentials so we'll
	  # send an email to the administrator and kill the script
	    if [[ $cURL == *"login"* ]]; then
	      echo "Hover.com API login failure"
	      echo "Notifying domain administrator!"
	      $(notify)
	      echo "Email has been sent"
            echo "Aborting script to prevent lockout"
	      exit
        fi
		
	  # Incriment the RETRY variable
	  RETRY=$(( $RETRY + 1 ))
	  
	  # Echo some info to the terminal
	  echo "cURL request failed $RETRY times."
	  echo $cURL
	  
	  # Check if the script has reached it's max retry limit
	  if [[ $RETRY -ge $cfg_curlretrys ]]; then
		  echo "cURL requests have failed!"
		  # If set to email admin in config, send that email!
		  if [[ "$cfg_emailadmin" == "true" ]]; then
			echo "Notifying domain administrator!" 
			$(notify)
			echo "Email sent and aborting script!"
		  else
			echo "Aborting script!"
		  fi
		exit
	  fi
	  
	  # Sleep the script for an amount of time before retying
	  echo "Sleeping for "$cfg_curlsleep" seconds."
	  sleep $cfg_curlsleep
	  
	  # Retrying the curl request
	  cURL=$(curlDO)
	done
fi

# ECHO out the server response if for visual confirmation if you
# run the file directly in terminal rather than setting an
# unattended CRON job.
echo $cURL
