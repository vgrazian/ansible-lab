#!/bin/bash

# Simple vault setup script
echo "Setting up Ansible Vault for the lab..."

# Create vault password file if it doesn't exist
if [ ! -f "../../.vault_pass" ]; then
    echo "ansible_vault_lab_password" > ../../.vault_pass
    chmod 600 ../../.vault_pass
    echo "Created default vault password file: ../../.vault_pass"
    echo "Password: ansible_vault_lab_password"
    echo ""
    echo "⚠️  For production use, change this password!"
    echo "⚠️  Run: ansible-vault rekey group_vars/all/vault.yml"
else
    echo "Vault password file already exists at ../../.vault_pass"
fi

# Create group_vars directory
mkdir -p group_vars/all

# Create encrypted vault file with sample data
if [ ! -f "group_vars/all/vault.yml" ]; then
    cat > group_vars/all/vault.yml << 'EOF'
---
# Sensitive variables - Encrypted with Ansible Vault
secret_api_key: "AKIAIOSFODNN7EXAMPLE12345"
db_password: "SuperSecretDBP@ssw0rd!"
app_secret: "MyVeryLongAndComplexAppSecretKey123!"
encryption_salt: "RandomSaltValueForHashing123"
EOF
    
    echo "Encrypting vault file..."
    ansible-vault encrypt --vault-password-file ../../.vault_pass group_vars/all/vault.yml
    echo "Vault file created and encrypted at group_vars/all/vault.yml"
else
    echo "Vault file already exists at group_vars/all/vault.yml"
fi

echo ""
echo "✅ Vault setup complete!"
echo "🚀 Run the vault example: ./vault_manage.sh run"