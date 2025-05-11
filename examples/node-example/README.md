# Vaultarq Node.js Example

This is an example application demonstrating how to use the `@vaultarq/node` SDK to load secrets from Vaultarq into your Node.js application.

## Prerequisites

- Node.js 14+
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

2. Install dependencies:

```bash
npm install
```

## Running the Example

```bash
npm start
```

This will:
1. Check if Vaultarq is installed
2. Load secrets from Vaultarq into `process.env`
3. Display the loaded environment variables

## How It Works

The example uses the `@vaultarq/node` SDK to:

1. Check if Vaultarq is available
2. Load secrets into `process.env`
3. Display the environment variables for demonstration

In a real application, you would typically load the secrets at startup and then use them throughout your application via `process.env.VARIABLE_NAME`. 