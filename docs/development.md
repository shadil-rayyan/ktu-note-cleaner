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

## Local packaging (Fastforge / flutter_distributor)

Fastforge is the new name for flutter_distributor. This repo includes a `distribute_options.yaml` that packages:

- Universal APK
- Split-per-ABI APKs
- AAB

Install the CLI and ensure it's on your PATH:

```bash
# Prefer the new name
dart pub global activate fastforge
export PATH="$PATH:$HOME/.pub-cache/bin"

# If you still use the legacy CLI, you can:
# dart pub global activate flutter_distributor
# and replace `fastforge` with `flutter_distributor` in the commands below.
```

Package all Android artifacts defined in `distribute_options.yaml`:

```bash
fastforge release --name local
```

Quick one-off without using the config (APK + AAB):

```bash
fastforge package --platform=android --targets=apk,aab
```

Outputs are written to `dist/` (gitignored).

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
