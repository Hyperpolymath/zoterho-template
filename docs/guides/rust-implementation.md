# Rust Implementation Guide

Complete guide for creating RSR-compliant Rust projects.

## Prerequisites

- Rust 1.70+ (`rustup install stable`)
- Cargo (comes with Rust)
- Optional: `cargo-audit`, `cargo-tarpaulin`

## Quick Start

```bash
# Create new Rust project
cargo new my-rsr-project
cd my-rsr-project

# Copy RSR template files
cp /path/to/zoterho-template/{README.md,LICENSE.txt,SECURITY.md,etc.} .
cp -r /path/to/zoterho-template/.well-known .

# Initialize RSR structure
just init  # if using justfile
```

## Project Structure

```
my-rsr-project/
├── src/
│   ├── main.rs          # Entry point
│   ├── lib.rs           # Library code (optional)
│   └── error.rs         # Error types
├── tests/
│   └── integration_test.rs
├── Cargo.toml           # Project manifest
├── Cargo.lock           # Dependency lock file
├── README.md            # RSR-compliant README
├── LICENSE.txt          # Dual MIT + Palimpsest
├── SECURITY.md          # Security policy
└── .well-known/         # RFC 9116 compliance
```

## Cargo.toml Configuration

```toml
[package]
name = "my-rsr-project"
version = "0.1.0"
edition = "2021"
rust-version = "1.70"
authors = ["Your Name <email@example.com>"]
license = "MIT OR Palimpsest-0.8"
description = "RSR-compliant Rust project"
repository = "https://github.com/username/my-rsr-project"
readme = "README.md"
keywords = ["rsr", "rhodium"]
categories = []

[dependencies]
# Prefer zero dependencies for RSR Bronze level
# Use only std library when possible

[dev-dependencies]
# Testing and development tools only

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
strip = true
panic = "abort"
```

## RSR Compliance Checklist

### 1. Type Safety ✅

**Rust provides compile-time type safety by default.**

Best practices:
- Use strong types instead of primitives
- Leverage the type system for domain modeling
- Avoid `as` casts; use `From`/`Into` traits
- Use newtypes for domain-specific values

```rust
// ❌ Primitive obsession
fn process_user_id(id: i32) { }

// ✅ Strong typing
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct UserId(i32);

fn process_user_id(id: UserId) { }
```

### 2. Memory Safety ✅

**Zero `unsafe` blocks for Bronze level.**

Verification:
```bash
# Search for unsafe code
rg "unsafe" src/

# Should return no results for Bronze compliance
```

Best practices:
- Let Rust's ownership system prevent memory errors
- Use `Option<T>` instead of null
- Use `Result<T, E>` for error handling
- Avoid `.unwrap()` in production code

```rust
// ❌ Panics on None
let value = option.unwrap();

// ✅ Proper error handling
let value = option.ok_or(Error::MissingValue)?;
```

### 3. Offline-First ✅

**Zero network dependencies.**

```toml
[dependencies]
# ❌ No network dependencies
# reqwest = "0.11"
# tokio = { version = "1", features = ["net"] }

# ✅ Offline-friendly only
# serde = { version = "1", default-features = false }
```

Verification:
```bash
# Check dependencies
cargo tree

# Ensure no network-related crates
```

### 4. Zero Dependencies (Ideal)

**For Bronze level, minimize dependencies.**

```bash
# Check dependency count
cargo tree --depth 1 | wc -l

# Goal: 0 dependencies for examples
```

Using only `std`:
```rust
use std::collections::HashMap;
use std::fs;
use std::io::{self, Write};
use std::error::Error;
```

### 5. Comprehensive Testing

**100% test pass rate required.**

Test structure:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_functionality() {
        let result = my_function(input);
        assert_eq!(result, expected);
    }

    #[test]
    #[should_panic(expected = "error message")]
    fn test_error_handling() {
        my_function(invalid_input);
    }
}
```

Run tests:
```bash
# Run all tests
cargo test

# Run with output
cargo test -- --nocapture

# Run specific test
cargo test test_name

# With coverage (requires cargo-tarpaulin)
cargo tarpaulin --out Html
```

### 6. Error Handling

**Use custom error types.**

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
pub enum MyError {
    Io(std::io::Error),
    Parse(String),
    Validation(String),
}

impl fmt::Display for MyError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            MyError::Io(e) => write!(f, "IO error: {}", e),
            MyError::Parse(msg) => write!(f, "Parse error: {}", msg),
            MyError::Validation(msg) => write!(f, "Validation error: {}", msg),
        }
    }
}

impl Error for MyError {}

impl From<std::io::Error> for MyError {
    fn from(error: std::io::Error) -> Self {
        MyError::Io(error)
    }
}

pub type Result<T> = std::result::Result<T, MyError>;
```

### 7. Code Quality

**Use clippy and rustfmt.**

```bash
# Format code
cargo fmt

# Check formatting
cargo fmt -- --check

# Lint with clippy
cargo clippy

# Clippy with strict settings
cargo clippy -- -D warnings
```

Configuration (`.clippy.toml` or `Cargo.toml`):
```toml
[lints.clippy]
all = "warn"
pedantic = "warn"
nursery = "warn"
cargo = "warn"
```

