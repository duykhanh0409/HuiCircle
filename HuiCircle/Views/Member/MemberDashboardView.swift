import SwiftUI
import SwiftData

struct MemberDashboardView: View {
    @AppStorage("selectedRole") private var selectedRole: String = ""
    @Query private var groups: [HuiGroup]
    
    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Chào bạn 👋")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Theo dõi hụi dễ dàng")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.top)
                        
                        // Fake overview metrics
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                StatCard(title: "Tổng đã đóng", value: "20,000,000đ", icon: "arrow.up.right", color: .red)
                                StatCard(title: "Tổng đã nhận", value: "115,000,000đ", icon: "arrow.down.left", color: .green)
                            }
                            
                            StatCard(title: "Tiền cần nộp kỳ này", value: "7,000,000đ", icon: "clock.fill", color: .orange)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Tổng quan")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Thoát") {
                            withAnimation { selectedRole = "" }
                        }
                    }
                }
            }
            .tabItem {
                Label("Tổng Quan", systemImage: "chart.pie.fill")
            }
            
            MyGroupsView()
                .tabItem {
                    Label("Hụi của tôi", systemImage: "list.star")
                }
        }
        .accentColor(DesignTokens.Colors.primaryStart)
    }
}

// For MVP, just reuse the HuiCardView logic but styled differently
struct MyGroupsView: View {
    @Query(sort: \HuiGroup.startDate, order: .reverse) private var groups: [HuiGroup]
    
    var body: some View {
        NavigationStack {
            List {
                if groups.isEmpty {
                    EmptyStateView(
                        iconName: "tray.fill",
                        title: "Không có dữ liệu",
                        message: "Bạn chưa tham gia dây hụi nào."
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(groups) { group in
                        ZStack {
                            NavigationLink(destination: GroupDetailMemberView(group: group)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            HuiCardView(
                                title: group.name,
                                amount: group.baseAmount,
                                frequency: group.frequency.rawValue,
                                statusText: "Bạn chưa hốt", // hardcoded logic for MVP Member view
                                statusColor: .orange,
                                progress: progress(for: group)
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Hụi Của Tôi")
        }
    }
    
    private func progress(for group: HuiGroup) -> Double {
        guard group.totalRounds > 0 else { return 0 }
        let completed = group.rounds.filter { $0.status == .completed }.count
        return Double(completed) / Double(group.totalRounds)
    }
}
