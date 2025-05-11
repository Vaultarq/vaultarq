//! # vaultarq
//!
//! A Rust SDK for the Vaultarq secrets manager that seamlessly integrates
//! with Rust applications by automatically loading secrets from a Vaultarq vault
//! and injecting them into the environment.
//!
//! ## Basic Usage
//!
//! ```rust,no_run
//! use vaultarq::init;
//!
//! fn main() {
//!     // Load secrets into environment variables
//!     init().unwrap();
//!
//!     // Now use secrets from environment
//!     println!("API_KEY: {}", std::env::var("API_KEY").unwrap_or_default());
//! }
//! ```

use std::env;
use std::ffi::OsStr;
use std::path::Path;
use std::process::Command;
use thiserror::Error;
use regex::Regex;
use which::which;

/// Errors that can occur when using the Vaultarq SDK.
#[derive(Error, Debug)]
pub enum Error {
    /// Vaultarq CLI is not installed or not in PATH.
    #[error("Vaultarq CLI not found")]
    NotFound,

    /// Failed to execute Vaultarq CLI command.
    #[error("Failed to execute Vaultarq: {0}")]
    ExecutionError(String),

    /// Failed to switch Vaultarq environment.
    #[error("Failed to switch environment: {0}")]
    EnvironmentSwitchError(String),

    /// Invalid format.
    #[error("Invalid format: {0}")]
    InvalidFormat(String),
}

/// Format for exporting secrets.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Format {
    /// Export as `export KEY="VALUE"` statements (default).
    Bash,
    /// Export as `KEY=VALUE` statements.
    Dotenv,
    /// Export as JSON object.
    Json,
}

impl Format {
    /// Convert to string for command-line argument.
    fn as_arg(&self) -> &'static str {
        match self {
            Format::Bash => "--bash",
            Format::Dotenv => "--dotenv",
            Format::Json => "--json",
        }
    }
}

/// Configuration for loading secrets.
#[derive(Debug, Clone)]
pub struct Config {
    /// Path to the Vaultarq executable.
    bin_path: String,
    
    /// Whether to throw an error if Vaultarq is not found.
    throw_if_not_found: bool,
    
    /// Environment to load secrets from.
    environment: Option<String>,
    
    /// Format to export secrets in.
    format: Format,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            bin_path: "vaultarq".to_string(),
            throw_if_not_found: false,
            environment: None,
            format: Format::Bash,
        }
    }
}

impl Config {
    /// Create a new default configuration.
    pub fn new() -> Self {
        Self::default()
    }

    /// Set the path to the Vaultarq executable.
    pub fn with_bin_path(mut self, path: &str) -> Self {
        self.bin_path = path.to_string();
        self
    }

    /// Set whether to throw an error if Vaultarq is not found.
    pub fn with_throw_if_not_found(mut self, throw: bool) -> Self {
        self.throw_if_not_found = throw;
        self
    }

    /// Set the environment to load secrets from.
    pub fn with_environment(mut self, env: &str) -> Self {
        self.environment = Some(env.to_string());
        self
    }

    /// Set the format to export secrets in.
    pub fn with_format(mut self, format: Format) -> Self {
        self.format = format;
        self
    }
}

/// Check if Vaultarq is installed and accessible.
///
/// # Examples
///
/// ```rust,no_run
/// if vaultarq::is_available() {
///     println!("Vaultarq is available");
/// } else {
///     println!("Vaultarq is not available");
/// }
/// ```
pub fn is_available() -> bool {
    is_available_with_path("vaultarq")
}

/// Check if Vaultarq is installed and accessible at the specified path.
///
/// # Examples
///
/// ```rust,no_run
/// if vaultarq::is_available_with_path("/usr/local/bin/vaultarq") {
///     println!("Vaultarq is available at the specified path");
/// } else {
///     println!("Vaultarq is not available at the specified path");
/// }
/// ```
pub fn is_available_with_path<S: AsRef<OsStr>>(bin_path: S) -> bool {
    // If a full path is provided, check if it exists
    let path = Path::new(&bin_path);
    if path.is_absolute() {
        if !path.exists() || !path.is_file() {
            return false;
        }
    } else {
        // Otherwise check if it's in PATH
        if which(&bin_path).is_err() {
            return false;
        }
    }

    // Try running the command
    match Command::new(&bin_path).output() {
        Ok(_) => true,
        Err(_) => false,
    }
}

/// Load secrets from Vaultarq into environment variables using default configuration.
///
/// # Examples
///
/// ```rust,no_run
/// match vaultarq::init() {
///     Ok(_) => println!("Secrets loaded successfully"),
///     Err(e) => eprintln!("Failed to load secrets: {}", e),
/// }
/// ```
pub fn init() -> Result<(), Error> {
    init_with_config(&Config::default())
}

/// Load secrets from Vaultarq into environment variables using custom configuration.
///
/// # Examples
///
/// ```rust,no_run
/// let config = vaultarq::Config::new()
///     .with_environment("prod")
///     .with_throw_if_not_found(true);
///
/// match vaultarq::init_with_config(&config) {
///     Ok(_) => println!("Secrets loaded from 'prod' environment"),
///     Err(e) => eprintln!("Failed to load secrets: {}", e),
/// }
/// ```
pub fn init_with_config(config: &Config) -> Result<(), Error> {
    // Check if vaultarq is available
    if !is_available_with_path(&config.bin_path) {
        if config.throw_if_not_found {
            return Err(Error::NotFound);
        }
        return Ok(());
    }

    // Switch environment if needed
    if let Some(environment) = &config.environment {
        let output = Command::new(&config.bin_path)
            .arg("link")
            .arg(environment)
            .output()
            .map_err(|e| Error::ExecutionError(e.to_string()))?;

        if !output.status.success() {
            let error = String::from_utf8_lossy(&output.stderr);
            return Err(Error::EnvironmentSwitchError(error.to_string()));
        }
    }

    // Get secrets
    let output = Command::new(&config.bin_path)
        .arg("export")
        .arg(config.format.as_arg())
        .output()
        .map_err(|e| Error::ExecutionError(e.to_string()))?;

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        return Err(Error::ExecutionError(error.to_string()));
    }

    // Parse and set environment variables
    let stdout = String::from_utf8_lossy(&output.stdout);
    let lines = stdout.lines().filter(|line| !line.trim().is_empty());

    for line in lines {
        if line.starts_with("export ") {
            // Parse bash format: export KEY="VALUE"
            let re = Regex::new(r#"^export\s+([A-Za-z0-9_]+)="(.*)"$"#).unwrap();
            if let Some(captures) = re.captures(line) {
                let key = captures.get(1).unwrap().as_str();
                let value = captures.get(2).unwrap().as_str();
                env::set_var(key, value);
            }
        } else {
            // Parse dotenv format: KEY=VALUE
            let re = Regex::new(r"^([A-Za-z0-9_]+)=(.*)$").unwrap();
            if let Some(captures) = re.captures(line) {
                let key = captures.get(1).unwrap().as_str();
                let value = captures.get(2).unwrap().as_str();
                // Remove surrounding quotes if they exist
                let value = if value.starts_with('"') && value.ends_with('"') {
                    &value[1..value.len() - 1]
                } else {
                    value
                };
                env::set_var(key, value);
            }
        }
    }

    Ok(())
}