#!/bin/bash
set -e

# Vaultarq Version Updater
# This script updates version numbers across all Vaultarq components

echo "====================================="
echo "Vaultarq Version Updater"
echo "====================================="
echo

# Check if a version argument was provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 0.2.0"
  exit 1
fi

# Get the version to set
NEW_VERSION=$1

# Validate version format (semver)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in the format X.Y.Z (e.g., 0.2.0)"
  exit 1
fi

echo "Setting version to $NEW_VERSION across all components..."
echo

# Update CLI version
echo "Updating CLI version..."
VAULTARQ_SCRIPT="$(pwd)/vaultarq"

if [ -f "$VAULTARQ_SCRIPT" ]; then
  # Add or update version information
  if grep -q "VERSION=" "$VAULTARQ_SCRIPT"; then
    # Update existing version
    sed -i "s/VERSION=.*$/VERSION=\"$NEW_VERSION\"/" "$VAULTARQ_SCRIPT"
    echo "✅ Updated CLI version in $VAULTARQ_SCRIPT"
  else
    # Add version after shebang line
    sed -i "2iVERSION=\"$NEW_VERSION\"" "$VAULTARQ_SCRIPT"
    echo "✅ Added version to CLI in $VAULTARQ_SCRIPT"
  fi
  
  # Ensure version command exists by adding it if needed
  if ! grep -q "version)" "$VAULTARQ_SCRIPT"; then
    # Find the case statement
    if grep -q "case" "$VAULTARQ_SCRIPT"; then
      # Add version command to case statement
      sed -i '/case $COMMAND in/a \  version) echo "Vaultarq CLI v$VERSION"; exit 0;;' "$VAULTARQ_SCRIPT"
      echo "✅ Added version command to CLI"
    else
      echo "⚠️ Could not add version command (no case statement found)"
    fi
  fi
else
  echo "❌ CLI script not found at $VAULTARQ_SCRIPT"
fi

# Update Rust SDK version
echo
echo "Updating Rust SDK version..."
RUST_CARGO="$(pwd)/sdks/rust-sdk/Cargo.toml"

if [ -f "$RUST_CARGO" ]; then
  # Update version in Cargo.toml
  sed -i "s/^version = \".*\"/version = \"$NEW_VERSION\"/" "$RUST_CARGO"
  echo "✅ Updated Rust SDK version in $RUST_CARGO"
else
  echo "❌ Rust SDK Cargo.toml not found at $RUST_CARGO"
fi

# Update Node.js SDK version
echo
echo "Updating Node.js SDK version..."
NODE_PACKAGE="$(pwd)/sdks/node-sdk/package.json"

if [ -f "$NODE_PACKAGE" ]; then
  # Update version in package.json
  sed -i "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" "$NODE_PACKAGE"
  echo "✅ Updated Node.js SDK version in $NODE_PACKAGE"
else
  echo "❌ Node.js SDK package.json not found at $NODE_PACKAGE"
fi

# Update Python SDK version
echo
echo "Updating Python SDK version..."
PYTHON_SETUP="$(pwd)/sdks/python-sdk/setup.py"
PYTHON_PROJECT="$(pwd)/sdks/python-sdk/pyproject.toml"

if [ -f "$PYTHON_SETUP" ]; then
  # Update version in setup.py
  sed -i "s/version=\".*\"/version=\"$NEW_VERSION\"/" "$PYTHON_SETUP"
  echo "✅ Updated Python SDK version in $PYTHON_SETUP"
elif [ -f "$PYTHON_PROJECT" ]; then
  # Update version in pyproject.toml
  sed -i "s/version = \".*\"/version = \"$NEW_VERSION\"/" "$PYTHON_PROJECT"
  echo "✅ Updated Python SDK version in $PYTHON_PROJECT"
else
  echo "❌ Python SDK setup files not found"
fi

# Update Go SDK version
echo
echo "Updating Go SDK version..."
GO_MOD="$(pwd)/sdks/go-sdk/go.mod"

if [ -f "$GO_MOD" ]; then
  # Update version in go.mod (more complex because Go uses v prefix and has module path)
  current_module=$(grep "^module" "$GO_MOD" | head -1 | awk '{print $2}')
  if [[ $current_module == *"/v"* ]]; then
    # Module has version in path, update that
    new_module=$(echo "$current_module" | sed -E "s|/v[0-9]+$|/v${NEW_VERSION%%.*}|")
    sed -i "s|^module .*$|module $new_module|" "$GO_MOD"
    echo "✅ Updated Go SDK module path to $new_module"
  else
    # No version in module path, use Go embed variable for version
    VERSION_GO="$(pwd)/sdks/go-sdk/version.go"
    if [ -f "$VERSION_GO" ]; then
      sed -i "s/var Version = \".*\"/var Version = \"$NEW_VERSION\"/" "$VERSION_GO"
      echo "✅ Updated Go SDK version in $VERSION_GO"
    else
      # Create version.go if it doesn't exist
      echo "package vaultarq

// Version is the current version of the Vaultarq Go SDK
var Version = \"$NEW_VERSION\"
" > "$VERSION_GO"
      echo "✅ Created $VERSION_GO with version $NEW_VERSION"
    fi
  fi
else
  echo "❌ Go SDK go.mod not found at $GO_MOD"
fi

# Update CHANGELOG.md if it exists
echo
echo "Updating CHANGELOG.md..."
CHANGELOG="$(pwd)/CHANGELOG.md"

if [ -f "$CHANGELOG" ]; then
  # Check if version header already exists
  if grep -q "## \[$NEW_VERSION\]" "$CHANGELOG"; then
    echo "ℹ️ Version $NEW_VERSION already exists in CHANGELOG.md"
  else
    # Add new version header after first line
    DATE=$(date +"%Y-%m-%d")
    sed -i "1a\\
\\
## [$NEW_VERSION] - $DATE\\
### Added\\
- Version synchronization across CLI and SDKs\\
\\
" "$CHANGELOG"
    echo "✅ Added version $NEW_VERSION to CHANGELOG.md"
  fi
else
  echo "❌ CHANGELOG.md not found at $CHANGELOG"
fi

echo
echo "✅ Version update complete!"
echo
echo "Next steps:"
echo "1. Commit these changes with: git commit -am \"Update version to $NEW_VERSION\""
echo "2. Run sync_check.sh to verify synchronization"
echo "3. Update documentation if necessary"
echo "4. Tag the release with: git tag v$NEW_VERSION" 