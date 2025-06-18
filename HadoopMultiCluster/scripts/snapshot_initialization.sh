#!/bin/bash

# Initialize snapshot for cluster1 and 2
DATETIME=$(date +'%Y%m%d_%H%M%S')
echo "At $(date): Enabling snapshot ..." >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode1 hdfs dfsadmin -allowSnapshot /yellow-tripdata/parquet/
docker exec -it namenode_backup hdfs dfsadmin -allowSnapshot /yellow-tripdata-backup/parquet

echo "- Successfully allow snapshot at $(date)" >> ../logs/snapshot_recovery_logs.txt

echo "- Current snapshottable directories: " >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode1 hdfs lsSnapshottableDir >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode_backup hdfs lsSnapshottableDir >> ../logs/snapshot_recovery_logs.txt

echo "At $(date): Creating snapshot for the yellow tripdata..." >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode1 hdfs dfs -createSnapshot /yellow-tripdata/parquet "yellow_tripdata_snapshots_$DATETIME"
docker exec -it namenode_backup hdfs dfs -createSnapshot /yellow-tripdata-backup/parquet "yellow_tripdata_snapshots_$DATETIME"

docker exec -it namenode1 hdfs lsSnapshottableDir >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode_backup hdfs lsSnapshottableDir >> ../logs/snapshot_recovery_logs.txt

sleep 5

echo "- Successfully creating and initializing snapshots at $(date)!!" >> ../logs/snapshot_recovery_logs.txt
