import Foundation

// MARK: - 本地持久化存储
// 对 UserDefaults 的轻量封装，避免散落各处

final class UserDefaultsManager {

    private let defaults = UserDefaults.standard

    // 示例：存储用户登录 token
    var authToken: String? {
        get { defaults.string(forKey: .authToken) }
        set { defaults.set(newValue, forKey: .authToken) }
    }

    var isFirstLaunch: Bool {
        get { defaults.bool(forKey: .isFirstLaunch) }
        set { defaults.set(newValue, forKey: .isFirstLaunch) }
    }

    /// 清除所有持久化数据（登出时调用）
    func clearAll() {
        defaults.removeObject(forKey: .authToken)
        defaults.removeObject(forKey: .isFirstLaunch)
    }
}

// MARK: - Key 常量（避免硬编码字符串）
private extension String {
    static let authToken = "auth_token"
    static let isFirstLaunch = "is_first_launch"
}
