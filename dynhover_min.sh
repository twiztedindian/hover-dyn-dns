#!/bin/bash

##########################################################
#
# Domains config file for DynHover
# https://github.com/twiztedindian/hover-dyn-dns
# By: Vernon "Twizted" Gibson 
#
##########################################################

[[ $# -lt 3 ]] && echo "Usage: $0 USERNAME PASSWORD DNS_ID"

USERNAME=${1}
PASSWORD=${2}
DNS_ID=${3}

IP=$(curl "http://ifconfig.me/ip" -s)

curl "https://www.hover.com/api/dns/${DNS_ID}" \
     -X PUT            \
     -d "content=${IP}" \
     -s                \
     -b <(curl "https://www.hover.com/api/signin" \
               -X POST                   \
               -G                        \
               -d "username=${USERNAME}" \
               -d "password=${PASSWORD}" \
               -s                        \
               -o /dev/null              \
               -c -)

echo
