import SwiftUI

struct HostDashboardView: View {
    @AppStorage("selectedRole") private var selectedRole: String = ""
    
    var body: some View {
        TabView {
            HostSummaryView(logoutAction: {
                withAnimation { selectedRole = "" }
            })
                .tabItem {
                    Label("Tổng Quan", systemImage: "chart.bar.fill")
                }
            
            HuiGroupListView()
                .tabItem {
                    Label("Dây Hụi", systemImage: "list.clipboard")
                }
        }
        .accentColor(DesignTokens.Colors.primaryStart)
    }
}

struct HostSummaryView: View {
    let logoutAction: () -> Void
    @State private var appearCards = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Chào Chủ Hụi 👋")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Tổng quan tình hình hôm nay")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Simple Statistics (Hardcoded math for UI demo)
                    HStack(spacing: 16) {
                        StatCard(title: "Dây Hụi Đang Chạy", value: "2", icon: "arrow.triangle.2.circlepath", color: .blue)
                            .scaleEffect(appearCards ? 1 : 0.8)
                            .opacity(appearCards ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appearCards)
                            
                        StatCard(title: "Tổng Người Chơi", value: "30", icon: "person.2.fill", color: .green)
                            .scaleEffect(appearCards ? 1 : 0.8)
                            .opacity(appearCards ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appearCards)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Cảnh báo chưa đóng")
                        
                        // Fake Warning Data
                        HStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.title)
                            
                            VStack(alignment: .leading) {
                                Text("3 thành viên đang chậm thanh toán")
                                    .font(.headline)
                                Text("Tổng số tiền phạt/nợ: 3,000,000đ")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.top)
                    .opacity(appearCards ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: appearCards)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Thoát Role") {
                        logoutAction()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    appearCards = true
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(DesignTokens.Colors.cardBackground)
        .cornerRadius(DesignTokens.Defaults.cornerRadius)
    }
}
