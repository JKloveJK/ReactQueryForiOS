import SwiftUI

@available(iOS 15.0, *)
@main
public struct DemoApp: App {

    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@available(iOS 15.0, *)
public struct ContentView: View {

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                Section("基础功能") {
                    NavigationLink("用户列表") {
                        UserListView()
                    }

                    NavigationLink("帖子列表") {
                        PostListView()
                    }

                    NavigationLink("创建帖子") {
                        CreatePostView()
                    }
                }

                Section("高级功能") {
                    NavigationLink("查询键示例") {
                        QueryKeyDemoView()
                    }

                    NavigationLink("突变示例") {
                        MutationDemoView()
                    }

                    NavigationLink("网络服务示例") {
                        NetworkServiceDemoView()
                    }
                }

                Section("配置示例") {
                    NavigationLink("缓存策略") {
                        CacheStrategyDemoView()
                    }

                    NavigationLink("错误处理") {
                        ErrorHandlingDemoView()
                    }
                }
            }
            .navigationTitle("React Query iOS 演示")
        }
    }
}

// MARK: - Demo Views

@available(iOS 15.0, *)
public struct PostListView: View {
    @StateObject private var queryClient = ExampleUsage.setupQueryClient()

    public var body: some View {
        QueryView(
            queryClient: queryClient,
            queryKey: "posts",
            queryFn: { try await ExampleUsage.fetchPosts() }
        ) { result in
            switch result {
            case .loading:
                DefaultLoadingView()
            case .success(let posts):
                List(posts) { post in
                    NavigationLink(destination: PostDetailView(postId: post.id)) {
                        VStack(alignment: .leading) {
                            Text(post.title)
                                .font(.headline)
                            Text(post.authorName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text("点赞: \(post.likes)")
                                Text("评论: \(post.comments)")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                    }
                }
            case .failure(let error):
                DefaultErrorView(error: error) {
                    // 重试逻辑
                }
            }
        }
        .navigationTitle("帖子列表")
    }
}

@available(iOS 15.0, *)
public struct QueryKeyDemoView: View {
    @StateObject private var queryClient = ExampleUsage.setupQueryClient()

    public var body: some View {
        VStack(spacing: 20) {
            Text("查询键示例")
                .font(.title)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {
                Text("基本查询键:")
                    .font(.headline)

                Text("• users")
                Text("• user:123")
                Text("• posts?page=1&limit=10")

                Text("使用构建器:")
                    .font(.headline)
                    .padding(.top)

                let userKey = QueryKeyBuilder.user("123")
                let postsKey = QueryKeyBuilder.posts(["page": "1", "limit": "10"])
                let searchKey = QueryKeyBuilder.search("react", ["type": "article"])

                Text("• \(userKey.stringValue)")
                Text("• \(postsKey.stringValue)")
                Text("• \(searchKey.stringValue)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .navigationTitle("查询键示例")
    }
}

@available(iOS 15.0, *)
public struct MutationDemoView: View {
    @StateObject private var queryClient = ExampleUsage.setupQueryClient()
    @StateObject private var mutationClient: MutationClient
    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    public init() {
        let queryClient = ExampleUsage.setupQueryClient()
        self._mutationClient = StateObject(wrappedValue: MutationClient(queryClient: queryClient))
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("突变操作示例")
                .font(.title)
                .fontWeight(.bold)

            Button("创建测试帖子") {
                createTestPost()
            }
            .buttonStyle(.borderedProminent)

            Button("删除测试帖子") {
                deleteTestPost()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

            Spacer()
        }
        .padding()
        .navigationTitle("突变示例")
        .alert("操作结果", isPresented: $isShowingAlert) {
            Button("确定") {}
        } message: {
            Text(alertMessage)
        }
    }

    private func createTestPost() {
        let request = CreatePostRequest(
            title: "测试帖子",
            content: "这是一个测试帖子的内容..."
        )

        mutationClient.mutateAndInvalidate(
            key: "create-test-post",
            mutationFn: { try await ExampleUsage.createPost(request: request) },
            invalidateQueries: ["posts"]
        )
        .sink { result in
            switch result {
            case .success:
                alertMessage = "帖子创建成功！"
                isShowingAlert = true
            case .failure(let error):
                alertMessage = "创建失败: \(error.localizedDescription)"
                isShowingAlert = true
            case .loading:
                break
            }
        }
        .store(in: &Set<AnyCancellable>())
    }

    private func deleteTestPost() {
        mutationClient.mutateAndInvalidate(
            key: "delete-test-post",
            mutationFn: { try await ExampleUsage.deletePost(id: "test-id") },
            invalidateQueries: ["posts", "post:test-id"]
        )
        .sink { result in
            switch result {
            case .success:
                alertMessage = "帖子删除成功！"
                isShowingAlert = true
            case .failure(let error):
                alertMessage = "删除失败: \(error.localizedDescription)"
                isShowingAlert = true
            case .loading:
                break
            }
        }
        .store(in: &Set<AnyCancellable>())
    }
}

@available(iOS 15.0, *)
public struct NetworkServiceDemoView: View {
    @StateObject private var networkService = ExampleUsage.setupNetworkService()
    @State private var responseText = ""

    public var body: some View {
        VStack(spacing: 20) {
            Text("网络服务示例")
                .font(.title)
                .fontWeight(.bold)

            Button("测试网络请求") {
                testNetworkRequest()
            }
            .buttonStyle(.borderedProminent)

            if !responseText.isEmpty {
                Text(responseText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("网络服务示例")
    }

    private func testNetworkRequest() {
        let endpoint = APIEndpoint(
            path: "/test",
            method: .get,
            queryItems: ["param": "value"]
        )

        // 这里只是演示，实际需要真实的 API
        responseText = "网络请求已发送到: \(endpoint.path)"
    }
}

@available(iOS 15.0, *)
public struct CacheStrategyDemoView: View {
    @StateObject private var fastQueryClient = QueryClient(config: QueryConfig.fastStale)
    @StateObject private var slowQueryClient = QueryClient(config: QueryConfig.slowStale)
    @StateObject private var infiniteQueryClient = QueryClient(config: QueryConfig.infiniteCache)

    public var body: some View {
        VStack(spacing: 20) {
            Text("缓存策略示例")
                .font(.title)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {
                Text("快速过期 (30秒):")
                    .font(.headline)
                Text("适用于实时数据，如股票价格、在线状态等")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 10) {
                Text("慢速过期 (30分钟):")
                    .font(.headline)
                Text("适用于静态数据，如用户信息、配置等")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 10) {
                Text("无限缓存:")
                    .font(.headline)
                Text("适用于很少变化的数据，如应用配置、常量等")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .navigationTitle("缓存策略")
    }
}

@available(iOS 15.0, *)
public struct ErrorHandlingDemoView: View {
    @StateObject private var queryClient = ExampleUsage.setupQueryClient()

    public var body: some View {
        VStack(spacing: 20) {
            Text("错误处理示例")
                .font(.title)
                .fontWeight(.bold)

            QueryView(
                queryClient: queryClient,
                queryKey: "error-demo",
                queryFn: { throw NetworkError.noConnection }
            ) { result in
                switch result {
                case .loading:
                    DefaultLoadingView()
                case .success:
                    Text("成功")
                case .failure(let error):
                    DefaultErrorView(error: error) {
                        // 重试逻辑
                        queryClient.invalidateQuery(key: "error-demo")
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("错误处理")
    }
}
