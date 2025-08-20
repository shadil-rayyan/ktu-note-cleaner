# Releasing

Automated via GitHub Actions: `.github/workflows/release.yml`.

## Android signing

Local (optional):

1. Generate keystore:
   ```bash
   keytool -genkeypair -v -keystore release.keystore -alias your-alias -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Move and configure:
   - Move `release.keystore` to `android/app/release.keystore`.
   - Create `android/key.properties` (gitignored):
     ```properties
     storeFile=android/app/release.keystore
     storePassword=<your-store-password>
     keyAlias=your-alias
     keyPassword=<your-key-password>
     ```
3. Build:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

CI:

- Add repository secrets:
  - `ANDROID_KEYSTORE_BASE64` (base64 of keystore)
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_ALIAS`
  - `ANDROID_KEY_PASSWORD`

Fallback behavior:

- The pipeline first attempts a signed build. If signing setup fails or is incomplete, it automatically falls back to an unsigned release build (debug-signed by the default debug key). Artifacts are suffixed with `-unsigned` in that case.

## Tag a release

```bash
git tag v0.2.0 -m "Signed release"
git push origin v0.2.0
```

Artifacts produced:

- Android: signed APK + AAB
- Linux: zip bundle + AppImage
- Windows: zip (optional signing)
- macOS: zip(s) (optional codesign & notarization)

Notes:

- If Android signing fails or secrets are missing, artifacts will be named:
  - `ktunotecleaner-<tag>-android-unsigned.apk`
  - `ktunotecleaner-<tag>-android-unsigned.aab`

## Optional platform signing

- macOS:
  - `APPLE_ID`, `APPLE_TEAM_ID`, `APPLE_APP_SPECIFIC_PASSWORD`, `APPLE_SIGNING_IDENTITY`
- Windows:
  - `WIN_CERT_BASE64`, `WIN_CERT_PASSWORD`

## Notes

- Web build is disabled because the app relies on `dart:io` for file I/O.
