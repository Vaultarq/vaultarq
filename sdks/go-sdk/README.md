# vaultarq/go

> Go SDK for Vaultarq - The developer-first, invisible secrets manager

This SDK provides a seamless integration with Vaultarq for Go applications, automatically loading secrets from your Vaultarq vault into your application's environment variables.

## Installation

```bash
go get github.com/vaultarq/go
```

## Requirements

- Vaultarq CLI installed and initialized
- Go 1.16 or higher

## Usage

### Basic Usage

```go
package main

import (
	"fmt"
	"os"
	
	"github.com/vaultarq/go"
)

func main() {
	// Load secrets into environment variables
	err := vaultarq.Load()
	if err != nil {
		fmt.Println("Error loading secrets:", err)
		return
	}
	
	// Now use secrets from environment
	fmt.Println("API_KEY:", os.Getenv("API_KEY"))
}
```

### With Options

```go
package main

import (
	"fmt"
	"os"
	
	"github.com/vaultarq/go"
)

func main() {
	// Configure options
	config := &vaultarq.Config{
		Environment:     "prod",
		ThrowIfNotFound: true,
		BinPath:         "/usr/local/bin/vaultarq",
	}
	
	// Load secrets with custom config
	err := vaultarq.LoadWithConfig(config)
	if err != nil {
		fmt.Println("Error loading secrets:", err)
		return
	}
	
	// Use secrets
	fmt.Println("PROD_DB_URL:", os.Getenv("PROD_DB_URL"))
}
```

### Checking Availability

```go
package main

import (
	"fmt"
	
	"github.com/vaultarq/go"
)

func main() {
	// Check if Vaultarq is available
	if vaultarq.IsAvailable() {
		fmt.Println("Vaultarq is available")
		vaultarq.Load()
	} else {
		fmt.Println("Vaultarq not found, using fallback")
		// ... your fallback logic
	}
}
```

### With Web Server

```go
package main

import (
	"fmt"
	"net/http"
	"os"
	
	"github.com/vaultarq/go"
)

func main() {
	// Load secrets before starting the server
	err := vaultarq.Load()
	if err != nil {
		fmt.Println("Error loading secrets:", err)
		return
	}
	
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		dbName := os.Getenv("DB_NAME")
		if dbName == "" {
			dbName = "unknown"
		}
		fmt.Fprintf(w, "Connected to database: %s", dbName)
	})
	
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	
	fmt.Printf("Server running on port %s\n", port)
	http.ListenAndServe(":"+port, nil)
}
```

## API

### `Load() error`

Loads secrets from the Vaultarq vault into environment variables using default configuration.

### `LoadWithConfig(config *Config) error`

Loads secrets from the Vaultarq vault into environment variables using custom configuration.

### `IsAvailable() bool`

Checks if Vaultarq is installed and accessible.

### `IsAvailableWithPath(binPath string) bool`

Checks if Vaultarq is installed and accessible at the specified path.

### `Config` struct

Configuration options for loading secrets:

- `BinPath string`: Path to the Vaultarq executable (default: "vaultarq")
- `ThrowIfNotFound bool`: Whether to throw an error if Vaultarq is not found (default: false)
- `Environment string`: Environment to load secrets from (default: current linked env)
- `Format string`: Format to export secrets in (default: "bash")

## License

MIT 