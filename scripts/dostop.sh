#!/usr/bin/env bash

LAB_DIR=$(realpath "$(dirname "$0")/..")
cd "$LAB_DIR"

# EDIT THIS LINE IF YOU HAVE MORE NODES
podman rm -f ansible_controller lab_node1 lab_node2

podman network rm lab_network

echo "Containers and network removed."