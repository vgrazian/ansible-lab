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

# Create dynamic welcome message based on inventory
generate_welcome_message() {
    local inventory_file="$1"
    local welcome_file="$2"
    
    # Extract nodes from inventory (handles different formats)
    local node_list=$(grep -E '^lab_node[0-9]+' "$inventory_file" | sort -V)
    local node_count=$(echo "$node_list" | wc -l)
    
    # Format node list with bullets
    local formatted_nodes=""
    while IFS= read -r node; do
        [[ -n "$node" ]] && formatted_nodes="${formatted_nodes}- $node\n"
    done <<< "$node_list"
    
    cat > "$welcome_file" << EOF
Welcome to your Ansible Lab Environment!

You have $node_count nodes available for testing:
${formatted_nodes}
Try these example playbooks:
1. Simple ping test:
   ansible-playbook -i inventory playbooks/ping.yml

2. Test connectivity and get hostnames:
   ansible-playbook -i inventory playbooks/test.yml

3. Full site setup (webserver + database + config):
   ansible-playbook -i inventory playbooks/site.yml

Your playbooks are in the /ansible/playbooks directory.

Quick test commands:
- Test web servers: curl http://lab_node1
- Test databases: mysql -h lab_node1 -u testuser -ptestpass testdb -e "SELECT VERSION();"
EOF
}

generate_welcome_message "${LAB_DIR}/ansible/inventory" "${LAB_DIR}/ansible/welcome.txt"

echo "Generated welcome message"

# Start controller with ansible volume mounted and display welcome message
podman run -it --name ansible_controller \
  --network lab_network \
  --cap-add=CAP_AUDIT_WRITE \
  --cap-add=CAP_AUDIT_CONTROL \
  -v "${LAB_DIR}/ansible:/ansible:Z" \
  lab_ansible_controller /bin/bash -c "cat /ansible/welcome.txt && echo '' && exec /bin/bash"