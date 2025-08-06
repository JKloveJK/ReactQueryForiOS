# ReactQueryForiOS

一个类似 React Query 的 iOS Swift 库，提供强大的数据获取、缓存和状态管理功能。

## 功能特性

- ✅ **智能缓存**: 自动缓存查询结果，支持过期时间和缓存策略
- ✅ **自动重试**: 网络请求失败时自动重试，可配置重试次数和延迟
- ✅ **后台刷新**: 支持在应用进入后台时刷新数据
- ✅ **查询失效**: 支持手动和自动使查询失效
- ✅ **突变操作**: 支持数据修改操作，自动失效相关查询
- ✅ **SwiftUI 集成**: 提供便捷的 SwiftUI 组件和视图模型
- ✅ **UIKit 支持**: 完整的 UIKit 集成和示例
- ✅ **Combine 支持**: 基于 Combine 框架，支持响应式编程
- ✅ **类型安全**: 完全类型安全，编译时检查
- ✅ **iOS 15.0+**: 支持 iOS 15.0 及以上版本

## 安装

### CocoaPods

在您的 `Podfile` 中添加：

```ruby
pod 'ReactQueryForiOS', '~> 1.0.0'
```

然后运行：

```bash
pod install
```

### Swift Package Manager

在 Xcode 项目中添加依赖：

1. 选择您的项目
2. 点击 "Package Dependencies" 标签
3. 点击 "+" 按钮
4. 输入仓库 URL: `https://github.com/JKloveJK/ReactQueryForiOS.git`
5. 选择版本并添加

## 快速开始

### 1. 创建查询客户端

```swift
import ReactQueryForiOS

// 创建查询客户端
let queryClient = QueryClient(config: QueryConfig(
    staleTime: 5 * 60, // 5分钟过期
    cacheTime: 10 * 60, // 10分钟缓存
    retryCount: 3,
    retryDelay: 1.0
))
```

### 2. 定义数据模型

```swift
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
}
```

### 3. 创建查询函数

```swift
func fetchUsers() async throws -> [User] {
    // 您的网络请求逻辑
    let url = URL(string: "https://api.example.com/users")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([User].self, from: data)
}
```

### 4. 在 SwiftUI 中使用

```swift
struct UserListView: View {
    @StateObject private var queryClient = QueryClient()
    
    var body: some View {
        QueryView(
            queryClient: queryClient,
            queryKey: "users",
            queryFn: { try await fetchUsers() }
        ) { result in
            switch result {
            case .loading:
                ProgressView()
            case .success(let users):
                List(users) { user in
                    Text(user.name)
                }
            case .failure(let error):
                Text("错误: \(error.localizedDescription)")
            }
        }
    }
}
```

### 5. 在 UIKit 中使用

```swift
class UserListViewController: UIViewController {
    private let queryClient = QueryClient()
    private var cancellables = Set<AnyCancellable>()
    private var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuery()
    }
    
    private func setupQuery() {
        queryClient.query(key: "users", queryFn: { try await fetchUsers() })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .loading:
                    self?.showLoading()
                case .success(let users):
                    self?.users = users
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
}
```

## 核心组件

### QueryClient

查询客户端，负责管理所有查询状态和缓存。

```swift
let queryClient = QueryClient()

// 执行查询
queryClient.query(key: "users", queryFn: fetchUsers)
    .sink { result in
        // 处理结果
    }
    .store(in: &cancellables)

// 预取查询
queryClient.prefetch(key: "users", queryFn: fetchUsers)

// 使查询失效
queryClient.invalidateQuery(key: "users")
```

### QueryConfig

查询配置，定义缓存策略和行为。

```swift
let config = QueryConfig(
    staleTime: 5 * 60,        // 数据过期时间
    cacheTime: 10 * 60,       // 缓存时间
    retryCount: 3,            // 重试次数
    retryDelay: 1.0,          // 重试延迟
    enableBackgroundRefresh: false,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true
)

// 预设配置
let fastConfig = QueryConfig.fastStale      // 快速过期
let slowConfig = QueryConfig.slowStale      // 慢速过期
let infiniteConfig = QueryConfig.infiniteCache // 无限缓存
```

### QueryView

SwiftUI 查询视图，提供便捷的查询组件。

```swift
QueryView(
    queryClient: queryClient,
    queryKey: "users",
    queryFn: fetchUsers
) { result in
    // 根据结果状态渲染 UI
}
```

### MutationClient

突变客户端，用于处理数据修改操作。

```swift
let mutationClient = MutationClient(queryClient: queryClient)

// 执行突变
mutationClient.mutateAndInvalidate(
    key: "create-user",
    mutationFn: createUser,
    invalidateQueries: ["users"]
)
.sink { result in
    switch result {
    case .success(let user):
        print("用户创建成功: \(user)")
    case .failure(let error):
        print("创建失败: \(error)")
    case .loading:
        break
    }
}
```

### QueryKey

查询键工具，用于生成和管理查询键。

```swift
// 基本查询键
let userKey = QueryKey("user", "123")
let postsKey = QueryKey("posts", "page=1", "limit=10")

// 使用构建器
let userKey = QueryKeyBuilder.user("123")
let postsKey = QueryKeyBuilder.posts(["page": "1", "limit": "10"])
let searchKey = QueryKeyBuilder.search("react", ["type": "article"])

// 模式匹配
let pattern = QueryKey("user", "*")
let matchingKeys = QueryKeyPattern.getMatchingKeys(allKeys, pattern: pattern)
```

