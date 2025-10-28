#!/usr/bin/env bash

set -eu

LAB_DIR=$(realpath "$(dirname "$0")")
cd "$LAB_DIR"

if [ ! -d "scripts" ]; then
  echo "Error: current directory is incorrect. This script should be run from the lab/ directory"
  exit 1
fi

# Read the stored node count, default to 2 if file doesn't exist
if [ -f ".node_count" ]; then
    NODE_COUNT=$(cat .node_count)
    echo "Restarting with previously used node count: $NODE_COUNT"
else
    NODE_COUNT=2
    echo "No previous node count found, using default: $NODE_COUNT"
fi

echo "Stopping containers..."
./stop.sh

echo "Rebuilding images..."
./scripts/build-images.sh

echo "Starting containers with $NODE_COUNT nodes..."
./start.sh $NODE_COUNT

echo "Lab environment has been restarted successfully with $NODE_COUNT nodes!"