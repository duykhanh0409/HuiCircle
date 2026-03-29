import SwiftUI
import SwiftData

struct CreateHuiGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var baseAmountStr: String = ""
    @State private var totalMembers: Int = 10
    @State private var frequency: Frequency = .monthly
    @State private var startDate: Date = Date()
    @State private var userRole: UserRoleInGroup = .owner
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Thông tin cơ bản")) {
                    TextField("Tên dây hụi (Vd: Dây của Cô Sáu)", text: $name)
                    TextField("Số tiền hụi mỗi phần (VNĐ)", text: $baseAmountStr)
                        .keyboardType(.numberPad)
                    
                    Picker("Chu kỳ thu", selection: $frequency) {
                        ForEach(Frequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    
                    DatePicker("Ngày bắt đầu", selection: $startDate, displayedComponents: .date)
                    
                    Picker("Vai trò của tôi", selection: $userRole) {
                        ForEach([UserRoleInGroup.owner, .participant], id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                }
                
                Section(header: Text("Thiết lập dây")) {
                    Stepper("Số phần hụi (Kỳ đóng): \(totalMembers)", value: $totalMembers, in: 2...100)
                    Text("Số lượng thành viên cũng chính là tổng số kỳ hụi cần chạy.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Ghi chú")) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Tạo Dây Hụi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lưu") { saveGroup() }
                        .disabled(name.isEmpty || baseAmountStr.isEmpty)
                }
            }
        }
    }
    
    private func saveGroup() {
        guard let baseAmount = Double(baseAmountStr) else { return }
        
        let newGroup = HuiGroup(
            name: name,
            baseAmount: baseAmount,
            totalRounds: totalMembers,
            startDate: startDate,
            frequency: frequency,
            status: .active,
            userRole: userRole,
            notes: notes
        )
        modelContext.insert(newGroup)
        
        // Auto-generate rounds
        let calendar = Calendar.current
        for i in 1...totalMembers {
            let components: Calendar.Component = {
                switch frequency {
                case .daily: return .day
                case .weekly: return .weekday
                case .biweekly: return .day
                case .monthly: return .month
                }
            }()
            
            let value = frequency == .biweekly ? (i - 1) * 14 : (i - 1)
            let dueDate = calendar.date(byAdding: components, value: value, to: startDate) ?? startDate
            
            let round = HuiRound(roundNumber: i, dueDate: dueDate)
            modelContext.insert(round)
            round.group = newGroup
            newGroup.rounds.append(round)
        }
        
        try? modelContext.save()
        dismiss()
    }
}
