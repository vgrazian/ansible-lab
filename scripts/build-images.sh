#!/usr/bin/env bash

set -eu

LAB_DIR=$(realpath "$(dirname "$0")/..")
cd "$LAB_DIR"
echo "Building container images in lab directory: $LAB_DIR"

if [ ! -d "Containerfiles" ]; then
  echo "Error: current directory is incorrect. This script should be run from the lab/ directory"
  exit 1
fi

# Generate SSH keys if they don't exist
if [ ! -f "keys/id_rsa" ]; then
  ssh-keygen -t rsa -N "" -f keys/id_rsa
fi

# Copy SSH keys to build contexts
cp keys/id_rsa Containerfiles/controller/
cp keys/id_rsa.pub Containerfiles/controller/
cp keys/id_rsa.pub Containerfiles/node/
cp keys/id_rsa.pub Containerfiles/node/authorized_keys

# Build images
podman build -t lab_ansible_controller ./Containerfiles/controller
podman build -t lab_node ./Containerfiles/node

# Clean up keys from build contexts
rm Containerfiles/controller/id_rsa*
rm Containerfiles/node/id_rsa*
rm Containerfiles/node/authorized_keys