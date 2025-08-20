# Development

## Prerequisites

- Flutter (stable channel)
- JDK 11 (Android builds)
- Android SDK/Xcode as needed for mobile

## Setup

```bash
flutter --version
flutter pub get
flutter analyze
flutter test
flutter run
```

Run per‑platform:

```bash
flutter run -d linux
flutter run -d windows
flutter run -d macos
flutter run -d android
```

## Building releases

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## Code style & linting

- Lints configured via `analysis_options.yaml`.
- Keep imports ordered and avoid unused imports.
- Prefer small, testable functions in domain/data layers.

## Tests

```bash
flutter test -r compact
```

## Adding a new feature

- Create `lib/features/<feature>/` with subfolders `presentation/`, `domain/`, `data/`.
- Add a use case in `domain/usecases/` and a repository interface/impl in `domain/` and `data/` respectively.
- Keep UI in `presentation/` minimal; delegate to use cases.
