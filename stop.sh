#!/usr/bin/env bash

LAB_DIR=$(realpath "$(dirname "$0")/..")
cd "$LAB_DIR"

# Remove controller
podman rm -f ansible_controller

# Remove all nodes matching pattern lab_node*
podman rm -f $(podman ps -a --filter name=lab_node* -q)

# Remove network
podman network rm lab_network

# Remove node count file if it exists
if [ -f "scripts/.node_count" ]; then
    rm scripts/.node_count
fi

echo "Containers, network, and configuration removed."