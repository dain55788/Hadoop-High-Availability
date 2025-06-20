#!/bin/bash

# DATA BACKUP PIPELINE

# Create Snapshot in Cluster
echo "At $(date): Starting backing up data from cluster1 to backup cluster..." >> /logs/backup_pipeline_logs.txt
echo "At $(date): Creating snapshot in cluster1 ..." >> /logs/backup_pipeline_logs.txt
DATETIME=$(date +'%Y%m%d_%H%M%S')
docker exec namenode1 hdfs dfs -createSnapshot /yellow-tripdata/parquet "yellow_tripdata_snapshots_$DATETIME"
echo "At $(date): Finished creating snapshot!!" >> /logs/backup_pipeline_logs.txt

# DistCp copy snapshot to Cluster2
echo "At $(date): Distributed incremental copy snapshotted file from cluster1 to cluster2..." >> /logs/backup_pipeline_logs.txt
LATEST_SNAPSHOT=$(docker exec namenode1 hdfs dfs -ls /yellow-tripdata/parquet/.snapshot/ | grep "yellow_tripdata_snapshots_" | awk '{print $8}' | sort | tail -1)
docker exec namenode1 hadoop distcp -m 10 -update hdfs://namenode1:9000/"$LATEST_SNAPSHOT" hdfs://namenodebackup:9010/yellow-tripdata-backup/parquet
echo "At $(date): Finished copying data!!" >> /logs/backup_pipeline_logs.txt

# Delete old history snapshots
echo "At $(date): Deleting old history snapshot..." >> /logs/backup_pipeline_logs.txt 
docker exec namenode1 hdfs dfs -deleteSnapshot /yellow-tripdata/parquet \
$(docker exec namenode1 hdfs dfs -ls /yellow-tripdata/parquet/.snapshot/ | grep "^d" | awk '{print $8}' | xargs -I {} basename {} | sort | head -n 1 | tr -d '\r\n' | xargs)
