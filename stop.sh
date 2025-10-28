#!/usr/bin/env bash

LAB_DIR=$(realpath "$(dirname "$0")/..")
cd "$LAB_DIR"

# Remove controller
podman rm -f ansible_controller

# Remove all nodes matching pattern lab_node*
podman rm -f $(podman ps -a --filter name=lab_node* -q)

# Remove network
podman network rm lab_network

echo "Containers and network removed."