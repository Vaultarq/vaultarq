# Vaultarq

> A developer-first, invisible secrets manager that replaces .env files and injects secrets into any shell or application without changing the code.

Vaultarq allows developers to store secrets once and access them instantly in any shell-based environment (Bash, Zsh, CI, Docker, etc.). It replaces the need for .env files by generating export-ready scripts securely from an encrypted vault file.

## Features

- **Zero friction**: Works seamlessly with any shell environment (Bash, Zsh, CI/CD)
- **Encrypted storage**: AES-256-GCM encryption with Argon2id key derivation
- **Environment isolation**: Easily switch between dev, staging, prod environments
- **Shell-friendly**: Focus on bash-first workflows
- **Portable**: One self-contained CLI tool
- **Secure by default**: No secrets in plain text, only encrypted at rest
- **Multi-language SDKs**: Native integration for Node.js, Python, Rust, and Go

## Installation

### Quick Install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/Vaultarq/vaultarq/main/install.sh | bash
```

This installs Vaultarq to `~/.local/bin/vaultarq` by default. You can specify a different install location:

```bash
curl -fsSL https://raw.githubusercontent.com/Vaultarq/vaultarq/main/install.sh | bash -s -- /usr/local/bin
```

### Manual Installation

```bash
git clone https://github.com/Vaultarq/vaultarq.git
cd vaultarq
./install.sh
```

## Quick Start

1. **Create a new vault**:
   ```bash
   vaultarq init
   ```
   You'll be prompted to set a master password.

2. **Add secrets**:
   ```bash
   vaultarq push API_KEY=abc123
   vaultarq push DB_PASSWORD=supersecure
   ```

3. **Load secrets into your shell**:
   ```bash
   vaultarq pull
   source env/env.sh
   ```

4. **Or use directly in a command**:
   ```bash
   eval "$(vaultarq export --bash)"
   node app.js
   ```

5. **Switch environments**:
   ```bash
   vaultarq link prod
   vaultarq push API_KEY=prod_abc123
   ```

## Usage Examples

### Working with Multiple Environments

```bash
# Create a new vault
vaultarq init

# Add dev secrets (dev is the default environment)
vaultarq push API_KEY=dev_key
vaultarq push DB_PASS=dev_pass

# Switch to prod environment
vaultarq link prod

# Add prod secrets
vaultarq push API_KEY=prod_key
vaultarq push DB_PASS=prod_pass

# View available secrets
vaultarq list

# View secret values (be careful!)
vaultarq list --values
```

### Using in CI/CD Pipeline

```bash
# In your CI script
echo "$VAULT_PASSWORD" | vaultarq pull
source env/env.sh
npm run test
```

### Injecting Into Docker Containers

```bash
# Build with env vars
docker build -t myapp .

# Run with env vars from vaultarq
docker run --rm -it $(vaultarq export --dotenv | xargs -I{} echo "-e {}") myapp
```

## Language SDKs

Vaultarq provides official SDKs for multiple programming languages, making it easy to integrate with your application without changing any code.

### Node.js SDK

```bash
# Install from npm
npm install @vaultarq/node
```

```javascript
// Use in your code
import vaultarq from '@vaultarq/node';

// Load secrets into process.env
await vaultarq.load();

// Now use secrets from process.env
console.log(process.env.API_KEY);
```

### Python SDK

```bash
# Install from PyPI
pip install vaultarq
```

```python
# Use in your code
from vaultarq import load_env

# Load secrets into os.environ
load_env()

# Now use secrets from os.environ
import os
print(os.environ["API_KEY"])
```

### Rust SDK

```toml
# Add to your Cargo.toml
[dependencies]
vaultarq = "0.1.0"
```

```rust
// Use in your code
use vaultarq::init;

fn main() {
    // Load secrets into environment variables
    init().unwrap();
    
    // Now use secrets from environment
    println!("API_KEY: {}", std::env::var("API_KEY").unwrap_or_default());
}
```

### Go SDK

```bash
# Add to your project
go get github.com/Vaultarq/go
```

```go
// Use in your code
package main

import (
    "fmt"
    "os"
    
    "github.com/Vaultarq/go"
)

func main() {
    // Load secrets into environment variables
    vaultarq.Load()
    
    // Now use secrets from environment
    fmt.Println("API_KEY:", os.Getenv("API_KEY"))
}
```

## Command Reference

| Command | Description |
|---------|-------------|
| `vaultarq init` | Create a new encrypted vault |
| `vaultarq push KEY=VALUE` | Add/update secrets to the vault |
| `vaultarq pull` | Load secrets into current shell |
| `vaultarq export` | Output secrets as `export VAR=value` statements |
| `vaultarq link ENV` | Set active environment (dev/prod/etc.) |
| `vaultarq list` | List secrets in vault |
| `vaultarq open` | Show vault path or current env info |

## Security

- All secrets are stored in an encrypted vault file using AES-256-GCM
- Master password is never stored; must be entered for each operation
- Password-derived key using Argon2id with memory-hard KDF
- Vault file is protected against tampering with GCM authentication
- Only temporary exports to memory or shell-sourced files

## Vault Storage

- Local encrypted file: `~/.vaultarq/vault.json.enc`
- JSON structure per environment:
  ```json
  {
    "dev": { "STRIPE_KEY": "...", "DB_PASS": "..." },
    "prod": { "STRIPE_KEY": "...", "DB_PASS": "..." }
  }
  ```

## Requirements

- Bash
- Node.js (for encryption/decryption)
- jq (for JSON manipulation)

## License

MIT 

## Author

Dedan Okware (softengdedan@gmail.com) 