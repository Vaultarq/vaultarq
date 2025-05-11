#!/bin/bash
set -e

# Vaultarq CLI-SDK Synchronization Checker
# This script verifies that the CLI and SDKs are working together correctly

echo "====================================="
echo "Vaultarq CLI-SDK Sync Checker"
echo "====================================="
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Available SDKs in the repository
AVAILABLE_SDKS=("rust-sdk" "node-sdk" "python-sdk" "go-sdk")

# Function to check if vaultarq CLI is installed
check_cli() {
  echo "Checking Vaultarq CLI installation..."
  
  if ! command -v vaultarq &> /dev/null; then
    echo -e "${RED}❌ Vaultarq CLI is not installed or not in your PATH${NC}"
    
    # Try to find it in the local directory
    if [ -f "$(pwd)/vaultarq" ] && [ -x "$(pwd)/vaultarq" ]; then
      echo -e "${YELLOW}ℹ️ Found Vaultarq CLI in current directory, but it's not in your PATH${NC}"
      echo "For testing purposes, you can run: export PATH=\"\$PATH:$(pwd)\""
    fi
    
    return 1
  else
    echo -e "${GREEN}✅ Vaultarq CLI is installed: $(which vaultarq)${NC}"
    
    # Check if it's operational
    echo "Testing CLI basic functionality..."
    if vaultarq &> /dev/null; then
      echo -e "${GREEN}✅ CLI is operational${NC}"
    else
      echo -e "${RED}❌ CLI is not functioning correctly${NC}"
      return 1
    fi
    
    return 0
  fi
}

# Function to check SDK integrity
check_sdk_integrity() {
  local sdk=$1
  echo "Checking $sdk integrity..."
  
  case $sdk in
    "rust-sdk")
      if [ -f "$(pwd)/sdks/rust-sdk/Cargo.toml" ]; then
        echo -e "${GREEN}✅ Rust SDK structure is valid${NC}"
        return 0
      else
        echo -e "${RED}❌ Rust SDK structure is invalid${NC}"
        return 1
      fi
      ;;
    "node-sdk")
      if [ -f "$(pwd)/sdks/node-sdk/package.json" ]; then
        echo -e "${GREEN}✅ Node SDK structure is valid${NC}"
        return 0
      else
        echo -e "${RED}❌ Node SDK structure is invalid${NC}"
        return 1
      fi
      ;;
    "python-sdk")
      if [ -f "$(pwd)/sdks/python-sdk/setup.py" ] || [ -f "$(pwd)/sdks/python-sdk/pyproject.toml" ]; then
        echo -e "${GREEN}✅ Python SDK structure is valid${NC}"
        return 0
      else
        echo -e "${RED}❌ Python SDK structure is invalid${NC}"
        return 1
      fi
      ;;
    "go-sdk")
      if [ -f "$(pwd)/sdks/go-sdk/go.mod" ]; then
        echo -e "${GREEN}✅ Go SDK structure is valid${NC}"
        return 0
      else
        echo -e "${RED}❌ Go SDK structure is invalid${NC}"
        return 1
      fi
      ;;
    *)
      echo -e "${RED}❌ Unknown SDK: $sdk${NC}"
      return 1
      ;;
  esac
}

