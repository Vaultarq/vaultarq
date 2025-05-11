#!/usr/bin/env python3
"""
Example application using Vaultarq Python SDK
"""

import os
import sys
from vaultarq import load_env, is_available


def main():
    """Main application function"""
    print("Checking if Vaultarq is installed...")
    if not is_available():
        print("❌ Vaultarq is not installed or not in PATH")
        print("Please install Vaultarq and try again:")
        print("curl -fsSL https://raw.githubusercontent.com/Vaultarq/vaultarq/main/install.sh | bash")
        sys.exit(1)
    
    print("✅ Vaultarq is installed")
    print("Loading secrets into environment variables...")
    
    try:
        success = load_env()
        
        if success:
            print("✅ Secrets loaded successfully")
            
            # Print all environment variables loaded from Vaultarq
            print("\nLoaded environment variables:")
            
            found_secrets = False
            
            # Get all environment variables and sort them
            env_vars = sorted(os.environ.items())
            
            for key, value in env_vars:
                # Skip system environment variables for cleaner output
                if (key.startswith("PYTHON") or 
                    key in ("PATH", "PWD", "HOME", "SHELL", "USER", "LANG", "TERM")):
                    continue
                
                print(f"{key}={value}")
                found_secrets = True
            
            if not found_secrets:
                print("No secrets found in Vaultarq vault.")
                print("Try adding some with: vaultarq push API_KEY=my-secret-key")
            else:
                print("\nExample use:")
                print("-----------------------------")
                print("In your application, you can now access these variables using:")
                print("os.environ['API_KEY'], os.environ.get('DB_PASSWORD', 'default'), etc.")
        else:
            print("❌ Failed to load secrets")
            print("Make sure Vaultarq is properly initialized:")
            print("vaultarq init")
    except Exception as e:
        print(f"❌ Error loading secrets: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main() 