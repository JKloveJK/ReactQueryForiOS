# 更新日志

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范。

## [1.0.0] - 2024-01-01

### 新增功能

- 🎉 **初始版本发布**
- ✨ **核心查询功能**
  - QueryClient：查询客户端，管理所有查询状态和缓存
  - QueryConfig：查询配置，支持自定义缓存策略
  - QueryResult：查询结果枚举，包含加载、成功、失败状态
- 🔄 **突变操作支持**
  - MutationClient：突变客户端，处理数据修改操作
  - MutationResult：突变结果枚举
  - 自动查询失效功能
- 🎨 **SwiftUI 集成**
  - QueryView：SwiftUI 查询视图组件
  - QueryViewModel：SwiftUI 视图模型
  - MutationViewModel：突变视图模型
  - 默认加载和错误视图
- 📱 **UIKit 支持**
  - 完整的 UIKit 集成示例
  - UIKitQueryViewController：用户列表查询示例
  - UIKitUserDetailViewController：用户详情示例
  - UIKitMutationViewController：突变操作示例
  - UIKitNetworkServiceViewController：网络服务示例
- 🌐 **网络服务**
  - NetworkService：统一的网络请求接口
  - APIEndpoint：API 端点定义
  - HTTPMethod：HTTP 方法枚举
  - NetworkError：网络错误处理
- 🔑 **查询键管理**
  - QueryKey：查询键结构体
  - QueryKeyBuilder：查询键构建器
  - QueryKeyPattern：查询键模式匹配
- ⚡ **性能优化**
  - 智能缓存系统
  - 自动重试机制
  - 内存管理优化
  - 并发控制

### 技术特性

- 🛡️ **类型安全**：完全类型安全的 API 设计
- 🔧 **iOS 15.0+**：支持 iOS 15.0 及以上版本
- 📦 **多平台支持**：同时支持 Swift Package Manager 和 CocoaPods
- 🧪 **单元测试**：完整的测试覆盖
- 📚 **详细文档**：包含使用指南和最佳实践

### 安装方式

#### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/JKloveJK/ReactQueryForiOS.git", from: "1.0.0")
]
```

#### CocoaPods

```ruby
pod 'ReactQueryForiOS', '~> 1.0.0'
```

### 快速开始

#### SwiftUI 使用

```swift
import SwiftUI
import ReactQueryForiOS

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

#### UIKit 使用

```swift
import UIKit
import ReactQueryForiOS
import Combine

class UserListViewController: UIViewController {
    private let queryClient = QueryClient()
    private var cancellables = Set<AnyCancellable>()
    
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

### 配置选项

#### 查询配置

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

#### 预设配置

- `QueryConfig.fastStale`：快速过期，适用于实时数据
- `QueryConfig.slowStale`：慢速过期，适用于静态数据
- `QueryConfig.infiniteCache`：无限缓存，适用于配置数据

### 文档

- 📖 [完整文档](README.md)
- 🎯 [UIKit 使用指南](ReactQueryForiOS/Sources/UIKit/UIKitUsageGuide.md)
- 📦 [CocoaPods 安装指南](COCOAPODS_INSTALLATION.md)
- 🚀 [发布指南](RELEASE_GUIDE.md)

### 示例项目

- 📱 [SwiftUI 示例](ReactQueryForiOS/Sources/Demo/)
- 📱 [UIKit 示例](ReactQueryForiOS/Sources/UIKit/)
- 📱 [CocoaPods 示例](Example/)

### 贡献

感谢所有为这个项目做出贡献的开发者！

### 许可证

MIT License - 详情请查看 [LICENSE](LICENSE) 文件。

---

## 版本历史

### [1.0.0] - 2024-01-01
- 🎉 初始版本发布
- ✨ 完整的查询和突变功能
- 🎨 SwiftUI 和 UIKit 支持
- 📚 详细文档和示例

---

## 未来计划

### 即将推出

- 🔄 无限查询支持
- 📊 查询统计和分析
- 🔐 认证和授权集成
- 🌍 国际化支持
- 📱 更多平台支持

### 长期计划

- 🚀 性能优化
- 🔧 更多配置选项
- 📈 监控和日志
- 🛠️ 开发工具集成

---

## 支持

如果您在使用过程中遇到问题，请：

1. 📖 查看 [文档](README.md)
2. 🔍 搜索 [GitHub Issues](https://github.com/JKloveJK/ReactQueryForiOS/issues)
3. 💬 提交新的 Issue
4. 📧 联系维护团队

---

## 致谢

感谢以下开源项目的启发：

- [React Query](https://react-query.tanstack.com/) - 灵感来源
- [Combine](https://developer.apple.com/documentation/combine) - 响应式编程框架
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - 声明式 UI 框架 