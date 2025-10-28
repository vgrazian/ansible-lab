# Ansible Lab Environment

A local Ansible testing environment using Podman on macOS. This lab creates a containerized environment with one Ansible controller and multiple nodes for testing and development. Includes examples for infrastructure automation, configuration management, and secure secrets handling with Ansible Vault.

## Prerequisites

- macOS
- Podman installed (`brew install podman`)
- Podman machine running (`podman machine start`)

## Quick Start

1. Clone the repository
2. Build container images and generate SSH keys:

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

4. The controller container will start with an interactive shell and display available nodes
5. Run test playbooks to verify setup:

   ```bash
   # Basic connectivity test
   ansible-playbook -i inventory playbooks/ping.yml

   # Full infrastructure setup
   ansible-playbook -i inventory playbooks/site.yml
   ```

## Directory Structure

```
ansible-lab/
├── ansible/                    # Ansible configuration and playbooks
│   ├── ansible.cfg            # Ansible configuration
│   ├── inventory              # Dynamic inventory (generated)
│   └── playbooks/             # All playbooks and templates
│       ├── ping.yml           # Basic connectivity test
│       ├── test.yml           # Host information test
│       ├── setup_webserver.yml # Apache web server setup
│       ├── setup_database.yml  # MariaDB database setup
│       ├── config_management.yml # Configuration management example
│       ├── site.yml           # Complete infrastructure setup
│       ├── vault_example.yml  # Ansible Vault demonstration
│       ├── vault_manage.sh    # Vault management script
│       ├── setup_vault.sh     # Vault setup script
│       ├── group_vars/        # Group variables
│       │   └── all/
│       │       ├── vars.yml   # Non-sensitive variables
│       │       └── vault.yml  # Encrypted sensitive variables
│       └── templates/         # Jinja2 templates
│           └── secure_app.conf.j2
├── Containerfiles/            # Container definitions
│   ├── controller/            # Ansible controller container
│   └── node/                  # Node container template
├── keys/                      # SSH keys (auto-generated)
├── scripts/                   # Management scripts
│   ├── build-images.sh        # Build container images
│   ├── dostart.sh             # Start lab environment
│   ├── dostop.sh              # Stop lab environment
│   └── generate_inventory.sh  # Dynamic inventory generation
├── start.sh                   # Start lab (main script)
├── stop.sh                    # Stop lab
├── restart.sh                 # Restart lab
├── status.sh                  # Check lab status
└── .vault_pass                # Ansible Vault password file
```

## Example Playbooks

### Basic Testing

- **`ping.yml`** - Basic connectivity test
- **`test.yml`** - Get host information and test connectivity

### Infrastructure Setup

- **`setup_webserver.yml`** - Install and configure Apache web server
- **`setup_database.yml`** - Install and configure MariaDB database
- **`config_management.yml`** - Configuration management with templates
- **`site.yml`** - Complete setup (webserver + database + config)

### Secrets Management with Ansible Vault

The lab includes a comprehensive Ansible Vault example for secure secrets management:

#### Vault Setup

```bash
# From inside the controller container:
cd /ansible/playbooks

# Run the vault setup (first time only)
./setup_vault.sh
```

This script:

- Creates a vault password file (`../../.vault_pass`)
- Generates encrypted vault file (`group_vars/all/vault.yml`)
- Sets up sample encrypted variables

#### Vault Management

Use the `vault_manage.sh` script for all vault operations:

```bash
# View available commands
./vault_manage.sh

# Common workflow:
./vault_manage.sh setup     # Set up new password (optional)
./vault_manage.sh edit      # Edit encrypted variables
./vault_manage.sh view      # View encrypted content
./vault_manage.sh run       # Run vault example playbook
```

#### Manual Vault Commands

```bash
# Edit encrypted vault file
ansible-vault edit group_vars/all/vault.yml

# View encrypted content
ansible-vault view group_vars/all/vault.yml

# Run playbook with vault
ansible-playbook --vault-password-file ../../.vault_pass vault_example.yml
```

#### Vault Example Playbook

The `vault_example.yml` playbook demonstrates:

- Using encrypted variables in templates
- Secure configuration file generation
- Masking secrets in playbook output
- Template-based configuration with sensitive data

#### Vault Security Notes

- The default vault password is `ansible_vault_lab_password`
- For production use, change the password: `ansible-vault rekey group_vars/all/vault.yml`
- Never commit unencrypted vault files to version control
- The `.vault_pass` file is excluded from git via `.gitignore`

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

### Basic Commands

- Start lab with default 2 nodes: `./start.sh`
- Start lab with N nodes: `./start.sh N`
- Stop lab: `./stop.sh`
- Restart lab: `./restart.sh`
- Check status: `./status.sh`

### Status Command

The `status.sh` script provides comprehensive lab status:

- Podman machine status
- Network status
- Running containers
- Node count vs. stored configuration
- Inventory configuration

### Scaling the Lab

To run the lab with more nodes:

```bash
# Start with 5 nodes
./start.sh 5

# Start with 10 nodes
./start.sh 10
```

The inventory file is automatically generated based on the number of nodes specified.

## Default Setup

- 1 Ansible controller container
- Configurable number of target nodes (default: 2)
- Private network for inter-container communication
- SSH key authentication
- Dynamic inventory generation
- Pre-configured example playbooks
- Ansible Vault setup for secrets management

## Testing Connectivity

### Web Server Test

```bash
# Test web servers from controller
curl http://lab_node1
curl http://lab_node2
```

### Database Test

```bash
# Test database connectivity
mysql -h lab_node1 -u testuser -ptestpass testdb -e "SELECT VERSION();"
```

### Ansible Connectivity Test

```bash
# Test Ansible connectivity
ansible -i inventory all -m ping
ansible -i inventory all -a "hostname"
```

## Troubleshooting

### Common Issues

1. **Podman machine not running**

   ```bash
   podman machine start
   ```

2. **Containers already exist**

   ```bash
   ./stop.sh
   ./start.sh
   ```

3. **SSH connection issues**

   ```bash
   # Rebuild images with new SSH keys
   rm keys/id_rsa*
   ./scripts/build-images.sh
   ./restart.sh
   ```

4. **Vault password issues**

   ```bash
   # Reset vault setup
   rm .vault_pass
   rm -rf ansible/playbooks/group_vars
   cd ansible/playbooks && ./setup_vault.sh
   ```

### Getting Help

- Check lab status: `./status.sh`
- View container logs: `podman logs <container_name>`
- Test basic connectivity: `ansible-playbook -i inventory playbooks/ping.yml`

## Notes

- SSH keys are stored in `keys/` and are gitignored for security
- Container images are based on Debian 12
- The lab uses Podman instead of Docker for better macOS compatibility
- Inventory is dynamically generated based on number of nodes
- All sensitive files are excluded from version control via `.gitignore`
- The lab environment is completely isolated and safe for experimentation
