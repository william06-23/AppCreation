import Foundation

// MARK: - 日志工具
// 统一日志输出，可按级别过滤，方便调试

struct Logger {

    let subsystem: String
    let category: String

    enum Level: String {
        case debug = "🔍"
        case info  = "ℹ️"
        case warn  = "⚠️"
        case error = "❌"
    }

    func log(_ message: String, level: Level = .debug) {
        #if DEBUG
        print("[\(level.rawValue)][\(category)] \(message)")
        #endif
    }
}
