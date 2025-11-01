#!/bin/bash
# Scales GPU node group on/off for cost control

CLUSTER_NAME="agentic-cluster"
NODEGROUP_NAME="gpu_nodes"
REGION="us-east-1"

ACTION=$1

if [ "$ACTION" == "up" ]; then
  echo "Scaling GPU nodes up..."
  aws eks update-nodegroup-config --cluster-name $CLUSTER_NAME \
      --nodegroup-name $NODEGROUP_NAME --scaling-config minSize=1,maxSize=2,desiredSize=1 --region $REGION
elif [ "$ACTION" == "down" ]; then
  echo "Scaling GPU nodes down..."
  aws eks update-nodegroup-config --cluster-name $CLUSTER_NAME \
      --nodegroup-name $NODEGROUP_NAME --scaling-config minSize=0,maxSize=2,desiredSize=0 --region $REGION
else
  echo "Usage: ./scale_gpu.sh up|down"
fi
