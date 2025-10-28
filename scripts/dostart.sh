#!/usr/bin/env bash

LAB_DIR=$(realpath "$(dirname "$0")/..")
cd "$LAB_DIR"

if [ ! -d "scripts" ]; then
  echo "Error: current directory is incorrect. This script should be run from the lab/ directory"
  exit 1
fi

# Get number of nodes from first argument, default to 2
NODE_COUNT=${1:-2}

echo "Starting Ansible lab with $NODE_COUNT nodes..."

# Generate inventory file
scripts/generate_inventory.sh "$NODE_COUNT"

# Create network if it doesn't exist
if ! podman network exists lab_network; then
  podman network create lab_network
fi

# Start nodes
for i in $(seq 1 $NODE_COUNT); do
  echo "Starting node $i..."
  if [ $i -eq 1 ]; then
    podman run -d --name "lab_node$i" \
      --network lab_network \
      --cap-add=CAP_AUDIT_WRITE \
      --cap-add=CAP_AUDIT_CONTROL \
      --cap-add SYS_ADMIN \
      --device /dev/fuse \
      lab_node
  else
    podman run -d --name "lab_node$i" \
      --network lab_network \
      --cap-add=CAP_AUDIT_WRITE \
      --cap-add=CAP_AUDIT_CONTROL \
      lab_node
  fi
done

echo "Nodes started."

# Create welcome message
cat > "${LAB_DIR}/ansible/welcome.txt" << EOF
Welcome to your Ansible Lab Environment!

You have ${NODE_COUNT} nodes available for testing:
$(for i in $(seq 1 $NODE_COUNT); do echo "- lab_node$i"; done)

Try these example playbooks:
1. Simple ping test:
   ansible-playbook -i inventory playbooks/ping.yml

2. Test connectivity and get hostnames:
   ansible-playbook -i inventory playbooks/test.yml

Your playbooks are in the /ansible/playbooks directory.
EOF

# Start controller with ansible volume mounted and display welcome message
podman run -it --name ansible_controller \
  --network lab_network \
  --cap-add=CAP_AUDIT_WRITE \
  --cap-add=CAP_AUDIT_CONTROL \
  -v "${LAB_DIR}/ansible:/ansible:Z" \
  lab_ansible_controller /bin/bash -c "cat /ansible/welcome.txt && echo '' && exec /bin/bash"