#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires sudo privileges. Please enter your password:"
  exec sudo "$0" "$@" # This re-executes the script with sudo
fi

# setup variables
export PROJECT_ROOT=/var/0chain/blobber
export BLOCK_WORKER_URL=0chainblockworker
export BLOBBER_HOST_OLD_URL=0chainblobberhostoldurl
export BLOBBER_HOST_NEW_URL=0chainblobberhostnewurl

# export PROJECT_ROOT_SSD=/var/0chain/blobber/ssd
# export PROJECT_ROOT_HDD=/var/0chain/blobber/hdd

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Put down all the running container in order to avoid data corruption.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  docker-compose -f docker-compose.yml down
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Updating blobber url into docker-compose.yml
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  sed -i "s|${BLOBBER_HOST_OLD_URL}|${BLOBBER_HOST_NEW_URL}|g" docker-compose.yml
  echo "docker-compose file updated."
  sleep 1s
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Updating blobber url into Caddyfile
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  sed -i "s|${BLOBBER_HOST_OLD_URL}|${BLOBBER_HOST_NEW_URL}|g" Caddyfile
  echo "Caddyfile updated."
  sleep 1s
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Starting all the containers with applied changes
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  docker-compose -f docker-compose.yml up -d
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Blobber must be available on the new url now.
===============================================================================================================================================================================  \e[39m"
echo "Blobber host url updation completed."
echo "Blobber is available on url --> https://${BLOBBER_HOST_NEW_URL}/_stats"
