# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial RSR (Rhodium Standard Repository) framework implementation
- Bronze-level compliance with all 11 RSR categories
- Complete documentation suite (README, LICENSE, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT, MAINTAINERS, CHANGELOG)
- .well-known/ directory structure (security.txt, ai.txt, humans.txt)
- Dual licensing: MIT + Palimpsest v0.8
- TPCF Perimeter 3 (Community Sandbox) governance model
- Build automation with justfile
- RSR compliance validation tooling

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- Implemented security.txt per RFC 9116
- Added vulnerability disclosure process
- Security scanning in CI/CD pipeline

## Version History

### [0.1.0] - YYYY-MM-DD (Upcoming)

**Initial Release**

This is the first release of Zoterho Template, a minimal RSR-compliant template repository.

**Highlights:**
- ✅ RSR Bronze-level compliance
- ✅ Complete documentation
- ✅ TPCF Perimeter 3 governance
- ✅ Dual MIT + Palimpsest licensing
- ✅ Offline-first design
- ✅ Type-safe and memory-safe practices
- ✅ 100% test pass rate

---

## Legend

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security improvements or vulnerability fixes

## Release Cycle

- **Major versions** (x.0.0): Breaking changes, major features
- **Minor versions** (0.x.0): New features, backwards compatible
- **Patch versions** (0.0.x): Bug fixes, security patches

## Versioning Policy

We follow [Semantic Versioning](https://semver.org/):

Given a version number MAJOR.MINOR.PATCH:
- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible functionality additions
- **PATCH**: Backwards-compatible bug fixes

Pre-1.0.0 versions may have breaking changes in minor versions.

## Support

- **Current stable**: Receives all updates
- **Previous minor**: Security fixes only (6 months)
- **Older versions**: No support

## How to Read This Changelog

Each version lists changes in categories:
1. Read **Security** first (critical updates)
2. Check **Breaking Changes** in Changed/Removed (migration needed)
3. Review **Added** (new features you can use)
4. Scan **Fixed** (bugs that are resolved)

## Contributing to Changelog

When submitting a PR, add your changes under `[Unreleased]` in the appropriate category:

```markdown
### Added
- Brief description of new feature (#PR-number)
```

Maintainers will move entries to versioned sections upon release.

---

*For older versions and detailed commit history, see [GitHub Releases](../../releases).*
