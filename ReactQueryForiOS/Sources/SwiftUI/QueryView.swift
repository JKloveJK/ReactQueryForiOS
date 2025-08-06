import Combine
import SwiftUI

/// SwiftUI 查询视图，提供便捷的查询组件
@available(iOS 15.0, *)
public struct QueryView<T: Codable, Content: View>: View {

    // MARK: - Properties

    @StateObject private var viewModel: QueryViewModel<T>
    private let content: (QueryResult<T>) -> Content

    // MARK: - Initialization

    public init(
        queryClient: QueryClient,
        queryKey: String,
        queryFn: @escaping () async throws -> T,
        config: QueryConfig? = nil,
        @ViewBuilder content: @escaping (QueryResult<T>) -> Content
    ) {
        self._viewModel = StateObject(
            wrappedValue: QueryViewModel(
                queryClient: queryClient,
                queryKey: queryKey,
                queryFn: queryFn,
                config: config
            ))
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        content(viewModel.result)
            .onAppear {
                // 视图出现时自动开始查询
            }
            .onDisappear {
                // 视图消失时可以选择是否取消查询
            }
    }
}

// MARK: - Convenience Initializers

@available(iOS 15.0, *)
extension QueryView {

    /// 使用默认配置的便捷初始化器
    public init(
        queryClient: QueryClient,
        queryKey: String,
        queryFn: @escaping () async throws -> T,
        @ViewBuilder content: @escaping (QueryResult<T>) -> Content
    ) {
        self.init(
            queryClient: queryClient,
            queryKey: queryKey,
            queryFn: queryFn,
            config: nil,
            content: content
        )
    }
}

// MARK: - Query View Modifiers

@available(iOS 15.0, *)
public struct QueryViewModifier<T: Codable>: ViewModifier {

    private let queryClient: QueryClient
    private let queryKey: String
    private let queryFn: () async throws -> T
    private let config: QueryConfig?

    public init(
        queryClient: QueryClient,
        queryKey: String,
        queryFn: @escaping () async throws -> T,
        config: QueryConfig? = nil
    ) {
        self.queryClient = queryClient
        self.queryKey = queryKey
        self.queryFn = queryFn
        self.config = config
    }

    public func body(content: Content) -> some View {
        QueryView(
            queryClient: queryClient,
            queryKey: queryKey,
            queryFn: queryFn,
            config: config
        ) { result in
            content
        }
    }
}

// MARK: - View Extensions

@available(iOS 15.0, *)
extension View {

    /// 为视图添加查询功能
    public func query<T: Codable>(
        queryClient: QueryClient,
        queryKey: String,
        queryFn: @escaping () async throws -> T,
        config: QueryConfig? = nil
    ) -> some View {
        modifier(
            QueryViewModifier(
                queryClient: queryClient,
                queryKey: queryKey,
                queryFn: queryFn,
                config: config
            ))
    }
}

// MARK: - Query Result View Builders

@available(iOS 15.0, *)
public struct QueryResultView<T: Codable, Loading: View, Success: View, Error: View>: View {

    private let result: QueryResult<T>
    private let loading: () -> Loading
    private let success: (T) -> Success
    private let error: (Error) -> Error

    public init(
        result: QueryResult<T>,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder success: @escaping (T) -> Success,
        @ViewBuilder error: @escaping (Error) -> Error
    ) {
        self.result = result
        self.loading = loading
        self.success = success
        self.error = error
    }

    public var body: some View {
        switch result {
        case .loading:
            loading()
        case .success(let data):
            success(data)
        case .failure(let error):
            error(error)
        }
    }
}

// MARK: - Default Query Result Views

@available(iOS 15.0, *)
public struct DefaultLoadingView: View {
    public var body: some View {
        VStack {
            ProgressView()
            Text("加载中...")
                .foregroundColor(.secondary)
        }
    }
}

@available(iOS 15.0, *)
public struct DefaultErrorView: View {
    private let error: Error
    private let retryAction: (() -> Void)?

    public init(error: Error, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text("加载失败")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let retryAction = retryAction {
                Button("重试", action: retryAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
