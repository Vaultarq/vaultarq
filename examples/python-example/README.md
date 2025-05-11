# Vaultarq Python Example

This is an example application demonstrating how to use the `vaultarq` Python SDK to load secrets from Vaultarq into your Python application.

## Prerequisites

- Python 3.7+
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
pip install -r requirements.txt
```

## Running the Example

```bash
python app.py
```

This will:
1. Check if Vaultarq is installed
2. Load secrets from Vaultarq into environment variables
3. Display the loaded environment variables

## How It Works

The example uses the `vaultarq` Python SDK to:

1. Check if Vaultarq is available with `is_available()`
2. Load secrets into `os.environ` with `load_env()`
3. Display the environment variables for demonstration

In a real application, you would typically load the secrets at startup and then use them throughout your application via `os.environ["VARIABLE_NAME"]` or `os.environ.get("VARIABLE_NAME", "default_value")`. 