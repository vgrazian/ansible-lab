#!/usr/bin/env bash

LAB_DIR=$(realpath "$(dirname "$0")")
cd "$LAB_DIR"

if [ ! -d "scripts" ]; then
  echo "Error: current directory is incorrect. This script should be run from the lab/ directory"
  exit 1
fi

# Pass the first argument (number of nodes) to dostart.sh, default to 2 if not specified
NODE_COUNT=${1:-2}
scripts/dostart.sh $NODE_COUNT