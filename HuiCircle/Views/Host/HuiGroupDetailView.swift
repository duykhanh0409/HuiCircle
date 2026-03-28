import SwiftUI
import SwiftData

struct HuiGroupDetailView: View {
    @Bindable var group: HuiGroup
    
    var body: some View {
        List {
            Section(header: Text("Chi tiết dây hụi")) {
                LabeledContent("Giá trị mỗi kỳ", value: formatCurrency(group.baseAmount))
                LabeledContent("Tần suất", value: group.frequency.rawValue)
                LabeledContent("Số thành viên", value: "\(group.members.count)/\(group.totalRounds)")
                LabeledContent("Trạng thái", value: group.status.rawValue)
            }
            
            Section(header: Text("Lịch trình (\(group.totalRounds) kỳ)")) {
                let sortedRounds = group.rounds.sorted(by: { $0.roundNumber < $1.roundNumber })
                
                ForEach(sortedRounds) { round in
                    NavigationLink(destination: RoundDetailView(round: round)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Kỳ \(round.roundNumber)")
                                    .font(.headline)
                                Text(formatDate(round.dueDate))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            StatusBadge(text: round.status.rawValue, color: statusColor(for: round.status))
                        }
                    }
                }
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Thành viên", destination: MemberListView(group: group))
            }
        }
    }
    
    private func statusColor(for status: RoundStatus) -> Color {
        switch status {
        case .pending: return .gray
        case .active: return .orange
        case .completed: return .green
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) đ"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
