# WeighPoint

An iOS app for tracking body metrics, viewing progress toward weight goals, and generating optional AI insights. Built with SwiftUI, SwiftData, HealthKit, and CloudKit.

## Local setup

1. Open `WeighPoint.xcodeproj` in Xcode 26 or later. The app targets iOS 18 or later.
2. Copy `Config/Local.example.xcconfig` to `Config/Local.xcconfig`.
3. Set `GEMINI_API_KEY` in the local file to enable Gemini insights. Without a key, AI requests return no result; the project can still build.
4. Set your Apple `DEVELOPMENT_TEAM` in the same local file for device signing. If using your own developer account, configure your own bundle identifiers and iCloud container in Xcode.
5. Allow Xcode to resolve the Swift package dependencies, then run the WeighPoint scheme.

`Config/Shared.xcconfig` supplies blank defaults and optionally includes the ignored local file for Debug and Release. The existing bundle and iCloud container identifiers identify the app; they are not authentication credentials.

## Keeping credentials out of Git

`Config/Local.xcconfig` contains private settings and must never be committed. The ignore rules also exclude environment files, signing keys, Xcode user settings, build output, logs, and local databases. Only blank example configuration belongs in the repository.

Enable the included commit check after cloning:

```sh
git config core.hooksPath .githooks
```

Run a check manually:

```sh
python3 scripts/check-secrets.py
python3 scripts/check-secrets.py --staged
```

The check rejects common credential formats and private file paths without printing their contents. It is a basic safeguard, not an exhaustive secret detector. Review staged changes before pushing; `.gitignore` does not remove anything already committed.

The Gemini key is substituted into the built app's Info.plist. This keeps it out of Git, but a distributed app's key can still be extracted. Use a backend to keep a production service key private, and do not upload app archives or build logs containing local settings. Rotate any key that has previously been shared or included in a distributed build.
