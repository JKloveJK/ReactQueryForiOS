import Combine
import SwiftUI

// MARK: - Example Usage

@available(iOS 15.0, *)
public struct ExampleUsage {

    // MARK: - Setup

    /// 创建查询客户端
    public static func setupQueryClient() -> QueryClient {
        let config = QueryConfig(
            staleTime: 5 * 60,  // 5分钟
            cacheTime: 10 * 60,  // 10分钟
            retryCount: 3,
            retryDelay: 1.0
        )

        return QueryClient(config: config)
    }

    /// 创建网络服务
    public static func setupNetworkService() -> NetworkService {
        let baseURL = URL(string: "https://api.example.com")!
        let headers = [
            "Authorization": "Bearer your-token-here",
            "Content-Type": "application/json",
        ]

        return NetworkService(
            baseURL: baseURL,
            headers: headers,
            timeoutInterval: 15.0
        )
    }

    // MARK: - API Functions

    /// 获取用户列表
    public static func fetchUsers(filters: UserFilters = UserFilters()) async throws -> [User] {
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 1_000_000_000)  // 1秒延迟

        return [
            User(id: "1", name: "张三", email: "zhangsan@example.com"),
            User(id: "2", name: "李四", email: "lisi@example.com"),
            User(id: "3", name: "王五", email: "wangwu@example.com"),
        ]
    }

    /// 获取单个用户
    public static func fetchUser(id: String) async throws -> User {
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 500_000_000)  // 0.5秒延迟

        return User(
            id: id,
            name: "用户\(id)",
            email: "user\(id)@example.com",
            avatar: "https://example.com/avatar/\(id).jpg"
        )
    }

    /// 获取帖子列表
    public static func fetchPosts(filters: PostFilters = PostFilters()) async throws -> [Post] {
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5秒延迟

        return [
            Post(
                id: "1",
                title: "第一篇帖子",
                content: "这是第一篇帖子的内容...",
                authorId: "1",
                authorName: "张三",
                likes: 10,
                comments: 5
            ),
            Post(
                id: "2",
                title: "第二篇帖子",
                content: "这是第二篇帖子的内容...",
                authorId: "2",
                authorName: "李四",
                likes: 15,
                comments: 8
            ),
        ]
    }

    /// 获取单个帖子
    public static func fetchPost(id: String) async throws -> Post {
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 800_000_000)  // 0.8秒延迟

        return Post(
            id: id,
            title: "帖子\(id)",
            content: "这是帖子\(id)的详细内容...",
            authorId: "1",
            authorName: "张三",
            likes: 20,
            comments: 12
        )
    }

    /// 创建帖子
    public static func createPost(request: CreatePostRequest) async throws -> Post {
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 2_000_000_000)  // 2秒延迟

        return Post(
            id: UUID().uuidString,
            title: request.title,
            content: request.content,
            authorId: "current-user-id",
            authorName: "当前用户"
        )
    }

    /// 更新帖子
    public static func updatePost(id: String, request: UpdatePostRequest) async throws -> Post {
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5秒延迟

        return Post(
            id: id,
            title: request.title ?? "更新后的标题",
            content: request.content ?? "更新后的内容",
            authorId: "current-user-id",
            authorName: "当前用户"
        )
    }

    /// 删除帖子
    public static func deletePost(id: String) async throws -> Bool {
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 1_000_000_000)  // 1秒延迟

        return true
    }
}

// MARK: - Example SwiftUI Views

@available(iOS 15.0, *)
public struct UserListView: View {
    @StateObject private var queryClient = ExampleUsage.setupQueryClient()

    public var body: some View {
        NavigationView {
            QueryView(
                queryClient: queryClient,
                queryKey: "users",
                queryFn: { try await ExampleUsage.fetchUsers() }
            ) { result in
                switch result {
                case .loading:
                    DefaultLoadingView()
                case .success(let users):
                    List(users) { user in
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                case .failure(let error):
                    DefaultErrorView(error: error) {
                        // 重试逻辑
                    }
                }
            }
            .navigationTitle("用户列表")
        }
    }
}

@available(iOS 15.0, *)
public struct PostDetailView: View {
    let postId: String
    @StateObject private var queryClient = ExampleUsage.setupQueryClient()
    @StateObject private var mutationClient: MutationClient

    public init(postId: String) {
        self.postId = postId
        let queryClient = ExampleUsage.setupQueryClient()
        self._mutationClient = StateObject(wrappedValue: MutationClient(queryClient: queryClient))
    }

