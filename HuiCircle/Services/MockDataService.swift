import SwiftData
import Foundation

class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    @MainActor
    func seedDataIfNeeded(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<HuiGroup>()
        let existingGroups = try? modelContext.fetch(fetchDescriptor)
        
        if let existingGroups = existingGroups, existingGroups.isEmpty {
            // Create Mock Group
            let calendar = Calendar.current
            
            let group = HuiGroup(
                name: "Hụi Tháng 10 triệu",
                baseAmount: 10_000_000,
                totalRounds: 15,
                startDate: Date(),
                frequency: .monthly,
                status: .active
            )
            modelContext.insert(group)
            
            // Create Members
            for i in 1...15 {
                let member = HuiMember(
                    name: "Người chơi \(i)",
                    phone: "090\(Int.random(in: 1000000...9999999))",
                    joinedAt: Date()
                )
                modelContext.insert(member)
                member.group = group
                group.members.append(member)
            }
            
            // Create Rounds
            for i in 1...15 {
                let dueDate = calendar.date(byAdding: .month, value: i - 1, to: Date()) ?? Date()
                let round = HuiRound(
                    roundNumber: i,
                    dueDate: dueDate,
                    status: i == 1 ? RoundStatus.active : RoundStatus.pending
                )
                modelContext.insert(round)
                round.group = group
                group.rounds.append(round)
                
                // For active round, create empty payments
                if round.status == .active {
                    for member in group.members {
                        let payment = Payment(amount: group.baseAmount, roundNumber: round.roundNumber)
                        modelContext.insert(payment)
                        payment.member = member
                        member.payments.append(payment)
                    }
                }
            }
            
            try? modelContext.save()
        }
    }
}
