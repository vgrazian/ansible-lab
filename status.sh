#!/usr/bin/env bash

LAB_DIR=$(realpath "$(dirname "$0")")
cd "$LAB_DIR"

if [ ! -d "scripts" ]; then
  echo "Error: current directory is incorrect. This script should be run from the lab/ directory"
  exit 1
fi

echo "=== Ansible Lab Status ==="
echo

# Check if Podman machine is running
if ! podman info >/dev/null 2>&1; then
    echo "❌ Podman machine is not running"
    echo "   Run: podman machine start"
    exit 1
fi

# Check network
if podman network exists lab_network; then
    echo "✅ Lab network is running"
else
    echo "❌ Lab network is not running"
fi

# Check controller
if podman ps --filter name=ansible_controller --format "{{.Names}}" | grep -q ansible_controller; then
    echo "✅ Ansible controller is running"
else
    echo "❌ Ansible controller is not running"
fi

# Check nodes
RUNNING_NODES=$(podman ps --filter name=lab_node* --format "{{.Names}}" | sort -V)
NODE_COUNT=$(echo "$RUNNING_NODES" | grep -c "lab_node" || true)

if [ "$NODE_COUNT" -gt 0 ]; then
    echo "✅ $NODE_COUNT node(s) running:"
    echo "$RUNNING_NODES" | sed 's/^/   - /'
else
    echo "❌ No nodes running"
fi

# Check stored node count
if [ -f "scripts/.node_count" ]; then
    STORED_COUNT=$(cat scripts/.node_count)
    echo
    echo "📊 Stored configuration:"
    echo "   Last used node count: $STORED_COUNT"
    
    if [ "$NODE_COUNT" -ne "$STORED_COUNT" ] && [ "$NODE_COUNT" -gt 0 ]; then
        echo "   ⚠️  Running node count ($NODE_COUNT) differs from stored count ($STORED_COUNT)"
    fi
fi

# Check inventory
if [ -f "ansible/inventory" ]; then
    INVENTORY_NODES=$(grep -c "lab_node" ansible/inventory || echo "0")
    echo
    echo "📁 Inventory file:"
    echo "   Configured nodes in inventory: $INVENTORY_NODES"
    
    if [ "$NODE_COUNT" -ne "$INVENTORY_NODES" ] && [ "$NODE_COUNT" -gt 0 ]; then
        echo "   ⚠️  Running nodes ($NODE_COUNT) differ from inventory ($INVENTORY_NODES)"
    fi
fi

echo
echo "=== Management Commands ==="
echo "Start lab: ./start.sh [node_count]"
echo "Stop lab: ./stop.sh"
echo "Restart lab: ./restart.sh"
echo "Rebuild images: ./scripts/build-images.sh"