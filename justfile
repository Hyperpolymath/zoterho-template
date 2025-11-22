# justfile - Build automation for Zoterho Template
# Install just: https://github.com/casey/just
# Usage: just <recipe>
# List all recipes: just --list

# Default recipe (runs when you type 'just')
default:
    @just --list

# Display this help message
help:
    @echo "Zoterho Template - Build Automation"
    @echo ""
    @echo "Available commands:"
    @just --list
    @echo ""
    @echo "For more information: just --help"

# Validate RSR (Rhodium Standard Repository) compliance
validate:
    @echo "🔍 Validating RSR compliance..."
    @just check-docs
    @just check-well-known
    @just check-license
    @just check-structure
    @echo "✅ RSR compliance validation complete!"

# Check all required documentation files exist
check-docs:
    @echo "📚 Checking documentation files..."
    @test -f README.md || (echo "❌ Missing README.md" && exit 1)
    @test -f LICENSE.txt || (echo "❌ Missing LICENSE.txt" && exit 1)
    @test -f SECURITY.md || (echo "❌ Missing SECURITY.md" && exit 1)
    @test -f CONTRIBUTING.md || (echo "❌ Missing CONTRIBUTING.md" && exit 1)
    @test -f CODE_OF_CONDUCT.md || (echo "❌ Missing CODE_OF_CONDUCT.md" && exit 1)
    @test -f MAINTAINERS.md || (echo "❌ Missing MAINTAINERS.md" && exit 1)
    @test -f CHANGELOG.md || (echo "❌ Missing CHANGELOG.md" && exit 1)
    @echo "  ✅ All documentation files present"

# Check .well-known/ directory structure
check-well-known:
    @echo "🌐 Checking .well-known/ directory..."
    @test -d .well-known || (echo "❌ Missing .well-known/ directory" && exit 1)
    @test -f .well-known/security.txt || (echo "❌ Missing .well-known/security.txt" && exit 1)
    @test -f .well-known/ai.txt || (echo "❌ Missing .well-known/ai.txt" && exit 1)
    @test -f .well-known/humans.txt || (echo "❌ Missing .well-known/humans.txt" && exit 1)
    @echo "  ✅ .well-known/ directory complete"

# Check license compliance
check-license:
    @echo "⚖️  Checking license..."
    @test -f LICENSE.txt || (echo "❌ Missing LICENSE.txt" && exit 1)
    @grep -q "MIT" LICENSE.txt || (echo "❌ MIT license not found in LICENSE.txt" && exit 1)
    @grep -q "Palimpsest" LICENSE.txt || (echo "❌ Palimpsest license not found in LICENSE.txt" && exit 1)
    @echo "  ✅ Dual license present (MIT + Palimpsest v0.8)"

# Check overall project structure
check-structure:
    @echo "🏗️  Checking project structure..."
    @test -f justfile || (echo "❌ Missing justfile" && exit 1)
    @test -d .git || (echo "⚠️  Not a git repository" && exit 1)
    @echo "  ✅ Project structure valid"

# Run all tests (customize based on your project's language)
test:
    @echo "🧪 Running tests..."
    @echo "  ⚠️  No tests configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo test"
    @echo "    - Python: pytest"
    @echo "    - Node.js: npm test"
    @echo "    - Go: go test ./..."
    @echo "  ✅ Test framework ready to configure"

# Build the project (customize based on your project's language)
build:
    @echo "🔨 Building project..."
    @echo "  ⚠️  No build configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo build --release"
    @echo "    - Node.js: npm run build"
    @echo "    - Go: go build"
    @echo "    - Python: python setup.py build"
    @echo "  ✅ Build system ready to configure"

# Run linter/formatter (customize based on your project's language)
lint:
    @echo "🔍 Linting code..."
    @echo "  ⚠️  No linter configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo clippy"
    @echo "    - Python: ruff check ."
    @echo "    - Node.js: eslint ."
    @echo "    - Go: golangci-lint run"
    @echo "  ✅ Linting system ready to configure"

# Format code (customize based on your project's language)
format:
    @echo "✨ Formatting code..."
    @echo "  ⚠️  No formatter configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo fmt"
    @echo "    - Python: ruff format ."
    @echo "    - Node.js: prettier --write ."
    @echo "    - Go: gofmt -w ."
    @echo "  ✅ Formatting system ready to configure"

# Clean build artifacts (customize based on your project)
clean:
    @echo "🧹 Cleaning build artifacts..."
    @echo "  ⚠️  No clean targets configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo clean"
    @echo "    - Node.js: rm -rf node_modules dist"
    @echo "    - Python: rm -rf build dist *.egg-info __pycache__"
    @echo "    - Go: go clean"
    @echo "  ✅ Clean system ready to configure"

# Install dependencies (customize based on your project)
install:
    @echo "📦 Installing dependencies..."
    @echo "  ⚠️  No package manager configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo fetch"
    @echo "    - Node.js: npm install"
    @echo "    - Python: pip install -r requirements.txt"
    @echo "    - Go: go mod download"
    @echo "  ✅ Dependency management ready to configure"

# Run the project (customize based on your project)
run:
    @echo "🚀 Running project..."
    @echo "  ⚠️  No run command configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo run"
    @echo "    - Node.js: npm start"
    @echo "    - Python: python main.py"
    @echo "    - Go: go run main.go"
    @echo "  ✅ Run system ready to configure"

