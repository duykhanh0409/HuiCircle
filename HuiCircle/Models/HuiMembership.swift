import Foundation
import SwiftData

/// Bảng join giữa User (người chơi) và HuiGroup.
/// Khi Host thêm memberBằng SĐT, app sẽ tạo 1 HuiMembership để sau này
/// User đăng nhập bằng SĐT đó sẽ thấy đúng dây hụi của mình.
@Model
final class HuiMembership: Identifiable {
    var id: UUID = UUID()
    
    /// SĐT người chơi — dùng để match với User.phone khi Member đăng nhập
    var memberPhone: String
    
    var joinedAt: Date = Date()
    
    /// Dây hụi mà membership này thuộc về
    var group: HuiGroup?
    
    /// Thành viên cụ thể trong dây hụi đó
    var member: HuiMember?
    
    init(memberPhone: String, group: HuiGroup, member: HuiMember) {
        self.memberPhone = memberPhone
        self.group = group
        self.member = member
    }
}