# Function to check if SDK uses same vault format as CLI
check_sdk_vault_compatibility() {
  local sdk=$1
  echo "Checking $sdk vault compatibility with CLI..."
  
  # For this test, we'll check if the SDK code contains references to the same vault file location
  local vault_pattern=".vaultarq/vault"
  
  case $sdk in
    "rust-sdk")
      if grep -r "$vault_pattern" "$(pwd)/sdks/rust-sdk" &> /dev/null; then
        echo -e "${GREEN}✅ Rust SDK appears to use compatible vault format${NC}"
        return 0
      else
        echo -e "${YELLOW}⚠️ Could not verify Rust SDK vault compatibility${NC}"
        return 1
      fi
      ;;
    "node-sdk")
      if grep -r "$vault_pattern" "$(pwd)/sdks/node-sdk" &> /dev/null; then
        echo -e "${GREEN}✅ Node SDK appears to use compatible vault format${NC}"
        return 0
      else
        echo -e "${YELLOW}⚠️ Could not verify Node SDK vault compatibility${NC}"
        return 1
      fi
      ;;
    "python-sdk")
      if grep -r "$vault_pattern" "$(pwd)/sdks/python-sdk" &> /dev/null; then
        echo -e "${GREEN}✅ Python SDK appears to use compatible vault format${NC}"
        return 0
      else
        echo -e "${YELLOW}⚠️ Could not verify Python SDK vault compatibility${NC}"
        return 1
      fi
      ;;
    "go-sdk")
      if grep -r "$vault_pattern" "$(pwd)/sdks/go-sdk" &> /dev/null; then
        echo -e "${GREEN}✅ Go SDK appears to use compatible vault format${NC}"
        return 0
      else
        echo -e "${YELLOW}⚠️ Could not verify Go SDK vault compatibility${NC}"
        return 1
      fi
      ;;
    *)
      echo -e "${RED}❌ Unknown SDK: $sdk${NC}"
      return 1
      ;;
  esac
}

# Function to check SDK version matches CLI version
check_sdk_version_sync() {
  local sdk=$1
  echo "Checking $sdk version synchronization with CLI..."
  
  # Try to get CLI version
  local cli_version=$(vaultarq version 2>/dev/null || echo "unknown")
  
  if [ "$cli_version" == "unknown" ]; then
    echo -e "${YELLOW}⚠️ Could not determine CLI version${NC}"
    return 1
  fi
  
  # Extract version number
  cli_version=$(echo "$cli_version" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
  
  case $sdk in
    "rust-sdk")
      local sdk_version=$(grep -oE 'version = "[0-9]+\.[0-9]+\.[0-9]+"' "$(pwd)/sdks/rust-sdk/Cargo.toml" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
      ;;
    "node-sdk")
      local sdk_version=$(grep -oE '"version": "[0-9]+\.[0-9]+\.[0-9]+"' "$(pwd)/sdks/node-sdk/package.json" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
      ;;
    "python-sdk")
      local sdk_version=$(grep -oE 'version="[0-9]+\.[0-9]+\.[0-9]+"' "$(pwd)/sdks/python-sdk/setup.py" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
      ;;
    "go-sdk")
      # First try version.go
      if [ -f "$(pwd)/sdks/go-sdk/version.go" ]; then
        local sdk_version=$(grep -oE 'Version = "[0-9]+\.[0-9]+\.[0-9]+"' "$(pwd)/sdks/go-sdk/version.go" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
      else
        # Try to extract from go.mod if it has versioned path
        local sdk_version=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$(pwd)/sdks/go-sdk/go.mod" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
      fi
      ;;
    *)
      echo -e "${RED}❌ Unknown SDK: $sdk${NC}"
      return 1
      ;;
  esac
  
  if [ "$sdk_version" == "unknown" ]; then
    echo -e "${YELLOW}⚠️ Could not determine $sdk version${NC}"
    return 1
  fi
  
  if [ "$cli_version" == "$sdk_version" ]; then
    echo -e "${GREEN}✅ $sdk version ($sdk_version) matches CLI version ($cli_version)${NC}"
    return 0
  else
    echo -e "${RED}❌ Version mismatch: $sdk ($sdk_version) vs CLI ($cli_version)${NC}"
    return 1
  fi
}

