import SwiftUI
import SwiftData

/// Cập nhật: nhận thêm membership để biết đây là member slot nào của user hiện tại
struct GroupDetailMemberView: View {
    @Bindable var group: HuiGroup
    var membership: HuiMembership? = nil
    
    private var currentMember: HuiMember? {
        membership?.member ?? group.members.first
    }
    
    var body: some View {
        List {
            Section(header: Text("Chi tiết dây hụi")) {
                LabeledContent("Giá trị mỗi kỳ", value: formatCurrency(group.baseAmount))
                LabeledContent("Tần suất", value: group.frequency.rawValue)
                LabeledContent("Số thành viên", value: "\(group.members.count)/\(group.totalRounds)")
                LabeledContent("Trạng thái", value: group.status.rawValue)
            }
            
            if let member = currentMember {
                if member.hasWon, let wonRound = member.wonRound {
                    Section {
                        HStack {
                            Image(systemName: "crown.fill").foregroundColor(.orange)
                            Text("Bạn đã hốt hụi kỳ \(wonRound)!")
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Section(header: Text("Thanh toán của bạn (\(member.name))")) {
                    let sortedRounds = group.rounds.sorted { $0.roundNumber < $1.roundNumber }
                    
                    if sortedRounds.filter({ $0.status != .pending }).isEmpty {
                        Text("Chưa bắt đầu kỳ hụi nào.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(sortedRounds.filter { $0.status != .pending }) { round in
                            let payment = member.payments.first { $0.roundNumber == round.roundNumber }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Kỳ \(round.roundNumber)")
                                        .font(.headline)
                                    if round.winner?.id == member.id {
                                        Text("🎉 Bạn hốt hụi kỳ này")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    } else {
                                        Text(formatDate(round.dueDate))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                
                                if let p = payment {
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(formatCurrency(p.amount))
                                            .fontWeight(.bold)
                                            .foregroundColor(p.isPaid ? .green : .red)
                                        Text(p.isPaid ? "✓ Đã nộp" : "⏳ Chưa nộp")
                                            .font(.caption)
                                            .foregroundColor(p.isPaid ? .green : .red)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Section {
                    Text("Không tìm thấy thông tin của bạn trong dây hụi này.")
                        .foregroundColor(.orange)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
