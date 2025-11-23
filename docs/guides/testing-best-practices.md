# Testing Best Practices for RSR-Compliant Projects

Comprehensive testing guide for achieving 100% test pass rate across all languages.

## Core Testing Principles

### 1. Test Pyramid

```
        /\
       /  \   E2E Tests (Few)
      /____\
     /      \  Integration Tests (Some)
    /________\
   /          \
  /____________\ Unit Tests (Many)
```

- **Unit Tests**: 70% - Fast, isolated, test single functions
- **Integration Tests**: 20% - Test component interactions
- **E2E Tests**: 10% - Test full user workflows

### 2. AAA Pattern

Every test should follow Arrange-Act-Assert:

```rust
#[test]
fn test_user_creation() {
    // Arrange
    let name = "Alice";
    let email = "alice@example.com";

    // Act
    let user = User::new(name, email).unwrap();

    // Assert
    assert_eq!(user.name(), name);
    assert_eq!(user.email(), email);
}
```

### 3. Test Naming Convention

**Format**: `test_<function>_<scenario>_<expected_result>`

Examples:
- `test_parse_valid_input_returns_config`
- `test_validate_empty_string_returns_error`
- `test_calculate_with_zero_returns_zero`

## Language-Specific Testing

### Rust Testing

**Framework**: Built-in test framework

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_success_case() {
        let result = my_function(valid_input);
        assert_eq!(result, expected);
    }

    #[test]
    #[should_panic(expected = "error message")]
    fn test_panic_case() {
        my_function(invalid_input);
    }

    #[test]
    fn test_result_error() -> Result<()> {
        let result = my_function(input)?;
        assert_eq!(result, expected);
        Ok(())
    }
}
```

**Running Tests**:
```bash
# All tests
cargo test

# Specific test
cargo test test_name

# With output
cargo test -- --nocapture

# Parallel execution (default)
cargo test -- --test-threads=4

# Sequential execution
cargo test -- --test-threads=1
```

**Property-Based Testing**:
```rust
// Add to Cargo.toml: proptest = "1.0"
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_reversibility(s in ".*") {
        let encoded = encode(&s);
        let decoded = decode(&encoded).unwrap();
        prop_assert_eq!(s, decoded);
    }
}
```

### TypeScript Testing

**Framework**: Node.js built-in test runner (Node 18+)

```typescript
import { test } from 'node:test';
import assert from 'node:assert/strict';

test('validates user input', () => {
  // Arrange
  const input = { name: 'Alice', age: 30 };

  // Act
  const result = validateUser(input);

  // Assert
  assert.equal(result.valid, true);
});

test('rejects invalid input', () => {
  const input = { name: '', age: -1 };

  assert.throws(
    () => validateUser(input),
    (error: unknown) => {
      return error instanceof ValidationError &&
             error.message.includes('Invalid name');
    }
  );
});
```

**Async Testing**:
```typescript
test('async operation completes', async () => {
  const result = await fetchData();
  assert.equal(result.status, 'success');
});
```

**Running Tests**:
```bash
# Build and test
npm run build && npm test

# Watch mode
npm test -- --watch

# Specific test file
node --test dist/user.test.js
```

### Python Testing

**Framework**: pytest

```python
def test_user_creation() -> None:
    """Test that user is created with valid data."""
    # Arrange
    name = "Alice"
    email = "alice@example.com"

    # Act
    user = User(name, email)

    # Assert
    assert user.name == name
    assert user.email == email

def test_invalid_email_raises_error() -> None:
    """Test that invalid email raises ValueError."""
    with pytest.raises(ValueError, match="Invalid email"):
        User("Alice", "invalid-email")
```

**Parametrized Tests**:
```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("WORLD", "WORLD"),
    ("", ""),
    ("Test123", "TEST123"),
])
def test_uppercase(input: str, expected: str) -> None:
    assert uppercase(input) == expected
```

**Fixtures**:
```python
@pytest.fixture
def sample_user() -> User:
    """Create a sample user for testing."""
    return User("Alice", "alice@example.com")

def test_user_update(sample_user: User) -> None:
    sample_user.update_email("newemail@example.com")
    assert sample_user.email == "newemail@example.com"
```

**Running Tests**:
```bash
# All tests
pytest

# With coverage
pytest --cov=mypackage --cov-report=term-missing

