//
//  ContentView.swift
//  HuiCircle
//
//  Created by KhanhNguyen on 28/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        // Vào thẳng dashboard chính, không Onboarding rườm rà.
        MainTabView()
            .onAppear {
                // MockDataService.shared.seedDataIfNeeded(modelContext: modelContext) // Tắt mock khi test clean flow
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [HuiGroup.self, User.self, HuiMembership.self], inMemory: true)
}
