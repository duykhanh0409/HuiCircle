import Foundation
import Observation

/// Singleton lưu trạng thái user đang đăng nhập cho toàn app.
/// Inject qua `.environment(appState)` ở root.
@Observable
class AppState {
    var currentUser: User?
    
    var isLoggedIn: Bool { currentUser != nil }
    
    var canActAsHost: Bool {
        currentUser?.role == .host || currentUser?.role == .both
    }
    
    var canActAsMember: Bool {
        currentUser?.role == .member || currentUser?.role == .both
    }
    
    func logout() {
        currentUser = nil
    }
}
