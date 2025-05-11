use std::env;
use std::process;
use vaultarq::{init, is_available};

fn main() {
    println!("Checking if Vaultarq is installed...");
    if !is_available() {
        println!("❌ Vaultarq is not installed or not in PATH");
        println!("Please install Vaultarq and try again:");
        println!("curl -fsSL https://raw.githubusercontent.com/Vaultarq/vaultarq/main/install.sh | bash");
        process::exit(1);
    }
    
    println!("✅ Vaultarq is installed");
    println!("Loading secrets into environment variables...");
    
    match init() {
        Ok(_) => {
            println!("✅ Secrets loaded successfully");
            
            // Print all environment variables loaded from Vaultarq
            println!("\nLoaded environment variables:");
            
            let mut found_secrets = false;
            
            // Get all environment variables and sort them
            let mut vars: Vec<(String, String)> = env::vars().collect();
            vars.sort_by(|a, b| a.0.cmp(&b.0));
            
            for (key, value) in vars {
                // Skip system environment variables for cleaner output
                if key.starts_with("CARGO_") || 
                   key.starts_with("RUST_") || 
                   key == "PATH" || 
                   key == "PWD" || 
                   key == "HOME" || 
                   key == "SHELL" {
                    continue;
                }
                
                println!("{}={}", key, value);
                found_secrets = true;
            }
            
            if !found_secrets {
                println!("No secrets found in Vaultarq vault.");
                println!("Try adding some with: vaultarq push API_KEY=my-secret-key");
            } else {
                println!("\nExample use:");
                println!("-----------------------------");
                println!("In your application, you can now access these variables using:");
                println!("std::env::var(\"API_KEY\").unwrap_or_default()");
            }
        },
        Err(e) => {
            println!("❌ Failed to load secrets: {}", e);
            println!("Make sure Vaultarq is properly initialized:");
            println!("vaultarq init");
            process::exit(1);
        }
    }
} 