//
//  testingIosAppApp.swift
//  testingIosApp
//
//  Created by Deepak Grandhi on 12/01/26.
//

import SwiftUI
import tradeableIOSWrapper

@main
struct testingIosAppApp: App {
    init() {
        // Initialize TFS with authentication credentials
        let navigator = TradeableFlutterNavigator.shared
        
        navigator.initializeTFS(
            baseUrl: "https://dev.api.tradeable.app/axis/",
            authToken: "",
            portalToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiMSIsIm9pZCI6MiwiaWF0IjoxNzQyNDkwOTY0LCJleHAiOjk5OTk5OTk5OTl9.BbSv_2Z9JgE53bIMbFzg2MaeeCFsrza-epaay7BfEj0",
            appId: "",
            clientId: "",
            publicKey: ""
        ) { success, error in
            if success {
                print("TFS initialized successfully")
            } else {
                print("TFS initialization failed: \(error ?? "Unknown error")")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
