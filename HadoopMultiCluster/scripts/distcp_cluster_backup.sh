
#!/bin/bash

# Trigger Distributed Copy (DistCp) between 2 namenodes/ hadoop clusters
echo "At $(date): Starting synchronizing yellow tripdata on schedule..." >> ../logs/distcp_backup_logs.txt
docker exec namenode1 hadoop distcp -m 10 -update hdfs://namenode1:9000/yellow-tripdata/parquet hdfs://namenodebackup:9010/yellow-tripdata-backup/parquet
echo "At $(date): Finished backing up & synchronizing data!!" >> ../logs/distcp_backup_logs.txt
