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
    @Environment(AppState.self) private var appState
    
    /// Lấy tất cả users trong DB, nếu có thì tự động login
    @Query private var users: [User]
    
    var body: some View {
        Group {
            if let user = appState.currentUser {
                // Đã đăng nhập — routing theo role
                switch user.role {
                case .host:
                    HostDashboardView()
                case .member:
                    MemberDashboardView()
                case .both:
                    BothRoleDashboardView()
                }
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            // Auto-login: nếu DB đã có user (không phải lần đầu) thì login luôn
            if appState.currentUser == nil, let existingUser = users.first {
                appState.currentUser = existingUser
            }
        }
        .onChange(of: users) { _, newUsers in
            if appState.currentUser == nil, let existingUser = newUsers.first {
                appState.currentUser = existingUser
            }
        }
    }
}

/// Dashboard cho user có cả 2 roles — hiển thị TabView với cả Host lẫn Member tabs
struct BothRoleDashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var activeTab: Int = 0
    
    var body: some View {
        TabView(selection: $activeTab) {
            HostGroupsTab()
                .tabItem { Label("Quản lý Hụi", systemImage: "crown.fill") }
                .tag(0)
            
            MemberGroupsTab()
                .tabItem { Label("Hụi của tôi", systemImage: "list.star") }
                .tag(1)
            
            ProfileView()
                .tabItem { Label("Hồ Sơ", systemImage: "person.circle") }
                .tag(2)
        }
        .accentColor(DesignTokens.Colors.primaryStart)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [HuiGroup.self, User.self, HuiMembership.self], inMemory: true)
        .environment(AppState())
}
