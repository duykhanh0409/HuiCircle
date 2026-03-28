import SwiftUI
import SwiftData

struct CreateHuiGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var baseAmountStr: String = ""
    @State private var totalMembers: Int = 10
    @State private var frequency: Frequency = .monthly
    @State private var startDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Thông tin cơ bản")) {
                    TextField("Tên dây hụi", text: $name)
                    
                    TextField("Số tiền mỗi kỳ (VNĐ)", text: $baseAmountStr)
                        .keyboardType(.numberPad)
                    
                    Picker("Chu kỳ thu", selection: $frequency) {
                        ForEach(Frequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    
                    DatePicker("Ngày bắt đầu", selection: $startDate, displayedComponents: .date)
                }
                
                Section(header: Text("Thành viên"), footer: Text("Số lượng thành viên cũng chính là tổng số kỳ hụi cần chạy.")) {
                    Stepper("Số lượng người chơi: \(totalMembers)", value: $totalMembers, in: 2...50)
                }
            }
            .navigationTitle("Tạo Dây Hụi Mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lưu") { saveGroup() }
                        .disabled(name.isEmpty || Double(baseAmountStr) == nil)
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
            status: .active
        )
        modelContext.insert(newGroup)
        
        // Auto generate empty rounds based on size
        let calendar = Calendar.current
        for i in 1...totalMembers {
            var dateComponent = DateComponents()
            switch frequency {
            case .daily: dateComponent.day = i - 1
            case .weekly: dateComponent.day = (i - 1) * 7
            case .biweekly: dateComponent.day = (i - 1) * 14
            case .monthly: dateComponent.month = i - 1
            }
            
            let roundDate = calendar.date(byAdding: dateComponent, to: startDate) ?? Date()
            let status: RoundStatus = i == 1 ? RoundStatus.active : RoundStatus.pending
            
            let round = HuiRound(roundNumber: i, dueDate: roundDate, status: status)
            modelContext.insert(round)
            round.group = newGroup
            newGroup.rounds.append(round)
        }
        
        // Let user add members later or here.
        dismiss()
    }
}
