import Combine
import Foundation

/// 网络服务协议
@available(iOS 15.0, *)
public protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError>
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
}

/// 网络服务实现
@available(iOS 15.0, *)
public final class NetworkService: NetworkServiceProtocol {

    // MARK: - Properties

    private let session: URLSession
    private let baseURL: URL
    private let headers: [String: String]
    private let timeoutInterval: TimeInterval

    // MARK: - Initialization

    public init(
        baseURL: URL,
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 15.0,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.headers = headers
        self.timeoutInterval = timeoutInterval
        self.session = session
    }

    // MARK: - Public Methods

    public func request<T: Codable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = buildURL(for: endpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = timeoutInterval

        // 设置请求头
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        if let body = endpoint.body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                return Fail(error: NetworkError.invalidBody)
                    .eraseToAnyPublisher()
            }
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                guard 200...299 ~= httpResponse.statusCode else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                }

                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return NetworkError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }

    public func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = buildURL(for: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = timeoutInterval

        // 设置请求头
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 设置请求体
        if let body = endpoint.body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.invalidBody
            }
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    // MARK: - Private Methods

    private func buildURL(for endpoint: APIEndpoint) -> URL? {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)

        if let queryItems = endpoint.queryItems {
            components?.queryItems = queryItems.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }

        return components?.url
    }
}

// MARK: - API Endpoint

@available(iOS 15.0, *)
public struct APIEndpoint {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let body: [String: Any]?
    public let queryItems: [String: String]?

    public init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: [String: Any]? = nil,
        queryItems: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.queryItems = queryItems
    }
}

// MARK: - HTTP Method

@available(iOS 15.0, *)
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Network Error

@available(iOS 15.0, *)
public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidBody
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
    case noConnection

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidBody:
            return "无效的请求体"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let statusCode, _):
            return "HTTP 错误: \(statusCode)"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        case .noConnection:
            return "网络连接失败"
        }
    }
}
