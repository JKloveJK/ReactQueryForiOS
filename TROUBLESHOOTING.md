# 故障排除指南

本指南将帮助您解决在使用 ReactQueryForiOS 库时遇到的常见问题。

## CocoaPods 相关问题

### 1. "No such module 'XCTest'" 错误

**问题描述**: 在验证 podspec 时出现 XCTest 模块找不到的错误。

**解决方案**:
```bash
# 使用 --allow-warnings 标志
pod spec lint ReactQueryForiOS.podspec --allow-warnings

# 或者跳过验证直接发布
pod trunk push ReactQueryForiOS.podspec --allow-warnings
```

### 2. 编译错误

**问题描述**: 在使用库时出现编译错误。

**解决方案**:
```bash
# 清理项目
pod deintegrate
pod install

# 清理 Xcode 缓存
Product > Clean Build Folder
```

### 3. 版本冲突

**问题描述**: 与其他库发生版本冲突。

**解决方案**:
```bash
# 查看依赖树
pod dependency

# 强制更新
pod update --repo-update
```

### 4. 缓存问题

**问题描述**: 安装后出现奇怪的行为。

**解决方案**:
```bash
# 清理 CocoaPods 缓存
pod cache clean --all
pod install

# 删除 Pods 目录重新安装
rm -rf Pods
rm -rf Podfile.lock
pod install
```

## Swift Package Manager 相关问题

### 1. 包解析失败

**问题描述**: SPM 无法解析包依赖。

**解决方案**:
```bash
# 清理包缓存
swift package clean
swift package reset

# 重新解析
swift package resolve
```

### 2. 编译错误

**问题描述**: 在 SPM 项目中编译失败。

**解决方案**:
```bash
# 检查依赖
swift package show-dependencies

# 重新编译
swift build
```

## 常见使用问题

### 1. 查询不工作

**问题描述**: 查询没有返回数据。

**检查清单**:
- [ ] 确保网络连接正常
- [ ] 检查查询键是否正确
- [ ] 验证查询函数是否正确实现
- [ ] 检查错误处理

**示例**:
```swift
// 正确的查询设置
queryClient.query(key: "users", queryFn: { try await fetchUsers() })
    .receive(on: DispatchQueue.main)
    .sink { [weak self] result in
        switch result {
        case .loading:
            print("正在加载...")
        case .success(let users):
            print("加载成功: \(users.count) 个用户")
        case .failure(let error):
            print("加载失败: \(error)")
        }
    }
    .store(in: &cancellables)
```

### 2. 缓存不生效

**问题描述**: 数据没有正确缓存。

**检查清单**:
- [ ] 检查 QueryConfig 配置
- [ ] 验证 staleTime 和 cacheTime 设置
- [ ] 确保查询键一致

**示例**:
```swift
// 正确的缓存配置
let config = QueryConfig(
    staleTime: 5 * 60,  // 5分钟过期
    cacheTime: 10 * 60  // 10分钟缓存
)

let queryClient = QueryClient(config: config)
```

### 3. 突变操作失败

**问题描述**: 突变操作没有正确执行。

**检查清单**:
- [ ] 确保突变函数正确实现
- [ ] 检查网络连接
- [ ] 验证请求参数
- [ ] 检查错误处理

**示例**:
```swift
// 正确的突变设置
mutationClient.mutateAndInvalidate(
    key: "create-user",
    mutationFn: { try await createUserAPI(request: request) },
    invalidateQueries: ["users"]
)
.receive(on: DispatchQueue.main)
.sink { [weak self] result in
    switch result {
    case .success(let user):
        print("创建成功: \(user)")
    case .failure(let error):
        print("创建失败: \(error)")
    case .loading:
        print("正在创建...")
    }
}
.store(in: &cancellables)
```

## 性能问题

### 1. 内存泄漏

**问题描述**: 应用内存使用量持续增长。

**解决方案**:
```swift
// 正确管理订阅
class ViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.removeAll()
    }
    
    private func setupQuery() {
        queryClient.query(key: "users", queryFn: fetchUsers)
            .sink { result in
                // 处理结果
            }
            .store(in: &cancellables)  // 重要：存储订阅
    }
}
```

### 2. 频繁网络请求

**问题描述**: 应用发送过多网络请求。

**解决方案**:
```swift
// 使用适当的缓存配置
let config = QueryConfig(
    staleTime: 30 * 60,  // 30分钟过期
    cacheTime: 60 * 60   // 1小时缓存
)

// 使用查询键构建器
let userKey = QueryKeyBuilder.user("123")
queryClient.query(key: userKey.stringValue, queryFn: fetchUser)
```

## 调试技巧

### 1. 启用详细日志

```swift
// 在开发环境中启用详细日志
#if DEBUG
print("查询键: \(queryKey)")
print("查询结果: \(result)")
#endif
```

### 2. 使用断点调试

```swift
// 在关键位置设置断点
queryClient.query(key: "users", queryFn: fetchUsers)
    .sink { result in
        // 在这里设置断点
        switch result {
        case .loading:
            break  // 断点 1
        case .success(let users):
            break  // 断点 2
        case .failure(let error):
            break  // 断点 3
        }
    }
```

### 3. 网络调试

```swift
// 使用 URLSession 的调试功能
let session = URLSession(configuration: .default)
session.configuration.waitsForConnectivity = true
session.configuration.timeoutIntervalForRequest = 30
```

## 环境问题

### 1. Xcode 版本兼容性

**问题描述**: 在不同 Xcode 版本间编译失败。

**解决方案**:
- 确保使用 Xcode 14.0 或更高版本
- 检查 Swift 版本兼容性
- 更新到最新的 Xcode 版本

### 2. iOS 版本兼容性

**问题描述**: 在特定 iOS 版本上运行失败。

**解决方案**:
- 确保目标 iOS 版本为 15.0 或更高
- 检查 API 可用性
- 使用 `@available` 标记

## 获取帮助

如果以上解决方案无法解决您的问题，请：

1. **查看文档**
   - [README.md](README.md)
   - [UIKit 使用指南](ReactQueryForiOS/Sources/UIKit/UIKitUsageGuide.md)
   - [CocoaPods 安装指南](COCOAPODS_INSTALLATION.md)

2. **搜索现有问题**
   - 在 [GitHub Issues](https://github.com/JKloveJK/ReactQueryForiOS/issues) 中搜索类似问题

3. **提交新问题**
   - 提供详细的错误信息
   - 包含复现步骤
   - 提供环境信息（Xcode 版本、iOS 版本等）

4. **联系维护团队**
   - 通过 GitHub Issues 联系
   - 提供完整的错误日志

## 预防措施

### 1. 定期更新

```bash
# 更新 CocoaPods 依赖
pod update ReactQueryForiOS

# 更新 Swift Package Manager 依赖
swift package update
```

### 2. 代码审查

- 检查内存管理
- 验证错误处理
- 确保类型安全

### 3. 测试覆盖

- 编写单元测试
- 进行集成测试
- 测试不同设备和 iOS 版本

---

## 快速修复命令

```bash
# 清理并重新安装 CocoaPods
pod deintegrate
pod install

# 清理 Xcode 缓存
Product > Clean Build Folder

# 验证 podspec
pod spec lint ReactQueryForiOS.podspec --allow-warnings

# 更新依赖
pod update --repo-update
``` 