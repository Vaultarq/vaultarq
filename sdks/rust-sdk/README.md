# vaultarq

> Rust SDK for Vaultarq - The developer-first, invisible secrets manager

This SDK provides a seamless integration with Vaultarq for Rust applications, automatically loading secrets from your Vaultarq vault into your application's environment variables.

## Installation

Add this to your `Cargo.toml`:

```toml
[dependencies]
vaultarq = "0.1.0"
```

## Requirements

- Vaultarq CLI installed and initialized
- Rust 1.56 or higher (for edition 2021)

## Usage

### Basic Usage

```rust
use vaultarq::init;

fn main() {
    // Load secrets into environment variables
    init().unwrap();
    
    // Now use secrets from environment
    println!("API_KEY: {}", std::env::var("API_KEY").unwrap_or_default());
}
```

### With Options

```rust
use vaultarq::{Config, init_with_config};

fn main() {
    // Configure options
    let config = Config::new()
        .with_environment("prod")
        .with_bin_path("/usr/local/bin/vaultarq")
        .with_throw_if_not_found(true);
    
    // Load secrets with custom config
    init_with_config(&config).unwrap();
}
```

### Checking Availability

```rust
use vaultarq::{init, is_available};

fn main() {
    // Check if Vaultarq is available
    if is_available() {
        init().unwrap();
    } else {
        println!("Vaultarq not found, using fallback");
        // ... your fallback logic
    }
}
```

### With Actix Web

```rust
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use vaultarq::init;

async fn index() -> impl Responder {
    let db_name = std::env::var("DB_NAME").unwrap_or_else(|_| "unknown".to_string());
    HttpResponse::Ok().body(format!("Connected to database: {}", db_name))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Load secrets before starting the server
    init().unwrap_or_else(|e| {
        eprintln!("Failed to load secrets: {}", e);
        // Continue anyway
    });
    
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(index))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
```

## API

### `init() -> Result<(), Error>`

Loads secrets from the Vaultarq vault into environment variables using default configuration.

### `init_with_config(config: &Config) -> Result<(), Error>`

Loads secrets from the Vaultarq vault into environment variables using custom configuration.

### `is_available() -> bool`

Checks if Vaultarq is installed and accessible.

### `Config`

Configuration struct for customizing how secrets are loaded.

#### Methods

- `new() -> Config`: Creates a new configuration with default values
- `with_bin_path(path: &str) -> Self`: Sets the path to the Vaultarq executable
- `with_throw_if_not_found(throw: bool) -> Self`: Sets whether to throw an error if Vaultarq is not found
- `with_environment(env: &str) -> Self`: Sets the environment to load secrets from
- `with_format(format: Format) -> Self`: Sets the format to export secrets in

### `Format`

Enum for specifying the export format:
- `Format::Bash` (default): Export as `export KEY="VALUE"` statements
- `Format::Dotenv`: Export as `KEY=VALUE` statements
- `Format::Json`: Export as JSON object

## License

MIT 