## Build Automation

**justfile recipes:**

```just
# Run all tests
test:
    cargo test --verbose

# Build release binary
build:
    cargo build --release

# Run clippy
lint:
    cargo clippy -- -D warnings

# Format code
format:
    cargo fmt

# Security audit
security-check:
    cargo audit

# Full CI pipeline
ci: format lint test build

# Pre-commit checks
pre-commit: format lint test
```

## Security Best Practices

1. **Dependency Auditing**
   ```bash
   cargo install cargo-audit
   cargo audit
   ```

2. **No unsafe code** (Bronze level)
   - Search: `rg "unsafe" src/`
   - Should return zero results

3. **Input Validation**
   ```rust
   pub fn validate_input(input: &str) -> Result<String> {
       if input.is_empty() {
           return Err(MyError::Validation("Input cannot be empty".into()));
       }
       if input.len() > MAX_LENGTH {
           return Err(MyError::Validation("Input too long".into()));
       }
       Ok(input.to_string())
   }
   ```

4. **Secure Defaults**
   ```rust
   #[derive(Debug)]
   pub struct Config {
       pub debug: bool,      // default: false
       pub verbose: bool,    // default: false
   }

   impl Default for Config {
       fn default() -> Self {
           Config {
               debug: false,    // Secure default
               verbose: false,
           }
       }
   }
   ```

## Documentation

**Use rustdoc comments:**

```rust
/// Parses a configuration file.
///
/// # Arguments
///
/// * `path` - Path to the configuration file
///
/// # Returns
///
/// * `Ok(Config)` - Parsed configuration
/// * `Err(MyError)` - Parse error with details
///
/// # Examples
///
/// ```
/// use my_crate::parse_config;
///
/// let config = parse_config("config.toml")?;
/// assert_eq!(config.name, "MyApp");
/// ```
///
/// # Errors
///
/// Returns `Err` if:
/// - File doesn't exist
/// - File contains invalid UTF-8
/// - Parse error in TOML format
pub fn parse_config(path: &str) -> Result<Config> {
    // Implementation
}
```

Generate docs:
```bash
cargo doc --open
```

## Performance Tips

1. **Use `cargo build --release`** for production
2. **Profile before optimizing:**
   ```bash
   cargo install flamegraph
   cargo flamegraph
   ```

3. **Minimize allocations:**
   ```rust
   // ❌ Unnecessary allocation
   fn process(data: String) -> String {
       data.to_uppercase()
   }

   // ✅ Borrow when possible
   fn process(data: &str) -> String {
       data.to_uppercase()
   }
   ```

4. **Use iterators:**
   ```rust
   // ✅ Lazy, efficient
   let sum: i32 = data.iter().filter(|x| **x > 0).sum();
   ```

## Common Patterns

### Builder Pattern
```rust
pub struct ConfigBuilder {
    name: Option<String>,
    version: Option<String>,
}

impl ConfigBuilder {
    pub fn new() -> Self {
        ConfigBuilder {
            name: None,
            version: None,
        }
    }

    pub fn name(mut self, name: impl Into<String>) -> Self {
        self.name = Some(name.into());
        self
    }

    pub fn version(mut self, version: impl Into<String>) -> Self {
        self.version = Some(version.into());
        self
    }

    pub fn build(self) -> Result<Config> {
        Ok(Config {
            name: self.name.ok_or(MyError::Validation("Missing name".into()))?,
            version: self.version.ok_or(MyError::Validation("Missing version".into()))?,
        })
    }
}
```

### Newtype Pattern
```rust
#[derive(Debug, Clone)]
pub struct Email(String);

impl Email {
    pub fn new(email: impl Into<String>) -> Result<Self> {
        let email = email.into();
        if !email.contains('@') {
            return Err(MyError::Validation("Invalid email".into()));
        }
        Ok(Email(email))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}
```

## Troubleshooting

### Issue: Borrow checker errors

**Solution:** Understand ownership rules
```rust
// ❌ Moves ownership
let s1 = String::from("hello");
let s2 = s1;
println!("{}", s1); // Error: s1 was moved

// ✅ Borrow instead
let s1 = String::from("hello");
let s2 = &s1;
println!("{}", s1); // OK
```

### Issue: Lifetime annotations

**Solution:** Let compiler infer when possible
```rust
// ✅ Compiler infers lifetimes
fn first_word(s: &str) -> &str {
    s.split_whitespace().next().unwrap_or("")
}
```

### Issue: Slow compile times

**Solutions:**
1. Use `cargo check` during development
2. Enable incremental compilation (default in Cargo.toml)
3. Use `sccache` for caching:
   ```bash
   cargo install sccache
   export RUSTC_WRAPPER=sccache
   ```

## Next Steps

- [TypeScript Implementation Guide](typescript-implementation.md)
- [Python Implementation Guide](python-implementation.md)
- [Testing Best Practices](testing-best-practices.md)
- [Security Hardening](security-hardening.md)

## Resources

- [Rust Book](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [clippy lints](https://rust-lang.github.io/rust-clippy/)
