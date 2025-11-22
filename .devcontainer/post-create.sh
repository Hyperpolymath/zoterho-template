#!/bin/bash
set -e

echo "🚀 Setting up RSR development environment..."

# Install just (build automation)
echo "📦 Installing just..."
cargo install just || echo "just already installed"

# Install Rust tools
echo "🦀 Installing Rust tools..."
rustup component add rustfmt clippy
cargo install cargo-audit cargo-tarpaulin || echo "Rust tools already installed"

# Install Python tools
echo "🐍 Installing Python tools..."
pip install --upgrade pip
pip install mypy ruff pytest pytest-cov

# Install Node.js tools globally
echo "📘 Installing Node.js tools..."
npm install -g typescript prettier eslint

# Set up git hooks
echo "🪝 Setting up git hooks..."
if [ -f "justfile" ]; then
    just git-hooks || echo "Could not set up git hooks"
fi

# Verify installations
echo "✅ Verifying installations..."
echo "  - Rust: $(rustc --version)"
echo "  - Cargo: $(cargo --version)"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - Python: $(python3 --version)"
echo "  - just: $(just --version || echo 'not installed')"

echo ""
echo "🎉 Development environment ready!"
echo ""
echo "Quick start:"
echo "  - Run 'just --list' to see available commands"
echo "  - Run 'just validate' to check RSR compliance"
echo "  - Run 'just test' to run tests"
echo ""
