#!/bin/bash

# DistCp Recovery from incident
echo "=== INCIDENT STIMULATOR ===" >> ../logs/distcp_recovery_logs.txt
DATETIME=$(date +'%Y%m%d_%H%M%S')

# Receive new data after the last backup
echo "At $(date): Receiving new yellow tripdata 2023..." >> ../logs/distcp_recovery_logs.txt
docker exec -it namenode1 hdfs dfs -put data/nyc_taxi_tripdata_parquet/yellow-tripdata-2023/ /yellow-tripdata/parquet/
echo "At $(date): Added new data to HDFS" >> ../logs/distcp_recovery_logs.txt

current_size=$(docker exec -it namenode1 hdfs dfs -du -s /yellow-tripdata/parquet/)
actual_size=$(echo "$current_size" | awk '{print $1}' | tr -d '\r')
actual_size_mb=$(echo "scale=2; $actual_size / 1048576" | bc)
bf_incident_size=$actual_size_mb

echo "At $(date): Data size BEFORE INCIDENT = $actual_size_mb MB" >> ../logs/distcp_recovery_logs.txt
echo "" >> ../logs/distcp_recovery_logs.txt

sleep 3

echo "At $(date): Starting delete data in Cluster1 HDFS..." >> ../logs/distcp_recovery_logs.txt

# Delete snapshots, disable snapshots and delete data
echo "At $(date): Deleting snapshots..." >> ../logs/distcp_recovery_logs.txt
docker exec namenode1 hdfs dfs -ls /yellow-tripdata/parquet/.snapshot/ | grep "yellow_tripdata_snapshots" | awk '{print $8}' | while read cluster1_snapshot_path; do
    cluster1_snapshot_name=$(basename $cluster1_snapshot_path)
    docker exec namenode1 hdfs dfs -deleteSnapshot /yellow-tripdata/parquet "$cluster1_snapshot_name"
done
echo "- Successfully delete snapshots!!" >> ../logs/distcp_recovery_logs.txt

echo "At $(date): Disabling snapshots..." >> ../logs/distcp_recovery_logs.txt
docker exec -it namenode1 hdfs dfsadmin -disallowSnapshot /yellow-tripdata/parquet/
echo "- Successfully disable snapshots!!" >> ../logs/distcp_recovery_logs.txt

INCIDENT_TIMESTAMP=$(date '+%s')
echo "" >> ../logs/distcp_recovery_logs.txt

# Delete data in the directories after disabling snapshots
echo "At $(date): Deleting data..." >> ../logs/distcp_recovery_logs.txt
docker exec -it namenode1 hdfs dfs -rm -skipTrash -r /yellow-tripdata/parquet/*
echo "- Finish deleting yellow tripdata at ($date)!!" >> ../logs/distcp_recovery_logs.txt

# DistCp recovery from Cluster2 to Cluster1
echo "At $(date): Start data recovery process for the main cluster..." >> ../logs/distcp_recovery_logs.txt
RECOVERY_START_TIME=$(date '+%s')

echo "At $(date): Start recovering data..." >> ../logs/distcp_recovery_logs.txt
docker exec -it namenode_backup hadoop distcp -m 10 -update hdfs://namenodebackup:9010/yellow-tripdata-backup/parquet/ hdfs://namenode1:9000/yellow-tripdata/parquet/
echo "- Successfully recover data!!" >> ../logs/distcp_recovery_logs.txt

sleep 3
echo "" >> ../logs/distcp_recovery_logs.txt

echo "At $(date): Creating snapshots for the main cluster..." >> ../logs/distcp_recovery_logs.txt
docker exec -it namenode1 hdfs dfsadmin -allowSnapshot /yellow-tripdata/parquet/
echo "- Successfully allow snapshot at $(date)" >> ../logs/snapshot_recovery_logs.txt
echo "- Current snapshottable directories: " >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode1 hdfs lsSnapshottableDir >> ../logs/snapshot_recovery_logs.txt
echo "At $(date): Creating snapshot for the yellow tripdata..." >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode1 hdfs dfs -createSnapshot /yellow-tripdata/parquet "yellow_tripdata_snapshots_$DATETIME"

echo "At $(date): Recovering process finished successfully!!" >> ../logs/distcp_recovery_logs.txt
RECOVERY_END_TIMESTAMP=$(date '+%s')

# Calculate RTO and RPO of DistCp
recovered_size=$(docker exec -it namenode1 hdfs dfs -du -s /yellow-tripdata/parquet/)
actual_recovered_size=$(echo "$recovered_size" | awk '{print $1}' | tr -d '\r')
actual_recovered_size_mb=$(echo "scale=2; $actual_recovered_size / 1048576" | bc)
af_incident_size=$actual_recovered_size_mb
echo "At $(date): Data size AFTER INCIDENT = $actual_recovered_size_mb MB" >> ../logs/distcp_recovery_logs.txt

# Calculating RTO (Recovery Time Objective)
RTO_SECONDS=$((RECOVERY_END_TIMESTAMP - INCIDENT_TIMESTAMP))
RTO_MINUTES=$((RTO_SECONDS / 60))
echo "RTO in seconds = $RTO_SECONDS" >> ../logs/distcp_recovery_logs.txt
echo "RTO in minutes = $RTO_MINUTES" >> ../logs/distcp_recovery_logs.txt

# Calculating RPO (Recovery Point Objective)
lost_data=$(echo "scale=2; $bf_incident_size - $af_incident_size" | bc)
echo "Total RPO = $lost_data" >> ../logs/distcp_recovery_logs.txt
echo "" >> ../logs/distcp_recovery_logs.txt
