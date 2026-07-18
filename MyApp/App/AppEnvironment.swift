import SwiftUI

// MARK: - 全局依赖环境
// 聚合所有 Service，通过 @Published 暴露状态，下游视图用 @EnvironmentObject 取用

final class AppEnvironment: ObservableObject {

    @Published var isLoggedIn: Bool = false

    let apiClient: APIClient
    let userDefaults: UserDefaultsManager
    let logger: Logger

    init() {
        self.logger = Logger(subsystem: "com.myapp", category: "general")
        self.apiClient = APIClient(logger: logger)
        self.userDefaults = UserDefaultsManager()
    }
}
