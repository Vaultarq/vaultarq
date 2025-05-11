#!/bin/bash

# vaultarq push - Add/update secrets to the vault

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Initialize common requirements
init_common

# Check if vault exists
if ! vault_exists; then
  echo "Error: No vault found. Run 'vaultarq init' first."
  exit 1
fi

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: vaultarq push KEY=VALUE [KEY2=VALUE2 ...]"
  echo "Example: vaultarq push API_KEY=abc123 DB_PASSWORD=secure"
  exit 1
fi

# Check that each argument is in KEY=VALUE format
for arg in "$@"; do
  if [[ ! "$arg" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
    echo "Error: Invalid format for '$arg'. Must be KEY=VALUE."
    echo "Usage: vaultarq push KEY=VALUE [KEY2=VALUE2 ...]"
    exit 1
  fi
done

# Get password
password=$(get_password)

# Decrypt the vault
echo "Decrypting vault..."
decrypted_vault=$(decrypt_vault "$password")

if [ $? -ne 0 ]; then
  echo "Error: Failed to decrypt vault. Incorrect password?"
  exit 1
fi

# Parse the JSON and add/update the secrets
for key_value in "$@"; do
  key="${key_value%%=*}"
  value="${key_value#*=}"
  
  # Update the value in the current environment
  decrypted_vault=$(echo "$decrypted_vault" | jq --arg env "$CURRENT_ENV" --arg key "$key" --arg val "$value" '.[$env][$key] = $val')
  
  echo "Added/updated $key in $CURRENT_ENV environment"
done

# Encrypt and save the updated vault
echo "Encrypting and saving vault..."
encrypted_vault=$(encrypt_vault "$decrypted_vault" "$password")
echo "$encrypted_vault" > "$VAULT_FILE"

echo "Secrets added successfully to $CURRENT_ENV environment" 