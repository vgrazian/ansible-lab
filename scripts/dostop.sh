#!/usr/bin/env bash

LAB_DIR=$(realpath "$(dirname "$0")/..")
cd "$LAB_DIR"

# Remove controller and all lab nodes dynamically
podman rm -f ansible_controller
podman rm -f $(podman ps -a --filter name=lab_node* -q)

podman network rm lab_network

echo "Containers and network removed."