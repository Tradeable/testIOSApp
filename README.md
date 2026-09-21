# Tradeable iOS Integration App

Example iOS app showing how to integrate and exercise `tradeableIOSWrapper` in a UIKit application.

## change log
- migrated app from SwiftUI to UIKit (`AppDelegate` + `ContentViewController`), hosting Flutter widgets via `UIHostingController`
- added new user progress widget

## What This App Demonstrates

- SDK initialization at app startup via `TradeableFlutterNavigator.shared.initializeTFS(...)`
- Embedding Flutter UI inside UIKit using `TradeableFlutterView` via `UIHostingController`
- Display modes in one screen:
  - direct mode
  - card flip mode
  - fullscreen mode
- Native side drawer with Flutter side-nav content
- Fullscreen topic/dashboard content driven by Flutter drawer actions
- Passing initial payload data into Flutter widgets
- Fullscreen invocation with a `topicId`
- User progress widget

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

Edit `testingIosApp/AppDelegate.swift` and update `initializeTFS(...)` values:

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

The main screen (`ContentViewController`) includes:

- Header with app title
- Direct mode widget (`mode: .direct`)
- Card flip widget (`mode: .cardFlip`)
- Fullscreen launcher (`mode: .fullscreen`, `topicId: 6`)
- Native side drawer (`mode: .sideDrawer`, `pageId: 6`)
- Fullscreen content host (`mode: .fullscreenContent` / `.dashboardContent`)
- User Progress widget with recent activity/topic suggestions (`mode: .userProgress`)

## Side Nav Implementation

This app uses a native drawer implementation built with UIKit (`UIView` overlay plus a dimmed backdrop) and renders Flutter content inside it via `UIHostingController`.

```swift
let drawerWidth = view.bounds.width - 32
let drawerHeight = view.bounds.height

let drawer = UIView()
drawer.backgroundColor = .white
drawer.layer.shadowColor = UIColor.black.cgColor
drawer.layer.shadowOpacity = 0.2
drawer.layer.shadowRadius = 12
drawer.layer.shadowOffset = CGSize(width: -3, height: 0)
view.addSubview(drawer)

embed(
    TradeableFlutterView(
        mode: .sideDrawer,
        width: drawerWidth,
        height: drawerHeight,
        data: ["text": "Native Side Drawer"],
        pageId: sideDrawerPageId,
        onCloseSideDrawer: { [weak self] in
            self?.closeDrawer()
        }
    ),
    in: drawer
)
```

The app listens for Flutter events and opens a new fullscreen screen natively:

```swift
navigator.registerDataHandler { [weak self] payload in
    self?.handleFlutterNavigationEvent(payload)
}

private func handleFlutterNavigationEvent(_ payload: [String: Any]) {
    guard let action = payload["action"] as? String else { return }

    DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.closeDrawer()

        switch action {
        case "openTopic":
            let topicId = payload["topicId"] as? Int ?? 0
            if topicId > 0 { self.presentFullscreen(...) }
        case "openDashboard":
            self.presentFullscreen(...)
        default:
            break
        }
    }
}
```

## Usage

Use `TradeableFlutterView` inside a UIKit view controller by wrapping it in a `UIHostingController`. The app's `ContentViewController` provides an `embed(_:in:)` helper for this:

```swift
@discardableResult
private func embed<Content: View>(_ rootView: Content, in container: UIView) -> UIHostingController<Content> {
    let hostingController = UIHostingController(rootView: rootView)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    hostingController.view.backgroundColor = .clear
    addChild(hostingController)
    container.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    NSLayoutConstraint.activate([
        hostingController.view.topAnchor.constraint(equalTo: container.topAnchor),
        hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])
    return hostingController
}
```

Widgets are hosted inside fixed-height containers within a `UIScrollView`/`UIStackView`:

```swift
// Direct mode
embed(
    TradeableFlutterView(mode: .direct, width: 320, height: 220, data: ["text": "Trading Widget"]),
    in: directContainer
)

// Card flip mode
embed(
    TradeableFlutterView(mode: .cardFlip, width: 320, height: 220, data: ["text": "Tap to Flip"]),
    in: cardFlipContainer
)

// Fullscreen launcher
embed(
    TradeableFlutterView(mode: .fullscreen, data: ["text": "Open Fullscreen"], topicId: 6),
    in: fullscreenContainer
)
```

Native side drawer + fullscreen content flow:

```swift
// Drawer content
embed(
    TradeableFlutterView(
        mode: .sideDrawer,
        width: view.bounds.width - 32,
        height: view.bounds.height,
        pageId: 6,
        onCloseSideDrawer: { [weak self] in self?.closeDrawer() }
    ),
    in: drawer
)

// Fullscreen topic content
presentFullscreen(
    TradeableFlutterView(
        mode: .fullscreenContent,
        topicId: 6,
        onCloseFullscreen: { [weak self] in self?.dismiss(animated: true) }
    )
)

// Fullscreen dashboard content
presentFullscreen(
    TradeableFlutterView(
        mode: .dashboardContent,
        onCloseFullscreen: { [weak self] in self?.dismiss(animated: true) }
    )
)

// User Progress widget
embed(
    TradeableFlutterView(mode: .userProgress, width: 360, height: 400),
    in: userProgressContainer
)
```

where fullscreen content is presented as a full-screen `UIHostingController`:

```swift
private func presentFullscreen(_ rootView: TradeableFlutterView) {
    let hostingController = UIHostingController(rootView: rootView)
    hostingController.view.backgroundColor = .white
    hostingController.modalPresentationStyle = .fullScreen
    present(hostingController, animated: true)
}
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
│   ├── AppDelegate.swift          # App entry + initializeTFS
│   ├── ContentView.swift          # Demo screen with 3 display modes (UIKit)
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