#!/bin/bash
set -e

# Vaultarq SDK Test Examples
# This script demonstrates how to use each SDK with the CLI

echo "====================================="
echo "Vaultarq SDK Test Examples"
echo "====================================="
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to check if vaultarq CLI is installed
check_cli() {
  echo "Checking Vaultarq CLI installation..."
  
  if ! command -v vaultarq &> /dev/null; then
    echo -e "${RED}❌ Vaultarq CLI is not installed or not in your PATH${NC}"
    return 1
  else
    echo -e "${GREEN}✅ Vaultarq CLI is installed: $(which vaultarq)${NC}"
    
    # Check version
    local version=$(vaultarq version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}   Version: $version${NC}"
    
    return 0
  fi
}

# Function to create a test vault with sample data
create_test_vault() {
  echo "Creating test vault for examples..."
  
  # Initialize a vault (non-interactive if possible)
  vaultarq init &> /dev/null || true
  
  # Add test secrets
  vaultarq push TEST_API_KEY=test_123456 &> /dev/null || true
  vaultarq push TEST_DATABASE_URL=postgresql://test:password@localhost:5432/testdb &> /dev/null || true
  
  echo -e "${GREEN}✅ Test vault created${NC}"
  echo
}

# Function to demonstrate Rust SDK
test_rust_sdk() {
  echo "====================================="
  echo "Rust SDK Example"
  echo "====================================="
  
  if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}⚠️ Rust not installed, skipping Rust SDK example${NC}"
    return 0
  fi
  
  echo "Creating Rust test project..."
  
  # Create temporary directory
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  # Initialize Rust project
  cargo init --name vaultarq_rust_test &> /dev/null
  cd vaultarq_rust_test
  
  # Add vaultarq dependency
  CARGO_TOML="$(pwd)/Cargo.toml"
  echo "[dependencies]
vaultarq = { path = \"$(pwd)/../../../../sdks/rust-sdk\" }" >> "$CARGO_TOML"
  
  # Create Rust test file
  cat > src/main.rs << 'EOF'
use std::env;

fn main() {
    println!("Vaultarq Rust SDK Test");
    println!("=====================");
    
    // Check if Vaultarq is available
    println!("\nChecking if Vaultarq is available...");
    if vaultarq::is_available() {
        println!("✅ Vaultarq is available");
    } else {
        println!("❌ Vaultarq is not available");
        return;
    }
    
    // Initialize Vaultarq
    println!("\nInitializing Vaultarq...");
    match vaultarq::init() {
        Ok(_) => println!("✅ Vaultarq initialized successfully"),
        Err(e) => {
            println!("❌ Failed to initialize Vaultarq: {}", e);
            return;
        }
    }
    
    // Try to get test environment variables
    println!("\nReading environment variables...");
    let test_vars = ["TEST_API_KEY", "TEST_DATABASE_URL"];
    
    for var in test_vars {
        match env::var(var) {
            Ok(value) => {
                let masked = if value.len() > 4 {
                    format!("{}***", &value[0..4])
                } else {
                    "***".to_string()
                };
                println!("✅ {} = {}", var, masked);
            },
            Err(_) => println!("❌ {} not found", var),
        }
    }
    
    println!("\nRust SDK test completed");
}
EOF
  
  # Build and run
  echo "Building and running Rust example..."
  if cargo run &> /dev/null; then
    # Run with proper output
    cargo run
    echo -e "\n${GREEN}✅ Rust SDK test completed${NC}"
  else
    echo -e "${RED}❌ Failed to build or run Rust example${NC}"
  fi
  
  # Clean up
  cd ../../
  rm -rf "$TEMP_DIR"
  echo
}

# Function to demonstrate Node.js SDK
test_node_sdk() {
  echo "====================================="
  echo "Node.js SDK Example"
  echo "====================================="
  
  if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠️ Node.js not installed, skipping Node.js SDK example${NC}"
    return 0
  fi
  
  echo "Creating Node.js test project..."
  
  # Create temporary directory
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  # Initialize Node.js project
  mkdir vaultarq_node_test
  cd vaultarq_node_test
  
  # Create package.json
  cat > package.json << 'EOF'
{
  "name": "vaultarq_node_test",
  "version": "1.0.0",
  "description": "Vaultarq Node.js SDK Test",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  }
}
EOF
  
  # Create index.js test file
  cat > index.js << 'EOF'
const vaultarq = require('../../../../sdks/node-sdk');

async function main() {
  console.log('Vaultarq Node.js SDK Test');
  console.log('========================');
  
  // Check if Vaultarq is available
  console.log('\nChecking if Vaultarq is available...');
  if (vaultarq.isAvailable()) {
    console.log('✅ Vaultarq is available');
  } else {
    console.log('❌ Vaultarq is not available');
    return;
  }
  
  // Initialize Vaultarq
  console.log('\nInitializing Vaultarq...');
  try {
    await vaultarq.init();
    console.log('✅ Vaultarq initialized successfully');
  } catch (error) {
    console.log(`❌ Failed to initialize Vaultarq: ${error}`);
    return;
  }
  
  // Try to get test environment variables
  console.log('\nReading environment variables...');
  const testVars = ['TEST_API_KEY', 'TEST_DATABASE_URL'];
  
  testVars.forEach(varName => {
    const value = process.env[varName];
    if (value) {
      const masked = value.length > 4 ? `${value.substring(0, 4)}***` : '***';
      console.log(`✅ ${varName} = ${masked}`);
    } else {
      console.log(`❌ ${varName} not found`);
    }
  });
  
  console.log('\nNode.js SDK test completed');
}

