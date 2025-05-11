#!/bin/bash

set -e

# Vaultarq installer script
echo "Installing Vaultarq - The developer-first, invisible secrets manager"
echo "=================================================================="

# Default install directory
INSTALL_DIR="$HOME/.local/bin"
if [ "$1" != "" ]; then
  INSTALL_DIR="$1"
fi

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Create temp directory for download
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download or copy from current directory
if [ -d "$(dirname "$0")/bash" ] && [ -d "$(dirname "$0")/core" ]; then
  echo "Installing from local directory..."
  VAULTARQ_SRC="$(cd "$(dirname "$0")" && pwd)"
else
  echo "Downloading Vaultarq..."
  if ! command -v git &> /dev/null; then
    echo "Error: git is required for installation"
    echo "Please install git and try again"
    exit 1
  fi
  
  git clone https://github.com/yourname/vaultarq.git "$TEMP_DIR/vaultarq"
  VAULTARQ_SRC="$TEMP_DIR/vaultarq"
fi

# Create installation directory
VAULTARQ_INSTALL="$HOME/.vaultarq-cli"
echo "Installing to $VAULTARQ_INSTALL..."
mkdir -p "$VAULTARQ_INSTALL"
mkdir -p "$VAULTARQ_INSTALL/env"

# Copy files
cp -r "$VAULTARQ_SRC/bash" "$VAULTARQ_INSTALL/"
cp -r "$VAULTARQ_SRC/core" "$VAULTARQ_INSTALL/"
cp "$VAULTARQ_SRC/vaultarq" "$VAULTARQ_INSTALL/"

# Install Node.js dependencies
echo "Installing dependencies..."
cd "$VAULTARQ_INSTALL/core"
npm install --production

# Create symlink in the bin directory
if [ ! -e "$INSTALL_DIR/vaultarq" ]; then
  ln -s "$VAULTARQ_INSTALL/vaultarq" "$INSTALL_DIR/vaultarq"
else
  echo "Warning: $INSTALL_DIR/vaultarq already exists. Skipping symlink creation."
fi

# Check if the bin directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo "Warning: $INSTALL_DIR is not in your PATH"
  
  # Suggest adding to PATH based on shell
  SHELL_NAME=$(basename "$SHELL")
  case "$SHELL_NAME" in
    bash)
      echo "Add this to your ~/.bashrc:"
      echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
      ;;
    zsh)
      echo "Add this to your ~/.zshrc:"
      echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
      ;;
    *)
      echo "Add $INSTALL_DIR to your PATH to use vaultarq from any directory"
      ;;
  esac
fi

echo ""
echo "🎉 Vaultarq installed successfully!"
echo "Run 'vaultarq init' to create your first vault"
echo ""
echo "Quick Start:"
echo "  vaultarq init              # Create a new vault"
echo "  vaultarq push API_KEY=abc  # Add a secret"
echo "  vaultarq list              # List secrets"
echo "  vaultarq pull              # Generate env file"
echo "  source env/env.sh          # Load secrets into shell"
echo "" 