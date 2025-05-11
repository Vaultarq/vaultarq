# Vaultarq Docker Guide

This guide explains how to use Vaultarq with Docker, allowing you to run both Vaultarq itself and applications that depend on it without needing external hosting.

## Quick Start

1. Set up the Docker environment:

```bash
./bin/setup-docker.sh
```

2. Initialize your Vaultarq vault:

```bash
./vaultarq-docker.sh init
```

3. Add some secrets:

```bash
./vaultarq-docker.sh push API_KEY=my-secret-key
./vaultarq-docker.sh push DB_PASSWORD=secure-db-password
```

4. Run the example application to verify it can access the secrets:

```bash
docker-compose run example
```

## How It Works

This Docker setup includes:

1. **Vaultarq container**: A containerized version of the Vaultarq CLI
2. **Persistent volume**: Stores your encrypted vault data across container restarts
3. **Example application**: Demonstrates accessing Vaultarq secrets from another container

## Using With Your Own Applications

To use Vaultarq with your own applications:

1. Add your application to `docker-compose.yml`:

```yaml
myapp:
  image: your-app-image
  volumes:
    - vaultarq_data:/root/.vaultarq
    - ./bin/vaultarq:/vaultarq
  environment:
    - VAULTARQ_BIN_PATH=/vaultarq
```

2. In your application code, use the appropriate Vaultarq SDK:

```javascript
// Node.js example
const vaultarq = require('@vaultarq/node').default;
await vaultarq.load({
  binPath: process.env.VAULTARQ_BIN_PATH || 'vaultarq'
});
```

## Managing Environments

You can manage multiple environments (dev, staging, prod):

```bash
# Switch to production environment
./vaultarq-docker.sh link prod

# Add production secrets
./vaultarq-docker.sh push API_KEY=prod-api-key
```

## Backup and Restore

The vault data is stored in a Docker volume named `vaultarq_data`. To backup:

```bash
docker run --rm -v vaultarq_data:/data -v $(pwd):/backup busybox tar czf /backup/vaultarq-backup.tar.gz /data
```

To restore:

```bash
docker run --rm -v vaultarq_data:/data -v $(pwd):/backup busybox tar xzf /backup/vaultarq-backup.tar.gz -C /
```

## Security Considerations

- The vault password is still required to decrypt the vault
- Use Docker secrets or another secure method to provide the password in production
- Consider mounting the vault volume as read-only for application containers 