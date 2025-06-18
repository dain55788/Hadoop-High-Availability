#!/bin/bash

# Delete snapshots, disable snapshots and delete data for cluster1 and 2
echo "At $(date '+%s'): Deleting snapshots..." >> ../logs/snapshot_recovery_logs.txt
docker exec namenode1 hdfs dfs -ls /yellow-tripdata/parquet/.snapshot/ | grep "yellow_tripdata_snapshots" | awk '{print $8}' | while read cluster1_snapshot_path; do
    cluster1_snapshot_name=$(basename $cluster1_snapshot_path)
    docker exec namenode1 hdfs dfs -deleteSnapshot /yellow-tripdata/parquet "$cluster1_snapshot_name"
done

docker exec namenode_backup hdfs dfs -ls /yellow-tripdata-backup/parquet/.snapshot/ | grep "yellow_tripdata_snapshots" | awk '{print $8}' | while read cluster2_snapshot_path; do
    cluster2_snapshot_name=$(basename $cluster2_snapshot_path)
    docker exec namenode_backup hdfs dfs -deleteSnapshot /yellow-tripdata-backup/parquet "$cluster2_snapshot_name"
done

echo "- Successfully delete snapshots!!" >> ../logs/recovery_logs.txt

echo "At $(date): Disabling snapshots..." >> ../logs/recovery_logs.txt
docker exec -it namenode1 hdfs dfsadmin -disallowSnapshot /yellow-tripdata/parquet/
docker exec -it namenode_backup hdfs dfsadmin -disallowSnapshot /yellow-tripdata-backup/parquet/
echo "- Successfully disable snapshots!!"

# Delete data in the directories after disabling snapshots
echo "At $(date): Deleting data..." >> ../logs/recovery_logs.txt
docker exec -it namenode1 hdfs dfs -rm -skipTrash -r /yellow-tripdata/parquet/*
docker exec -it namenode_backup hdfs dfs -rm -skipTrash -r /yellow-tripdata-backup/parquet/*
echo "- Finish deleting the yellow trip data!" >> ../logs/recovery_logs.txt
echo "- Successfully delete yellow tripdata at ($date)!!" >> ../logs/recovery_logs.txt
