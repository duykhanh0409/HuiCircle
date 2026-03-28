import Foundation
import SwiftData

@Model
final class HuiMember: Identifiable {
    var id: UUID = UUID()
    var name: String
    var phone: String
    var joinedAt: Date = Date()
    var hasWon: Bool = false
    var wonRound: Int?
    
    @Relationship(deleteRule: .cascade, inverse: \Payment.member)
    var payments: [Payment] = []
    
    var group: HuiGroup?
    
    init(name: String, phone: String, joinedAt: Date = Date(), hasWon: Bool = false, wonRound: Int? = nil) {
        self.name = name
        self.phone = phone
        self.joinedAt = joinedAt
        self.hasWon = hasWon
        self.wonRound = wonRound
    }
}
