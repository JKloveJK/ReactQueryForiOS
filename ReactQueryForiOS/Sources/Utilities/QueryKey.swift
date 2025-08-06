import Foundation

/// 查询键工具类
@available(iOS 15.0, *)
public struct QueryKey {

    // MARK: - Properties

    private let components: [String]

    // MARK: - Initialization

    public init(_ components: String...) {
        self.components = components
    }

    public init(_ components: [String]) {
        self.components = components
    }

    // MARK: - Public Methods

    /// 生成查询键字符串
    public var stringValue: String {
        return components.joined(separator: ":")
    }

    /// 添加组件
    public func appending(_ component: String) -> QueryKey {
        return QueryKey(components + [component])
    }

    /// 添加多个组件
    public func appending(_ components: [String]) -> QueryKey {
        return QueryKey(self.components + components)
    }

    /// 获取组件数组
    public var arrayValue: [String] {
        return components
    }

    /// 获取组件数量
    public var count: Int {
        return components.count
    }

    /// 获取指定索引的组件
    public subscript(index: Int) -> String? {
        guard index >= 0 && index < components.count else {
            return nil
        }
        return components[index]
    }
}

// MARK: - Query Key Extensions

@available(iOS 15.0, *)
extension QueryKey: CustomStringConvertible {
    public var description: String {
        return stringValue
    }
}

@available(iOS 15.0, *)
extension QueryKey: Equatable {
    public static func == (lhs: QueryKey, rhs: QueryKey) -> Bool {
        return lhs.components == rhs.components
    }
}

@available(iOS 15.0, *)
extension QueryKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(components)
    }
}

// MARK: - Query Key Builders

@available(iOS 15.0, *)
public struct QueryKeyBuilder {

    /// 创建用户相关的查询键
    public static func user(_ userId: String) -> QueryKey {
        return QueryKey("user", userId)
    }

    /// 创建用户列表查询键
    public static func users(_ filters: [String: String] = [:]) -> QueryKey {
        var components = ["users"]
        if !filters.isEmpty {
            components.append(
                filters.sorted { $0.key < $1.key }
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: ","))
        }
        return QueryKey(components)
    }

    /// 创建帖子相关的查询键
    public static func post(_ postId: String) -> QueryKey {
        return QueryKey("post", postId)
    }

    /// 创建帖子列表查询键
    public static func posts(_ filters: [String: String] = [:]) -> QueryKey {
        var components = ["posts"]
        if !filters.isEmpty {
            components.append(
                filters.sorted { $0.key < $1.key }
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: ","))
        }
        return QueryKey(components)
    }

    /// 创建评论相关的查询键
    public static func comments(_ postId: String) -> QueryKey {
        return QueryKey("comments", postId)
    }

    /// 创建通知相关的查询键
    public static func notifications(_ userId: String? = nil) -> QueryKey {
        if let userId = userId {
            return QueryKey("notifications", userId)
        } else {
            return QueryKey("notifications")
        }
    }

    /// 创建设置相关的查询键
    public static func settings(_ userId: String) -> QueryKey {
        return QueryKey("settings", userId)
    }

    /// 创建搜索相关的查询键
    public static func search(_ query: String, _ filters: [String: String] = [:]) -> QueryKey {
        var components = ["search", query]
        if !filters.isEmpty {
            components.append(
                filters.sorted { $0.key < $1.key }
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: ","))
        }
        return QueryKey(components)
    }
}

// MARK: - Query Key Patterns

@available(iOS 15.0, *)
public struct QueryKeyPattern {

    /// 检查查询键是否匹配模式
    public static func matches(_ key: QueryKey, pattern: QueryKey) -> Bool {
        guard key.count == pattern.count else {
            return false
        }

        for i in 0..<key.count {
            let keyComponent = key[i] ?? ""
            let patternComponent = pattern[i] ?? ""

            // 如果模式组件是通配符，则匹配任何值
            if patternComponent == "*" {
                continue
            }

            // 否则必须完全匹配
            if keyComponent != patternComponent {
                return false
            }
        }

        return true
    }

    /// 获取匹配指定模式的查询键
    public static func getMatchingKeys(_ keys: [QueryKey], pattern: QueryKey) -> [QueryKey] {
        return keys.filter { matches($0, pattern: pattern) }
    }
}
