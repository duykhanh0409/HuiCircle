import Foundation
import SwiftData

@Model
final class HuiGroup: Identifiable {
    var id: UUID = UUID()
    var name: String
    var baseAmount: Double
    var totalRounds: Int
    var startDate: Date
    var frequency: Frequency
    var status: GroupStatus
    
    var members: [HuiMember] = []
    
    @Relationship(deleteRule: .cascade, inverse: \HuiRound.group)
    var rounds: [HuiRound] = []
    
    init(name: String, baseAmount: Double, totalRounds: Int, startDate: Date = Date(), frequency: Frequency = Frequency.monthly, status: GroupStatus = GroupStatus.active) {
        self.name = name
        self.baseAmount = baseAmount
        self.totalRounds = totalRounds
        self.startDate = startDate
        self.frequency = frequency
        self.status = status
    }
}

enum Frequency: String, Codable, CaseIterable {
    case daily = "Hằng ngày"
    case weekly = "Hằng tuần"
    case biweekly = "2 Tuần"
    case monthly = "Hằng tháng"
}

enum GroupStatus: String, Codable {
    case active = "Đang chạy"
    case completed = "Hoàn thành"
    case paused = "Tạm dừng"
}
