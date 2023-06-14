#!/bin/sh
for i in $(seq 1 8)
do
  mkdir -p docker.local/sharder"$i"/data/blocks
  mkdir -p docker.local/sharder"$i"/data/rocksdb
  mkdir -p docker.local/sharder"$i"/log
  mkdir -p docker.local/sharder"$i"/data/postgresql
done