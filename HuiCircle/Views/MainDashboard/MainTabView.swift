import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var activeTab: Int = 0
    
    var body: some View {
        TabView(selection: $activeTab) {
            UnifiedDashboardView()
                .tabItem { Label("Tổng quan", systemImage: "chart.pie.fill") }
                .tag(0)
            
            AllGroupsView()
                .tabItem { Label("Dây Hụi", systemImage: "list.bullet.rectangle.fill") }
                .tag(1)
            
            SettingsView()
                .tabItem { Label("Cài đặt", systemImage: "gearshape.fill") }
                .tag(2)
        }
        .accentColor(DesignTokens.Colors.primaryStart)
    }
}

// MARK: - Summary Dashboard (Như "Sổ Hụi")

struct UnifiedDashboardView: View {
    @Query private var allGroups: [HuiGroup]
    @State private var appearCards = false
    
    // Logic tính toán thực tế (giả định User là Member của tất cả các dây họ tham gia)
    private var totalContributed: Double {
        // Tính tổng tiền User đã đóng trong tất cả các kỳ của tất cả các dây
        // (Đây là logic cần làm sâu ở Sprint 4)
        return 0 
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // FINANCIAL SUMMARY CARD (Sổ Hụi Style)
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tổng tiền đã đóng")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(formatCurrency(totalContributed))
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "eye.fill")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        HStack {
                            SummarySmallCard(title: "Tổng lời", value: "+0đ", color: .green)
                            Spacer()
                            SummarySmallCard(title: "Dự kiến hốt", value: "0đ", color: .yellow)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(DesignTokens.Colors.gradient)
                    )
                    .shadow(color: DesignTokens.Colors.primaryStart.opacity(0.3), radius: 15, x: 0, y: 10)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Quick Action
                    NavigationLink(destination: CreateHuiGroupView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("TẠO DÂY HỤI MỚI")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Categorized Lists
                    VStack(alignment: .leading, spacing: 12) {
                        DashboardLinkRow(icon: "list.bullet", title: "Danh sách dây hụi", count: allGroups.count, color: .blue)
                        DashboardLinkRow(icon: "archivebox", title: "Hụi đã hoàn thành", count: 0, color: .gray)
                        DashboardLinkRow(icon: "trash", title: "Thùng rác", count: 0, color: .red)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("HuiCircle")
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0đ"
    }
}

struct SummarySmallCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct DashboardLinkRow: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 32)
            Text(title)
            Spacer()
            Text("\(count)")
                .foregroundColor(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(DesignTokens.Colors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Cài đặt chung") {
                    Label("Thông báo", systemImage: "bell.fill")
                    Label("Tiền tệ (VND)", systemImage: "dollarsign.circle.fill")
                }
                
                Section("Hỗ trợ") {
                    Label("Hướng dẫn sử dụng", systemImage: "book.fill")
                    Label("Liên hệ", systemImage: "envelope.fill")
                }
                
                Section {
                    Text("Phiên bản 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}

// MARK: - All Groups View (Dây Hụi tab)

struct AllGroupsView: View {
    @Query(sort: \HuiGroup.startDate, order: .reverse) private var groups: [HuiGroup]
    @State private var showingCreateGroup = false
    
    var body: some View {
        NavigationStack {
            List {
                if groups.isEmpty {
                    EmptyStateView(
                        iconName: "tray.fill",
                        title: "Chưa có dây hụi",
                        message: "Bạn chưa tạo dây hụi nào.",
                        buttonTitle: "Tạo ngay",
                        buttonAction: { showingCreateGroup = true }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(groups) { group in
                        NavigationLink(destination: groupDetailDestination(group)) {
                                let completedRounds = group.rounds.filter { $0.status == .completed }.count
                            let progress = group.totalRounds > 0 ? Double(completedRounds) / Double(group.totalRounds) : 0.0
                            
                            HuiCardView(
                                title: group.name,
                                amount: group.baseAmount,
                                frequency: group.frequency.rawValue,
                                statusText: group.status.rawValue,
                                statusColor: group.status == .active ? .green : .blue,
                                progress: progress
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Danh sách dây hụi")
            .toolbar {
                Button(action: { showingCreateGroup = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingCreateGroup) {
                CreateHuiGroupView()
            }
        }
    }
    
    @ViewBuilder
    private func groupDetailDestination(_ group: HuiGroup) -> some View {
        if group.userRole == .owner {
            HuiGroupDetailView(group: group)
        } else {
            GroupDetailMemberView(group: group)
        }
    }
}
