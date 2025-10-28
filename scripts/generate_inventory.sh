#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR=$(realpath "$(dirname "$0")")
LAB_DIR=$(realpath "${SCRIPT_DIR}/..")
NODE_COUNT=$1
INVENTORY_FILE="${LAB_DIR}/ansible/inventory"

# Create ansible directory if it doesn't exist
mkdir -p "${LAB_DIR}/ansible"

# Generate inventory content
{
    echo "[nodes]"
    for i in $(seq 1 "$NODE_COUNT"); do
        echo "lab_node${i}"
    done
} > "$INVENTORY_FILE"

chmod 644 "$INVENTORY_FILE"

echo "Generated inventory with $NODE_COUNT nodes at $INVENTORY_FILE"