import Foundation

// MARK: - 数据模型示例
// 纯数据容器，不包含业务逻辑
// 遵循 Codable 可快速序列化到 JSON / Plist

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case avatarURL = "avatar_url"   // 映射后端下划线命名 → Swift 驼峰命名
    }
}

// MARK: - 示例：嵌套模型
struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
    let author: User          // 嵌套 User，Codable 自动处理
    let createdAt: Date       // JSONDecoder.dateDecodingStrategy 可配置解析策略
}
