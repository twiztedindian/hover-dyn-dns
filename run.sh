#!/bin/bash

##########################################################
#
# Domains config file for DynHover
# https://github.com/twiztedindian/hover-dyn-dns
# By: Vernon "Twizted" Gibson 
#
##########################################################

# Import configs
source $(pwd)/config.cfg

# Change to the directory containing the dynhover.sh script
cd $cfg_dynhoverpath

# Setup array of 'domain.tld;host_type;dns_record' to be updated
declare -A domains

# Import domains array from dynhover.domains
source $(pwd)/domains.cfg

# Iterate through domains array to run dynhover.sh with required arguments
for i in "${domains[@]}"
do
        arr=(${i//;/ })
        domain=${arr[0]}
        host_type=${arr[1]}
        dns_id=${arr[2]}
        ./dynhover.sh $cfg_hoveruser $cfg_hoverpass $domain $host_type $dns_id
done

