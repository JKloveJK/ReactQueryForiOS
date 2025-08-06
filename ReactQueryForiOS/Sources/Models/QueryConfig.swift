import Foundation

/// 查询配置
@available(iOS 15.0, *)
public struct QueryConfig {

    // MARK: - Properties

    /// 数据过期时间（秒）
    public let staleTime: TimeInterval

    /// 缓存时间（秒）
    public let cacheTime: TimeInterval

    /// 重试次数
    public let retryCount: Int

    /// 重试延迟（秒）
    public let retryDelay: TimeInterval

    /// 是否启用后台刷新
    public let enableBackgroundRefresh: Bool

    /// 是否在窗口重新获得焦点时刷新
    public let refetchOnWindowFocus: Bool

    /// 是否在网络重新连接时刷新
    public let refetchOnReconnect: Bool

    // MARK: - Initialization

    public init(
        staleTime: TimeInterval = 5 * 60,  // 5分钟
        cacheTime: TimeInterval = 10 * 60,  // 10分钟
        retryCount: Int = 3,
        retryDelay: TimeInterval = 1.0,
        enableBackgroundRefresh: Bool = false,
        refetchOnWindowFocus: Bool = true,
        refetchOnReconnect: Bool = true
    ) {
        self.staleTime = staleTime
        self.cacheTime = cacheTime
        self.retryCount = retryCount
        self.retryDelay = retryDelay
        self.enableBackgroundRefresh = enableBackgroundRefresh
        self.refetchOnWindowFocus = refetchOnWindowFocus
        self.refetchOnReconnect = refetchOnReconnect
    }

    // MARK: - Preset Configurations

    /// 快速过期配置（用于实时数据）
    public static let fastStale = QueryConfig(
        staleTime: 30,  // 30秒
        cacheTime: 60,  // 1分钟
        retryCount: 2,
        retryDelay: 0.5
    )

    /// 慢速过期配置（用于静态数据）
    public static let slowStale = QueryConfig(
        staleTime: 30 * 60,  // 30分钟
        cacheTime: 60 * 60,  // 1小时
        retryCount: 5,
        retryDelay: 2.0
    )

    /// 无限缓存配置（用于很少变化的数据）
    public static let infiniteCache = QueryConfig(
        staleTime: TimeInterval.infinity,
        cacheTime: TimeInterval.infinity,
        retryCount: 1,
        retryDelay: 1.0
    )
}
