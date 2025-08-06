import Combine
import Foundation
import SwiftUI

/// 查询视图模型，用于在 SwiftUI 中管理查询状态
@available(iOS 15.0, *)
@MainActor
public final class QueryViewModel<T: Codable>: ObservableObject {

    // MARK: - Published Properties

    /// 查询结果
    @Published public private(set) var result: QueryResult<T> = .loading

    /// 是否正在刷新
    @Published public private(set) var isRefetching = false

    /// 查询键
    public let queryKey: String

    // MARK: - Private Properties

    private let queryClient: QueryClient
    private let queryFn: () async throws -> T
    private let config: QueryConfig
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        queryClient: QueryClient,
        queryKey: String,
        queryFn: @escaping () async throws -> T,
        config: QueryConfig? = nil
    ) {
        self.queryClient = queryClient
        self.queryKey = queryKey
        self.queryFn = queryFn
        self.config = config ?? queryClient.defaultConfig

        setupQuery()
    }

    // MARK: - Public Methods

    /// 手动刷新查询
    public func refetch() {
        isRefetching = true

        queryClient.query(key: queryKey, queryFn: queryFn, config: config)
            .sink { [weak self] result in
                self?.result = result
                self?.isRefetching = false
            }
            .store(in: &cancellables)
    }

    /// 使查询失效
    public func invalidate() {
        queryClient.invalidateQuery(key: queryKey)
        result = .loading
    }

    // MARK: - Private Methods

    private func setupQuery() {
        queryClient.query(key: queryKey, queryFn: queryFn, config: config)
            .sink { [weak self] result in
                self?.result = result
            }
            .store(in: &cancellables)
    }
}

// MARK: - Convenience Extensions

@available(iOS 15.0, *)
extension QueryViewModel {

    /// 数据（如果成功）
    public var data: T? {
        result.data
    }

    /// 错误（如果失败）
    public var error: Error? {
        result.error
    }

    /// 是否正在加载
    public var isLoading: Bool {
        result.isLoading
    }

    /// 是否成功
    public var isSuccess: Bool {
        result.isSuccess
    }

    /// 是否失败
    public var isFailure: Bool {
        result.isFailure
    }
}