# Verbose
pytest -v

# Stop on first failure
pytest -x

# Specific test
pytest tests/test_user.py::test_user_creation
```

## Test Coverage

### Measuring Coverage

**Rust** (using `cargo-tarpaulin`):
```bash
cargo install cargo-tarpaulin
cargo tarpaulin --out Html
```

**TypeScript** (using `c8`):
```bash
npm install --save-dev c8
npx c8 npm test
```

**Python** (using `pytest-cov`):
```bash
pip install pytest-cov
pytest --cov=mypackage --cov-report=html
```

### Coverage Goals

- **Bronze RSR Level**: 80%+ coverage
- **Silver RSR Level**: 90%+ coverage
- **Gold RSR Level**: 95%+ coverage

### What to Test

✅ **Do test**:
- Business logic
- Edge cases (empty, null, boundary values)
- Error handling
- Input validation
- State transitions

❌ **Don't test**:
- Third-party library internals
- Language built-ins
- Trivial getters/setters
- Generated code

## Integration Testing

### Rust Integration Tests

```rust
// tests/integration_test.rs
use my_crate::{Config, parse_config};

#[test]
fn test_full_workflow() {
    let config = Config::default();
    let result = parse_config(&config).unwrap();
    assert!(result.is_valid());
}
```

### TypeScript Integration Tests

```typescript
// tests/integration.test.ts
test('full workflow', async () => {
  const config = await loadConfig('test-config.json');
  const result = await processData(config);
  assert.equal(result.status, 'success');
});
```

### Python Integration Tests

```python
# tests/test_integration.py
def test_full_workflow(tmp_path):
    """Test complete workflow from input to output."""
    config_file = tmp_path / "config.yaml"
    config_file.write_text("name: test\nversion: 1.0")

    config = load_config(str(config_file))
    result = process(config)

    assert result.success is True
```

## Test Data Management

### Test Fixtures

**Rust**:
```rust
fn create_test_user() -> User {
    User {
        name: "Test User".to_string(),
        email: "test@example.com".to_string(),
    }
}
```

**TypeScript**:
```typescript
function createTestUser(): User {
  return {
    name: 'Test User',
    email: 'test@example.com',
  };
}
```

**Python**:
```python
@pytest.fixture
def test_user() -> User:
    return User(name="Test User", email="test@example.com")
```

### Temporary Files

**Rust**:
```rust
use std::fs;
use tempfile::TempDir;

#[test]
fn test_file_operations() -> Result<()> {
    let temp_dir = TempDir::new()?;
    let file_path = temp_dir.path().join("test.txt");

    fs::write(&file_path, "test content")?;
    let content = fs::read_to_string(&file_path)?;

    assert_eq!(content, "test content");
    Ok(())
} // temp_dir automatically cleaned up
```

**Python**:
```python
def test_file_operations(tmp_path):
    file_path = tmp_path / "test.txt"
    file_path.write_text("test content")

    content = file_path.read_text()
    assert content == "test content"
```

## Mocking and Stubbing

### When to Mock

✅ **Mock**:
- External dependencies (network, database, filesystem in some cases)
- Slow operations
- Non-deterministic behavior (random, time)

❌ **Don't Mock**:
- Simple value objects
- Pure functions
- Your own business logic

### Dependency Injection for Testability

**Rust**:
```rust
pub trait DataStore {
    fn get(&self, key: &str) -> Option<String>;
    fn set(&mut self, key: &str, value: String);
}

pub struct InMemoryStore {
    data: HashMap<String, String>,
}

impl DataStore for InMemoryStore {
    fn get(&self, key: &str) -> Option<String> {
        self.data.get(key).cloned()
    }

    fn set(&mut self, key: &str, value: String) {
        self.data.insert(key.to_string(), value);
    }
}

// Test with mock
#[cfg(test)]
struct MockStore {
    data: HashMap<String, String>,
}

impl DataStore for MockStore {
    // ... implementation
}
```

**TypeScript**:
```typescript
interface DataStore {
  get(key: string): string | undefined;
  set(key: string, value: string): void;
}

class InMemoryStore implements DataStore {
  private data = new Map<string, string>();

  get(key: string): string | undefined {
    return this.data.get(key);
  }

  set(key: string, value: string): void {
    this.data.set(key, value);
  }
}

