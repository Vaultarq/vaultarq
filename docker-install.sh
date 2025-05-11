#!/bin/bash
set -e

# VaultARQ Docker-based Installer
echo "====================================="
echo "VaultARQ Docker-based Installer"
echo "====================================="
echo

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is required but not installed."
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Default install directory
INSTALL_DIR="$HOME/.local/bin"
if [ "$1" != "" ]; then
    INSTALL_DIR="$1"
fi

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Create VaultARQ config directory
VAULTARQ_HOME="${HOME}/.vaultarq"
mkdir -p "${VAULTARQ_HOME}"
mkdir -p "${VAULTARQ_HOME}/env"

# Create the wrapper script
WRAPPER_PATH="${INSTALL_DIR}/vaultarq"
cat > "${WRAPPER_PATH}" << 'EOF'
#!/bin/bash

# VaultARQ Docker Wrapper
# This script runs VaultARQ CLI commands via Docker

# Support for interactive commands
TTY_ARG=""
if [ -t 0 ]; then
    TTY_ARG="-it"
fi

# Map the home directory to allow access to the vault
docker run --rm $TTY_ARG \
    -v "${HOME}/.vaultarq:/root/.vaultarq" \
    -v "${PWD}:/workdir" \
    -w /workdir \
    vaultarq/cli:latest "$@"
EOF

# Make wrapper executable
chmod +x "${WRAPPER_PATH}"

echo "🎉 VaultARQ installed successfully!"
echo "The CLI is available at: ${WRAPPER_PATH}"

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
echo "Quick Start:"
echo "  vaultarq init              # Create a new vault"
echo "  vaultarq push API_KEY=abc  # Add a secret"
echo "  vaultarq list              # List secrets"
echo "  vaultarq pull              # Generate env file"
echo "  source ~/.vaultarq/env/env.sh   # Load secrets into shell"
echo "" 