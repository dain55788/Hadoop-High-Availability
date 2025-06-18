#!/bin/bash

# Disaster Script and Data Recovery
echo "" >> ../logs/snapshot_recovery_logs.txt
echo "=== DISASTER RECOVERY SNAPSHOT ===" >> ../logs/snapshot_recovery_logs.txt

# Receive new data after the last backup
echo "At $(date): Receiving new yellow tripdata 2023..." >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode1 hdfs dfs -put data/nyc_taxi_tripdata_parquet/yellow-tripdata-2023/ /yellow-tripdata/parquet/
echo "At $(date): Added new data to HDFS" >> ../logs/snapshot_recovery_logs.txt

current_size=$(docker exec -it namenode1 hdfs dfs -du -s /yellow-tripdata/parquet/)
actual_size=$(echo "$current_size" | awk '{print $1}' | tr -d '\r')
actual_size_mb=$(echo "scale=2; $actual_size / 1048576" | bc)
bf_incident_size=$actual_size_mb

echo "At $(date): Data size BEFORE INCIDENT = $actual_size_mb MB" >> ../logs/snapshot_recovery_logs.txt
echo "" >> ../logs/snapshot_recovery_logs.txt

sleep 5

# Delete critical data
echo "At $(date): Deleting data..." >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode1 hdfs dfs -rm -skipTrash -r /yellow-tripdata/parquet/*
echo "Finish deleting the $i yellow trip data!" >> ../logs/snapshot_recovery_logs.txt
echo "At $(date): Deleted yellow-tripdata!!" >> ../logs/snapshot_recovery_logs.txt
INCIDENT_TIMESTAMP=$(date '+%s')
echo "At $(date): Incident time stamp!!" >> ../logs/snapshot_recovery_logs.txt
echo "" >> ../logs/snapshot_recovery_logs.txt

# Recover data from the last backup (HDFS Snapshot)
RECOVERY_START_TIME=$(date)
LATEST_SNAPSHOT=$(docker exec namenode1 hdfs dfs -ls /yellow-tripdata/parquet/.snapshot/ | grep "yellow_tripdata_snapshots_" | awk '{print $8}' | sort | tail -1)
SNAPSHOT_NAME=$(basename "$LATEST_SNAPSHOT")
echo "At $(date): Starting recovery from $SNAPSHOT_NAME..." >> ../logs/snapshot_recovery_logs.txt
docker exec -it namenode1 hdfs dfs -cp "$LATEST_SNAPSHOT/*" /yellow-tripdata/parquet/

sleep 5

echo "At $(date): Successfully recover data at !!" >> ../logs/snapshot_recovery_logs.txt
echo "" >> ../logs/snapshot_recovery_logs.txt
RECOVERY_END_TIMESTAMP=$(date '+%s')

snapshot_size=$(docker exec -it namenode1 hdfs dfs -du -s /yellow-tripdata/parquet/)
actual_snapshot_size=$(echo "$snapshot_size" | awk '{print $1}' | tr -d '\r')
actual_snapshot_size_mb=$(echo "scale=2; $actual_snapshot_size / 1048576" | bc)
af_incident_size=$actual_snapshot_size_mb

echo "At $(date): Data size AFTER INCIDENT = $actual_snapshot_size_mb MB" >> ../logs/snapshot_recovery_logs.txt

# Calculating RTO (Recovery Time Objective)
RTO_SECONDS=$((RECOVERY_END_TIMESTAMP - INCIDENT_TIMESTAMP))
RTO_MINUTES=$((RTO_SECONDS / 60))

echo "RTO in seconds = $RTO_SECONDS" >> ../logs/snapshot_recovery_logs.txt
echo "RTO in minutes = $RTO_MINUTES" >> ../logs/snapshot_recovery_logs.txt

# Calculating RPO (Recovery Point Objective)
lost_data=$(echo "scale=2; $bf_incident_size - $af_incident_size" | bc)
echo "Total RPO = $lost_data" >> ../logs/snapshot_recovery_logs.txt
