#!/bin/bash

# Initialize directories path for 2 clusters
echo "At $(date): Initializing directories for cluster1..." >> ../logs/distcp_backup_logs.txt
docker exec -it namenode1 hdfs dfs -mkdir /yellow-tripdata
docker exec -it namenode1 hdfs dfs -mkdir /yellow-tripdata/parquet
echo "- Initialized paths for cluster1" >> ../logs/distcp_backup_logs.txt
docker exec -it namenode_backup hdfs dfs -mkdir /yellow-tripdata-backup
docker exec -it namenode_backup hdfs dfs -mkdir /yellow-tripdata-backup/parquet
echo "- Initialized paths for cluster2" >> ../logs/distcp_backup_logs.txt
