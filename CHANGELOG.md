# Changelog

## [0.1.10] - 2025-05-12
### Added
- Docker-based CLI distribution system
- Support for GitHub Packages and Docker Hub distribution
- Improved installation script with registry fallbacks
- Synchronized versioning across CLI and all SDK components

### Fixed
- Release workflow issues with cargo publish
- Installation script reliability improvements
- Proper version tagging in all components

## [0.1.9] - 2025-05-12
### Added
- Version synchronization across CLI and SDKs



All notable changes to the Vaultarq project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.8] - 2025-05-11

### Fixed
- Fixed GitHub Release creation by adding proper permissions to the workflow
- Updated release creation action to use softprops/action-gh-release

## [0.1.7] - 2025-05-11

### Added
- Proper CHANGELOG.md for tracking project history
- Complete release notes for GitHub Releases

### Fixed
- Fixed GitHub Release creation by adding CHANGELOG.md

## [0.1.6] - 2025-05-11

### Added
- Python SDK published to PyPI using API token authentication
- Successful publishing of all SDKs to respective package registries
- Complete CI/CD pipeline for automated releases

### Fixed
- Fixed Rust SDK publishing using direct cargo commands
- Updated GitHub Actions workflow to handle package-lock.json

## [0.1.5] - 2025-05-11

### Changed
- Updated Python SDK to use PyPI API token for publishing

### Fixed
- Python SDK publishing error due to deprecated username/password authentication

## [0.1.4] - 2025-05-11

### Changed
- Updated all SDK versions to be in sync
- Improved Rust SDK publishing process

### Fixed
- Node.js SDK build process now uses npm install instead of npm ci

## [0.1.3] - 2025-05-11

### Added
- GitHub Actions workflow for automated SDK publishing
- Standardized versioning across all SDKs

## [0.1.0] - 2025-05-10

### Added
- Initial release of Vaultarq
- Node.js SDK with TypeScript support
- Python SDK
- Rust SDK
- Documentation for each SDK 