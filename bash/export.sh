#!/bin/bash

# vaultarq export - Output secrets as `export VAR=value` statements

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Initialize common requirements
init_common

# Parse arguments
format="bash"
for arg in "$@"; do
  case $arg in
    --bash)
      format="bash"
      ;;
    --dotenv)
      format="dotenv"
      ;;
    --json)
      format="json"
      ;;
    --help)
      echo "Usage: vaultarq export [--bash|--dotenv|--json]"
      echo ""
      echo "Options:"
      echo "  --bash    Output as 'export KEY=VALUE' (default)"
      echo "  --dotenv  Output as 'KEY=VALUE' (.env format)"
      echo "  --json    Output as JSON object"
      echo ""
      echo "Example:"
      echo "  eval \"\$(vaultarq export --bash)\""
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Run 'vaultarq export --help' for usage information"
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
  echo "Error: Failed to decrypt vault. Incorrect password?" >&2
  exit 1
fi

# Get secrets for the current environment based on format
case $format in
  bash)
    # Output as 'export KEY="VALUE"'
    echo "$decrypted_vault" | jq -r --arg env "$CURRENT_ENV" '.[$env] | to_entries | map("export \(.key)=\"\(.value)\"") | .[]'
    ;;
  dotenv)
    # Output as 'KEY=VALUE'
    echo "$decrypted_vault" | jq -r --arg env "$CURRENT_ENV" '.[$env] | to_entries | map("\(.key)=\(.value)") | .[]'
    ;;
  json)
    # Output as JSON object
    echo "$decrypted_vault" | jq -r --arg env "$CURRENT_ENV" '.[$env]'
    ;;
esac 