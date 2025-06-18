#!/bin/bash

DATETIME=$(date +'%Y%m%d_%H%M%S')

# Run snapshot backup scheduled for cluster1 and cluster2
echo "At $(date): Start backing up snapshots..." >> /logs/snapshot_backup_logs.txt
echo "At $(date): Creating snapshot for both  cluster..." >> /logs/snapshot_backup_logs.txt
docker exec namenode1 hdfs dfs -createSnapshot /yellow-tripdata/parquet "yellow_tripdata_snapshots_$DATETIME"

echo "- Successfully create backup snapshot for both cluster!!" >> /logs/snapshot_backup_logs.txt

echo "At $(date): Creating snapshot for the second cluster..." >> /logs/snapshot_backup_logs.txt
docker exec namenode_backup hdfs dfs -createSnapshot /yellow-tripdata-backup/parquet/ "yellow_tripdata_snapshots_$DATETIME"
echo "- Successfully create backup snapshot for the second cluster!!" >> /logs/snapshot_backup_logs.txt

echo "At $(date): Finish backing up snapshot!!" >> /logs/snapshot_backup_logs.txt
