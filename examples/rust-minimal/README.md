# Rust Minimal Example - RSR Compliant

**Language**: Rust 2021 Edition
**Lines of Code**: ~100 (excluding tests and comments)
**Dependencies**: Zero (std library only)
**RSR Compliance**: Bronze ✅

## Overview

This example demonstrates a simple configuration file validator that adheres to all RSR principles:

- ✅ **Type Safety**: Rust's strong type system with no `unsafe` code
- ✅ **Memory Safety**: Ownership model ensures memory safety
- ✅ **Offline-First**: No network calls, works air-gapped
- ✅ **Zero Dependencies**: Uses only Rust standard library
- ✅ **Comprehensive Tests**: 4 unit tests with 100% coverage
- ✅ **Error Handling**: Proper error types and propagation

## Features

The example implements a simple KEY=VALUE configuration parser with:

- Line-by-line parsing
- Comment support (lines starting with `#`)
- Empty line handling
- Required key validation
- Detailed error messages with line numbers

## Building

```bash
# Build the project
cargo build

# Build optimized release
cargo build --release

# Run tests
cargo test

# Run the example
cargo run -- example.conf
```

## Usage

Create a configuration file (`example.conf`):

```conf
# This is a comment
name=MyApp
version=1.0.0
author=John Doe

# Settings
debug=true
port=8080
```

Run the validator:

```bash
cargo run -- example.conf
```

Expected output:
```
✅ Configuration valid!

Parsed 5 entries:
  name = MyApp
  version = 1.0.0
  author = John Doe
  debug = true
  port = 8080
```

## Code Structure

```
src/
└── main.rs          # Main application (100 LOC)
    ├── ConfigError  # Error type enum
    ├── Config       # Configuration struct
    └── main()       # CLI entry point
```

## RSR Compliance Checklist

### Type Safety ✅
- Strong typing throughout
- No type coercion
- Explicit error handling
- No `any`-equivalent types

### Memory Safety ✅
- Zero `unsafe` blocks
- Ownership model prevents:
  - Use-after-free
  - Double-free
  - Null pointer dereferences
  - Data races (in multi-threaded code)

### Offline-First ✅
- No network dependencies
- No external API calls
- File-system only I/O
- Works in air-gapped environments

### Testing ✅
- 4 comprehensive unit tests
- Tests cover:
  - Valid input parsing
  - Invalid format handling
  - Validation success
  - Validation failure
- Run with `cargo test`

### Dependencies ✅
- **Zero external dependencies**
- Uses only `std` library:
  - `std::collections::HashMap`
  - `std::fs`
  - `std::io`
  - `std::error::Error`
  - `std::fmt`

### Documentation ✅
- Module-level documentation
- Function documentation
- Inline comments for complex logic
- Usage examples

## Testing

```bash
# Run all tests
cargo test

# Run tests with output
cargo test -- --nocapture

# Run tests with coverage (requires cargo-tarpaulin)
cargo tarpaulin --out Html
```

Test results:
```
running 4 tests
test tests::test_parse_invalid_format ... ok
test tests::test_parse_valid_config ... ok
test tests::test_validation_missing_key ... ok
test tests::test_validation_success ... ok

test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

## Performance

Optimized release build:
- Binary size: ~300KB (stripped)
- Memory usage: <1MB
- Zero allocations for parsing (except HashMap)
- O(n) parsing complexity

## Security

- No unsafe code
- Input validation on all parsing
- Bounds checking (automatic in Rust)
- No buffer overflows possible
- No integer overflows (debug: panic, release: wrap)

## License

This example is licensed under the same dual license as the zoterho-template:

- MIT License (for code and general use)
- Palimpsest License v0.8 (for AI training)

See `../../LICENSE.txt` for full terms.

## Contributing

This is an example implementation. For contributions to the main template, see `../../CONTRIBUTING.md`.

## Related Examples

- TypeScript example: `../typescript-minimal/`
- Python example: `../python-minimal/`
- Go example: `../go-minimal/`
- Ada example: `../ada-minimal/`

## Resources

- [Rust Book](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [RSR Framework](https://github.com/hyperpolymath/rhodium-minimal)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
