#!/bin/bash

# Common utilities and functions for vaultarq CLI

# Constants and defaults
VAULTARQ_HOME="${HOME}/.vaultarq"
VAULT_FILE="${VAULTARQ_HOME}/vault.json.enc"
CONFIG_FILE="${VAULTARQ_HOME}/config"
ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env"
ENV_FILE="${ENV_DIR}/env.sh"
CURRENT_ENV="dev"  # Default environment

# Check if NodeJS and npm are installed
function check_prerequisites {
  if ! command -v node &> /dev/null; then
    echo "Error: NodeJS is required for vault encryption/decryption"
    echo "Please install NodeJS from https://nodejs.org/"
    exit 1
  fi

  if ! command -v npm &> /dev/null; then
    echo "Error: npm is required for vault encryption/decryption"
    echo "Please install npm"
    exit 1
  fi
}

# Initialize vaultarq directory structure
function init_dir_structure {
  if [ ! -d "$VAULTARQ_HOME" ]; then
    mkdir -p "$VAULTARQ_HOME"
  fi

  if [ ! -d "$ENV_DIR" ]; then
    mkdir -p "$ENV_DIR"
  fi
}

# Get the current active environment from config
function get_current_env {
  if [ -f "$CONFIG_FILE" ]; then
    CURRENT_ENV=$(grep "^ENVIRONMENT=" "$CONFIG_FILE" | cut -d= -f2)
  fi
  echo "$CURRENT_ENV"
}

# Set the current active environment in config
function set_current_env {
  local env="$1"
  if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "ENVIRONMENT=$env" > "$CONFIG_FILE"
  else
    # Replace or add the environment setting
    if grep -q "^ENVIRONMENT=" "$CONFIG_FILE"; then
      sed -i "s/^ENVIRONMENT=.*/ENVIRONMENT=$env/" "$CONFIG_FILE"
    else
      echo "ENVIRONMENT=$env" >> "$CONFIG_FILE"
    fi
  fi
}

# Get password from user with confirmation for new vaults
function get_new_password {
  local password
  local confirm_password
  
  echo -n "Enter master password: "
  read -s password
  echo
  
  echo -n "Confirm master password: "
  read -s confirm_password
  echo
  
  if [ "$password" != "$confirm_password" ]; then
    echo "Error: Passwords do not match."
    exit 1
  fi
  
  echo "$password"
}

# Get password from user for existing vault
function get_password {
  local password
  
  echo -n "Enter master password: "
  read -s password
  echo
  
  echo "$password"
}

# Encrypt data using the Node.js encryption helper
function encrypt_vault {
  local data="$1"
  local password="$2"
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  
  echo "$data" | node "${script_dir}/core/encrypt.js" "$password"
}

# Decrypt data using the Node.js decryption helper
function decrypt_vault {
  local password="$1"
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  
  cat "$VAULT_FILE" | node "${script_dir}/core/decrypt.js" "$password"
}

# Check if the vault exists
function vault_exists {
  [ -f "$VAULT_FILE" ]
}

# Create an export statement from a key=value pair
function create_export {
  local key_value="$1"
  local key="${key_value%%=*}"
  local value="${key_value#*=}"
  
  echo "export $key=\"$value\""
}

# Generate an .env compatible line from a key=value pair
function create_env_line {
  local key_value="$1"
  local key="${key_value%%=*}"
  local value="${key_value#*=}"
  
  echo "$key=\"$value\""
}

# Check if jq is installed
function check_jq {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is required for JSON processing"
    echo "Please install jq: sudo apt-get install jq (or equivalent for your OS)"
    exit 1
  fi
}

# Validate environment name
function validate_env_name {
  local env="$1"
  if [[ ! "$env" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Invalid environment name. Use only letters, numbers, underscores, and hyphens."
    exit 1
  fi
}

# Initialize everything that's needed for most commands
function init_common {
  check_prerequisites
  check_jq
  init_dir_structure
  CURRENT_ENV=$(get_current_env)
} 