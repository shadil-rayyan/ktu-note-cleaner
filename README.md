# KTU Notes PDF Cleaner

[![Release CI](https://github.com/shadil-rayyan/ktu-note-cleaner/actions/workflows/release.yml/badge.svg)](https://github.com/shadil-rayyan/ktu-note-cleaner/actions/workflows/release.yml)
[![Latest release](https://img.shields.io/github/v/release/shadil-rayyan/ktu-note-cleaner)](https://github.com/shadil-rayyan/ktu-note-cleaner/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/shadil-rayyan/ktu-note-cleaner/total)](https://github.com/shadil-rayyan/ktu-note-cleaner/releases)
[![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20Linux%20%7C%20Windows%20%7C%20macOS-blue)](#)
[![License](https://img.shields.io/github/license/shadil-rayyan/ktu-note-cleaner)](./LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/shadil-rayyan/ktu-note-cleaner)](https://github.com/shadil-rayyan/ktu-note-cleaner/commits)
[![Open issues](https://img.shields.io/github/issues/shadil-rayyan/ktu-note-cleaner)](https://github.com/shadil-rayyan/ktu-note-cleaner/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Flutter](https://img.shields.io/badge/Flutter-stable-blue?logo=flutter)](https://flutter.dev)

Remove clickable links and annotations from PDF notes in one click. Cross‑platform Flutter app for Linux, Windows, macOS, and Android.

## Overview

KTU Notes PDF Cleaner strips link annotations from your PDFs so scrolling and selecting text doesn’t accidentally open browsers or jump pages. It processes files locally on your device — no uploads, no telemetry.

## Features

- Remove PDF link annotations using `syncfusion_flutter_pdf`
- Select multiple files or an entire folder
- Overwrite originals or save as `<name>_cleaned.pdf`
- Android scoped‑storage fallback to a safe app directory when overwrite is blocked
- Desktop builds: Linux (AppImage + zip), Windows (zip), macOS (zip)

## Download

- Get prebuilt binaries from GitHub Releases (when available)
- Or build from source (see Development)

## Usage

1. Launch the app.
2. Click “Select PDFs or Folder”.
3. Choose whether to overwrite originals or save `_cleaned` copies.
4. Start. The status label shows progress and results.

Notes:
- On Android, overwriting arbitrary locations may fail due to scoped storage. The app automatically saves cleaned copies into an app‑writable directory.
- No network access is required; all processing is local.

## Architecture

Folder layout highlights:

- `lib/core/result.dart` — lightweight result helpers.
- `lib/features/pdf_cleaner/` — vertical slice for the PDF cleaning feature
  - `domain/` — `CleanPdfsUseCase`
  - `data/pdf_cleaner_repository_impl.dart` — removes `PdfLinkAnnotation` objects, handles Android fallback
  - `presentation/pages/pdf_cleaner_page.dart` — UI

Key flow:
`PdfCleanerPage` → `CleanPdfsUseCase` → `PdfCleanerRepositoryImpl.cleanPdfs()` → Syncfusion PDF API → write output.

## Development

Prereqs: Flutter (stable channel), Android SDK/Xcode as needed.

```bash
flutter --version
flutter pub get
flutter analyze
flutter test
flutter run
```

Build releases:

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# Linux/Windows/macOS
flutter build linux --release
flutter build windows --release
flutter build macos --release
```

## Releasing (CI)

Workflow: `.github/workflows/release.yml`

- Android signing via `android/key.properties` (local) or GitHub Secrets (CI):
  - `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`
- Fallback: if signing fails or secrets are missing, an unsigned release build is produced automatically. Android artifacts will be suffixed with `-unsigned`.
- Artifacts:
  - Android: signed APK + AAB
  - Linux: zip bundle + AppImage
  - Windows: zip (optional code signing)
  - macOS: zip(s) (optional codesign / notarization)
- Create a tag (e.g., `v0.2.0`) to trigger the pipeline.

See `docs/releasing.md` for step‑by‑step details.

## Troubleshooting

- Android cannot overwrite PDF: cleaned copy is saved to app‑writable directory automatically.
- Linux library issues: prefer the AppImage artifact.
- macOS Gatekeeper: either notarize (CI option) or right‑click → Open the first time.
- Windows SmartScreen: provide a code‑signed build (optional in CI).

More in `docs/troubleshooting.md`.

## Acknowledgements

- Syncfusion Flutter PDF — PDF manipulation
- file_picker, path_provider, permission_handler — cross‑platform I/O

## Contributing

PRs welcome! See `CONTRIBUTING.md` and `docs/development.md`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
