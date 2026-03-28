import Foundation
import SwiftData

@Model
final class Payment: Identifiable {
    var id: UUID = UUID()
    var amount: Double
    var paidAt: Date?
    var isPaid: Bool = false
    var roundNumber: Int
    
    var member: HuiMember?
    
    init(amount: Double, roundNumber: Int, isPaid: Bool = false, paidAt: Date? = nil) {
        self.amount = amount
        self.roundNumber = roundNumber
        self.isPaid = isPaid
        self.paidAt = paidAt
    }
}
