# Tradeable iOS Integration App

Example iOS app showing how to integrate and exercise `tradeableIOSWrapper` in a SwiftUI application.

## What This App Demonstrates

- SDK initialization at app startup via `TradeableFlutterNavigator.shared.initializeTFS(...)`
- Embedding Flutter UI inside SwiftUI using `TradeableFlutterView`
- Display modes in one screen:
  - direct mode
  - card flip mode
  - fullscreen mode
- Native side drawer with Flutter side-nav content
- Fullscreen topic/dashboard content driven by Flutter drawer actions
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
- Native side drawer (`mode: .sideDrawer`, `pageId: 6`)
- Fullscreen content host (`mode: .fullscreenContent` / `.dashboardContent`)

## Side Nav Implementation

This app uses a native drawer container and renders Flutter content inside it.

```swift
TradeableFlutterView(
    mode: .sideDrawer,
    width: proxy.size.width - 32,
    height: proxy.size.height,
    data: ["text": "Native Side Drawer"],
    pageId: sideDrawerPageId,
    onCloseSideDrawer: {
        showNativeDrawer = false
    }
)
```

The app listens for Flutter events and opens a new fullscreen screen natively:

```swift
navigator.registerDataHandler { payload in
    guard let action = payload["action"] as? String else { return }

    showNativeDrawer = false

    switch action {
    case "openTopic":
        let topicId = payload["topicId"] as? Int ?? 0
        if topicId > 0 { presentedScreen = .topic(topicId) }
    case "openDashboard":
        presentedScreen = .dashboard
    default:
        break
    }
}
```

## Usage

Use `TradeableFlutterView` directly in SwiftUI.

```swift
// Direct mode
TradeableFlutterView(
    mode: .direct,
    width: 320,
    height: 220,
    data: ["text": "Trading Widget"]
)

// Card flip mode
TradeableFlutterView(
    mode: .cardFlip,
    width: 320,
    height: 220,
    data: ["text": "Tap to Flip"]
)

// Fullscreen launcher
TradeableFlutterView(
    mode: .fullscreen,
    data: ["text": "Open Fullscreen"],
    topicId: 6
)
```

Native side drawer + fullscreen content flow:

```swift
// Drawer content
TradeableFlutterView(
    mode: .sideDrawer,
    width: proxy.size.width - 32,
    height: proxy.size.height,
    pageId: 6,
    onCloseSideDrawer: { showNativeDrawer = false }
)

// Fullscreen topic content
TradeableFlutterView(
    mode: .fullscreenContent,
    topicId: 6,
    onCloseFullscreen: { presentedScreen = nil }
)

// Fullscreen dashboard content
TradeableFlutterView(
    mode: .dashboardContent,
    onCloseFullscreen: { presentedScreen = nil }
)
```

## Method Channels Used

Channels:

- `embedded_flutter`
- `embedded_flutter/auth`
- `embedded_flutter/navigation`

Host -> Flutter:

- `setData`
- `initializeTFS`
- `openTradeableSideDrawer`
- `navigateTo`, `replaceRoute`, `popToRoot`, `receiveData`

Flutter -> Host:

- `closeCard`
- `closeFullscreen`
- `closeSideDrawer`
- `sendData` (actions: `openTopic`, `openDashboard`)

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