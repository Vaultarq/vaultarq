#!/bin/bash

# vaultarq list - List secrets in vault

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Initialize common requirements
init_common

# Parse arguments
show_values=false
list_env="$CURRENT_ENV"

for arg in "$@"; do
  case $arg in
    --values)
      show_values=true
      ;;
    --env=*)
      list_env="${arg#*=}"
      validate_env_name "$list_env"
      ;;
    --all)
      list_env="all"
      ;;
    --help)
      echo "Usage: vaultarq list [options]"
      echo ""
      echo "Options:"
      echo "  --values       Show secret values (default: keys only)"
      echo "  --env=<name>   List secrets for a specific environment"
      echo "  --all          List secrets for all environments"
      echo ""
      echo "Example:"
      echo "  vaultarq list --values"
      echo "  vaultarq list --env=prod"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Run 'vaultarq list --help' for usage information"
      exit 1
      ;;
  esac
done

# Check if vault exists
if ! vault_exists; then
  echo "Error: No vault found. Run 'vaultarq init' first."
  exit 1
fi

# Get password
password=$(get_password)

# Decrypt the vault
decrypted_vault=$(decrypt_vault "$password")

if [ $? -ne 0 ]; then
  echo "Error: Failed to decrypt vault. Incorrect password?"
  exit 1
fi

# List environments if --all is specified
if [ "$list_env" = "all" ]; then
  echo "Available environments:"
  envs=$(echo "$decrypted_vault" | jq -r 'keys[]')
  
  # For each environment, list its secrets
  while IFS= read -r env; do
    secret_count=$(echo "$decrypted_vault" | jq -r --arg env "$env" '.[$env] | length')
    echo ""
    echo "[$env] - $secret_count secrets"
    
    if [ "$secret_count" -gt 0 ]; then
      if [ "$show_values" = true ]; then
        # Show keys and values
        echo "$decrypted_vault" | jq -r --arg env "$env" '.[$env] | to_entries | map("  \(.key) = \"\(.value)\"") | .[]'
      else
        # Show keys only
        echo "$decrypted_vault" | jq -r --arg env "$env" '.[$env] | keys[] | "  \(.)"'
      fi
    else
      echo "  (empty)"
    fi
  done <<< "$envs"
  
  exit 0
fi

# Check if the specified environment exists
env_exists=$(echo "$decrypted_vault" | jq --arg env "$list_env" 'has($env)')

if [ "$env_exists" != "true" ]; then
  echo "Error: Environment '$list_env' does not exist."
  echo "Available environments:"
  echo "$decrypted_vault" | jq -r 'keys[]' | sed 's/^/  /'
  exit 1
fi

# Count the secrets in the environment
secret_count=$(echo "$decrypted_vault" | jq -r --arg env "$list_env" '.[$env] | length')

echo "Environment: $list_env"
echo "Secret count: $secret_count"
echo ""

if [ "$secret_count" -eq 0 ]; then
  echo "No secrets found in '$list_env' environment."
  echo "Add secrets with: vaultarq push KEY=VALUE"
  exit 0
fi

# List the secrets
if [ "$show_values" = true ]; then
  # Show keys and values
  echo "$decrypted_vault" | jq -r --arg env "$list_env" '.[$env] | to_entries | map("\(.key) = \"\(.value)\"") | .[]'
else
  # Show keys only
  echo "$decrypted_vault" | jq -r --arg env "$list_env" '.[$env] | keys[]'
fi 