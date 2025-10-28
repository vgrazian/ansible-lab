# Ansible Lab Environment

A local Ansible testing environment using Podman on macOS. This lab creates a containerized environment with one Ansible controller and multiple nodes for testing and development.

## Prerequisites

- macOS
- Podman installed (`brew install podman`)
- Podman machine running (`podman machine start`)

## Directory Structure

```
ansible-lab/
├── ansible/              # Your Ansible playbooks and configuration
│   ├── inventory        # Inventory file defining nodes
│   ├── ansible.cfg      # Ansible configuration
│   └── playbooks/       # Your playbooks go here
├── Containerfiles/      # Container definitions
│   ├── controller/      # Ansible controller container
│   └── node/           # Node container template
├── keys/               # SSH keys (gitignored)
└── scripts/            # Management scripts
```

## Quick Start

1. Clone the repository
2. Generate SSH keys (see section below) and build images:

   ```bash
   ./scripts/build-images.sh
   ```

3. Start the lab environment:

   ```bash
   # Start with default 2 nodes
   ./start.sh

   # Or specify number of nodes (e.g., 4 nodes)
   ./start.sh 4
   ```

4. The controller container will start with an interactive shell
5. Run the test playbook:

   ```bash
   ansible-playbook -i inventory playbooks/test.yml
   ```

## SSH Key Setup

The lab uses SSH keys for authentication between the controller and nodes. While the `build-images.sh` script automatically generates keys if they don't exist, you can also manually create them:

```bash
# Create keys directory if it doesn't exist
mkdir -p keys

# Generate SSH key pair
ssh-keygen -t rsa -N "" -f keys/id_rsa
```

Key locations:

- Private key: `keys/id_rsa`
- Public key: `keys/id_rsa.pub`

Notes:

- Keys are automatically copied to the appropriate containers during build
- The keys directory is gitignored for security
- If you rebuild the images, existing keys will be reused
- To generate new keys, simply delete the existing ones and rebuild:

  ```bash
  rm keys/id_rsa*
  ./scripts/build-images.sh
  ```

## Custom Playbooks

The `ansible/` directory is mounted into the controller container at `/ansible`. This means:

- All playbooks in `ansible/playbooks/` are automatically available in the container
- Changes to playbooks are immediate - no need to rebuild or restart
- You can edit playbooks on your host machine with your preferred editor
- New playbooks added to `ansible/playbooks/` are instantly accessible

Example workflow:

```bash
# On your host machine
echo "---
- name: My new playbook
  hosts: all
  tasks:
    - name: Echo test
      ansible.builtin.debug:
        msg: Hello from new playbook" > ansible/playbooks/new.yml

# In the controller container
ansible-playbook -i inventory playbooks/new.yml
```

## Managing the Lab

- Start lab with default 2 nodes: `./start.sh`
- Start lab with N nodes: `./start.sh N`
- Stop lab: `./stop.sh`
- Rebuild and restart: `./restart.sh`

## Default Setup

- 1 Ansible controller
- By default 2 target nodes (lab_node1, lab_node2)
- Configurable number of nodes via command line parameter
- Private network for inter-container communication
- SSH key authentication
- Dynamic inventory generation based on number of nodes

## Scaling the Lab

To run the lab with more nodes:

```bash
# Start with 5 nodes
./start.sh 5

# Start with 10 nodes
./start.sh 10
```

The inventory file is automatically generated based on the number of nodes specified.

## Notes

- SSH keys are stored in `keys/` and are gitignored for security
- Container images are based on Debian 12
- The lab uses Podman instead of Docker for better macOS compatibility
- Inventory is dynamically generated based on number of nodes