main().catch(console.error);
EOF
  
  # Run the test
  echo "Running Node.js example..."
  if node index.js; then
    echo -e "\n${GREEN}✅ Node.js SDK test completed${NC}"
  else
    echo -e "${RED}❌ Failed to run Node.js example${NC}"
  fi
  
  # Clean up
  cd ../../
  rm -rf "$TEMP_DIR"
  echo
}

# Function to demonstrate Python SDK
test_python_sdk() {
  echo "====================================="
  echo "Python SDK Example"
  echo "====================================="
  
  if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠️ Python not installed, skipping Python SDK example${NC}"
    return 0
  fi
  
  echo "Creating Python test project..."
  
  # Create temporary directory
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  # Create Python test file
  cat > vaultarq_test.py << 'EOF'
import os
import sys

# Add the SDK to the path
sdk_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../../sdks/python-sdk"))
sys.path.insert(0, sdk_path)

import vaultarq

def main():
    print("Vaultarq Python SDK Test")
    print("=======================")
    
    # Check if Vaultarq is available
    print("\nChecking if Vaultarq is available...")
    if vaultarq.is_available():
        print("✅ Vaultarq is available")
    else:
        print("❌ Vaultarq is not available")
        return
    
    # Initialize Vaultarq
    print("\nInitializing Vaultarq...")
    try:
        vaultarq.init()
        print("✅ Vaultarq initialized successfully")
    except Exception as e:
        print(f"❌ Failed to initialize Vaultarq: {e}")
        return
    
    # Try to get test environment variables
    print("\nReading environment variables...")
    test_vars = ["TEST_API_KEY", "TEST_DATABASE_URL"]
    
    for var in test_vars:
        value = os.environ.get(var)
        if value:
            masked = f"{value[:4]}***" if len(value) > 4 else "***"
            print(f"✅ {var} = {masked}")
        else:
            print(f"❌ {var} not found")
    
    print("\nPython SDK test completed")

if __name__ == "__main__":
    main()
EOF
  
  # Run the test
  echo "Running Python example..."
  if python3 vaultarq_test.py; then
    echo -e "\n${GREEN}✅ Python SDK test completed${NC}"
  else
    echo -e "${RED}❌ Failed to run Python example${NC}"
  fi
  
  # Clean up
  cd ../
  rm -rf "$TEMP_DIR"
  echo
}

# Function to demonstrate Go SDK
test_go_sdk() {
  echo "====================================="
  echo "Go SDK Example"
  echo "====================================="
  
  if ! command -v go &> /dev/null; then
    echo -e "${YELLOW}⚠️ Go not installed, skipping Go SDK example${NC}"
    return 0
  fi
  
  echo "Creating Go test project..."
  
  # Create temporary directory
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  # Initialize Go module
  mkdir vaultarq_go_test
  cd vaultarq_go_test
  go mod init vaultarq_go_test &> /dev/null
  
  # Create Go test file
  cat > main.go << 'EOF'
package main

import (
	"fmt"
	"os"
	"strings"

	"../../../../sdks/go-sdk"
)

func main() {
	fmt.Println("Vaultarq Go SDK Test")
	fmt.Println("===================")
	
	// Check if Vaultarq is available
	fmt.Println("\nChecking if Vaultarq is available...")
	if vaultarq.IsAvailable() {
		fmt.Println("✅ Vaultarq is available")
	} else {
		fmt.Println("❌ Vaultarq is not available")
		return
	}
	
	// Initialize Vaultarq
	fmt.Println("\nInitializing Vaultarq...")
	err := vaultarq.Init()
	if err != nil {
		fmt.Printf("❌ Failed to initialize Vaultarq: %v\n", err)
		return
	}
	fmt.Println("✅ Vaultarq initialized successfully")
	
	// Try to get test environment variables
	fmt.Println("\nReading environment variables...")
	testVars := []string{"TEST_API_KEY", "TEST_DATABASE_URL"}
	
	for _, varName := range testVars {
		value := os.Getenv(varName)
		if value != "" {
			var masked string
			if len(value) > 4 {
				masked = value[0:4] + "***"
			} else {
				masked = "***"
			}
			fmt.Printf("✅ %s = %s\n", varName, masked)
		} else {
			fmt.Printf("❌ %s not found\n", varName)
		}
	}
	
	fmt.Println("\nGo SDK test completed")
}
EOF
  
  # Run the test
  echo "Running Go example..."
  if go run main.go; then
    echo -e "\n${GREEN}✅ Go SDK test completed${NC}"
  else
    echo -e "${RED}❌ Failed to run Go example${NC}"
  fi
  
  # Clean up
  cd ../../
  rm -rf "$TEMP_DIR"
  echo
}

# Main function
main() {
  # Check if CLI is available
  if ! check_cli; then
    echo
    echo -e "${RED}❌ Vaultarq CLI is required for SDK tests${NC}"
    echo "Please install the CLI first"
    exit 1
  fi
  
  echo
  
  # Create test vault
  create_test_vault
  
  # Run SDK tests
  test_rust_sdk
  test_node_sdk
  test_python_sdk
  test_go_sdk
  
  # Summary
  echo "====================================="
  echo "SDK Test Summary"
  echo "====================================="
  echo -e "${GREEN}✅ Examples demonstrate how to use each SDK with the CLI${NC}"
  echo
  echo "Key points for SDK integration:"
  echo "1. Each SDK provides an is_available() function to detect the CLI"
  echo "2. SDKs use the init() function to load secrets from the vault"
  echo "3. After initialization, secrets are available as environment variables"
  echo "4. All SDKs implement a consistent API pattern"
  echo
  echo "For more information, see CLI_SDK_SYNC.md"
}

# Run the main function
main 