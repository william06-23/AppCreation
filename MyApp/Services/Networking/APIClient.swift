import Foundation

// MARK: - 网络请求层
// 封装 URLSession，统一处理请求、响应、错误

final class APIClient {

    private let session: URLSession
    private let logger: Logger
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601      // 自动解析 ISO 8601 日期
        d.keyDecodingStrategy = .convertFromSnakeCase  // 自动 snake_case → camelCase
        return d
    }()

    init(logger: Logger, session: URLSession = .shared) {
        self.logger = logger
        self.session = session
    }

    /// 泛型请求方法：传入 Endpoint，返回解码后的模型
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        logger.log("→ \(endpoint.method) \(url.absoluteString)")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        logger.log("← \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.log("❌ Decode error: \(error)")
            throw APIError.decodingFailed(error)
        }
    }
}

// MARK: - 统一错误类型

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "无效的 URL"
        case .invalidResponse:    return "无效的服务器响应"
        case .httpError(let code): return "HTTP 错误: \(code)"
        case .decodingFailed:     return "数据解析失败"
        }
    }
}
