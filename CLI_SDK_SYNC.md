# Vaultarq CLI and SDK Synchronization Guide

This document outlines best practices for maintaining synchronization between the Vaultarq CLI and the various language SDKs. Proper synchronization ensures a consistent developer experience across all Vaultarq components.

## Architecture Overview

Vaultarq consists of two main components:

1. **CLI Tool**: The command-line interface for vault management operations such as creating vaults, adding secrets, and switching environments.
2. **Language SDKs**: Libraries in various programming languages (Rust, Node.js, Python, Go) that enable applications to interact with Vaultarq vaults.

## Synchronization Requirements

The following aspects must remain synchronized between CLI and SDKs:

### 1. Vault Format

- The vault file format (structure, encryption, location) must be compatible across CLI and all SDKs
- Changes to the vault format in the CLI must be reflected in all SDKs
- Location pattern is typically `~/.vaultarq/vault.json.enc`

### 2. Version Numbering

- CLI and SDK versions should align using semantic versioning
- Major version bumps indicate breaking changes requiring updates to all components
- When publishing a new CLI version, all SDKs should be updated and released with the same version number

### 3. CLI Detection

- All SDKs should have a reliable method to detect if the CLI is installed (e.g., `is_available()` function)
- SDKs should provide helpful error messages when the CLI is not found

### 4. Environment Variables

- Environment variable handling should be consistent between CLI and SDKs
- Format of exported variables should match across all components

## Implementation Guidelines

### For CLI Development

1. **Document Changes**: When modifying the CLI, document all changes that might affect SDKs
2. **Vault Schema Versioning**: Include a version field in the vault schema for compatibility checks
3. **Maintain Backward Compatibility**: When possible, ensure new CLI versions can read older vault formats
4. **Release Process**: Bump all version numbers together (CLI and SDKs)

### For SDK Development

1. **CLI Dependency**: Clearly document whether the SDK requires the CLI or can function independently
2. **Vault Access**: Implement consistent methods for accessing vault contents
3. **Error Handling**: Provide user-friendly error messages that suggest installing/updating the CLI if needed
4. **Feature Parity**: Ensure all SDKs support the same core features

### Sync Check Script

Use the provided `sync_check.sh` script to verify synchronization between CLI and SDKs:

```bash
# Make the script executable
chmod +x sync_check.sh

# Run the synchronization check
./sync_check.sh
```

## Best Practices for Specific Languages

### Rust SDK

```rust
// Check if CLI is available
pub fn is_available() -> bool {
    // Implementation should check if the vaultarq CLI is in PATH and executable
}

// Get version information
pub fn get_version() -> Result<String, Error> {
    // Should return the same version as the CLI
}

// Initialize with CLI detection
pub fn init() -> Result<(), Error> {
    if !is_available() {
        return Err(Error::CLINotFound("Vaultarq CLI not found. Please install it first."));
    }
    // Rest of implementation
}
```

### Node.js SDK

```javascript
// Check if CLI is available
function isAvailable() {
  // Implementation should check if the vaultarq CLI is in PATH and executable
}

// Get version information
function getVersion() {
  // Should return the same version as the CLI
}

// Initialize with CLI detection
function init() {
  if (!isAvailable()) {
    throw new Error('Vaultarq CLI not found. Please install it first.');
  }
  // Rest of implementation
}
```

### Python SDK

```python
# Check if CLI is available
def is_available():
    # Implementation should check if the vaultarq CLI is in PATH and executable
    pass

# Get version information
def get_version():
    # Should return the same version as the CLI
    pass

# Initialize with CLI detection
def init():
    if not is_available():
        raise RuntimeError("Vaultarq CLI not found. Please install it first.")
    # Rest of implementation
```

### Go SDK

```go
// Check if CLI is available
func IsAvailable() bool {
    // Implementation should check if the vaultarq CLI is in PATH and executable
}

// Get version information
func GetVersion() (string, error) {
    // Should return the same version as the CLI
}

// Initialize with CLI detection
func Init() error {
    if !IsAvailable() {
        return fmt.Errorf("Vaultarq CLI not found. Please install it first")
    }
    // Rest of implementation
}
```

## Troubleshooting

If synchronization issues are detected:

1. Check version numbers across all components
2. Verify vault format compatibility
3. Test CLI detection mechanisms
4. Ensure environment variable handling is consistent

## When Publishing Updates

1. Update all version numbers simultaneously
2. Run the sync check script before publishing
3. Update documentation to reflect any changes
4. Test with each supported language

By following these guidelines, you'll maintain a consistent experience for developers using Vaultarq across different languages and environments. 