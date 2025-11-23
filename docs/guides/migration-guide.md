# Migration Guide to RSR Compliance

This guide helps you migrate existing projects to meet Realtime Software Repository (RSR) compliance standards. Whether you're migrating a Create React App, a Rust cargo project, or a Python application, this guide provides step-by-step instructions.

## Table of Contents

1. [Assessment Checklist](#assessment-checklist)
2. [Step-by-Step Migration Process](#step-by-step-migration-process)
3. [Migrating from Common Templates](#migrating-from-common-templates)
4. [Adding Required Documentation](#adding-required-documentation)
5. [Implementing Dual Licensing](#implementing-dual-licensing)
6. [Setting Up .well-known/](#setting-up-well-known)
7. [Adding Build Automation](#adding-build-automation)
8. [Improving Type Safety](#improving-type-safety)
9. [Adding Comprehensive Tests](#adding-comprehensive-tests)
10. [Common Migration Pitfalls](#common-migration-pitfalls)
11. [Before/After Examples](#beforeafter-examples)

## Assessment Checklist

Before starting migration, assess your current project's compliance level:

### Bronze Level Requirements

- [ ] **Documentation**
  - [ ] README.md with clear description
  - [ ] LICENSE file present
  - [ ] CLAUDE.md (Claude-specific documentation)
  - [ ] CONTRIBUTING.md guidelines
  - [ ] CHANGELOG.md
  - [ ] CODE_OF_CONDUCT.md

- [ ] **Build & Testing**
  - [ ] Reproducible build process
  - [ ] Automated test suite (>50% coverage)
  - [ ] CI/CD pipeline configured
  - [ ] Linting configured

- [ ] **Project Structure**
  - [ ] Clear directory organization
  - [ ] Dependency management
  - [ ] .gitignore configured
  - [ ] .well-known/ directory for metadata

- [ ] **Code Quality**
  - [ ] Type safety (TypeScript, Rust, mypy for Python)
  - [ ] Error handling
  - [ ] Code formatting (prettier, rustfmt, black)

### Silver & Gold Levels

Silver and Gold levels require additional security hardening, monitoring, and advanced testing. Start with Bronze compliance first.

## Step-by-Step Migration Process

### Step 1: Backup Your Project

```bash
# Create a backup branch
git checkout -b pre-rsr-backup
git push origin pre-rsr-backup

# Create migration branch
git checkout -b rsr-migration
```

### Step 2: Analyze Current Structure

```bash
# Check current project structure
tree -L 2 -a

# Analyze dependencies
npm list --depth=0          # Node.js
cargo tree --depth=1        # Rust
pip list                    # Python

# Check test coverage
npm test -- --coverage      # Node.js
cargo tarpaulin            # Rust
pytest --cov               # Python
```

### Step 3: Create Migration Plan

Document your migration plan:

```markdown
# RSR Migration Plan

## Current State
- Framework: [e.g., Create React App]
- Build tool: [e.g., Webpack]
- Test coverage: [e.g., 30%]
- Documentation: [e.g., README only]

## Target State
- RSR Bronze compliance
- 50%+ test coverage
- Complete documentation
- CI/CD pipeline

## Timeline
- Week 1: Documentation and licensing
- Week 2: Build automation and testing
- Week 3: Code quality improvements
- Week 4: Final review and deployment
```

### Step 4: Execute Migration

Follow the sections below based on your starting template.

## Migrating from Common Templates

### From Create React App (CRA)

#### Before: Typical CRA Structure

```
my-app/
├── public/
├── src/
│   ├── App.js
│   ├── index.js
│   └── components/
├── package.json
└── README.md
```

#### Migration Steps

**1. Migrate to TypeScript**

```bash
# Install TypeScript
npm install --save-dev typescript @types/node @types/react @types/react-dom

# Create tsconfig.json
npx tsc --init
```

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "allowJs": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "build"]
}
```

**2. Rename Files to TypeScript**

```bash
# Rename .js to .tsx/.ts
find src -name "*.js" -exec sh -c 'mv "$1" "${1%.js}.tsx"' _ {} \;

# Fix any type errors
npm run build
```

**3. Add Required Documentation**

```bash
# Create documentation files
touch CLAUDE.md CONTRIBUTING.md CHANGELOG.md CODE_OF_CONDUCT.md

# Create .well-known directory
mkdir -p .well-known
touch .well-known/metadata.json
```

**4. Improve Test Setup**

```bash
# Install testing libraries
npm install --save-dev @testing-library/react @testing-library/jest-dom \
  @testing-library/user-event vitest @vitest/ui c8
```

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    coverage: {
      provider: 'c8',
      reporter: ['text', 'json', 'html'],
      lines: 50,
      functions: 50,
      branches: 50,
      statements: 50,
    },
  },
});
```

**5. Add Linting and Formatting**

```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin \
  eslint-plugin-react eslint-plugin-react-hooks prettier eslint-config-prettier
```

```json
// .eslintrc.json
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "prettier"
  ],
  "plugins": ["@typescript-eslint", "react", "react-hooks"],
  "rules": {
    "react/react-in-jsx-scope": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/no-explicit-any": "error"
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
```

**6. Update package.json Scripts**

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "lint:fix": "eslint src --ext ts,tsx --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,json,css,md}\"",
    "format:check": "prettier --check \"src/**/*.{ts,tsx,json,css,md}\"",
    "type-check": "tsc --noEmit"
  }
}
```

**7. Add CI/CD**

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run type-check
      - run: npm run lint
      - run: npm run format:check
      - run: npm run test:coverage
      - run: npm run build
```

#### After: RSR-Compliant Structure

```
my-app/
├── .github/
│   └── workflows/
│       └── ci.yml
├── .well-known/
│   └── metadata.json
├── public/
├── src/
│   ├── components/
│   │   ├── App.tsx
│   │   └── App.test.tsx
│   ├── test/
│   │   └── setup.ts
│   └── main.tsx
├── .eslintrc.json
├── .gitignore
├── .prettierrc
├── CHANGELOG.md
├── CLAUDE.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── package.json
├── tsconfig.json
└── vite.config.ts
```

### From Cargo Init (Rust)

#### Before: Basic Cargo Project

```
my-project/
├── src/
│   └── main.rs
├── Cargo.toml
└── README.md
```

#### Migration Steps

**1. Enhance Cargo.toml**

```toml
[package]
name = "my-project"
version = "0.1.0"
authors = ["Your Name <you@example.com>"]
edition = "2021"
license = "MIT OR Apache-2.0"
description = "A brief description of your project"
repository = "https://github.com/yourusername/my-project"
keywords = ["keyword1", "keyword2"]
categories = ["category1"]
readme = "README.md"

[dependencies]
# Production dependencies
tokio = { version = "1.35", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }

[dev-dependencies]
# Test dependencies
criterion = "0.5"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1

[profile.dev]
opt-level = 0

[[bench]]
name = "benchmarks"
harness = false
```

**2. Add Project Structure**

```bash
# Create directory structure
mkdir -p src/{lib,bin,tests,benches}
mkdir -p examples

# Move main.rs if appropriate
mv src/main.rs src/bin/main.rs

# Create lib.rs
touch src/lib.rs
```

**3. Add Testing Infrastructure**

```rust
// src/lib.rs
pub mod core;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
```

```rust
// tests/integration_test.rs
use my_project::core;

#[test]
fn integration_test() {
    // Integration tests here
}
```

**4. Add Benchmarks**

```rust
// benches/benchmarks.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use my_project::core::some_function;

fn benchmark_function(c: &mut Criterion) {
    c.bench_function("some_function", |b| {
        b.iter(|| some_function(black_box(42)))
    });
}

criterion_group!(benches, benchmark_function);
criterion_main!(benches);
```

**5. Add Documentation**

```rust
//! # My Project
//!
//! `my_project` is a collection of utilities to make X easier.
//!
//! ## Examples
//!
//! ```
//! use my_project::core::some_function;
//!
//! let result = some_function(42);
//! assert_eq!(result, 84);
//! ```

/// Does something useful with the input
///
/// # Examples
///
/// ```
/// use my_project::core::some_function;
///
/// let result = some_function(5);
/// assert_eq!(result, 10);
/// ```
///
/// # Panics
///
/// This function panics if the input is negative.
pub fn some_function(x: i32) -> i32 {
    x * 2
}
```

**6. Add Clippy Configuration**

```toml
# .clippy.toml
msrv = "1.70.0"
```

```bash
# Run clippy
cargo clippy --all-targets --all-features -- -D warnings
```

**7. Add CI/CD**

```yaml
# .github/workflows/rust.yml
name: Rust CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  CARGO_TERM_COLOR: always

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/toolchain@v1
        with:
          profile: minimal
          toolchain: stable
          components: rustfmt, clippy
      - uses: Swatinem/rust-cache@v2
      - name: Check formatting
        run: cargo fmt --all -- --check
      - name: Run clippy
        run: cargo clippy --all-targets --all-features -- -D warnings
      - name: Run tests
        run: cargo test --verbose
      - name: Run doc tests
        run: cargo test --doc
      - name: Build
        run: cargo build --release --verbose
```

#### After: RSR-Compliant Rust Project

```
my-project/
├── .github/
│   └── workflows/
│       └── rust.yml
├── .well-known/
│   └── metadata.json
├── benches/
│   └── benchmarks.rs
├── examples/
│   └── basic.rs
├── src/
│   ├── bin/
│   │   └── main.rs
│   ├── core/
│   │   ├── mod.rs
│   │   └── logic.rs
│   └── lib.rs
├── tests/
│   └── integration_test.rs
├── .clippy.toml
├── .gitignore
├── Cargo.toml
├── CHANGELOG.md
├── CLAUDE.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE-APACHE
├── LICENSE-MIT
└── README.md
```

### From Python Boilerplate

#### Before: Basic Python Project

```
my-project/
├── my_module.py
├── requirements.txt
└── README.md
```

#### Migration Steps

**1. Create Proper Package Structure**

```bash
# Create package structure
mkdir -p src/my_project/{core,utils}
mkdir -p tests/{unit,integration}
mkdir -p docs

# Move existing code
mv my_module.py src/my_project/core/main.py
```

**2. Add pyproject.toml**

```toml
# pyproject.toml
[build-system]
requires = ["setuptools>=68.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-project"
version = "0.1.0"
description = "A brief description"
authors = [
    {name = "Your Name", email = "you@example.com"}
]
license = {text = "MIT OR Apache-2.0"}
readme = "README.md"
requires-python = ">=3.10"
keywords = ["keyword1", "keyword2"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "License :: OSI Approved :: Apache Software License",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    "pydantic>=2.0",
    "httpx>=0.25",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4",
    "pytest-cov>=4.1",
    "pytest-asyncio>=0.21",
    "mypy>=1.7",
    "ruff>=0.1",
    "black>=23.12",
    "isort>=5.13",
]

[project.urls]
Homepage = "https://github.com/yourusername/my-project"
Repository = "https://github.com/yourusername/my-project"
Documentation = "https://github.com/yourusername/my-project/docs"

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --cov=my_project --cov-report=html --cov-report=term-missing --cov-fail-under=50"

[tool.mypy]
python_version = "3.10"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
strict_equality = true

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false

[tool.black]
line-length = 100
target-version = ['py310', 'py311', 'py312']
include = '\.pyi?$'

[tool.isort]
profile = "black"
line_length = 100
multi_line_output = 3

[tool.ruff]
line-length = 100
target-version = "py310"
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "SIM",  # flake8-simplify
]
ignore = ["E501"]  # line too long (handled by black)

[tool.ruff.per-file-ignores]
"__init__.py" = ["F401"]  # unused imports
"tests/*" = ["S101"]      # use of assert
```

**3. Add Type Hints**

```python
# src/my_project/__init__.py
"""My Project - A brief description."""

__version__ = "0.1.0"

from my_project.core.main import MyClass

__all__ = ["MyClass"]
```

```python
# src/my_project/core/main.py
"""Core functionality for my_project."""

from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field


class Config(BaseModel):
    """Configuration for MyClass."""

    name: str = Field(..., description="The name field")
    value: int = Field(default=0, ge=0, description="A non-negative integer")
    options: Optional[Dict[str, Any]] = None


class MyClass:
    """Main class for my_project.

    Args:
        config: Configuration object

    Examples:
        >>> config = Config(name="test", value=42)
        >>> obj = MyClass(config)
        >>> obj.process()
        'Processed: test'
    """

    def __init__(self, config: Config) -> None:
        self.config = config

    def process(self) -> str:
        """Process the configuration.

        Returns:
            A string representation of the processed data.

        Raises:
            ValueError: If configuration is invalid.
        """
        if not self.config.name:
            raise ValueError("Name cannot be empty")

        return f"Processed: {self.config.name}"

    @staticmethod
    def helper_function(data: List[int]) -> int:
        """Calculate sum of list.

        Args:
            data: List of integers to sum

        Returns:
            Sum of all integers in the list
        """
        return sum(data)
```

**4. Add Comprehensive Tests**

```python
# tests/unit/test_main.py
"""Unit tests for main module."""

import pytest
from my_project.core.main import MyClass, Config


class TestMyClass:
    """Test cases for MyClass."""

    def test_initialization(self) -> None:
        """Test that MyClass initializes correctly."""
        config = Config(name="test", value=42)
        obj = MyClass(config)
        assert obj.config.name == "test"
        assert obj.config.value == 42

    def test_process_valid_config(self) -> None:
        """Test processing with valid configuration."""
        config = Config(name="test", value=42)
        obj = MyClass(config)
        result = obj.process()
        assert result == "Processed: test"

    def test_process_empty_name_raises(self) -> None:
        """Test that empty name raises ValueError."""
        config = Config(name="", value=42)
        obj = MyClass(config)
        with pytest.raises(ValueError, match="Name cannot be empty"):
            obj.process()

    @pytest.mark.parametrize(
        "data,expected",
        [
            ([1, 2, 3], 6),
            ([0], 0),
            ([], 0),
            ([-1, 1], 0),
        ],
    )
    def test_helper_function(self, data: list[int], expected: int) -> None:
        """Test helper_function with various inputs."""
        assert MyClass.helper_function(data) == expected


class TestConfig:
    """Test cases for Config model."""

    def test_valid_config(self) -> None:
        """Test creating valid configuration."""
        config = Config(name="test", value=42)
        assert config.name == "test"
        assert config.value == 42

    def test_negative_value_raises(self) -> None:
        """Test that negative value raises ValidationError."""
        from pydantic import ValidationError

        with pytest.raises(ValidationError):
            Config(name="test", value=-1)

    def test_default_value(self) -> None:
        """Test default value is applied."""
        config = Config(name="test")
        assert config.value == 0
```

**5. Add Scripts for Development**

```bash
# Makefile
.PHONY: install test lint format type-check clean

install:
	pip install -e ".[dev]"

test:
	pytest

test-coverage:
	pytest --cov-report=html --cov-report=term

lint:
	ruff check src tests
	black --check src tests
	isort --check-only src tests

format:
	black src tests
	isort src tests
	ruff check --fix src tests

type-check:
	mypy src

clean:
	rm -rf build dist *.egg-info
	rm -rf .pytest_cache .mypy_cache .ruff_cache
	rm -rf htmlcov .coverage
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

all: format lint type-check test
```

**6. Add CI/CD**

```yaml
# .github/workflows/python.yml
name: Python CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v3
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"

      - name: Lint with ruff
        run: ruff check src tests

      - name: Check formatting
        run: |
          black --check src tests
          isort --check-only src tests

      - name: Type check
        run: mypy src

      - name: Run tests
        run: pytest --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
```

#### After: RSR-Compliant Python Project

```
my-project/
├── .github/
│   └── workflows/
│       └── python.yml
├── .well-known/
│   └── metadata.json
├── docs/
│   └── index.md
├── src/
│   └── my_project/
│       ├── __init__.py
│       ├── core/
│       │   ├── __init__.py
│       │   └── main.py
│       └── utils/
│           └── __init__.py
├── tests/
│   ├── __init__.py
│   ├── unit/
│   │   ├── __init__.py
│   │   └── test_main.py
│   └── integration/
│       └── __init__.py
├── .gitignore
├── CHANGELOG.md
├── CLAUDE.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── Makefile
├── README.md
└── pyproject.toml
```

## Adding Required Documentation

### CLAUDE.md

```markdown
# Claude Integration Guide

This document provides guidance for Claude (Anthropic's AI assistant) when working with this project.

## Project Overview

[Brief description of what the project does and its main purpose]

## Architecture

[High-level architecture overview, key components, data flow]

## Development Workflow

### Setup
\`\`\`bash
npm install  # or cargo build, pip install -e .
\`\`\`

### Running Tests
\`\`\`bash
npm test  # or cargo test, pytest
\`\`\`

### Building
\`\`\`bash
npm run build  # or cargo build --release, pip install -e .
\`\`\`

## Code Patterns

### Naming Conventions
- Components: PascalCase
- Functions: camelCase (JS/TS) or snake_case (Rust/Python)
- Constants: UPPER_SNAKE_CASE
- Files: kebab-case.ext or snake_case.ext

### Project-Specific Patterns
[Document any project-specific patterns, conventions, or idioms]

## Common Tasks

### Adding a New Feature
1. Create feature branch
2. Implement feature with tests
3. Update documentation
4. Submit PR

### Debugging Tips
[Common issues and how to debug them]

## Important Files

- `src/main.*` - Application entry point
- `tests/` - Test suites
- `docs/` - Documentation

## External Dependencies

[List and briefly explain key dependencies]

## Testing Strategy

- Unit tests: Test individual functions/methods
- Integration tests: Test component interactions
- E2E tests: Test complete user workflows

## Deployment

[Brief deployment instructions or links to deployment docs]
```

### CONTRIBUTING.md

```markdown
# Contributing to [Project Name]

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/project.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `npm test` (or `cargo test`, `pytest`)
6. Commit your changes: `git commit -m "Add feature X"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

[Detailed setup instructions]

## Coding Standards

- Follow the existing code style
- Write tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

### Style Guide

- TypeScript: Follow [TypeScript guidelines](docs/guides/typescript-implementation.md)
- Rust: Follow [Rust guidelines](docs/guides/rust-implementation.md)
- Python: Follow [Python guidelines](docs/guides/python-implementation.md)

## Testing

All contributions must include tests:

- Unit tests for business logic
- Integration tests for component interactions
- E2E tests for user-facing features (when applicable)

Target coverage: >50% (Bronze), >80% (Gold)

## Pull Request Process

1. Update README.md if adding features
2. Update CHANGELOG.md with your changes
3. Ensure all CI checks pass
4. Request review from maintainers
5. Address review feedback
6. Squash commits if requested

## Commit Message Format

Use conventional commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: feat, fix, docs, style, refactor, test, chore

Example:
```
feat(auth): add JWT token validation

Implement JWT token validation middleware with
expiration checking and signature verification.

Closes #123
```

## License

By contributing, you agree that your contributions will be licensed under the project's dual license (MIT OR Apache-2.0).
```

### CHANGELOG.md

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature X
- New feature Y

### Changed
- Improved performance of Z

### Fixed
- Bug in component A

## [0.1.0] - 2024-01-15

### Added
- Initial release
- Basic functionality
- Documentation
- Test suite

[Unreleased]: https://github.com/user/repo/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/user/repo/releases/tag/v0.1.0
```

### CODE_OF_CONDUCT.md

```markdown
# Code of Conduct

## Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone.

## Our Standards

Examples of behavior that contributes to a positive environment:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

Examples of unacceptable behavior:

- Trolling, insulting comments, and personal attacks
- Public or private harassment
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

## Enforcement

Instances of abusive behavior may be reported to [email]. All complaints will be reviewed and investigated.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant](https://www.contributor-covenant.org/), version 2.1.
```

## Implementing Dual Licensing

### Create License Files

**MIT License (LICENSE-MIT or LICENSE):**

```
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Apache 2.0 License (LICENSE-APACHE):**

Download from: https://www.apache.org/licenses/LICENSE-2.0.txt

### Add License Headers to Source Files

```typescript
// TypeScript/JavaScript
/**
 * Copyright (c) 2024 [Your Name]
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree,
 * or the Apache License, Version 2.0 found in the LICENSE-APACHE
 * file in the root directory of this source tree.
 *
 * SPDX-License-Identifier: MIT OR Apache-2.0
 */
```

```rust
// Rust
// Copyright (c) 2024 [Your Name]
//
// This source code is licensed under the MIT license found in the
// LICENSE-MIT file in the root directory of this source tree,
// or the Apache License, Version 2.0 found in the LICENSE-APACHE
// file in the root directory of this source tree.
//
// SPDX-License-Identifier: MIT OR Apache-2.0
```

```python
# Python
"""
Copyright (c) 2024 [Your Name]

This source code is licensed under the MIT license found in the
LICENSE-MIT file in the root directory of this source tree,
or the Apache License, Version 2.0 found in the LICENSE-APACHE
file in the root directory of this source tree.

SPDX-License-Identifier: MIT OR Apache-2.0
"""
```

### Update Package Manifests

```json
// package.json
{
  "license": "MIT OR Apache-2.0"
}
```

```toml
# Cargo.toml
[package]
license = "MIT OR Apache-2.0"
```

```toml
# pyproject.toml
[project]
license = {text = "MIT OR Apache-2.0"}
```

## Setting Up .well-known/

### Create Metadata File

```json
// .well-known/metadata.json
{
  "rsr": {
    "version": "1.0",
    "compliance_level": "bronze",
    "project": {
      "name": "my-project",
      "version": "0.1.0",
      "description": "Brief project description",
      "homepage": "https://github.com/user/my-project",
      "repository": "https://github.com/user/my-project"
    },
    "languages": ["typescript"],
    "build": {
      "tool": "vite",
      "command": "npm run build",
      "output": "dist/"
    },
    "test": {
      "framework": "vitest",
      "command": "npm test",
      "coverage_threshold": 50
    },
    "documentation": {
      "readme": "README.md",
      "claude": "CLAUDE.md",
      "contributing": "CONTRIBUTING.md",
      "changelog": "CHANGELOG.md"
    },
    "license": "MIT OR Apache-2.0",
    "updated": "2024-01-15T00:00:00Z"
  }
}
```

### Security Policies

```
// .well-known/security.txt
Contact: mailto:security@example.com
Expires: 2025-12-31T23:59:59.000Z
Preferred-Languages: en
Canonical: https://example.com/.well-known/security.txt
Policy: https://example.com/security-policy
```

## Adding Build Automation

### Package Scripts (TypeScript/JavaScript)

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "lint": "eslint . --ext ts,tsx",
    "lint:fix": "eslint . --ext ts,tsx --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,json}\"",
    "format:check": "prettier --check \"src/**/*.{ts,tsx,json}\"",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist node_modules",
    "prebuild": "npm run clean && npm run type-check && npm run lint",
    "postbuild": "echo 'Build complete!'",
    "pretest": "npm run type-check",
    "prepare": "husky install"
  }
}
```

### Git Hooks with Husky

```bash
npm install --save-dev husky lint-staged
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
npx husky add .husky/pre-push "npm test"
```

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

### Makefile for Multi-Language Projects

```makefile
# Makefile
.PHONY: help install build test lint clean

help:
	@echo "Available commands:"
	@echo "  make install  - Install dependencies"
	@echo "  make build    - Build project"
	@echo "  make test     - Run tests"
	@echo "  make lint     - Run linters"
	@echo "  make clean    - Clean build artifacts"

install:
	npm ci  # or cargo fetch, pip install -e .

build:
	npm run build  # or cargo build --release, python -m build

test:
	npm test  # or cargo test, pytest

lint:
	npm run lint  # or cargo clippy, ruff check src

clean:
	npm run clean  # or cargo clean, rm -rf dist
```

## Improving Type Safety

### TypeScript

```typescript
// Enable strict mode in tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}

// Use branded types for type safety
type UserId = string & { readonly brand: unique symbol };
type EmailAddress = string & { readonly brand: unique symbol };

function createUserId(id: string): UserId {
  // Validation logic
  return id as UserId;
}

function sendEmail(to: EmailAddress, subject: string): void {
  // Email logic
}

// This prevents mixing up different string types
const userId = createUserId("123");
// sendEmail(userId, "test");  // Type error!
```

### Python with mypy

```python
# Enable strict mypy checking
from typing import Optional, List, Dict, TypeVar, Generic

T = TypeVar('T')

class Repository(Generic[T]):
    """Generic repository pattern."""

    def __init__(self) -> None:
        self._items: Dict[str, T] = {}

    def add(self, key: str, item: T) -> None:
        """Add item to repository."""
        self._items[key] = item

    def get(self, key: str) -> Optional[T]:
        """Get item from repository."""
        return self._items.get(key)

    def list(self) -> List[T]:
        """List all items."""
        return list(self._items.values())


# Usage with specific types
from dataclasses import dataclass

@dataclass
class User:
    name: str
    email: str

user_repo: Repository[User] = Repository()
user_repo.add("1", User("Alice", "alice@example.com"))
```

## Adding Comprehensive Tests

### Test Coverage Goals

- **Bronze**: 50%+ coverage
- **Silver**: 70%+ coverage
- **Gold**: 80%+ coverage

### Testing Pyramid

```
         /\
        /E2E\       10% - End-to-end tests
       /------\
      /Integr.\    20% - Integration tests
     /----------\
    /   Unit     \ 70% - Unit tests
   /--------------\
```

### Example Test Suite (TypeScript)

```typescript
// src/utils/math.ts
export function add(a: number, b: number): number {
  return a + b;
}

export function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}

// src/utils/math.test.ts
import { describe, it, expect } from 'vitest';
import { add, divide } from './math';

describe('Math utilities', () => {
  describe('add', () => {
    it('should add two positive numbers', () => {
      expect(add(2, 3)).toBe(5);
    });

    it('should add negative numbers', () => {
      expect(add(-2, -3)).toBe(-5);
    });

    it('should handle zero', () => {
      expect(add(0, 5)).toBe(5);
    });
  });

  describe('divide', () => {
    it('should divide two numbers', () => {
      expect(divide(10, 2)).toBe(5);
    });

    it('should throw on division by zero', () => {
      expect(() => divide(10, 0)).toThrow('Division by zero');
    });

    it('should handle negative numbers', () => {
      expect(divide(-10, 2)).toBe(-5);
    });
  });
});
```

## Common Migration Pitfalls

### 1. Incomplete Type Coverage

**Problem**: Gradual TypeScript migration leaves `any` types

**Solution**: Enable `noImplicitAny` and fix incrementally

```bash
# Find all 'any' types
npx tsc --noEmit --strict 2>&1 | grep "implicitly has an 'any' type"
```

### 2. Missing Test Coverage

**Problem**: New code without tests lowers coverage

**Solution**: Set up coverage gating in CI

```yaml
# .github/workflows/ci.yml
- name: Check coverage
  run: |
    npm run test:coverage
    if [ $(grep -oP '\d+(?=%)' coverage/coverage-summary.json | head -1) -lt 50 ]; then
      echo "Coverage below 50%"
      exit 1
    fi
```

### 3. Dependency Hell

**Problem**: Conflicting or outdated dependencies

**Solution**: Regular dependency updates

```bash
# Check for outdated packages
npm outdated
cargo outdated
pip list --outdated

# Update with caution
npm update
cargo update
pip install --upgrade -r requirements.txt
```

### 4. Breaking CI/CD

**Problem**: CI fails after migration

**Solution**: Test CI locally before pushing

```bash
# GitHub Actions local testing
act -j test

# Or use Docker
docker run -v $(pwd):/app -w /app node:20 npm test
```

### 5. Documentation Drift

**Problem**: Docs don't match new code structure

**Solution**: Update docs as part of migration PR

- [ ] Update README.md with new structure
- [ ] Update CLAUDE.md with new patterns
- [ ] Add migration notes to CHANGELOG.md

## Before/After Examples

### Example 1: Simple Express API

#### Before

```javascript
// server.js
const express = require('express');
const app = express();

app.get('/users/:id', (req, res) => {
  const userId = req.params.id;
  // Direct database query - SQL injection risk!
  const query = `SELECT * FROM users WHERE id = '${userId}'`;
  db.query(query, (err, result) => {
    if (err) {
      res.status(500).send('Error');
    } else {
      res.json(result);
    }
  });
});

app.listen(3000);
```

#### After (RSR-Compliant)

```typescript
// src/server.ts
import express, { Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import { z } from 'zod';
import { pool } from './db';

const app = express();

// Security middleware
app.use(helmet());
app.use(express.json());

// Input validation schema
const UserIdSchema = z.string().uuid();

// Type-safe route handler
app.get('/users/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Validate input
    const userId = UserIdSchema.parse(req.params.id);

    // Parameterized query - SQL injection safe
    const result = await pool.query(
      'SELECT id, name, email FROM users WHERE id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
});

// Error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export { app };
```

```typescript
// src/server.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { app } from './server';

describe('GET /users/:id', () => {
  it('should return user when ID is valid', async () => {
    const response = await request(app)
      .get('/users/550e8400-e29b-41d4-a716-446655440000')
      .expect(200);

    expect(response.body).toHaveProperty('id');
    expect(response.body).toHaveProperty('name');
  });

  it('should return 404 when user not found', async () => {
    await request(app)
      .get('/users/550e8400-e29b-41d4-a716-446655440001')
      .expect(404);
  });

  it('should return 400 when ID is invalid', async () => {
    await request(app)
      .get('/users/invalid-id')
      .expect(400);
  });
});
```

### Example 2: Python Data Processing

#### Before

```python
# process.py
import os

def process_file(filename):
    # Path traversal vulnerability!
    with open(f'/data/{filename}') as f:
        data = f.read()

    # No error handling
    result = eval(data)  # Code injection!
    return result

if __name__ == '__main__':
    file = os.environ.get('FILE')
    print(process_file(file))
```

#### After (RSR-Compliant)

```python
# src/processor/main.py
"""Secure file processor."""

import json
import logging
from pathlib import Path
from typing import Any, Dict

from pydantic import BaseModel, Field, validator

logger = logging.getLogger(__name__)


class ProcessorConfig(BaseModel):
    """Configuration for file processor."""

    data_dir: Path = Field(..., description="Base directory for data files")
    max_file_size: int = Field(default=10_485_760, description="Max file size in bytes")

    @validator('data_dir')
    def validate_data_dir(cls, v: Path) -> Path:
        """Ensure data directory exists and is a directory."""
        if not v.exists():
            raise ValueError(f"Data directory does not exist: {v}")
        if not v.is_dir():
            raise ValueError(f"Path is not a directory: {v}")
        return v.resolve()


class FileProcessor:
    """Securely process data files."""

    def __init__(self, config: ProcessorConfig) -> None:
        """Initialize processor with configuration."""
        self.config = config

    def safe_file_path(self, filename: str) -> Path:
        """Safely resolve file path preventing traversal attacks."""
        requested_path = (self.config.data_dir / filename).resolve()

        # Check if resolved path is within base directory
        if not requested_path.is_relative_to(self.config.data_dir):
            raise ValueError(f"Path traversal detected: {filename}")

        return requested_path

    def process_file(self, filename: str) -> Dict[str, Any]:
        """Process JSON file safely.

        Args:
            filename: Name of file to process (relative to data_dir)

        Returns:
            Processed data as dictionary

        Raises:
            ValueError: If file path is invalid or file too large
            FileNotFoundError: If file doesn't exist
            json.JSONDecodeError: If file is not valid JSON
        """
        try:
            file_path = self.safe_file_path(filename)

            # Check file size
            if file_path.stat().st_size > self.config.max_file_size:
                raise ValueError(f"File too large: {filename}")

            # Read and parse JSON (safe alternative to eval)
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            logger.info(f"Successfully processed file: {filename}")
            return data

        except Exception as e:
            logger.error(f"Error processing file {filename}: {e}")
            raise


def main() -> None:
    """Main entry point."""
    import os

    try:
        data_dir = os.environ.get('DATA_DIR', './data')
        filename = os.environ.get('FILE')

        if not filename:
            raise ValueError("FILE environment variable must be set")

        config = ProcessorConfig(data_dir=Path(data_dir))
        processor = FileProcessor(config)

        result = processor.process_file(filename)
        print(json.dumps(result, indent=2))

    except Exception as e:
        logger.exception("Fatal error in main")
        raise


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    main()
```

```python
# tests/unit/test_processor.py
"""Unit tests for file processor."""

import json
import pytest
from pathlib import Path
from processor.main import FileProcessor, ProcessorConfig


@pytest.fixture
def temp_data_dir(tmp_path: Path) -> Path:
    """Create temporary data directory."""
    data_dir = tmp_path / "data"
    data_dir.mkdir()
    return data_dir


@pytest.fixture
def processor(temp_data_dir: Path) -> FileProcessor:
    """Create file processor with temp directory."""
    config = ProcessorConfig(data_dir=temp_data_dir)
    return FileProcessor(config)


class TestFileProcessor:
    """Test cases for FileProcessor."""

    def test_process_valid_file(
        self, processor: FileProcessor, temp_data_dir: Path
    ) -> None:
        """Test processing a valid JSON file."""
        test_file = temp_data_dir / "test.json"
        test_data = {"key": "value", "number": 42}
        test_file.write_text(json.dumps(test_data))

        result = processor.process_file("test.json")
        assert result == test_data

    def test_path_traversal_blocked(self, processor: FileProcessor) -> None:
        """Test that path traversal attempts are blocked."""
        with pytest.raises(ValueError, match="Path traversal detected"):
            processor.process_file("../etc/passwd")

    def test_file_not_found(self, processor: FileProcessor) -> None:
        """Test handling of non-existent file."""
        with pytest.raises(FileNotFoundError):
            processor.process_file("nonexistent.json")

    def test_file_too_large(
        self, processor: FileProcessor, temp_data_dir: Path
    ) -> None:
        """Test that oversized files are rejected."""
        large_file = temp_data_dir / "large.json"
        large_file.write_text("x" * (processor.config.max_file_size + 1))

        with pytest.raises(ValueError, match="File too large"):
            processor.process_file("large.json")

    def test_invalid_json(
        self, processor: FileProcessor, temp_data_dir: Path
    ) -> None:
        """Test handling of invalid JSON."""
        invalid_file = temp_data_dir / "invalid.json"
        invalid_file.write_text("not valid json")

        with pytest.raises(json.JSONDecodeError):
            processor.process_file("invalid.json")
```

---

## Migration Timeline Template

### Week 1: Foundation
- [ ] Create backup and migration branches
- [ ] Add all required documentation files
- [ ] Set up dual licensing
- [ ] Create .well-known/ directory
- [ ] Initial CI/CD pipeline

### Week 2: Code Quality
- [ ] Add type safety (TypeScript/mypy/etc.)
- [ ] Configure linters and formatters
- [ ] Set up git hooks
- [ ] Fix linting errors incrementally

### Week 3: Testing
- [ ] Add test framework if missing
- [ ] Write tests for critical paths
- [ ] Achieve 50% coverage minimum
- [ ] Add coverage reporting to CI

### Week 4: Polish & Review
- [ ] Review all changes
- [ ] Update documentation
- [ ] Final testing
- [ ] Merge to main
- [ ] Tag release

---

## Conclusion

Migrating to RSR compliance is an iterative process. Start with Bronze level compliance and gradually improve. The key benefits include:

- **Better code quality**: Type safety and linting catch bugs early
- **Easier collaboration**: Clear documentation and contribution guidelines
- **Confidence in changes**: Comprehensive test coverage
- **Professional polish**: Proper licensing and project structure

Remember: RSR compliance is not just about checking boxes—it's about building maintainable, professional software that others (including AI assistants) can understand and work with effectively.

For language-specific guidance, see:
- [TypeScript Implementation Guide](./typescript-implementation.md)
- [Rust Implementation Guide](./rust-implementation.md)
- [Python Implementation Guide](./python-implementation.md)
- [Testing Best Practices](./testing-best-practices.md)
- [Security Hardening Guide](./security-hardening.md)

## License

This guide is dual-licensed under MIT OR Apache-2.0, same as the RSR template.
