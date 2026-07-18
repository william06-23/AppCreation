import Foundation

// MARK: - String 扩展
extension String {

    /// 是否是有效邮箱
    var isValidEmail: Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: regex, options: .regularExpression) != nil
    }

    /// 去除首尾空白和换行
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