## 网络服务

### NetworkService

提供统一的网络请求接口。

```swift
let networkService = NetworkService(
    baseURL: URL(string: "https://api.example.com")!,
    headers: ["Authorization": "Bearer token"]
)

let endpoint = APIEndpoint(
    path: "/users",
    method: .get,
    queryItems: ["page": "1", "limit": "10"]
)

networkService.request(endpoint)
    .sink(
        receiveCompletion: { completion in
            // 处理完成
        },
        receiveValue: { (users: [User]) in
            // 处理数据
        }
    )
```

## 视图模型

### QueryViewModel

用于在 SwiftUI 中管理查询状态。

```swift
class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let queryClient = QueryClient()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupQuery()
    }
    
    private func setupQuery() {
        queryClient.query(key: "users", queryFn: fetchUsers)
            .sink { [weak self] result in
                switch result {
                case .loading:
                    self?.isLoading = true
                case .success(let users):
                    self?.users = users
                    self?.isLoading = false
                case .failure(let error):
                    self?.error = error
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    func refetch() {
        queryClient.invalidateQuery(key: "users")
        setupQuery()
    }
}
```

### MutationViewModel

用于在 SwiftUI 中管理突变状态。

```swift
class CreateUserViewModel: ObservableObject {
    @Published var isMutating = false
    @Published var error: Error?
    
    private let mutationClient: MutationClient
    
    init(queryClient: QueryClient) {
        self.mutationClient = MutationClient(queryClient: queryClient)
    }
    
    func createUser(name: String, email: String) {
        isMutating = true
        
        mutationClient.mutateAndInvalidate(
            key: "create-user",
            mutationFn: { try await createUserAPI(name: name, email: email) },
            invalidateQueries: ["users"]
        )
        .sink { [weak self] result in
            switch result {
            case .success:
                self?.isMutating = false
            case .failure(let error):
                self?.error = error
                self?.isMutating = false
            case .loading:
                break
            }
        }
        .store(in: &cancellables)
    }
}
```

## UIKit 集成

### 基本查询示例

```swift
class UserListViewController: UIViewController {
    private let queryClient = QueryClient()
    private var cancellables = Set<AnyCancellable>()
    private var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuery()
    }
    
    private func setupQuery() {
        queryClient.query(key: "users", queryFn: { try await fetchUsers() })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .loading:
                    self?.showLoading()
                case .success(let users):
                    self?.users = users
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
}
```

### 突变操作示例

```swift
class CreateUserViewController: UIViewController {
    private let queryClient = QueryClient()
    private let mutationClient: MutationClient
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.mutationClient = MutationClient(queryClient: queryClient)
        super.init(nibName: nil, bundle: nil)
    }
    
    @IBAction func createUserTapped(_ sender: UIButton) {
        let request = CreateUserRequest(name: "张三", email: "zhangsan@example.com")
        
        mutationClient.mutateAndInvalidate(
            key: "create-user",
            mutationFn: { try await createUserAPI(request: request) },
            invalidateQueries: ["users"]
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            switch result {
            case .success(let user):
                self?.showSuccess("用户创建成功")
            case .failure(let error):
                self?.showError("创建失败: \(error.localizedDescription)")
            case .loading:
                break
            }
        }
        .store(in: &cancellables)
    }
}
```

## 配置选项

### 查询配置

```swift
let config = QueryConfig(
    staleTime: 5 * 60,        // 数据过期时间
    cacheTime: 10 * 60,       // 缓存时间
    retryCount: 3,            // 重试次数
    retryDelay: 1.0,          // 重试延迟
    enableBackgroundRefresh: false,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true
)
```

### 预设配置

- `QueryConfig.fastStale`: 快速过期，适用于实时数据
- `QueryConfig.slowStale`: 慢速过期，适用于静态数据
- `QueryConfig.infiniteCache`: 无限缓存，适用于配置数据

## 最佳实践

### 1. 查询键命名

使用有意义的查询键，便于管理和调试：

```swift
// 好的命名
"users"                    // 用户列表
"user:123"                // 单个用户
"posts?page=1&limit=10"   // 分页帖子列表
"user:123:posts"          // 用户的帖子

// 避免的命名
"data"                    // 太模糊
"query1"                  // 无意义
"temp"                    // 临时性
```

### 2. 缓存策略

根据数据特性选择合适的缓存策略：

```swift
// 实时数据 - 快速过期
let realtimeConfig = QueryConfig.fastStale

// 静态数据 - 慢速过期
let staticConfig = QueryConfig.slowStale

// 配置数据 - 无限缓存
let configData = QueryConfig.infiniteCache
```

### 3. 错误处理

提供友好的错误处理和重试机制：

```swift
QueryView(
    queryClient: queryClient,
    queryKey: "users",
    queryFn: fetchUsers
) { result in
    switch result {
    case .loading:
        ProgressView("加载中...")
    case .success(let users):
        UserList(users: users)
    case .failure(let error):
        ErrorView(
            error: error,
            retryAction: {
                queryClient.invalidateQuery(key: "users")
            }
        )
    }
}
```

### 4. 性能优化

- 使用适当的缓存策略减少网络请求
- 避免在短时间内重复查询相同数据
- 合理使用预取功能
- 及时清理过期缓存

## 示例项目

查看 `Examples/` 目录中的完整示例，包括：

- 用户管理
- 帖子系统
- 评论功能
- 搜索功能
- 分页加载

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License 