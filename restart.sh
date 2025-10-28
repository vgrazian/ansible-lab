#!/usr/bin/env bash

set -eu

LAB_DIR=$(realpath "$(dirname "$0")")
cd "$LAB_DIR"

if [ ! -d "scripts" ]; then
  echo "Error: current directory is incorrect. This script should be run from the lab/ directory"
  exit 1
fi

echo "Stopping containers..."
./stop.sh

echo "Rebuilding images..."
./scripts/build-images.sh

echo "Starting containers..."
./start.sh

echo "Lab environment has been restarted successfully!"