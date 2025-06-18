#!/bin/bash

# Deploy Namenode HA recovery
docker stop namenode1
sleep 90
docker start namenode1
