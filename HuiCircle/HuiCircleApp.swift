//
//  HuiCircleApp.swift
//  HuiCircle
//
//  Created by KhanhNguyen on 28/3/26.
//

import SwiftUI
import SwiftData

@main
struct HuiCircleApp: App {
    @State private var appState = AppState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HuiGroup.self, HuiMember.self, HuiRound.self, Payment.self,
            User.self, HuiMembership.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(appState)
    }
}

