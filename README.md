# Tradeable iOS Integration App

Example iOS app showing how to integrate and exercise `tradeableIOSWrapper` in a SwiftUI application.

## What This App Demonstrates

- SDK initialization at app startup via `TradeableFlutterNavigator.shared.initializeTFS(...)`
- Embedding Flutter UI inside SwiftUI using `TradeableFlutterView`
- All three display modes in one screen:
  - direct mode
  - card flip mode
  - fullscreen mode
- Passing initial payload data into Flutter widgets
- Fullscreen invocation with a `topicId`

## Setup

### 1. Install dependencies

```bash
pod install
```

The `Podfile` automatically:
- clones/pulls `tradeable_flutter_sdk_module` into `flutter_module`
- runs `flutter pub get`
- installs Flutter iOS pods via `install_all_flutter_pods(...)`
- installs `tradeableIOSWrapper` from GitHub

### 2. Configure credentials

Edit `testingIosApp/testingIosAppApp.swift` and update `initializeTFS(...)` values:

```swift
navigator.initializeTFS(
    baseUrl: "https://your-api-base-url.com",
    authToken: "your_auth_token",
    portalToken: "your_portal_token",
    appId: "your_app_id",
    clientId: "your_client_id",
    publicKey: "your_public_key"
) { success, error in
    if success {
        print("TFS initialized successfully")
    } else {
        print("TFS initialization failed: \(error ?? "Unknown error")")
    }
}
```

### 3. Open and run

```bash
open testingIosApp.xcworkspace
```

Then run the `testingIosApp` scheme from Xcode.

## UI Overview

The main screen (`ContentView`) includes:

- Header with app title
- Direct mode widget (`mode: .direct`)
- Card flip widget (`mode: .cardFlip`)
- Fullscreen launcher (`mode: .fullscreen`, `topicId: 6`)

## Project Structure

```text
testingIosApp/
├── testingIosApp/
│   ├── testingIosAppApp.swift   # App entry + initializeTFS
│   ├── ContentView.swift         # Demo screen with 3 display modes
│   └── Assets.xcassets/
├── Podfile
├── flutter_module/
└── testingIosApp.xcworkspace
```

## Dependencies

Managed through CocoaPods in this project:

- `tradeableIOSWrapper` (from GitHub)
- Flutter iOS pods from local `flutter_module`

## Troubleshooting

### Pod install issues

1. Ensure Flutter is installed and available in PATH.
2. Re-run `pod install` from the project root.

### Flutter view does not render

1. Confirm `initializeTFS(...)` is executed successfully at startup.
2. Check Xcode logs for `[TFS]` messages.
3. Verify credentials/base URL are valid for your environment.

## Security Note

Do not commit real production tokens or keys into source files. Prefer loading credentials from secure configuration at runtime.

## License

MIT