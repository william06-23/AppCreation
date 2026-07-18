import Foundation

// MARK: - 全局常量
// 所有硬编码值集中在这里，方便全局修改

enum Constants {

    // MARK: API
    enum API {
        static let baseURL = "https://api.example.com"
        static let timeout: TimeInterval = 30
    }

    // MARK: UI
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let defaultPadding: CGFloat = 16
        static let minimumTapTarget: CGFloat = 44  // Apple HIG 推荐
    }

    // MARK: UserDefaults Keys
    enum StorageKey {
        static let authToken = "auth_token"
        static let isFirstLaunch = "is_first_launch"
    }
}
