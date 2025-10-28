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

# Clean up any existing nodes with the same names first
echo "Cleaning up any existing containers..."
for i in $(seq 1 $NODE_COUNT); do
  if podman ps -a --filter name="lab_node$i" --format "{{.Names}}" | grep -q "lab_node$i"; then
    echo "Removing existing container: lab_node$i"
    podman rm -f "lab_node$i" >/dev/null 2>&1
  fi
done

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

# Start controller (clean up any existing one first)
if podman ps -a --filter name=ansible_controller --format "{{.Names}}" | grep -q ansible_controller; then
  echo "Removing existing ansible_controller container..."
  podman rm -f ansible_controller >/dev/null 2>&1
fi

# Generate welcome message completely inside the container
podman run -it --name ansible_controller \
  --network lab_network \
  --cap-add=CAP_AUDIT_WRITE \
  --cap-add=CAP_AUDIT_CONTROL \
  -v "${LAB_DIR}/ansible:/ansible:Z" \
  lab_ansible_controller /bin/bash -c "
    # Generate welcome message dynamically
    NODE_COUNT=\$(grep -c 'lab_node' /ansible/inventory)
    
    cat > /tmp/welcome.txt << EOF
Welcome to your Ansible Lab Environment!

You have \$NODE_COUNT nodes available for testing:
\$(grep 'lab_node' /ansible/inventory | sort -V | sed 's/^/- /')

Try these example playbooks:
1. Simple ping test:
   ansible-playbook -i inventory --vault-password-file .vault_pass playbooks/ping.yml

2. Test connectivity and get hostnames:
   ansible-playbook -i inventory --vault-password-file .vault_pass playbooks/test.yml

3. Full site setup (webserver + database + config):
   ansible-playbook -i inventory --vault-password-file .vault_pass playbooks/site.yml

4. Vault example (secure secrets management):
   cd playbooks && ./setup_vault.sh
   cd playbooks && ./vault_manage.sh run

Your playbooks are in the /ansible/playbooks directory.

Quick test commands:
- Test web servers: curl http://lab_node1
- Test databases: mysql -h lab_node1 -u testuser -ptestpass testdb -e \"SELECT VERSION();\"
EOF

    # Display welcome message
    cat /tmp/welcome.txt
    echo ''
    echo 'Welcome message saved to: /tmp/welcome.txt'
    echo ''
    exec /bin/bash
  "