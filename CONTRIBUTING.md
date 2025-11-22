# Contributing to Zoterho Template

Thank you for your interest in contributing! This project follows the **TPCF Perimeter 3: Community Sandbox** model, which means contributions are welcome from anyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Recognition](#recognition)

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

**Key Principles:**
- Be respectful and inclusive
- Welcome newcomers
- Assume good faith
- Focus on what's best for the community

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report:
1. Check existing issues to avoid duplicates
2. Gather information: version, OS, steps to reproduce
3. Create a detailed issue with reproducible steps

**Good Bug Report Includes:**
- Clear, descriptive title
- Step-by-step reproduction instructions
- Expected vs actual behavior
- Environment details (OS, version, etc.)
- Screenshots or error messages (if applicable)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues:
- Use a clear, descriptive title
- Explain why this enhancement would be useful
- Provide specific examples of how it would work
- Consider backwards compatibility

### Security Vulnerabilities

**DO NOT** report security vulnerabilities via public issues!

See [SECURITY.md](SECURITY.md) for responsible disclosure process.

### Your First Code Contribution

Unsure where to start?
- Look for issues labeled `good-first-issue`
- Look for issues labeled `help-wanted`
- Check documentation for outdated sections
- Improve test coverage

## Development Process

### 1. Fork and Clone

```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR-USERNAME/zoterho-template.git
cd zoterho-template
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-number-description
```

**Branch Naming:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or fixes

### 3. Make Your Changes

Follow our coding standards (see below) and ensure:
- Code is well-documented
- Tests pass: `just test`
- Linting passes: `just lint` (if applicable)
- RSR compliance: `just validate`

### 4. Commit Your Changes

Follow our commit message guidelines (see below).

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Coding Standards

### General Principles

1. **Type Safety**: Use strong typing, avoid `any` or equivalent
2. **Memory Safety**: Avoid unsafe operations, validate all input
3. **Offline-First**: Minimize network dependencies
4. **Minimal Dependencies**: Prefer standard library
5. **Readability**: Code should be self-documenting
6. **Testing**: All new features need tests

### Code Style

- Follow language-specific conventions (e.g., Rust: `rustfmt`, JavaScript: Prettier)
- Keep functions small and focused (< 50 lines ideal)
- Use descriptive variable names
- Comment only what's not obvious from code
- Avoid premature optimization

### Documentation

- **Public APIs**: Must have documentation comments
- **Complex Logic**: Explain the "why", not the "what"
- **README**: Update if adding features
- **CHANGELOG**: Add entry for user-facing changes

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, semicolons, etc.)
- `refactor`: Code change that neither fixes bug nor adds feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (build, CI, etc.)

### Examples

```
feat(auth): add OAuth2 support

Implement OAuth2 authentication flow with support for
Google and GitHub providers.

Closes #123
```

```
fix(parser): handle escaped quotes correctly

Previously, escaped quotes in strings caused parser errors.
This commit adds proper escape sequence handling.

Fixes #456
```

### Commit Message Rules

- Use present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor to" not "moves cursor to")
- First line ≤ 72 characters
- Reference issues and PRs when relevant
- Explain *why* the change was made in the body

## Pull Request Process

### Before Submitting

- ✅ Tests pass: `just test`
- ✅ Code follows style guidelines
- ✅ Documentation updated (if needed)
- ✅ CHANGELOG.md updated (if user-facing change)
- ✅ Commits are clean and well-described
- ✅ Branch is up-to-date with `main`

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How was this tested?

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Follows code style
- [ ] No security vulnerabilities introduced
```

### Review Process

1. **Automated Checks**: CI must pass
2. **Maintainer Review**: At least one maintainer approval required
3. **Community Feedback**: 48-hour window for comments
4. **Merge**: Squash and merge (typically)

### What Happens After Merge?

- Your contribution is added to CHANGELOG.md
- You're added to MAINTAINERS.md (Contributors section)
- You're recognized in release notes
- Changes are included in next release

## Recognition

We value all contributions! Contributors are recognized in:

- **MAINTAINERS.md**: All contributors listed
- **.well-known/humans.txt**: Human-readable attribution
- **Release Notes**: Significant contributions highlighted
- **GitHub**: Contributor graph and blame history

### Levels of Recognition

- **Contributor**: Anyone who has a PR merged
- **Regular Contributor**: 3+ merged PRs
- **Core Contributor**: Significant ongoing contributions
- **Maintainer**: Commit access + responsibilities

## Questions?

- Check existing documentation
- Search closed issues
- Open a GitHub Discussion
- Contact maintainers (see MAINTAINERS.md)

## License

By contributing, you agree that your contributions will be licensed under the same dual license as the project (MIT + Palimpsest v0.8). See [LICENSE.txt](LICENSE.txt).

---

**Thank you for contributing!** 🎉

Every contribution, no matter how small, makes this project better.
