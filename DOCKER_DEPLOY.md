# Docker Deployment and SDK Synchronization

This document outlines how Vaultarq is deployed using Docker and how synchronization is maintained between the CLI and SDKs.

## Docker-Based Distribution

Vaultarq uses a Docker-based distribution method to ensure consistent behavior across platforms. This approach provides several advantages:

1. **Cross-platform compatibility**: Works on any system with Docker installed
2. **Consistent environment**: Eliminates "works on my machine" issues
3. **Simplified installation**: Single command installation
4. **Automatic updates**: Latest version is always available

## Installation Methods

Users can install Vaultarq in several ways:

### 1. Docker-Based Script (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/Vaultarq/vaultarq/main/docker-install.sh | bash
```

This method:
- Creates a wrapper script that uses Docker behind the scenes
- Mounts the necessary directories for persistent storage
- Handles all Docker command complexity for users

### 2. Direct Docker Usage

```bash
docker run --rm -v "${HOME}/.vaultarq:/root/.vaultarq" -v "${PWD}:/workdir" -w /workdir vaultarq/cli:latest <command>
```

### 3. Manual Installation

For users who prefer traditional installation:

```bash
git clone https://github.com/Vaultarq/vaultarq.git
cd vaultarq
./install.sh
```

## Continuous Integration and Deployment

The project uses a GitHub Actions workflow for CI/CD:

1. **Synchronization Check**: Ensures CLI and SDKs are in sync
2. **Docker Image Building**: Creates and publishes Docker images to Docker Hub
3. **Installation Script Deployment**: Updates the installation script
4. **README Updates**: Keeps README installation instructions current

## SDK Synchronization

The synchronization between the CLI and SDKs is maintained through:

1. **Version Consistency**: All components share the same version number
2. **Vault Format Compatibility**: All SDKs use the same vault format
3. **CLI Detection**: SDKs check for CLI availability
4. **Automated Testing**: CI/CD pipeline verifies compatibility

## Usage in Docker Environments

For users running in containerized environments, Vaultarq works seamlessly:

```yaml
# docker-compose.yml example
services:
  app:
    image: your-app
    volumes:
      - vaultarq_data:/root/.vaultarq
    environment:
      - VAULTARQ_BIN_PATH=/usr/local/bin/vaultarq

volumes:
  vaultarq_data:
```

## Development Workflow

When developing Vaultarq:

1. Make changes to CLI and/or SDKs
2. Run `./update_versions.sh <new_version>` to update all versions
3. Run `./sync_check.sh` to verify synchronization
4. Push changes to trigger CI/CD pipeline
5. Create a new tag (e.g., `v0.2.0`) to trigger release process

## Deployment Architecture

```
┌────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                │     │                 │     │                 │
│  GitHub Repo   │────▶│  GitHub Actions │────▶│  Docker Hub     │
│                │     │                 │     │                 │
└────────────────┘     └─────────────────┘     └────────┬────────┘
                                                        │
                                                        ▼
┌────────────────┐     ┌─────────────────┐
│                │     │                 │
│  User Machine  │◀────│  GitHub Raw URL │
│                │     │                 │
└────────────────┘     └─────────────────┘
```

## Troubleshooting

If you encounter issues with the Docker-based installation:

1. Ensure Docker is installed and running
2. Check if the user has permissions to run Docker commands
3. Verify that the necessary volumes are being mounted correctly
4. Ensure network connectivity to access the Docker registry 