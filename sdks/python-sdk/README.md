# Vaultarq

> Python SDK for Vaultarq - The developer-first, invisible secrets manager

This SDK provides a seamless integration with Vaultarq for Python applications, automatically loading secrets from your Vaultarq vault into your application's environment variables.

## Installation

```bash
pip install vaultarq
```

## Requirements

- Vaultarq CLI installed and initialized
- Python 3.7 or higher

## Usage

### Basic Usage

```python
from vaultarq import load_env

# Load secrets into os.environ
load_env()

# Now use secrets from os.environ
import os
print(os.environ["API_KEY"])
```

### With Options

```python
from vaultarq import load_env

# Load secrets with custom options
load_env(
    environment="prod",  # Load secrets from specific environment
    throw_if_not_found=True,  # Throw error if Vaultarq not found
    bin_path="/usr/local/bin/vaultarq"  # Custom path to Vaultarq binary
)
```

### Checking Availability

```python
from vaultarq import is_available, load_env

# Check if Vaultarq is available
if is_available():
    load_env()
else:
    print("Vaultarq not found, using fallback")
    # ... your fallback logic
```

### With Flask Application

```python
from flask import Flask
from vaultarq import load_env

# Load secrets before creating the Flask app
load_env()

app = Flask(__name__)

@app.route('/')
def home():
    import os
    return f"Connected to database: {os.environ.get('DB_NAME', 'unknown')}"

if __name__ == '__main__':
    app.run(debug=True)
```

### With Django

In your `settings.py`:

```python
import os
from vaultarq import load_env

# Load environment variables from Vaultarq
load_env()

# Use secrets in your Django settings
SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY")
DEBUG = os.environ.get("DEBUG", "False").lower() == "true"

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get("DB_NAME"),
        'USER': os.environ.get("DB_USER"),
        'PASSWORD': os.environ.get("DB_PASSWORD"),
        'HOST': os.environ.get("DB_HOST", "localhost"),
        'PORT': os.environ.get("DB_PORT", "5432"),
    }
}
```

## API

### `load_env(options)`

Loads secrets from the Vaultarq vault into `os.environ`.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `bin_path` | `str` | `'vaultarq'` | Path to the Vaultarq executable |
| `throw_if_not_found` | `bool` | `False` | Whether to throw an error if Vaultarq is not found |
| `environment` | `str` | Current linked env | Environment to load secrets from |
| `format` | `str` | `'bash'` | Format to export secrets in (`'bash'`, `'dotenv'`, or `'json'`) |

Returns:
- `True` if secrets were successfully loaded
- `False` if loading failed (e.g., Vaultarq not installed)

### `is_available(bin_path='vaultarq')`

Checks if Vaultarq is installed and accessible.

Returns `True` if Vaultarq is available, `False` otherwise.

## License

MIT 