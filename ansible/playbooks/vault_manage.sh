#!/bin/bash

VAULT_DIR="group_vars/all"
VAULT_FILE="$VAULT_DIR/vault.yml"
VAULT_PASSWORD_FILE="../../.vault_pass"

echo "Ansible Vault Management"
echo "========================"

case "$1" in
    create)
        if [ -f "$VAULT_FILE" ]; then
            echo "Vault file already exists. Use 'edit' to modify or 'rekey' to change password."
        else
            echo "Creating new vault file..."
            mkdir -p "$VAULT_DIR"
            ansible-vault create "$VAULT_FILE"
        fi
        ;;
    edit)
        if [ -f "$VAULT_FILE" ]; then
            ansible-vault edit "$VAULT_FILE"
        else
            echo "Vault file doesn't exist. Use 'create' to make one."
            exit 1
        fi
        ;;
    view)
        if [ -f "$VAULT_FILE" ]; then
            ansible-vault view "$VAULT_FILE"
        else
            echo "Vault file doesn't exist."
            exit 1
        fi
        ;;
    encrypt)
        if [ -f "$VAULT_FILE" ]; then
            ansible-vault encrypt "$VAULT_FILE"
        else
            echo "Vault file doesn't exist."
            exit 1
        fi
        ;;
    decrypt)
        if [ -f "$VAULT_FILE" ]; then
            ansible-vault decrypt "$VAULT_FILE"
        else
            echo "Vault file doesn't exist."
            exit 1
        fi
        ;;
    setup)
        echo "Setting up vault password file..."
        read -s -p "Enter vault password: " password
        echo
        echo "$password" > "$VAULT_PASSWORD_FILE"
        chmod 600 "$VAULT_PASSWORD_FILE"
        echo "Vault password file created at $VAULT_PASSWORD_FILE"
        ;;
    run)
        if [ -f "$VAULT_PASSWORD_FILE" ]; then
            ansible-playbook -i ../inventory --vault-password-file "$VAULT_PASSWORD_FILE" vault_example.yml
        else
            echo "Vault password file not found. Run './vault_manage.sh setup' first."
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {create|edit|view|encrypt|decrypt|setup|run}"
        echo ""
        echo "Commands:"
        echo "  create  - Create a new vault file"
        echo "  edit    - Edit existing vault file"
        echo "  view    - View vault file contents"
        echo "  encrypt - Encrypt an existing vault file"
        echo "  decrypt - Decrypt vault file (use with caution)"
        echo "  setup   - Set up vault password file"
        echo "  run     - Run the vault example playbook"
        echo ""
        echo "Example workflow:"
        echo "  1. ./vault_manage.sh setup     # Set password"
        echo "  2. ./vault_manage.sh create    # Create vault file"
        echo "  3. ./vault_manage.sh run       # Run playbook"
        exit 1
        ;;
esac