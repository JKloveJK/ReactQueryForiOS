import Combine
import Foundation
import SwiftUI

/// 突变视图模型，用于在 SwiftUI 中管理突变状态
@available(iOS 15.0, *)
@MainActor
public final class MutationViewModel<T: Codable>: ObservableObject {

    // MARK: - Published Properties

    /// 突变结果
    @Published public private(set) var result: MutationResult<T> = .loading

    /// 是否正在执行突变
    @Published public private(set) var isMutating = false

    /// 突变键
    public let mutationKey: String

    // MARK: - Private Properties

    private let mutationClient: MutationClient
    private let mutationFn: () async throws -> T
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        mutationClient: MutationClient,
        mutationKey: String,
        mutationFn: @escaping () async throws -> T
    ) {
        self.mutationClient = mutationClient
        self.mutationKey = mutationKey
        self.mutationFn = mutationFn
    }

    // MARK: - Public Methods

    /// 执行突变
    public func mutate() {
        guard !isMutating else { return }

        isMutating = true
        result = .loading

        mutationClient.mutate(
            key: mutationKey,
            mutationFn: mutationFn,
            onSuccess: { [weak self] data in
                self?.result = .success(data)
                self?.isMutating = false
            },
            onError: { [weak self] error in
                self?.result = .failure(error)
                self?.isMutating = false
            }
        )
        .sink { [weak self] result in
            self?.result = result
        }
        .store(in: &cancellables)
    }

    /// 执行突变并失效相关查询
    /// - Parameter invalidateQueries: 需要失效的查询键
    public func mutateAndInvalidate(invalidateQueries: [String] = []) {
        guard !isMutating else { return }

        isMutating = true
        result = .loading

        mutationClient.mutateAndInvalidate(
            key: mutationKey,
            mutationFn: mutationFn,
            invalidateQueries: invalidateQueries,
            onSuccess: { [weak self] data in
                self?.result = .success(data)
                self?.isMutating = false
            },
            onError: { [weak self] error in
                self?.result = .failure(error)
                self?.isMutating = false
            }
        )
        .sink { [weak self] result in
            self?.result = result
        }
        .store(in: &cancellables)
    }

    /// 重置突变状态
    public func reset() {
        result = .loading
        isMutating = false
    }

    // MARK: - Convenience Properties

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

// MARK: - Mutation View Model with Parameters

@available(iOS 15.0, *)
@MainActor
public final class ParameterizedMutationViewModel<Input: Codable, Output: Codable>: ObservableObject
{

    // MARK: - Published Properties

    /// 突变结果
    @Published public private(set) var result: MutationResult<Output> = .loading

    /// 是否正在执行突变
    @Published public private(set) var isMutating = false

    /// 突变键
    public let mutationKey: String

    // MARK: - Private Properties

    private let mutationClient: MutationClient
    private let mutationFn: (Input) async throws -> Output
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        mutationClient: MutationClient,
        mutationKey: String,
        mutationFn: @escaping (Input) async throws -> Output
    ) {
        self.mutationClient = mutationClient
        self.mutationKey = mutationKey
        self.mutationFn = mutationFn
    }

    // MARK: - Public Methods

    /// 执行突变
    /// - Parameter input: 输入参数
    public func mutate(input: Input) {
        guard !isMutating else { return }

        isMutating = true
        result = .loading

        mutationClient.mutate(
            key: mutationKey,
            mutationFn: { [weak self] in
                guard let self = self else { throw NSError(domain: "MutationViewModel", code: -1) }
                return try await self.mutationFn(input)
            },
            onSuccess: { [weak self] data in
                self?.result = .success(data)
                self?.isMutating = false
            },
            onError: { [weak self] error in
                self?.result = .failure(error)
                self?.isMutating = false
            }
        )
        .sink { [weak self] result in
            self?.result = result
        }
        .store(in: &cancellables)
    }

    /// 执行突变并失效相关查询
    /// - Parameters:
    ///   - input: 输入参数
    ///   - invalidateQueries: 需要失效的查询键
    public func mutateAndInvalidate(input: Input, invalidateQueries: [String] = []) {
        guard !isMutating else { return }

        isMutating = true
        result = .loading

        mutationClient.mutateAndInvalidate(
            key: mutationKey,
            mutationFn: { [weak self] in
                guard let self = self else { throw NSError(domain: "MutationViewModel", code: -1) }
                return try await self.mutationFn(input)
            },
            invalidateQueries: invalidateQueries,
            onSuccess: { [weak self] data in
                self?.result = .success(data)
                self?.isMutating = false
            },
            onError: { [weak self] error in
                self?.result = .failure(error)
                self?.isMutating = false
            }
        )
        .sink { [weak self] result in
            self?.result = result
        }
        .store(in: &cancellables)
    }

    /// 重置突变状态
    public func reset() {
        result = .loading
        isMutating = false
    }

    // MARK: - Convenience Properties

    /// 数据（如果成功）
    public var data: Output? {
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
