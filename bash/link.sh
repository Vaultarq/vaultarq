#!/bin/bash

# vaultarq link - Set active environment (dev/prod/etc.)

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Initialize common requirements
init_common

# Check arguments
if [ $# -ne 1 ]; then
  echo "Usage: vaultarq link <environment>"
  echo "Example: vaultarq link prod"
  exit 1
fi

env_name="$1"

# Validate environment name
validate_env_name "$env_name"

# Check if vault exists
if ! vault_exists; then
  echo "Error: No vault found. Run 'vaultarq init' first."
  exit 1
fi

# Get password
password=$(get_password)

# Decrypt the vault
echo "Decrypting vault..."
decrypted_vault=$(decrypt_vault "$password")

if [ $? -ne 0 ]; then
  echo "Error: Failed to decrypt vault. Incorrect password?"
  exit 1
fi

# Check if the environment exists
env_exists=$(echo "$decrypted_vault" | jq --arg env "$env_name" 'has($env)')

if [ "$env_exists" != "true" ]; then
  # Create the environment if it doesn't exist
  echo "Environment '$env_name' does not exist. Creating it..."
  decrypted_vault=$(echo "$decrypted_vault" | jq --arg env "$env_name" '.[$env] = {}')
  
  # Encrypt and save the updated vault
  echo "Updating vault..."
  encrypted_vault=$(encrypt_vault "$decrypted_vault" "$password")
  echo "$encrypted_vault" > "$VAULT_FILE"
fi

# Set the current environment
set_current_env "$env_name"

echo "Active environment switched to: $env_name"
echo "Use 'vaultarq pull' to update your local environment file" 