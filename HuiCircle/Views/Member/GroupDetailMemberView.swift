import SwiftUI
import SwiftData

struct GroupDetailMemberView: View {
    @Bindable var group: HuiGroup
    
    // For MVP, randomly pick a member as the current user, or just first one
    private var currentUser: HuiMember? {
        group.members.first
    }
    
    var body: some View {
        List {
            Section(header: Text("Chi tiết dây hụi (Cho Khách)")) {
                LabeledContent("Giá trị mỗi kỳ", value: formatCurrency(group.baseAmount))
                LabeledContent("Tần suất", value: group.frequency.rawValue)
                LabeledContent("Số thành viên", value: "\(group.members.count)/\(group.totalRounds)")
            }
            
            if let member = currentUser {
                Section(header: Text("Thanh toán của bạn (\(member.name))")) {
                    let sortedRounds = group.rounds.sorted(by: { $0.roundNumber < $1.roundNumber })
                    
                    if sortedRounds.isEmpty {
                        Text("Chưa bắt đầu kỳ hụi nào.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(sortedRounds) { round in
                            if round.status == .active || round.status == .completed {
                                let payment = member.payments.first { $0.roundNumber == round.roundNumber }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Kỳ \(round.roundNumber)")
                                            .font(.headline)
                                        Text(round.status.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    
                                    if round.winner?.id == member.id {
                                        StatusBadge(text: "Bạn hốt hụi kỳ này!", color: .orange)
                                    } else if let p = payment {
                                        VStack(alignment: .trailing) {
                                            Text(formatCurrency(p.amount))
                                                .fontWeight(.bold)
                                                .foregroundColor(p.isPaid ? .green : .red)
                                            
                                            Text(p.isPaid ? "Đã nộp" : "Cần nộp")
                                                .font(.caption)
                                                .foregroundColor(p.isPaid ? .green : .red)
                                        }
                                    } else {
                                        Text("Kỳ hụi lỗi")
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Section {
                    Text("Không tìm thấy thông tin bạn trong dây hụi.")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) đ"
    }
}
