import Foundation

// MARK: - API 端点定义
// 集中管理所有 API 路径、方法、参数，方便维护

enum Endpoint {
    case getUsers
    case getUser(id: Int)
    case createUser(name: String, email: String)
}

extension Endpoint {

    var path: String {
        switch self {
        case .getUsers, .createUser:
            return "/users"
        case .getUser(let id):
            return "/users/\(id)"
        }
    }

    var method: String {
        switch self {
        case .getUsers, .getUser:
            return "GET"
        case .createUser:
            return "POST"
        }
    }

    var body: Data? {
        switch self {
        case .createUser(let name, let email):
            let dict = ["name": name, "email": email]
            return try? JSONSerialization.data(withJSONObject: dict)
        default:
            return nil
        }
    }

    var baseURL: String { "https://api.example.com" }
}
