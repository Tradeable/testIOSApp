import SwiftUI
import tradeableIOSWrapper

struct ContentView: View {
    private let navigator = TradeableFlutterNavigator.shared

    var body: some View {
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
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
