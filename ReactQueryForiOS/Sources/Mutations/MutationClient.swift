import Combine
import Foundation

/// 突变客户端，用于处理数据修改操作
@available(iOS 15.0, *)
public final class MutationClient: ObservableObject {

    // MARK: - Properties

    private let queryClient: QueryClient
    private var mutationSubscriptions: [String: AnyCancellable] = [:]

    // MARK: - Initialization

    public init(queryClient: QueryClient) {
        self.queryClient = queryClient
    }

    // MARK: - Public Methods

    /// 执行突变操作
    /// - Parameters:
    ///   - key: 突变键
    ///   - mutationFn: 突变函数
    ///   - onSuccess: 成功回调
    ///   - onError: 错误回调
    /// - Returns: 突变结果发布者
    public func mutate<T: Codable, R: Codable>(
        key: String,
        mutationFn: @escaping (T) async throws -> R,
        onSuccess: ((R) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> AnyPublisher<MutationResult<R>, Never> {

        let subject = PassthroughSubject<MutationResult<R>, Never>()

        // 取消之前的订阅
        mutationSubscriptions[key]?.cancel()

        let subscription =
            subject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let data):
                    onSuccess?(data)
                case .failure(let error):
                    onError?(error)
                case .loading:
                    break
                }
            }

        mutationSubscriptions[key] = subscription

        return subject.eraseToAnyPublisher()
    }

    /// 执行突变操作（无参数）
    /// - Parameters:
    ///   - key: 突变键
    ///   - mutationFn: 突变函数
    ///   - onSuccess: 成功回调
    ///   - onError: 错误回调
    /// - Returns: 突变结果发布者
    public func mutate<R: Codable>(
        key: String,
        mutationFn: @escaping () async throws -> R,
        onSuccess: ((R) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> AnyPublisher<MutationResult<R>, Never> {

        let subject = PassthroughSubject<MutationResult<R>, Never>()

        // 取消之前的订阅
        mutationSubscriptions[key]?.cancel()

        let subscription =
            subject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let data):
                    onSuccess?(data)
                case .failure(let error):
                    onError?(error)
                case .loading:
                    break
                }
            }

        mutationSubscriptions[key] = subscription

        // 执行突变
        Task {
            do {
                let result = try await mutationFn()
                await MainActor.run {
                    subject.send(.success(result))
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

    /// 执行突变并自动使相关查询失效
    /// - Parameters:
    ///   - key: 突变键
    ///   - mutationFn: 突变函数
    ///   - invalidateQueries: 需要失效的查询键模式
    ///   - onSuccess: 成功回调
    ///   - onError: 错误回调
    /// - Returns: 突变结果发布者
    public func mutateAndInvalidate<R: Codable>(
        key: String,
        mutationFn: @escaping () async throws -> R,
        invalidateQueries: [String] = [],
        onSuccess: ((R) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> AnyPublisher<MutationResult<R>, Never> {

        let subject = PassthroughSubject<MutationResult<R>, Never>()

        // 取消之前的订阅
        mutationSubscriptions[key]?.cancel()

        let subscription =
            subject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let data):
                    // 使相关查询失效
                    invalidateQueries.forEach { queryKey in
                        self?.queryClient.invalidateQuery(key: queryKey)
                    }
                    onSuccess?(data)
                case .failure(let error):
                    onError?(error)
                case .loading:
                    break
                }
            }

        mutationSubscriptions[key] = subscription

        // 执行突变
        Task {
            do {
                let result = try await mutationFn()
                await MainActor.run {
                    subject.send(.success(result))
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

    /// 取消突变操作
    /// - Parameter key: 突变键
    public func cancelMutation(key: String) {
        mutationSubscriptions[key]?.cancel()
        mutationSubscriptions.removeValue(forKey: key)
    }

    /// 取消所有突变操作
    public func cancelAllMutations() {
        mutationSubscriptions.values.forEach { $0.cancel() }
        mutationSubscriptions.removeAll()
    }
}

// MARK: - Mutation Result

@available(iOS 15.0, *)
public enum MutationResult<T> {
    case success(T)
    case failure(Error)
    case loading
}

// MARK: - Mutation Result Extensions

@available(iOS 15.0, *)
extension MutationResult {

    /// 获取成功的数据
    public var data: T? {
        switch self {
        case .success(let data):
            return data
        case .failure, .loading:
            return nil
        }
    }

    /// 获取错误信息
    public var error: Error? {
        switch self {
        case .failure(let error):
            return error
        case .success, .loading:
            return nil
        }
    }

    /// 是否正在加载
    public var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .success, .failure:
            return false
        }
    }

    /// 是否成功
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure, .loading:
            return false
        }
    }

    /// 是否失败
    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        case .success, .loading:
            return false
        }
    }
}
