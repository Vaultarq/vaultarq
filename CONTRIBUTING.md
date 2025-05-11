# Contributing to Vaultarq

Thank you for your interest in contributing to Vaultarq! This document provides guidelines and instructions for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/vaultarq.git`
3. Create a branch for your work: `git checkout -b my-feature`
4. Install dependencies and set up the project

## Project Structure

- `bash/`: Bash script implementations of Vaultarq commands
- `core/`: Core encryption/decryption helpers
- `sdks/`: SDKs for various programming languages
  - `node-sdk/`: Node.js SDK
  - `python-sdk/`: Python SDK
  - `rust-sdk/`: Rust SDK
  - `go-sdk/`: Go SDK
- `examples/`: Example applications showing how to use Vaultarq
- `scripts/`: Helper scripts for development

## Development Workflow

### Working on the Core CLI

1. Make changes to the relevant Bash scripts in the `bash/` directory
2. Test your changes locally by running `./vaultarq <command>`
3. Add appropriate error handling and feedback

### Working on SDKs

Each SDK has its own testing and build process:

#### Node.js SDK

```bash
cd sdks/node-sdk
npm install
npm run build
npm test
```

#### Python SDK

```bash
cd sdks/python-sdk
pip install -e .[dev]
python -m unittest discover tests
```

#### Rust SDK

```bash
cd sdks/rust-sdk
cargo test
```

#### Go SDK

```bash
cd sdks/go-sdk
go test ./...
```

## Guidelines

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Keep the first line under 72 characters
- Reference issues and pull requests where appropriate

### Pull Requests

1. Update documentation and tests along with your code changes
2. Ensure all tests pass before submitting your PR
3. Keep PRs focused on a single topic
4. Reference relevant issues in your PR description

### Coding Style

- Follow the style of the existing code
- Use meaningful variable and function names
- Include comments for non-obvious code sections
- Write unit tests for new functionality

### Changelog Entries

When making significant changes, please add an entry to the `CHANGELOG.md` file under the "Unreleased" section. Follow the existing format:

```markdown
## [Unreleased]

### Added
- Your new feature

### Changed
- Your change to existing functionality

### Fixed
- Your bug fix
```

## Release Process

Vaultarq follows semantic versioning (MAJOR.MINOR.PATCH). The release process is handled through the `scripts/release-version.sh` script and GitHub Actions.

To prepare a release:

1. Update the `CHANGELOG.md` with details for the new version under the "Unreleased" section
2. Run the release script to update versions and generate release notes:
   ```bash
   ./scripts/release-version.sh 0.2.0
   ```
3. Review the generated `RELEASE_NOTES.md` and make any necessary adjustments
4. Commit changes: `git commit -m "Bump version to 0.2.0"`
5. Tag the release: `git tag v0.2.0`
6. Push to GitHub: `git push && git push --tags`

The GitHub Actions workflow will automatically publish packages to npm, PyPI, and crates.io, and create a GitHub Release with the release notes.

## License

By contributing to Vaultarq, you agree that your contributions will be licensed under the project's MIT License. 