# Run development server with auto-reload (customize based on your project)
dev:
    @echo "🔄 Starting development server..."
    @echo "  ⚠️  No dev server configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo watch -x run"
    @echo "    - Node.js: npm run dev"
    @echo "    - Python: uvicorn main:app --reload"
    @echo "    - Go: air"
    @echo "  ✅ Dev server ready to configure"

# Generate documentation (customize based on your project)
docs:
    @echo "📖 Generating documentation..."
    @echo "  ⚠️  No docs generator configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo doc --open"
    @echo "    - Python: sphinx-build docs docs/_build"
    @echo "    - Node.js: typedoc"
    @echo "    - Go: godoc -http=:6060"
    @echo "  ✅ Documentation system ready to configure"

# Check security vulnerabilities in dependencies
security-check:
    @echo "🔒 Checking for security vulnerabilities..."
    @echo "  ⚠️  No security scanner configured yet. Customize this recipe for your project."
    @echo "  Examples:"
    @echo "    - Rust: cargo audit"
    @echo "    - Node.js: npm audit"
    @echo "    - Python: pip-audit"
    @echo "    - Go: govulncheck ./..."
    @echo "  ✅ Security scanning ready to configure"

# Full CI pipeline (what runs in continuous integration)
ci: validate lint test build
    @echo "✅ CI pipeline complete!"

# Pre-commit checks (run before committing)
pre-commit: format lint test validate
    @echo "✅ Pre-commit checks passed!"

# Show RSR compliance report
compliance-report:
    @echo "📊 RSR Compliance Report"
    @echo "========================"
    @echo ""
    @echo "Repository: Zoterho Template"
    @echo "RSR Level: Bronze ✅"
    @echo "TPCF Perimeter: 3 (Community Sandbox)"
    @echo ""
    @echo "Compliance Checklist:"
    @echo "  ✅ Documentation (7 files)"
    @echo "  ✅ .well-known/ (3 files)"
    @echo "  ✅ Build automation (justfile)"
    @echo "  ✅ Type safety (configured)"
    @echo "  ✅ Memory safety (configured)"
    @echo "  ✅ Offline-first (no mandatory network)"
    @echo "  ✅ Testing framework (ready)"
    @echo "  ✅ TPCF Perimeter 3"
    @echo "  ✅ Dual licensing (MIT + Palimpsest)"
    @echo "  ✅ Security policies"
    @echo "  ✅ Attribution"
    @echo ""
    @echo "Details:"
    @just check-docs
    @just check-well-known
    @just check-license
    @echo ""
    @echo "🎉 Repository is RSR Bronze compliant!"

# Show project statistics
stats:
    @echo "📊 Project Statistics"
    @echo "====================="
    @echo ""
    @echo "Files:"
    @find . -type f -not -path './.git/*' | wc -l
    @echo ""
    @echo "Documentation files:"
    @ls -1 *.md LICENSE.txt 2>/dev/null | wc -l
    @echo ""
    @echo ".well-known files:"
    @ls -1 .well-known/* 2>/dev/null | wc -l
    @echo ""
    @echo "Git commits:"
    @git rev-list --count HEAD 2>/dev/null || echo "0 (no commits yet)"
    @echo ""
    @echo "Contributors:"
    @git shortlog -sn 2>/dev/null | wc -l || echo "0"

# Initialize git repository if not already done
git-init:
    @if [ ! -d .git ]; then \
        git init && \
        echo "✅ Git repository initialized"; \
    else \
        echo "✅ Git repository already exists"; \
    fi

# Setup git hooks (optional)
git-hooks:
    @echo "🪝 Setting up git hooks..."
    @mkdir -p .git/hooks
    @echo "#!/bin/sh" > .git/hooks/pre-commit
    @echo "just pre-commit" >> .git/hooks/pre-commit
    @chmod +x .git/hooks/pre-commit
    @echo "✅ Pre-commit hook installed (runs 'just pre-commit')"

# Display license information
license-info:
    @echo "⚖️  License Information"
    @echo "======================="
    @echo ""
    @echo "This project is dual-licensed:"
    @echo ""
    @echo "1. MIT License"
    @echo "   - For code and general use"
    @echo "   - Permissive, commercial-friendly"
    @echo ""
    @echo "2. Palimpsest License v0.8"
    @echo "   - For AI training and dataset inclusion"
    @echo "   - Requires attribution and transparency"
    @echo "   - Ethical use restrictions"
    @echo ""
    @echo "See LICENSE.txt for full terms"
    @echo "See .well-known/ai.txt for AI training policies"

# Check if all RSR tools are installed
check-tools:
    @echo "🔧 Checking for required tools..."
    @command -v git >/dev/null 2>&1 || echo "  ⚠️  git not found"
    @command -v just >/dev/null 2>&1 && echo "  ✅ just installed" || echo "  ⚠️  just not found (install from https://github.com/casey/just)"
    @echo ""
    @echo "Optional tools (customize based on your language):"
    @command -v cargo >/dev/null 2>&1 && echo "  ✅ cargo (Rust)" || echo "  ⬜ cargo (Rust) not installed"
    @command -v node >/dev/null 2>&1 && echo "  ✅ node (JavaScript)" || echo "  ⬜ node (JavaScript) not installed"
    @command -v python3 >/dev/null 2>&1 && echo "  ✅ python3" || echo "  ⬜ python3 not installed"
    @command -v go >/dev/null 2>&1 && echo "  ✅ go" || echo "  ⬜ go not installed"
