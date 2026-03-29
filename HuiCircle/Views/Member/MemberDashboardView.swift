import SwiftUI
import SwiftData

struct MemberDashboardView: View {
    var body: some View {
        TabView {
            MemberGroupsTab()
                .tabItem { Label("Hụi của tôi", systemImage: "list.star") }
            
            ProfileView()
                .tabItem { Label("Hồ Sơ", systemImage: "person.circle") }
        }
        .accentColor(DesignTokens.Colors.primaryStart)
    }
}

// MARK: - Member Groups Tab (reusable giữa MemberDashboard và BothRoleDashboard)

struct MemberGroupsTab: View {
    @Environment(AppState.self) private var appState
    @Query private var allMemberships: [HuiMembership]
    @State private var appearCards = false
    
    /// Lọc HuiMembership theo SĐT của User đang đăng nhập
    private var myMemberships: [HuiMembership] {
        guard let phone = appState.currentUser?.phone else { return [] }
        return allMemberships.filter { $0.memberPhone == phone }
    }
    
    private var myGroups: [HuiGroup] {
        myMemberships.compactMap { $0.group }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HeaderBanner(
                        title: "Hụi của \(appState.currentUser?.name ?? "bạn") 👤",
                        subtitle: "Đang tham gia \(myGroups.count) dây hụi",
                        appearCards: $appearCards
                    )
                    
                    // Summary Stats
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Đang tham gia",
                            value: "\(myGroups.filter { $0.status == .active }.count)",
                            icon: "checkmark.seal.fill",
                            color: .blue
                        )
                        .scaleEffect(appearCards ? 1 : 0.8)
                        .opacity(appearCards ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15), value: appearCards)
                        
                        StatCard(
                            title: "Cần nộp",
                            value: "\(pendingPaymentsCount)",
                            icon: "clock.fill",
                            color: pendingPaymentsCount > 0 ? .orange : .green
                        )
                        .scaleEffect(appearCards ? 1 : 0.8)
                        .opacity(appearCards ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.25), value: appearCards)
                    }
                    
                    // Group list
                    VStack(spacing: 0) {
                        SectionHeader(title: "Dây Hụi Đang Tham Gia")
                        
                        if myGroups.isEmpty {
                            EmptyStateView(
                                iconName: "person.2.slash",
                                title: "Chưa tham gia dây hụi nào",
                                message: "Liên hệ Chủ Hụi để được thêm vào dây hụi của bạn."
                            )
                        } else {
                            ForEach(myMemberships) { membership in
                                if let group = membership.group {
                                    NavigationLink(destination: GroupDetailMemberView(group: group, membership: membership)) {
                                        HuiCardView(
                                            title: group.name,
                                            amount: group.baseAmount,
                                            frequency: group.frequency.rawValue,
                                            statusText: memberStatusText(membership),
                                            statusColor: membership.member?.hasWon == true ? .green : .orange,
                                            progress: progress(for: group)
                                        )
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Hụi Của Tôi")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                DispatchQueue.main.async { appearCards = true }
            }
        }
    }
    
    private var pendingPaymentsCount: Int {
        myMemberships.compactMap { m -> Int? in
            guard let member = m.member, let group = m.group else { return nil }
            return group.rounds
                .filter { $0.status == .active }
                .filter { round in
                    !(member.payments.first { $0.roundNumber == round.roundNumber }?.isPaid ?? false)
                }
                .count
        }.reduce(0, +)
    }
    
    private func memberStatusText(_ membership: HuiMembership) -> String {
        membership.member?.hasWon == true ? "Đã hốt" : "Chưa hốt"
    }
    
    private func progress(for group: HuiGroup) -> Double {
        guard group.totalRounds > 0 else { return 0 }
        let completed = group.rounds.filter { $0.status == .completed }.count
        return Double(completed) / Double(group.totalRounds)
    }
}
