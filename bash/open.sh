#!/bin/bash

# vaultarq open - Show vault path or current env info

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Initialize common requirements (but don't require Node or jq)
init_dir_structure
CURRENT_ENV=$(get_current_env)

echo "Vaultarq Configuration"
echo "====================="
echo ""
echo "Vault Location:"
echo "  $VAULT_FILE"
echo ""

if vault_exists; then
  echo "Vault Status: PRESENT"
else
  echo "Vault Status: NOT FOUND"
  echo "  Run 'vaultarq init' to create a new vault"
  exit 0
fi

echo ""
echo "Current Environment: $CURRENT_ENV"
echo ""
echo "Environment File:"
echo "  $ENV_FILE"
echo ""

if [ -f "$ENV_FILE" ]; then
  echo "Environment File Status: PRESENT"
  echo "  Last generated: $(stat -c %y "$ENV_FILE" 2>/dev/null || stat -f "%Sm" "$ENV_FILE" 2>/dev/null)"
else
  echo "Environment File Status: NOT GENERATED"
  echo "  Run 'vaultarq pull' to generate it"
fi

echo ""
echo "Usage:"
echo "  - View secrets: vaultarq list [--values]"
echo "  - Add/update secrets: vaultarq push KEY=VALUE"
echo "  - Load secrets: vaultarq pull && source $ENV_FILE"
echo "  - Switch environments: vaultarq link <env-name>" 