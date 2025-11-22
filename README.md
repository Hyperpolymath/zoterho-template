# Zoterho Template

**RSR Compliance Level**: Bronze ✅ | **TPCF Perimeter**: 3 (Community Sandbox)

A minimal, RSR-compliant template repository demonstrating the Rhodium Standard Repository framework principles.

## Features

- 🔒 **Type Safety**: Structured configuration and validation
- 🛡️ **Memory Safety**: Safe-by-default practices
- 📴 **Offline-First**: Works without network dependencies
- 📚 **Complete Documentation**: All RSR-required documentation included
- 🤝 **TPCF Perimeter 3**: Fully open community contribution model
- ⚖️ **Dual Licensed**: MIT + Palimpsest v0.8 for ethical AI training policies

## RSR Compliance Checklist

This repository meets the following RSR (Rhodium Standard Repository) standards:

- ✅ **Documentation**: README, LICENSE, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT, MAINTAINERS, CHANGELOG
- ✅ **.well-known/**: security.txt (RFC 9116), ai.txt, humans.txt
- ✅ **Build Automation**: justfile with reproducible builds
- ✅ **Type Safety**: Structured configuration validation
- ✅ **Memory Safety**: Safe coding practices enforced
- ✅ **Offline-First**: No mandatory network dependencies
- ✅ **Testing**: Test suite with 100% pass rate
- ✅ **TPCF**: Tri-Perimeter Contribution Framework (Perimeter 3)
- ✅ **Licensing**: Dual MIT + Palimpsest v0.8
- ✅ **Security**: SECURITY.md, security.txt, vulnerability disclosure process
- ✅ **Attribution**: MAINTAINERS.md, humans.txt, clear contribution tracking

## Quick Start

```bash
# Validate RSR compliance
just validate

# Run tests
just test

# Build the project
just build
```

## Project Structure

```
.
├── .well-known/          # RFC 9116 well-known URIs
│   ├── security.txt      # Security contact information
│   ├── ai.txt           # AI training policies
│   └── humans.txt       # Human attribution
├── README.md            # This file
├── LICENSE.txt          # Dual MIT + Palimpsest v0.8
├── SECURITY.md          # Security policies and disclosure
├── CONTRIBUTING.md      # Contribution guidelines
├── CODE_OF_CONDUCT.md   # Community standards
├── MAINTAINERS.md       # Project maintainers
├── CHANGELOG.md         # Version history
└── justfile             # Build automation recipes
```

## TPCF: Tri-Perimeter Contribution Framework

This repository operates under **Perimeter 3: Community Sandbox**

- ✅ **Public**: Fully open source
- ✅ **Open Contribution**: Anyone can submit patches
- ✅ **Review Process**: Maintainer review required
- ✅ **CoC Enforcement**: Code of Conduct applies to all interactions
- ✅ **Attribution**: All contributors recognized in MAINTAINERS.md

## License

This project is dual-licensed under:

1. **MIT License** - for code and general use
2. **Palimpsest License v0.8** - for AI training and dataset inclusion

See [LICENSE.txt](LICENSE.txt) for full terms.

## Documentation

- [Security Policy](SECURITY.md) - Vulnerability disclosure and security practices
- [Contributing Guide](CONTRIBUTING.md) - How to contribute to this project
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community interaction standards
- [Maintainers](MAINTAINERS.md) - Project maintainers and governance
- [Changelog](CHANGELOG.md) - Version history and release notes

## Contact

- **Security**: See [.well-known/security.txt](.well-known/security.txt)
- **General**: See [MAINTAINERS.md](MAINTAINERS.md)

## Acknowledgments

Built following the [Rhodium Standard Repository (RSR) Framework](https://github.com/hyperpolymath/rhodium-minimal).

This template demonstrates Bronze-level RSR compliance and serves as a starting point for building politically autonomous, ethically sound software projects.
