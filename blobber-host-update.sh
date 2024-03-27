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
export BLOBBER_ID=0chainblobberid

# export PROJECT_ROOT_SSD=/var/0chain/blobber/ssd
# export PROJECT_ROOT_HDD=/var/0chain/blobber/hdd

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Check if blob_wallet.json wallet file exists or not.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  if [[ -f blob_wallet.json ]] ; then
    echo "blob_wallet.json is present"
  else
    echo "Didn't found blob_wallet.json file. Kindly place the file at location ${PROJECT_ROOT}/blob_wallet.json and rerun the script again"
    exit 1
  fi
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                        Downloading zbox binary.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  echo "generating config.yaml file"
  echo "block_worker: https://mainnet.zus.network/dns" > config.yaml
  echo "signature_scheme: bls0chain" >> config.yaml
  echo "min_submit: 20" >> config.yaml
  echo "min_confirmation: 20" >> config.yaml
  echo "confirmation_chain_length: 3" >> config.yaml
  echo "max_txn_query: 5" >> config.yaml
  echo "query_sleep_time: 5" >> config.yaml
  sleep 5s

  if [[ -f bin/zbox ]] ; then
      echo "zbox binary already present"
  else
      ubuntu_version=$(lsb_release -rs | cut -f1 -d'.')
      if [[ ${ubuntu_version} -eq 18 ]]; then
          echo "Ubuntu 18 is not supported"
          exit 1
      elif [[ ${ubuntu_version} -eq 20 || ${ubuntu_version} -eq 22 ]]; then
          wget https://github.com/0chain/zcnwebappscripts/raw/as-deploy/0chain/zwallet-binary/zbox
          mkdir bin || true
          sudo mv zbox ${PROJECT_ROOT}/bin/
          sudo chmod +x bin/zbox
      else
          echo "Didn't found any Ubuntu version with 20/22."
          exit 1
      fi
  fi
popd > /dev/null;

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
                                                                            Updating URL on mainnet chain
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  ./bin/zbox bl-update --blobber_id ${BLOBBER_ID} --url https://${BLOBBER_HOST_NEW_URL}/ --wallet ./blob_del.json --configDir . --config ./config.yaml
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Blobber must be available on the new url now.
===============================================================================================================================================================================  \e[39m"
echo "Blobber host url updation completed."
echo "Blobber is available on url --> https://${BLOBBER_HOST_NEW_URL}/_stats"
