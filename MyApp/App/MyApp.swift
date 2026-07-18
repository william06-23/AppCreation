import SwiftUI

// MARK: - App 入口
// 使用 @main 标记，这是整个 App 的启动点
// SwiftUI 生命周期：无需 AppDelegate / SceneDelegate（iOS 14+）

@main
struct MyApp: App {

    // 集中管理所有依赖（网络、存储、配置等），用 @StateObject 保证生命周期与 App 一致
    @StateObject private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appEnvironment)
        }
    }
}
