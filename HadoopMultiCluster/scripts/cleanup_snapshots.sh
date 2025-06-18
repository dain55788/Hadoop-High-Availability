#!/bin/bash

# Cleanup old snapshots for more effective storage
KEEP_COUNT=12  # Keep 12 lastest snapshots
docker exec namenode1 hdfs dfs -ls /yellow-tripdata/parquet/.snapshot |
  tail -n +2 | tail -n +$((KEEP_COUNT+1)) |
  awk '{print $NF}' | sed 's|.*/||' |
  while read snapshot; do
    docker exec namenode1 hdfs dfs -deleteSnapshot /yellow-tripdata/parquet $snapshot
  done

docker exec namenode_backup hdfs dfs -ls /yellow-tripdata-backup/parquet/.snapshot |
  tail -n +2 | tail -n +$((KEEP_COUNT+1)) |
  awk '{print $NF}' | sed 's|.*/||' |
  while read snapshot; do
    docker exec namenode_backup hdfs dfs -deleteSnapshot /yellow-tripdata-backup/parquet $snapshot
  done
