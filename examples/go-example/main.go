package main

import (
	"fmt"
	"os"
	"sort"
	"strings"
	
	"github.com/Vaultarq/go"
)

func main() {
	fmt.Println("Checking if Vaultarq is installed...")
	if !vaultarq.IsAvailable() {
		fmt.Println("❌ Vaultarq is not installed or not in PATH")
		fmt.Println("Please install Vaultarq and try again:")
		fmt.Println("curl -fsSL https://raw.githubusercontent.com/Vaultarq/vaultarq/main/install.sh | bash")
		os.Exit(1)
	}
	
	fmt.Println("✅ Vaultarq is installed")
	fmt.Println("Loading secrets into environment variables...")
	
	err := vaultarq.Load()
	if err != nil {
		fmt.Printf("❌ Failed to load secrets: %s\n", err)
		fmt.Println("Make sure Vaultarq is properly initialized:")
		fmt.Println("vaultarq init")
		os.Exit(1)
	}
	
	fmt.Println("✅ Secrets loaded successfully")
	
	// Print all environment variables loaded from Vaultarq
	fmt.Println("\nLoaded environment variables:")
	
	// Get all environment variables
	envVars := os.Environ()
	
	// Convert to a map for easier filtering and sorting
	envMap := make(map[string]string)
	for _, envVar := range envVars {
		parts := strings.SplitN(envVar, "=", 2)
		if len(parts) == 2 {
			key := parts[0]
			value := parts[1]
			envMap[key] = value
		}
	}
	
	// Sort keys for consistent output
	var keys []string
	for key := range envMap {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	
	// Skip system environment variables
	foundSecrets := false
	for _, key := range keys {
		// Skip system environment variables for cleaner output
		if strings.HasPrefix(key, "GO") || 
		   strings.HasPrefix(key, "PATH") || 
		   key == "PWD" || 
		   key == "HOME" || 
		   key == "SHELL" || 
		   key == "USER" || 
		   key == "TERM" {
			continue
		}
		
		fmt.Printf("%s=%s\n", key, envMap[key])
		foundSecrets = true
	}
	
	if !foundSecrets {
		fmt.Println("No secrets found in Vaultarq vault.")
		fmt.Println("Try adding some with: vaultarq push API_KEY=my-secret-key")
	} else {
		fmt.Println("\nExample use:")
		fmt.Println("-----------------------------")
		fmt.Println("In your application, you can now access these variables using:")
		fmt.Println("os.Getenv(\"API_KEY\")")
	}
} 