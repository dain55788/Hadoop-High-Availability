#!/bin/bash

cd ..
cd cluster1
cd docker-hadoop


# Run zookeeper, journalnode1 2 3
docker compose -f cluster1-docker-compose.yml up -d zookeeper journalnode1 journalnode2 journalnode3

sleep 3

# Run namenode1
echo "Running namenode1..."
docker compose -f cluster1-docker-compose.yml up -d namenode1

sleep 5

# Format ZKFC
echo "Formatting ZKFC..."
docker exec -it namenode1 hdfs zkfc -formatZK

sleep 2

# Run namenode2
docker compose -f cluster1-docker-compose.yml up -d namenode2

sleep 3

# Bootstrap Standby namenode
echo "Bootstrapping standby namenode for sync edit logs... "
docker exec -it namenode2 hdfs namenode -bootstrapStandby -nonInteractive

docker restart namenode2

sleep 3

# Run zkfc1 and 2
echo "Composing up zkfc1 and zkfc2..."
docker compose -f cluster1-docker-compose.yml up -d zkfc1 zkfc2

sleep 5

# Run the remaining services
echo "Run other services..."
docker compose -f cluster1-docker-compose.yml up -d
