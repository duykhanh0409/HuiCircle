import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Avatar + Name
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .foregroundStyle(DesignTokens.Colors.gradient)
                                .frame(width: 64, height: 64)
                            
                            Text(initials)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appState.currentUser?.name ?? "Người dùng")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(appState.currentUser?.phone ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            StatusBadge(
                                text: appState.currentUser?.role.rawValue ?? "",
                                color: roleColor
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Tài khoản")) {
                    HStack {
                        Label("Vai trò", systemImage: "person.badge.key.fill")
                        Spacer()
                        Text(appState.currentUser?.role.rawValue ?? "-")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Label("Tham gia từ", systemImage: "calendar")
                        Spacer()
                        Text(formatDate(appState.currentUser?.createdAt ?? Date()))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Đăng xuất")
                        }
                    }
                }
            }
            .navigationTitle("Hồ Sơ")
            .alert("Đăng xuất?", isPresented: $showLogoutAlert) {
                Button("Đăng xuất", role: .destructive) {
                    logout()
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("Bạn sẽ cần đăng ký lại để sử dụng app.")
            }
        }
    }
    
    private var initials: String {
        let name = appState.currentUser?.name ?? "?"
        let parts = name.split(separator: " ")
        if let first = parts.first?.first {
            return String(first).uppercased()
        }
        return "?"
    }
    
    private var roleColor: Color {
        switch appState.currentUser?.role {
        case .host: return .purple
        case .member: return .blue
        case .both: return .green
        default: return .gray
        }
    }
    
    private func logout() {
        // Xoá User khỏi DB → lần sau mở app sẽ thấy Onboarding lại
        if let user = appState.currentUser {
            modelContext.delete(user)
            try? modelContext.save()
        }
        appState.logout()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
