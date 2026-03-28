import Foundation
import SwiftData

@Model
final class HuiRound: Identifiable {
    var id: UUID = UUID()
    var roundNumber: Int
    var dueDate: Date
    var winner: HuiMember?
    var bidAmount: Double = 0.0
    var status: RoundStatus = RoundStatus.pending
    
    var group: HuiGroup?
    
    init(roundNumber: Int, dueDate: Date, status: RoundStatus = RoundStatus.pending) {
        self.roundNumber = roundNumber
        self.dueDate = dueDate
        self.status = status
    }
    
    var actualPayment: Double {
        guard let group = group else { return 0 }
        return group.baseAmount - bidAmount
    }
    
    var receivedAmount: Double {
        guard let group = group else { return 0 }
        let membersCount = Double(group.members.count)
        return membersCount * actualPayment
    }
}

enum RoundStatus: String, Codable {
    case pending = "Chưa đến hạn"
    case active = "Đang thu"
    case completed = "Hoàn tất"
}
