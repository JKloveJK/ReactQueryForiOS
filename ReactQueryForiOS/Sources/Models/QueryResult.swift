import Foundation

/// 查询结果
@available(iOS 15.0, *)
public enum QueryResult<T> {
    case success(T)
    case failure(Error)
    case loading
}

// MARK: - Query Result Extensions

@available(iOS 15.0, *)
extension QueryResult {

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

    /// 映射结果
    public func map<U>(_ transform: (T) -> U) -> QueryResult<U> {
        switch self {
        case .success(let data):
            return .success(transform(data))
        case .failure(let error):
            return .failure(error)
        case .loading:
            return .loading
        }
    }

    /// 扁平映射结果
    public func flatMap<U>(_ transform: (T) -> QueryResult<U>) -> QueryResult<U> {
        switch self {
        case .success(let data):
            return transform(data)
        case .failure(let error):
            return .failure(error)
        case .loading:
            return .loading
        }
    }
}

// MARK: - Equatable Conformance

@available(iOS 15.0, *)
extension QueryResult: Equatable where T: Equatable {
    public static func == (lhs: QueryResult<T>, rhs: QueryResult<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.success(let lhsData), .success(let rhsData)):
            return lhsData == rhsData
        default:
            return false
        }
    }
}
