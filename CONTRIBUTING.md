# Contributing

Thanks for your interest in improving KTU Notes PDF Cleaner!

## Ways to contribute

- Report bugs and request features via GitHub Issues.
- Improve documentation and examples.
- Submit pull requests for fixes and enhancements.

## Development workflow

1. Fork & clone the repo.
2. Create a branch: `feat/...` or `fix/...`.
3. Run checks:
   ```bash
   flutter pub get
   flutter analyze
   flutter test -r compact
   ```
4. Commit with clear messages and open a PR.

## Code style

- Follow Flutter/Dart best practices and the repo lints in `analysis_options.yaml`.
- Keep functions small and focused; add tests for non‑UI logic.

## PR guidelines

- Describe the problem and solution clearly.
- Include screenshots for UI changes when relevant.
- Keep changes scoped; large refactors should be split into smaller PRs.
