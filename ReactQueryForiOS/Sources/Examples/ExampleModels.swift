import Foundation

// MARK: - User Model

@available(iOS 15.0, *)
public struct User: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let email: String
    public let avatar: String?
    public let createdAt: Date

    public init(
        id: String,
        name: String,
        email: String,
        avatar: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatar = avatar
        self.createdAt = createdAt
    }
}

// MARK: - Post Model

@available(iOS 15.0, *)
public struct Post: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let content: String
    public let authorId: String
    public let authorName: String
    public let likes: Int
    public let comments: Int
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        title: String,
        content: String,
        authorId: String,
        authorName: String,
        likes: Int = 0,
        comments: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.authorId = authorId
        self.authorName = authorName
        self.likes = likes
        self.comments = comments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Comment Model

@available(iOS 15.0, *)
public struct Comment: Codable, Identifiable, Equatable {
    public let id: String
    public let content: String
    public let postId: String
    public let authorId: String
    public let authorName: String
    public let createdAt: Date

    public init(
        id: String,
        content: String,
        postId: String,
        authorId: String,
        authorName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.postId = postId
        self.authorId = authorId
        self.authorName = authorName
        self.createdAt = createdAt
    }
}

// MARK: - API Response Models

@available(iOS 15.0, *)
public struct PaginatedResponse<T: Codable>: Codable {
    public let data: [T]
    public let page: Int
    public let limit: Int
    public let total: Int
    public let hasNext: Bool

    public init(
        data: [T],
        page: Int,
        limit: Int,
        total: Int,
        hasNext: Bool
    ) {
        self.data = data
        self.page = page
        self.limit = limit
        self.total = total
        self.hasNext = hasNext
    }
}

@available(iOS 15.0, *)
public struct APIResponse<T: Codable>: Codable {
    public let success: Bool
    public let data: T?
    public let message: String?
    public let error: String?

    public init(
        success: Bool,
        data: T? = nil,
        message: String? = nil,
        error: String? = nil
    ) {
        self.success = success
        self.data = data
        self.message = message
        self.error = error
    }
}

// MARK: - Create/Update Request Models

@available(iOS 15.0, *)
public struct CreatePostRequest: Codable {
    public let title: String
    public let content: String

    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}

@available(iOS 15.0, *)
public struct UpdatePostRequest: Codable {
    public let title: String?
    public let content: String?

    public init(title: String? = nil, content: String? = nil) {
        self.title = title
        self.content = content
    }
}

@available(iOS 15.0, *)
public struct CreateCommentRequest: Codable {
    public let content: String
    public let postId: String

    public init(content: String, postId: String) {
        self.content = content
        self.postId = postId
    }
}

@available(iOS 15.0, *)
public struct UpdateUserRequest: Codable {
    public let name: String?
    public let email: String?
    public let avatar: String?

    public init(name: String? = nil, email: String? = nil, avatar: String? = nil) {
        self.name = name
        self.email = email
        self.avatar = avatar
    }
}

// MARK: - Filter Models

@available(iOS 15.0, *)
public struct PostFilters: Codable {
    public let authorId: String?
    public let search: String?
    public let sortBy: String?
    public let sortOrder: String?

    public init(
        authorId: String? = nil,
        search: String? = nil,
        sortBy: String? = nil,
        sortOrder: String? = nil
    ) {
        self.authorId = authorId
        self.search = search
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
}

@available(iOS 15.0, *)
public struct UserFilters: Codable {
    public let search: String?
    public let sortBy: String?
    public let sortOrder: String?

    public init(
        search: String? = nil,
        sortBy: String? = nil,
        sortOrder: String? = nil
    ) {
        self.search = search
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
}
