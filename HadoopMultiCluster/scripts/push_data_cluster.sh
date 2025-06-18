#!/bin/bash

# Push data from local to HDFS Cluster 1 and 2
echo "At $(date): Pushing data from local to hdfs..." >> ../logs/snapshot_recovery_logs.txt
for i in {2017..2022}; do
        echo "- Processing year $i" >> ../logs/snapshot_recovery_logs.txt
        docker exec -it namenode1 hdfs dfs -put data/nyc_taxi_tripdata_parquet/yellow-tripdata-$i/ /yellow-tripdata/parquet/
        echo "Pushed $i yellow trip data" >> ../logs/snapshot_recovery_logs.txt
done
sleep 10
echo "Pushed data to cluster1 !!" >> ../logs/snapshot_recovery_logs.txt

for i in {2017..2022}; do
        echo "- Processing year $i" >> ../logs/snapshot_recovery_logs.txt
        docker exec -it namenode_backup hdfs dfs -put data/nyc_taxi_tripdata_parquet/yellow-tripdata-$i/ /yellow-tripdata-backup/parquet/
        echo "Pushed $i yellow trip data" >> ../logs/snapshot_recovery_logs.txt
done
sleep 10
echo "Pushed date to cluster2 !!" >> ../logs/snapshot_recovery_logs.txt

echo "At $(date): Successfully pull data from local to hdfs cluster!!" >> ../logs/snapshot_recovery_logs.txt
