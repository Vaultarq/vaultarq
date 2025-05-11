#!/bin/bash

# vaultarq init - Initialize a new encrypted vault

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

echo "Vaultarq init - Create a new encrypted vault"
echo "----------------------------------------"

# Create directories
init_dir_structure

# Check if vault already exists
if vault_exists; then
  echo "Error: Vault already exists at $VAULT_FILE"
  echo "To reinitialize, please remove the existing vault file first."
  exit 1
fi

# Ensure Node.js dependencies are installed
if [ ! -d "${SCRIPT_DIR}/../core/node_modules" ]; then
  echo "Installing dependencies..."
  (cd "${SCRIPT_DIR}/../core" && npm install)
fi

# Get password with confirmation
password=$(get_new_password)

# Create initial empty vault structure
initial_vault='{
  "dev": {},
  "prod": {}
}'

# Encrypt and save
echo "Creating encrypted vault..."
encrypted_vault=$(encrypt_vault "$initial_vault" "$password")
echo "$encrypted_vault" > "$VAULT_FILE"

# Set dev as the default environment
set_current_env "dev"

echo "Vault initialized successfully at $VAULT_FILE"
echo "Default environment: dev"
echo ""
echo "Add secrets with: vaultarq push KEY=VALUE"
echo "Switch environment with: vaultarq link <env>"
echo "List environment secrets with: vaultarq list" 