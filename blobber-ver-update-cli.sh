#!/bin/bash

export PROJECT_ROOT=/var/0chain/blobber
export BLOBBER_ID=0chainblobberid

sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 || true
sudo chmod a+x /usr/local/bin/yq || true

if grep -qF "pebble" "${PROJECT_ROOT}/docker-compose.yml"; then
    echo "pebble path already present in blobber docker-compose file"
else
    echo "Adding pebble path to blobber docker-compose file."
    yq e -i '.services.blobber.volumes += ["/var/0chain/blobber/ssd//data/pebble/data:/pebble/data", "/var/0chain/blobber/ssd//data/pebble/wal:/pebble/wal"]' ${PROJECT_ROOT}/docker-compose.yml
fi

yq e -i ".services.validator.image = \"0chaindev/validator:v1.18.3\"" ${PROJECT_ROOT}/docker-compose.yml
yq e -i ".services.blobber.image = \"0chaindev/blobber:v1.18.3\"" ${PROJECT_ROOT}/docker-compose.yml
/usr/local/bin/docker-compose -f ${PROJECT_ROOT}/docker-compose.yml pull
/usr/local/bin/docker-compose -f ${PROJECT_ROOT}/docker-compose.yml up -d

sleep 10s

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Check if blob_wallet.json wallet file exists or not.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  if [[ -f blob_wallet.json ]] ; then
    echo "blob_wallet.json is present"
  else
    echo "Didn't found blob_wallet.json file. Kindly place the file at location ${PROJECT_ROOT}/blob_wallet.json and rerun the script again"
    # exit 1
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
popd > /dev/null;


echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Updating blobber storage version on mainnet chain
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
  ./bin/zbox bl-update --storage_version 1 --blobber_id ${BLOBBER_ID} --wallet blob_wallet.json --config ./config.yaml --configDir .
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Blobber must be available on the new url now.
===============================================================================================================================================================================  \e[39m"
echo "Kindly check Blobber should available on url."
