# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [Unreleased]
- TBD

## [0.2.0] - 2025-08-20
### Added
- Android release signing support via `android/key.properties` and CI secrets.
- Linux AppImage packaging in CI.
- macOS optional codesign/notarization and Windows optional signing hooks.
- Documentation overhaul: README, Architecture, Development, Releasing, Troubleshooting, Contributing, Security.

### Changed
- Removed Web job from CI due to `dart:io` reliance.
- UI and repository improvements; Android scoped-storage fallback for overwrite.

### Fixed
- CI artifact uploads resilient to missing optional files.

[Unreleased]: https://github.com/shadil-rayyan/ktu-note-cleaner/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/shadil-rayyan/ktu-note-cleaner/releases/tag/v0.2.0
