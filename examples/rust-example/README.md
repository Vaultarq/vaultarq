# Vaultarq Rust Example

This is an example application demonstrating how to use the `vaultarq` Rust SDK to load secrets from Vaultarq into your Rust application.

## Prerequisites

- Rust toolchain (cargo, rustc)
- Vaultarq installed and initialized

## Setup

1. Make sure you have Vaultarq installed and initialized:

```bash
# Install Vaultarq
curl -fsSL https://raw.githubusercontent.com/Vaultarq/vaultarq/main/install.sh | bash

# Initialize a vault and add some secrets
vaultarq init
vaultarq push API_KEY=my-secret-api-key
vaultarq push DB_PASSWORD=supersecure
```

## Running the Example

```bash
cargo run
```

This will:
1. Check if Vaultarq is installed
2. Load secrets from Vaultarq into environment variables
3. Display the loaded environment variables

## How It Works

The example uses the `vaultarq` Rust SDK to:

1. Check if Vaultarq is available with `is_available()`
2. Load secrets into environment variables with `init()`
3. Display the environment variables for demonstration

In a real application, you would typically load the secrets at startup and then use them throughout your application via `std::env::var("VARIABLE_NAME").unwrap_or_default()`. 