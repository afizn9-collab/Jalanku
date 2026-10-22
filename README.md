# JalanKu — Flutter starter (Android + iOS)

Starter project for a branded community navigation app. It is a **real Flutter source project**, but it is not yet a Waze-equivalent service.

## Included
- Native Google Map view.
- Request current GPS location (with runtime permission handling).
- Address lookup using the `geocoding` plugin.
- Open turn-by-turn driving directions in the Google Maps app/browser.
- Local-only incident markers (accident, hazard, congestion, broken-down vehicle).
- Basic widget test.

## Not included yet
- Turn-by-turn navigation embedded inside JalanKu.
- Road route polylines/ETA from Routes API.
- Cloud database, accounts, moderation, report expiry, live sharing, push notifications.
- Waze community traffic data. Google Maps SDK/API usage does not grant access to Waze's private reports.
- Production privacy policy, security review, store assets and release signing.

## Requirements
- Flutter stable SDK (install from https://docs.flutter.dev/get-started/install)
- Android Studio + Android SDK for Android builds.
- macOS + Xcode for local iOS builds/signing. iOS Simulator and App Store builds require macOS.
- Google Cloud project with billing enabled and Maps SDK for Android + Maps SDK for iOS enabled.
- An API key you create in your own Google Cloud project. **No API key is included in this repository.**

## 1. Create platform folders
This starter contains `lib/` and `pubspec.yaml`. From this folder, run:

```bash
flutter create --platforms=android,ios --org com.example.jalanku .
flutter pub get
```

If Flutter asks about overwriting existing files, preserve `lib/main.dart` and `pubspec.yaml`. You may run the command in a fresh directory and copy these source files into it instead.

## 2. Configure Google Maps keys securely
Create a project at https://console.cloud.google.com/ and enable billing. Enable:
- Maps SDK for Android
- Maps SDK for iOS
- Geocoding API if required by the geocoding provider/setup you choose

Create separate Android and iOS API keys and restrict each key to its matching app. Never commit real keys to Git.

### Android
Edit `android/app/src/main/AndroidManifest.xml`. Inside the `<application>` element add:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}" />
```

For a simple local-only test, replace `${MAPS_API_KEY}` with your restricted Android key locally, but do not commit that file with the key. For team/CI use, configure a Gradle manifest placeholder or a local secrets mechanism.

Add location permission before `<application>` in the manifest:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS
Open `ios/Runner/AppDelegate.swift` and import GoogleMaps, then provide the iOS key before `GeneratedPluginRegistrant.register(with: self)`:

```swift
import GoogleMaps
// inside application(_:didFinishLaunchingWithOptions:)
GMSServices.provideAPIKey("YOUR_RESTRICTED_IOS_KEY")
```

Do not put a real key into source control. For a production app, load the key from a local xcconfig/build setting or a secrets pipeline. Follow the current Google Maps Flutter platform setup docs in case plugin versions change the native template.

Add the location usage description to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>JalanKu uses your location to show your position and help start navigation.</string>
```

The app currently needs foreground location only; do not request background location until a clearly defined feature needs it.

## 3. Run
```bash
flutter doctor
flutter pub get
flutter run
```

Connect a real Android phone with USB debugging enabled, or start an Android emulator. For iOS, use a Mac with Xcode and a simulator/device.

## 4. Test
```bash
flutter analyze
flutter test
```

Manual smoke test:
1. Launch the app; verify map loads (valid restricted API key required).
2. Tap the location icon and grant permission; verify camera moves to GPS location.
3. Search a full address or place name; verify a destination marker appears.
4. Tap “Navigasi dengan Google Maps”; verify Google Maps opens with a driving route.
5. Tap each incident report; verify a local marker appears and the UI states it is local-only.
6. Deny location permission and test error messaging.
7. Test offline/no API key to ensure the app fails gracefully.

## Architecture for next milestones
- `lib/features/map/`: map screen, location service, marker layer.
- `lib/features/search/`: Places search/autocomplete.
- `lib/features/navigation/`: Routes API client and Navigation SDK integration.
- `lib/features/reports/`: report model, validation and UI.
- `lib/data/`: repositories and API clients.
- Backend (Firebase/Cloud Run): auth, Firestore/SQL, report rate limiting, moderation and expiry.

Never call Routes API with a server-side secret embedded in a mobile app. Put server credentials behind a backend. Restrict mobile Maps SDK keys by package name + SHA-1 certificate for Android and bundle ID for iOS, plus API restrictions.
