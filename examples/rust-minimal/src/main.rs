//! RSR-Compliant Rust Example: Configuration Validator
//!
//! This example demonstrates RSR principles:
//! - Type safety (Rust's type system)
//! - Memory safety (ownership model, zero unsafe)
//! - Offline-first (no network calls)
//! - Zero dependencies (std only)
//! - Comprehensive error handling

use std::collections::HashMap;
use std::error::Error;
use std::fmt;
use std::fs;
use std::io::{self, Write};

/// Configuration validation error types
#[derive(Debug)]
enum ConfigError {
    IoError(io::Error),
    ParseError(String),
    ValidationError(String),
}

impl fmt::Display for ConfigError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            ConfigError::IoError(e) => write!(f, "IO error: {}", e),
            ConfigError::ParseError(msg) => write!(f, "Parse error: {}", msg),
            ConfigError::ValidationError(msg) => write!(f, "Validation error: {}", msg),
        }
    }
}

impl Error for ConfigError {}

impl From<io::Error> for ConfigError {
    fn from(error: io::Error) -> Self {
        ConfigError::IoError(error)
    }
}

/// Simple key-value configuration
#[derive(Debug, PartialEq)]
struct Config {
    entries: HashMap<String, String>,
}

impl Config {
    /// Create a new empty configuration
    fn new() -> Self {
        Config {
            entries: HashMap::new(),
        }
    }

    /// Parse configuration from string (simple KEY=VALUE format)
    fn parse(content: &str) -> Result<Self, ConfigError> {
        let mut config = Config::new();

        for (line_num, line) in content.lines().enumerate() {
            let trimmed = line.trim();

            // Skip empty lines and comments
            if trimmed.is_empty() || trimmed.starts_with('#') {
                continue;
            }

            // Parse KEY=VALUE
            let parts: Vec<&str> = trimmed.splitn(2, '=').collect();
            if parts.len() != 2 {
                return Err(ConfigError::ParseError(format!(
                    "Line {}: Expected KEY=VALUE format",
                    line_num + 1
                )));
            }

            let key = parts[0].trim();
            let value = parts[1].trim();

            if key.is_empty() {
                return Err(ConfigError::ParseError(format!(
                    "Line {}: Key cannot be empty",
                    line_num + 1
                )));
            }

            config.entries.insert(key.to_string(), value.to_string());
        }

        Ok(config)
    }

    /// Validate configuration against required keys
    fn validate(&self, required_keys: &[&str]) -> Result<(), ConfigError> {
        for key in required_keys {
            if !self.entries.contains_key(*key) {
                return Err(ConfigError::ValidationError(format!(
                    "Missing required key: {}",
                    key
                )));
            }
        }
        Ok(())
    }

    /// Get a value by key
    fn get(&self, key: &str) -> Option<&String> {
        self.entries.get(key)
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = std::env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: {} <config-file>", args[0]);
        eprintln!("\nRSR-Compliant Configuration Validator");
        eprintln!("Validates simple KEY=VALUE configuration files");
        std::process::exit(1);
    }

    let filename = &args[1];
    let content = fs::read_to_string(filename)?;
    let config = Config::parse(&content)?;

    // Example validation: require certain keys
    let required = ["name", "version"];
    config.validate(&required)?;

    println!("✅ Configuration valid!");
    println!("\nParsed {} entries:", config.entries.len());
    for (key, value) in &config.entries {
        println!("  {} = {}", key, value);
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_valid_config() {
        let input = "name=test\nversion=1.0\n# comment\n\nkey=value";
        let config = Config::parse(input).unwrap();
        assert_eq!(config.get("name"), Some(&"test".to_string()));
        assert_eq!(config.get("version"), Some(&"1.0".to_string()));
        assert_eq!(config.get("key"), Some(&"value".to_string()));
    }

    #[test]
    fn test_parse_invalid_format() {
        let input = "invalid line";
        assert!(Config::parse(input).is_err());
    }

    #[test]
    fn test_validation_missing_key() {
        let config = Config::new();
        let result = config.validate(&["required_key"]);
        assert!(result.is_err());
    }

    #[test]
    fn test_validation_success() {
        let input = "name=test\nversion=1.0";
        let config = Config::parse(input).unwrap();
        assert!(config.validate(&["name", "version"]).is_ok());
    }
}