# Function to check if SDK can detect CLI
check_sdk_cli_detection() {
  local sdk=$1
  echo "Checking if $sdk can detect CLI..."
  
  case $sdk in
    "rust-sdk")
      # Look for is_available or similar function that detects CLI
      if grep -r "is_available\|available\|find_cli" "$(pwd)/sdks/rust-sdk/src" &> /dev/null; then
        echo -e "${GREEN}✅ Rust SDK appears to have CLI detection capability${NC}"
        return 0
      else
        echo -e "${YELLOW}⚠️ Could not verify Rust SDK CLI detection capability${NC}"
        return 1
      fi
      ;;
    "node-sdk")
      if grep -r "isAvailable\|available\|findCli" "$(pwd)/sdks/node-sdk/src" &> /dev/null; then
        echo -e "${GREEN}✅ Node SDK appears to have CLI detection capability${NC}"
        return 0
      else
        echo -e "${YELLOW}⚠️ Could not verify Node SDK CLI detection capability${NC}"
        return 1
      fi
      ;;
    "python-sdk")
      if grep -r "is_available\|available\|find_cli" "$(pwd)/sdks/python-sdk/vaultarq" &> /dev/null; then
        echo -e "${GREEN}✅ Python SDK appears to have CLI detection capability${NC}"
        return 0
      else
        echo -e "${YELLOW}⚠️ Could not verify Python SDK CLI detection capability${NC}"
        return 1
      fi
      ;;
    "go-sdk")
      if grep -r "IsAvailable\|Available\|FindCLI" "$(pwd)/sdks/go-sdk" &> /dev/null; then
        echo -e "${GREEN}✅ Go SDK appears to have CLI detection capability${NC}"
        return 0
      else
        echo -e "${YELLOW}⚠️ Could not verify Go SDK CLI detection capability${NC}"
        return 1
      fi
      ;;
    *)
      echo -e "${RED}❌ Unknown SDK: $sdk${NC}"
      return 1
      ;;
  esac
}

# Run all checks
main() {
  local cli_ok=false
  local sdk_ok=true
  
  # Check CLI first
  if check_cli; then
    cli_ok=true
    echo
  else
    echo -e "${RED}❌ CLI checks failed, SDK synchronization may not be possible${NC}"
    echo
  fi
  
  # Check all SDKs
  for sdk in "${AVAILABLE_SDKS[@]}"; do
    echo "====================================="
    echo "Checking $sdk"
    echo "====================================="
    
    local sdk_checks_ok=true
    
    # Check SDK integrity
    if ! check_sdk_integrity $sdk; then
      sdk_checks_ok=false
    fi
    echo
    
    # Check vault compatibility
    if ! check_sdk_vault_compatibility $sdk; then
      sdk_checks_ok=false
    fi
    echo
    
    # Check version synchronization
    if $cli_ok; then
      if ! check_sdk_version_sync $sdk; then
        sdk_checks_ok=false
      fi
      echo
    fi
    
    # Check CLI detection
    if ! check_sdk_cli_detection $sdk; then
      sdk_checks_ok=false
    fi
    echo
    
    if [ "$sdk_checks_ok" = false ]; then
      sdk_ok=false
    fi
  done
  
  # Summary
  echo "====================================="
  echo "Synchronization Check Summary"
  echo "====================================="
  
  if [ "$cli_ok" = true ] && [ "$sdk_ok" = true ]; then
    echo -e "${GREEN}✅ All checks passed! CLI and SDKs appear to be in sync.${NC}"
  else
    echo -e "${RED}❌ Some checks failed. CLI and SDKs may not be properly synchronized.${NC}"
    
    if [ "$cli_ok" = false ]; then
      echo -e "${RED}   - CLI checks failed${NC}"
    fi
    
    if [ "$sdk_ok" = false ]; then
      echo -e "${RED}   - SDK checks failed${NC}"
    fi
    
    echo
    echo "Recommended actions:"
    echo "1. Ensure CLI is properly installed and functioning"
    echo "2. Check SDK versions match CLI version"
    echo "3. Verify SDKs can detect and interact with CLI"
    echo "4. Make sure vault formats are compatible across all components"
  fi
}

# Run the main function
main 