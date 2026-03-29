import Foundation
import SwiftData

@Model
final class User: Identifiable {
    var id: UUID = UUID()
    var name: String
    var phone: String
    var role: UserRole
    var createdAt: Date = Date()
    
    init(name: String, phone: String, role: UserRole) {
        self.name = name
        self.phone = phone
        self.role = role
    }
}

enum UserRole: String, Codable, CaseIterable {
    case host = "Chủ Hụi"
    case member = "Người Chơi"
    case both = "Cả hai"
    
    var icon: String {
        switch self {
        case .host: return "crown.fill"
        case .member: return "person.fill"
        case .both: return "person.2.fill"
        }
    }
}