    public var body: some View {
        VStack {
            QueryView(
                queryClient: queryClient,
                queryKey: "post:\(postId)",
                queryFn: { try await ExampleUsage.fetchPost(id: postId) }
            ) { result in
                switch result {
                case .loading:
                    DefaultLoadingView()
                case .success(let post):
                    VStack(alignment: .leading, spacing: 16) {
                        Text(post.title)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(post.content)
                            .font(.body)

                        HStack {
                            Text("作者: \(post.authorName)")
                                .font(.caption)
                            Spacer()
                            Text("点赞: \(post.likes)")
                                .font(.caption)
                            Text("评论: \(post.comments)")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)

                        Spacer()
                    }
                    .padding()
                case .failure(let error):
                    DefaultErrorView(error: error) {
                        // 重试逻辑
                    }
                }
            }

            // 删除按钮
            Button("删除帖子") {
                deletePost()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .navigationTitle("帖子详情")
    }

    private func deletePost() {
        mutationClient.mutateAndInvalidate(
            key: "delete-post",
            mutationFn: { try await ExampleUsage.deletePost(id: postId) },
            invalidateQueries: ["post:\(postId)", "posts"]
        )
        .sink { result in
            switch result {
            case .success:
                print("帖子删除成功")
            case .failure(let error):
                print("删除失败: \(error)")
            case .loading:
                break
            }
        }
    }
}

@available(iOS 15.0, *)
public struct CreatePostView: View {
    @StateObject private var queryClient = ExampleUsage.setupQueryClient()
    @StateObject private var mutationClient: MutationClient
    @State private var title = ""
    @State private var content = ""
    @Environment(\.dismiss) private var dismiss

    public init() {
        let queryClient = ExampleUsage.setupQueryClient()
        self._mutationClient = StateObject(wrappedValue: MutationClient(queryClient: queryClient))
    }

    public var body: some View {
        NavigationView {
            Form {
                Section("帖子信息") {
                    TextField("标题", text: $title)
                    TextField("内容", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }

                Section {
                    Button("创建帖子") {
                        createPost()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .navigationTitle("创建帖子")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func createPost() {
        let request = CreatePostRequest(title: title, content: content)

        mutationClient.mutateAndInvalidate(
            key: "create-post",
            mutationFn: { try await ExampleUsage.createPost(request: request) },
            invalidateQueries: ["posts"]
        )
        .sink { result in
            switch result {
            case .success:
                print("帖子创建成功")
                dismiss()
            case .failure(let error):
                print("创建失败: \(error)")
            case .loading:
                break
            }
        }
    }
}

// MARK: - Example with QueryKey

@available(iOS 15.0, *)
public struct AdvancedExampleView: View {
    @StateObject private var queryClient = ExampleUsage.setupQueryClient()

    public var body: some View {
        NavigationView {
            List {
                Section("用户相关") {
                    NavigationLink("用户列表") {
                        UserListView()
                    }

                    NavigationLink("用户详情") {
                        let userKey = QueryKeyBuilder.user("1")
                        QueryView(
                            queryClient: queryClient,
                            queryKey: userKey.stringValue,
                            queryFn: { try await ExampleUsage.fetchUser(id: "1") }
                        ) { result in
                            switch result {
                            case .loading:
                                DefaultLoadingView()
                            case .success(let user):
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(user.name)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            case .failure(let error):
                                DefaultErrorView(error: error)
                            }
                        }
                        .navigationTitle("用户详情")
                    }
                }

                Section("帖子相关") {
                    NavigationLink("帖子列表") {
                        let postsKey = QueryKeyBuilder.posts()
                        QueryView(
                            queryClient: queryClient,
                            queryKey: postsKey.stringValue,
                            queryFn: { try await ExampleUsage.fetchPosts() }
                        ) { result in
                            switch result {
                            case .loading:
                                DefaultLoadingView()
                            case .success(let posts):
                                List(posts) { post in
                                    VStack(alignment: .leading) {
                                        Text(post.title)
                                            .font(.headline)
                                        Text(post.authorName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            case .failure(let error):
                                DefaultErrorView(error: error)
                            }
                        }
                        .navigationTitle("帖子列表")
                    }

                    NavigationLink("创建帖子") {
                        CreatePostView()
                    }
                }
            }
            .navigationTitle("React Query 示例")
        }
    }
}
