#!/bin/sh

for i in $(seq 1 8)
do
  mkdir -p docker.local/miner"$i"
  sudo mkdir -p /mnt/ssd/miner"$i"/data/redis/state
  sudo mkdir -p /mnt/ssd/miner"$i"/data/redis/transactions
  sudo mkdir -p /mnt/ssd/miner"$i"/data/rocksdb
  sudo mkdir -p /mnt/ssd/miner"$i"/log
done