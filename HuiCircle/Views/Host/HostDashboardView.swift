import SwiftUI
import SwiftData

struct HostDashboardView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        TabView {
            HostGroupsTab()
                .tabItem { Label("Tổng Quan", systemImage: "chart.bar.fill") }
            
            ProfileView()
                .tabItem { Label("Hồ Sơ", systemImage: "person.circle") }
        }
        .accentColor(DesignTokens.Colors.primaryStart)
    }
}

// MARK: - Host Groups Tab (reusable giữa HostDashboard và BothRoleDashboard)

struct HostGroupsTab: View {
    @Environment(AppState.self) private var appState
    @Query private var allGroups: [HuiGroup]
    @State private var showingCreateGroup = false
    @State private var appearCards = false
    
    private var ownedGroups: [HuiGroup] {
        guard let userID = appState.currentUser?.id else { return [] }
        return allGroups
            .filter { $0.ownerUserID == userID }
            .sorted { $0.startDate > $1.startDate }
    }
    
    private var pendingPaymentsCount: Int {
        ownedGroups.flatMap { group in
            group.rounds
                .filter { $0.status == .active }
                .flatMap { round in
                    group.members.filter { member in
                        !(member.payments.first { $0.roundNumber == round.roundNumber }?.isPaid ?? false)
                    }
                }
        }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero header
                    HeaderBanner(
                        title: "Xin chào, \(appState.currentUser?.name ?? "Chủ Hụi") 👋",
                        subtitle: "Bạn đang quản lý \(ownedGroups.count) dây hụi",
                        appearCards: $appearCards
                    )
                    
                    // Stats row
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Dây đang chạy",
                            value: "\(ownedGroups.filter { $0.status == .active }.count)",
                            icon: "arrow.triangle.2.circlepath",
                            color: .blue
                        )
                        .scaleEffect(appearCards ? 1 : 0.8)
                        .opacity(appearCards ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15), value: appearCards)
                        
                        StatCard(
                            title: "Chưa nộp tiền",
                            value: "\(pendingPaymentsCount)",
                            icon: "exclamationmark.triangle.fill",
                            color: pendingPaymentsCount > 0 ? .orange : .green
                        )
                        .scaleEffect(appearCards ? 1 : 0.8)
                        .opacity(appearCards ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.25), value: appearCards)
                    }
                    
                    // Group List
                    VStack(spacing: 0) {
                        SectionHeader(
                            title: "Danh Sách Dây Hụi",
                            actionTitle: "Tạo mới",
                            action: { showingCreateGroup = true }
                        )
                        
                        if ownedGroups.isEmpty {
                            EmptyStateView(
                                iconName: "tray.fill",
                                title: "Chưa có dây hụi nào",
                                message: "Tạo dây hụi đầu tiên để bắt đầu quản lý.",
                                buttonTitle: "Tạo Dây Hụi",
                                buttonAction: { showingCreateGroup = true }
                            )
                        } else {
                            ForEach(ownedGroups) { group in
                                NavigationLink(destination: HuiGroupDetailView(group: group)) {
                                    HuiCardView(
                                        title: group.name,
                                        amount: group.baseAmount,
                                        frequency: group.frequency.rawValue,
                                        statusText: group.status.rawValue,
                                        statusColor: statusColor(for: group.status),
                                        progress: progress(for: group)
                                    )
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Quản Lý Hụi")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCreateGroup) {
                CreateHuiGroupView()
            }
            .onAppear {
                DispatchQueue.main.async { appearCards = true }
            }
        }
    }
    
    private func statusColor(for status: GroupStatus) -> Color {
        switch status {
        case .active: return .green
        case .completed: return .blue
        case .paused: return .orange
        }
    }
    
    private func progress(for group: HuiGroup) -> Double {
        guard group.totalRounds > 0 else { return 0 }
        let completed = group.rounds.filter { $0.status == .completed }.count
        return Double(completed) / Double(group.totalRounds)
    }
}
