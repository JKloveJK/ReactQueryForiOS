import Combine
import Foundation

/// 查询客户端，负责管理所有查询状态和缓存
@available(iOS 15.0, *)
public final class QueryClient: ObservableObject {

    // MARK: - Properties

    /// 查询缓存存储
    private let cache = NSCache<NSString, QueryCacheEntry>()

    /// 查询订阅管理
    private var querySubscriptions: [String: AnyCancellable] = [:]

    /// 后台队列用于处理查询
    private let queryQueue = DispatchQueue(label: "com.reactquery.ios.query", qos: .userInitiated)

    /// 默认配置
    public let defaultConfig: QueryConfig

    // MARK: - Initialization

    public init(config: QueryConfig = QueryConfig()) {
        self.defaultConfig = config
        setupCache()
    }

    // MARK: - Public Methods

    /// 执行查询
    /// - Parameters:
    ///   - key: 查询键
    ///   - queryFn: 查询函数
    ///   - config: 查询配置
    /// - Returns: 查询结果发布者
    public func query<T: Codable>(
        key: String,
        queryFn: @escaping () async throws -> T,
        config: QueryConfig? = nil
    ) -> AnyPublisher<QueryResult<T>, Never> {

        let finalConfig = config ?? defaultConfig

        // 检查缓存
        if let cachedEntry = getCachedEntry(for: key) as? QueryCacheEntry<T> {
            if !cachedEntry.isStale(config: finalConfig) {
                return Just(QueryResult.success(cachedEntry.data))
                    .eraseToAnyPublisher()
            }
        }

        // 创建新的查询
        return createQuery(key: key, queryFn: queryFn, config: finalConfig)
    }

    /// 预取查询
    /// - Parameters:
    ///   - key: 查询键
    ///   - queryFn: 查询函数
    ///   - config: 查询配置
    public func prefetch<T: Codable>(
        key: String,
        queryFn: @escaping () async throws -> T,
        config: QueryConfig? = nil
    ) {
        let finalConfig = config ?? defaultConfig

        Task {
            do {
                let data = try await queryFn()
                await MainActor.run {
                    self.setCacheEntry(QueryCacheEntry(data: data, timestamp: Date()), for: key)
                }
            } catch {
                print("[QueryClient] Prefetch failed for key: \(key), error: \(error)")
            }
        }
    }

    /// 使查询失效
    /// - Parameter key: 查询键
    public func invalidateQuery(key: String) {
        cache.removeObject(forKey: key as NSString)
        querySubscriptions[key]?.cancel()
        querySubscriptions.removeValue(forKey: key)
    }

    /// 使所有查询失效
    public func invalidateAllQueries() {
        cache.removeAllObjects()
        querySubscriptions.values.forEach { $0.cancel() }
        querySubscriptions.removeAll()
    }

    /// 获取缓存数据
    /// - Parameter key: 查询键
    /// - Returns: 缓存的数据
    public func getCachedData<T: Codable>(for key: String) -> T? {
        guard let entry = getCachedEntry(for: key) as? QueryCacheEntry<T> else {
            return nil
        }
        return entry.data
    }

    // MARK: - Private Methods

    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024  // 50MB
    }

    private func createQuery<T: Codable>(
        key: String,
        queryFn: @escaping () async throws -> T,
        config: QueryConfig
    ) -> AnyPublisher<QueryResult<T>, Never> {

        let subject = PassthroughSubject<QueryResult<T>, Never>()

        // 取消之前的订阅
        querySubscriptions[key]?.cancel()

        let subscription =
            subject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                if case .success(let data) = result {
                    self?.setCacheEntry(QueryCacheEntry(data: data, timestamp: Date()), for: key)
                }
            }

        querySubscriptions[key] = subscription

        // 执行查询
        Task {
            do {
                let data = try await queryFn()
                await MainActor.run {
                    subject.send(.success(data))
                    subject.send(completion: .finished)
                }
            } catch {
                await MainActor.run {
                    subject.send(.failure(error))
                    subject.send(completion: .finished)
                }
            }
        }

        return subject.eraseToAnyPublisher()
    }

    private func getCachedEntry(for key: String) -> Any? {
        return cache.object(forKey: key as NSString)
    }

    private func setCacheEntry(_ entry: Any, for key: String) {
        cache.setObject(entry as! NSObject, forKey: key as NSString)
    }
}

// MARK: - Query Cache Entry

@available(iOS 15.0, *)
private final class QueryCacheEntry<T: Codable>: NSObject {
    let data: T
    let timestamp: Date

    init(data: T, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
        super.init()
    }

    func isStale(config: QueryConfig) -> Bool {
        let age = Date().timeIntervalSince(timestamp)
        return age > config.staleTime
    }
}
