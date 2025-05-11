# @vaultarq/node

> Node.js SDK for Vaultarq - The developer-first, invisible secrets manager

This SDK provides a seamless integration with Vaultarq for Node.js applications, automatically loading secrets from your Vaultarq vault into your application's `process.env`.

## Installation

```bash
npm install @vaultarq/node
# or
yarn add @vaultarq/node
# or
pnpm add @vaultarq/node
```

## Requirements

- Vaultarq CLI installed and initialized
- Node.js 14 or higher

## Usage

### Basic Usage

```typescript
import vaultarq from '@vaultarq/node';

// Load secrets into process.env
await vaultarq.load();

// Now use secrets from process.env
console.log(process.env.API_KEY);
```

### With Options

```typescript
import vaultarq from '@vaultarq/node';

// Load secrets with custom options
await vaultarq.load({
  environment: 'prod',  // Load secrets from specific environment
  throwIfNotFound: true,  // Throw error if Vaultarq not found
  binPath: '/usr/local/bin/vaultarq'  // Custom path to Vaultarq binary
});
```

### Checking Availability

```typescript
import vaultarq from '@vaultarq/node';

// Check if Vaultarq is available
const isAvailable = await vaultarq.isAvailable();

if (isAvailable) {
  await vaultarq.load();
} else {
  console.log('Vaultarq not found, using fallback');
  // ... your fallback logic
}
```

### With Express.js Application

```typescript
import express from 'express';
import vaultarq from '@vaultarq/node';

async function startServer() {
  // Load secrets before starting the app
  await vaultarq.load();
  
  const app = express();
  
  app.get('/', (req, res) => {
    res.send(`Connected to database: ${process.env.DB_NAME}`);
  });
  
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

startServer().catch(console.error);
```

## API

### `vaultarq.load(options?): Promise<boolean>`

Loads secrets from the Vaultarq vault into `process.env`.

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `binPath` | `string` | `'vaultarq'` | Path to the Vaultarq executable |
| `throwIfNotFound` | `boolean` | `false` | Whether to throw an error if Vaultarq is not found |
| `environment` | `string` | Current linked env | Environment to load secrets from |
| `format` | `'bash'`, `'dotenv'`, or `'json'` | `'bash'` | Format to export secrets in |

Returns a `Promise` that resolves to:
- `true` if secrets were successfully loaded
- `false` if loading failed (e.g., Vaultarq not installed)

### `vaultarq.isAvailable(binPath?): Promise<boolean>`

Checks if Vaultarq is installed and accessible.

## License

MIT

## Author

Dedan Okware (softengdedan@gmail.com) 