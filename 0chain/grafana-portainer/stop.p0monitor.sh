#!/bin/sh
set -e

echo Removing monitoring essentials ...

docker-compose -f docker-compose.yaml down
