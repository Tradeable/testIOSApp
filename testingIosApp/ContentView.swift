import SwiftUI
import tradeableIOSWrapper

private enum PresentedTradeableScreen: Identifiable {
    case topic(Int)
    case dashboard

    var id: String {
        switch self {
        case .topic(let topicId):
            return "topic-\(topicId)"
        case .dashboard:
            return "dashboard"
        }
    }
}

struct ContentView: View {
    private let navigator = TradeableFlutterNavigator.shared
    @State private var showNativeDrawer = false
    @State private var sideDrawerPageId = 6
    @State private var presentedScreen: PresentedTradeableScreen?

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .trailing) {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .imageScale(.large)
                                .font(.system(size: 50))
                                .foregroundStyle(.tint)
                            Text("Tradeable iOS Wrapper Demo")
                                .font(.headline)
                        }
                        .padding()

                        Divider()

                        VStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Direct Mode")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TradeableFlutterView(
                                    mode: .direct,
                                    width: 320,
                                    height: 220,
                                    data: ["text": "Trading Widget"]
                                )
                            }

                            VStack(alignment: .leading) {
                                Text("Card Flip Mode")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TradeableFlutterView(
                                    mode: .cardFlip,
                                    width: 320,
                                    height: 220,
                                    data: ["text": "Tap to Flip"]
                                )
                            }

                            VStack(alignment: .leading) {
                                Text("Fullscreen Mode")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TradeableFlutterView(
                                    mode: .fullscreen,
                                    data: ["text": "Open Fullscreen"],
                                    topicId: 6
                                )
                            }

                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showNativeDrawer = true
                                }
                            } label: {
                                Text("Open Tradeable Side Drawer")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.pink)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }

                if showNativeDrawer {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showNativeDrawer = false
                            }
                        }

                    TradeableFlutterView(
                        mode: .sideDrawer,
                        width: proxy.size.width - 32,
                        height: proxy.size.height,
                        data: ["text": "Native Side Drawer"],
                        pageId: sideDrawerPageId,
                        onCloseSideDrawer: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showNativeDrawer = false
                            }
                        }
                    )
                    .background(Color.white)
                    .frame(width: proxy.size.width - 32, height: proxy.size.height)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: -3, y: 0)
                    .transition(.move(edge: .trailing))
                }
            }
            .fullScreenCover(item: $presentedScreen) { screen in
                switch screen {
                case .topic(let topicId):
                    TradeableFlutterView(
                        mode: .fullscreenContent,
                        width: proxy.size.width,
                        height: proxy.size.height,
                        data: ["text": "Topic Detail"],
                        topicId: topicId,
                        onCloseFullscreen: {
                            presentedScreen = nil
                        }
                    )
                case .dashboard:
                    TradeableFlutterView(
                        mode: .dashboardContent,
                        width: proxy.size.width,
                        height: proxy.size.height,
                        data: ["text": "Learn Dashboard"],
                        onCloseFullscreen: {
                            presentedScreen = nil
                        }
                    )
                }
            }
            .onAppear {
                navigator.registerDataHandler { payload in
                    handleFlutterNavigationEvent(payload)
                }
            }
        }
    }

    private func handleFlutterNavigationEvent(_ payload: [String: Any]) {
        guard let action = payload["action"] as? String else { return }

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.25)) {
                showNativeDrawer = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                switch action {
                case "openTopic":
                    let topicId = payload["topicId"] as? Int ?? 0
                    if topicId > 0 {
                        presentedScreen = .topic(topicId)
                    }
                case "openDashboard":
                    presentedScreen = .dashboard
                default:
                    break
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
