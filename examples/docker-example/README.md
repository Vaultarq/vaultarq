# Vaultarq Docker Example

This example demonstrates how to use Vaultarq in a containerized web application.

## Prerequisites

1. Docker and Docker Compose installed
2. Vaultarq setup for Docker (run `../../bin/setup-docker.sh` from the main project directory)

## Setup

1. First, initialize Vaultarq and add some secrets:

```bash
# From the project root
./vaultarq-docker.sh init
./vaultarq-docker.sh push API_KEY=my-secret-api-key
./vaultarq-docker.sh push DB_PASSWORD=supersecure
```

2. Build and start the example application:

```bash
cd examples/docker-example
docker-compose up --build
```

3. Visit http://localhost:3000 in your browser to see the secrets loaded into the application.

## How It Works

This example demonstrates:

1. A Node.js Express application running in a Docker container
2. Using the Vaultarq Node.js SDK to load secrets
3. Mounting the Vaultarq binary and vault data volume from the main container

The key components are:

- **Dockerfile**: Defines the container for running the web application
- **docker-compose.yml**: Sets up the container with access to Vaultarq
- **server.js**: The Express application that loads secrets using Vaultarq

## Security Note

This example only displays the names of environment variables for demonstration purposes, not their values. In a real application, you would never expose secret values to users. 