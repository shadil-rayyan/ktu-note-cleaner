# Security Policy

## Supported versions

The `main` branch is actively maintained. Releases are produced via GitHub Actions.

## Reporting a vulnerability

- Please do not disclose security issues publicly until they are triaged.
- Create a GitHub issue with minimal details and request a maintainer to initiate a private discussion, or submit a private security advisory if available on the repository.
- Provide steps to reproduce and affected platform(s).

## Handling secrets

- Never commit keystores or `android/key.properties`.
- Use GitHub Actions secrets for CI signing keys as documented in `docs/releasing.md`.
