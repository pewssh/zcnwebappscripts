#!/bin/bash

#Setting latest docker image wrt latest release
export TAG=$(curl -s https://registry.hub.docker.com/v2/repositories/0chaindev/blobber/tags?page_size=100 | jq -r '.results[] | select(.name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$")) | .name' | sort -V | tail -n 1)
export PROJECT_ROOT=/var/0chain/blobber

echo "Updating blobber and validator with $TAG tag "

echo "Installing yq"
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 || true
sudo chmod a+x /usr/local/bin/yq || true

echo "Updating docker-compose.yaml file"
yq e -i ".services.validator.image = \"0chaindev/validator:${TAG}\"" ${PROJECT_ROOT}/docker-compose.yml
yq e -i ".services.blobber.image = \"0chaindev/blobber:${TAG}\"" ${PROJECT_ROOT}/docker-compose.yml

echo "Pull $TAG tag from repo."
/usr/local/bin/docker-compose -f ${PROJECT_ROOT}/docker-compose.yml pull

echo "Updating blobber and validator"
/usr/local/bin/docker-compose -f ${PROJECT_ROOT}/docker-compose.yml up -d