// Test with mock
class MockStore implements DataStore {
  private data = new Map<string, string>();
  // ... implementation
}
```

## Testing Anti-Patterns

### ❌ Anti-Pattern 1: Test Implementation Details

```rust
// Bad - tests internal state
#[test]
fn test_counter_increments() {
    let mut counter = Counter::new();
    counter.increment();
    assert_eq!(counter.internal_value, 1); // Depends on internal field
}

// Good - tests behavior
#[test]
fn test_counter_increments() {
    let mut counter = Counter::new();
    counter.increment();
    assert_eq!(counter.value(), 1); // Tests public API
}
```

### ❌ Anti-Pattern 2: One Giant Test

```python
# Bad
def test_everything():
    user = create_user()
    update_user(user)
    delete_user(user)
    assert True  # What are we even testing?

# Good
def test_user_creation():
    user = create_user()
    assert user.name == "Test"

def test_user_update():
    user = create_user()
    update_user(user, name="Updated")
    assert user.name == "Updated"
```

### ❌ Anti-Pattern 3: Fragile Tests

```typescript
// Bad - depends on exact error message
test('validation fails', () => {
  assert.throws(
    () => validate(''),
    /Error: Validation failed: Input cannot be empty/
  );
});

// Good - checks error type and key information
test('validation fails', () => {
  assert.throws(
    () => validate(''),
    (error: unknown) => {
      return error instanceof ValidationError &&
             error.code === 'EMPTY_INPUT';
    }
  );
});
```

## Continuous Integration

### CI Test Strategy

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        # Test multiple versions
        rust: [stable, beta]
        node: [18, 20]
        python: ['3.11', '3.12']

    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: just test
```

### Pre-commit Hooks

```bash
# .git/hooks/pre-commit
#!/bin/sh

echo "Running tests..."
just test || exit 1

echo "Running lints..."
just lint || exit 1

echo "Checking formatting..."
just format-check || exit 1
```

## Performance Testing

### Benchmarking

**Rust** (using `criterion`):
```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn benchmark_parse(c: &mut Criterion) {
    c.bench_function("parse config", |b| {
        b.iter(|| parse_config(black_box("test input")))
    });
}

criterion_group!(benches, benchmark_parse);
criterion_main!(benches);
```

**Python** (using `pytest-benchmark`):
```python
def test_parse_performance(benchmark):
    result = benchmark(parse_config, "test input")
    assert result is not None
```

## Test Organization

### File Structure

```
project/
├── src/
│   └── module.rs
└── tests/
    ├── unit/
    │   └── module_test.rs
    ├── integration/
    │   └── workflow_test.rs
    └── fixtures/
        └── test_data.json
```

### Grouping Tests

**Rust**:
```rust
#[cfg(test)]
mod tests {
    mod user_tests {
        #[test]
        fn test_creation() { }

        #[test]
        fn test_validation() { }
    }

    mod config_tests {
        #[test]
        fn test_parsing() { }
    }
}
```

## Debugging Failed Tests

### 1. Read the Error Message

```
thread 'tests::test_parse' panicked at 'assertion failed: `(left == right)`
  left: `Some("expected")`,
 right: `Some("actual")`', src/lib.rs:42:5
```

### 2. Add Debug Output

**Rust**:
```rust
#[test]
fn test_calculation() {
    let result = calculate(input);
    dbg!(&result);  // Print debug output
    assert_eq!(result, expected);
}
```

**TypeScript**:
```typescript
test('calculation', () => {
  const result = calculate(input);
  console.log('Result:', result);  // Debug output
  assert.equal(result, expected);
});
```

### 3. Use Test-Specific Debugging

```bash
# Rust - run single test with output
cargo test test_name -- --nocapture

# Python - run with pdb
pytest --pdb

# TypeScript/Node - use debugger
node --inspect-brk --test dist/test.js
```

## Resources

- [Rust Testing Guide](https://doc.rust-lang.org/book/ch11-00-testing.html)
- [Node.js Test Runner](https://nodejs.org/api/test.html)
- [pytest Documentation](https://docs.pytest.org/)
- [Test-Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)

## Next Steps

- [Rust Implementation Guide](rust-implementation.md)
- [TypeScript Implementation Guide](typescript-implementation.md)
- [Python Implementation Guide](python-implementation.md)
- [Security Hardening Guide](security-hardening.md)
