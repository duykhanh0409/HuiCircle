import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var selectedRole: UserRole = .host
    
    @State private var currentStep: Int = 1
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Gradient
            ZStack {
                DesignTokens.Colors.gradient
                    .ignoresSafeArea(edges: .top)
                
                VStack(spacing: 12) {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1 : 0.6)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isAnimating)
                    
                    Text("HuiCircle")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Quản lý hụi thông minh")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 40)
            }
            .frame(maxHeight: 220)
            
            // Step indicator
            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { step in
                    Capsule()
                        .frame(width: currentStep == step ? 24 : 8, height: 8)
                        .foregroundColor(currentStep >= step ? DesignTokens.Colors.primaryStart : .gray.opacity(0.3))
                        .animation(.spring(), value: currentStep)
                }
            }
            .padding(.top, 24)
            
            // Steps content
            Group {
                if currentStep == 1 {
                    step1View
                } else if currentStep == 2 {
                    step2View
                } else {
                    step3View
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            
            Spacer()
            
            // Bottom button
            VStack(spacing: 12) {
                Button(action: nextStep) {
                    Text(currentStep == 3 ? "Bắt đầu sử dụng 🎉" : "Tiếp theo")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canProceed ? DesignTokens.Colors.primaryStart : Color.gray)
                        .cornerRadius(DesignTokens.Defaults.cornerRadius)
                        .animation(.easeInOut, value: canProceed)
                }
                .disabled(!canProceed)
                
                if currentStep > 1 {
                    Button("Quay lại") {
                        withAnimation { currentStep -= 1 }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            DispatchQueue.main.async { isAnimating = true }
        }
    }
    
    // MARK: - Steps
    
    private var step1View: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bước 1/3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Thông tin của bạn")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 16) {
                InputField(icon: "person.fill", placeholder: "Họ và tên", text: $name)
                InputField(icon: "phone.fill", placeholder: "Số điện thoại", text: $phone)
                    .keyboardType(.phonePad)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    private var step2View: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bước 2/3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Vai trò của bạn")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 12) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    RoleOptionCard(
                        role: role,
                        isSelected: selectedRole == role,
                        onTap: { withAnimation(.spring()) { selectedRole = role } }
                    )
                }
            }
            
            Text("💡 Nếu bạn vừa là Chủ Hụi vừa tham gia hụi, chọn \"Cả hai\".")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    private var step3View: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bước 3/3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Xác nhận thông tin")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 12) {
                ConfirmRow(label: "Tên", value: name)
                ConfirmRow(label: "SĐT", value: phone)
                ConfirmRow(label: "Vai trò", value: selectedRole.rawValue)
            }
            .padding()
            .background(DesignTokens.Colors.cardBackground)
            .cornerRadius(DesignTokens.Defaults.cornerRadius)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    // MARK: - Logic
    
    private var canProceed: Bool {
        switch currentStep {
        case 1: return !name.trimmingCharacters(in: .whitespaces).isEmpty && phone.count >= 9
        case 2: return true
        case 3: return true
        default: return false
        }
    }
    
    private func nextStep() {
        if currentStep < 3 {
            withAnimation { currentStep += 1 }
        } else {
            createUser()
        }
    }
    
    private func createUser() {
        let newUser = User(
            name: name.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            role: selectedRole
        )
        modelContext.insert(newUser)
        try? modelContext.save()
        
        withAnimation { appState.currentUser = newUser }
    }
}

// MARK: - Reusable Sub-components

struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(DesignTokens.Colors.primaryStart)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
        }
        .padding()
        .background(DesignTokens.Colors.cardBackground)
        .cornerRadius(12)
    }
}

struct RoleOptionCard: View {
    let role: UserRole
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: role.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : DesignTokens.Colors.primaryStart)
                    .frame(width: 36, height: 36)
                    .background(isSelected ? DesignTokens.Colors.primaryStart : DesignTokens.Colors.primaryStart.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(role.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(roleDescription(role))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DesignTokens.Colors.primaryStart)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? DesignTokens.Colors.primaryStart : Color.clear, lineWidth: 2)
                    .background(DesignTokens.Colors.cardBackground.cornerRadius(12))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func roleDescription(_ role: UserRole) -> String {
        switch role {
        case .host: return "Tạo và quản lý các dây hụi"
        case .member: return "Tham gia và theo dõi hụi"
        case .both: return "Vừa quản lý, vừa tham gia"
        }
    }
}

struct ConfirmRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}
