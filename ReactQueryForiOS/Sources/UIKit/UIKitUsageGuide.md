# UIKit 使用指南

本指南将详细介绍如何在 UIKit 项目中使用 ReactQueryForiOS 库。

## 目录

1. [基本设置](#基本设置)
2. [查询操作](#查询操作)
3. [突变操作](#突变操作)
4. [网络服务](#网络服务)
5. [错误处理](#错误处理)
6. [最佳实践](#最佳实践)
7. [完整示例](#完整示例)

## 基本设置

### 1. 导入库

```swift
import ReactQueryForiOS
import Combine
```

### 2. 创建查询客户端

```swift
class YourViewController: UIViewController {
    private let queryClient = QueryClient()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuery()
    }
}
```

## 查询操作

### 基本查询

```swift
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
```

### 带参数的查询

```swift
private func fetchUser(id: String) {
    let queryKey = QueryKeyBuilder.user(id).stringValue
    
    queryClient.query(key: queryKey, queryFn: { try await fetchUserAPI(id: id) })
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            switch result {
            case .loading:
                self?.showLoading()
            case .success(let user):
                self?.updateUI(with: user)
            case .failure(let error):
                self?.showError(error)
            }
        }
        .store(in: &cancellables)
}
```

### 刷新数据

```swift
@objc private func refreshData() {
    queryClient.invalidateQuery(key: "users")
    setupQuery()
}

// 在 UIRefreshControl 中使用
refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
```

## 突变操作

### 创建突变客户端

```swift
class CreateUserViewController: UIViewController {
    private let queryClient = QueryClient()
    private let mutationClient: MutationClient
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.mutationClient = MutationClient(queryClient: queryClient)
        super.init(nibName: nil, bundle: nil)
    }
}
```

### 执行突变

```swift
@IBAction func createUserTapped(_ sender: UIButton) {
    let request = CreateUserRequest(name: nameTextField.text!, email: emailTextField.text!)
    
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
            self?.dismiss(animated: true)
        case .failure(let error):
            self?.showError("创建失败: \(error.localizedDescription)")
        case .loading:
            self?.showLoading()
        }
    }
    .store(in: &cancellables)
}
```

### 更新操作

```swift
private func updateUser(id: String, name: String, email: String) {
    let request = UpdateUserRequest(name: name, email: email)
    
    mutationClient.mutateAndInvalidate(
        key: "update-user",
        mutationFn: { try await updateUserAPI(id: id, request: request) },
        invalidateQueries: [QueryKeyBuilder.user(id).stringValue, "users"]
    )
    .receive(on: DispatchQueue.main)
    .sink { [weak self] result in
        switch result {
        case .success(let user):
            self?.showSuccess("用户信息更新成功")
            self?.updateUI(with: user)
        case .failure(let error):
            self?.showError("更新失败: \(error.localizedDescription)")
        case .loading:
            break
        }
    }
    .store(in: &cancellables)
}
```

## 网络服务

### 创建网络服务

```swift
class NetworkViewController: UIViewController {
    private let networkService: NetworkService
    
    init() {
        let baseURL = URL(string: "https://api.example.com")!
        self.networkService = NetworkService(
            baseURL: baseURL,
            headers: ["Authorization": "Bearer your-token"],
            timeoutInterval: 15.0
        )
        super.init(nibName: nil, bundle: nil)
    }
}
```

### 发送请求

```swift
private func sendRequest() {
    let endpoint = APIEndpoint(
        path: "/users",
        method: .get,
        queryItems: ["page": "1", "limit": "10"]
    )
    
    networkService.request(endpoint)
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("请求完成")
                case .failure(let error):
                    self.showError(error)
                }
            },
            receiveValue: { (users: [User]) in
                self.users = users
                self.tableView.reloadData()
            }
        )
        .store(in: &cancellables)
}
```

### POST 请求

```swift
private func createUser(name: String, email: String) {
    let endpoint = APIEndpoint(
        path: "/users",
        method: .post,
        body: [
            "name": name,
            "email": email
        ]
    )
    
    networkService.request(endpoint)
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                // 处理完成
            },
            receiveValue: { (user: User) in
                self.showSuccess("用户创建成功")
            }
        )
        .store(in: &cancellables)
}
```

## 错误处理

### 基本错误处理

```swift
private func handleQueryResult(_ result: QueryResult<[User]>) {
    switch result {
    case .loading:
        showLoading()
    case .success(let users):
        hideLoading()
        self.users = users
        tableView.reloadData()
    case .failure(let error):
        hideLoading()
        showError(error)
    }
}

private func showError(_ error: Error) {
    let alert = UIAlertController(
        title: "错误",
        message: error.localizedDescription,
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "确定", style: .default))
    present(alert, animated: true)
}

private func showLoading() {
    loadingView.startAnimating()
    tableView.isHidden = true
}

private func hideLoading() {
    loadingView.stopAnimating()
    tableView.isHidden = false
}
```

### 重试机制

```swift
private func setupQueryWithRetry() {
    let config = QueryConfig(
        retryCount: 3,
        retryDelay: 1.0
    )
    
    queryClient.query(key: "users", queryFn: { try await fetchUsers() }, config: config)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            self?.handleQueryResult(result)
        }
        .store(in: &cancellables)
}
```

## 最佳实践

### 1. 内存管理

```swift
class YourViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        // 自动清理订阅
        cancellables.removeAll()
    }
}
```

### 2. 查询键管理

```swift
// 使用构建器创建查询键
let userKey = QueryKeyBuilder.user("123")
let postsKey = QueryKeyBuilder.posts(["page": "1", "limit": "10"])

// 在查询中使用
queryClient.query(key: userKey.stringValue, queryFn: { try await fetchUser(id: "123") })
```

### 3. 缓存策略

```swift
// 实时数据 - 快速过期
let realtimeConfig = QueryConfig.fastStale

// 静态数据 - 慢速过期
let staticConfig = QueryConfig.slowStale

// 配置数据 - 无限缓存
let configData = QueryConfig.infiniteCache

let queryClient = QueryClient(config: staticConfig)
```

### 4. 状态管理

```swift
class UserListViewController: UIViewController {
    private var users: [User] = []
    private var isLoading = false {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        tableView.isHidden = isLoading
        loadingView.isHidden = !isLoading
        refreshControl.isEnabled = !isLoading
    }
}
```

## 完整示例

### 用户列表视图控制器

```swift
class UserListViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    // MARK: - Properties
    private let queryClient = QueryClient()
    private var cancellables = Set<AnyCancellable>()
    private var users: [User] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupQuery()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "用户列表"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Query Setup
    private func setupQuery() {
        queryClient.query(key: "users", queryFn: { try await fetchUsers() })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.handleQueryResult(result)
            }
            .store(in: &cancellables)
    }
    
    private func handleQueryResult(_ result: QueryResult<[User]>) {
        switch result {
        case .loading:
            loadingView.startAnimating()
            tableView.isHidden = true
            
        case .success(let users):
            loadingView.stopAnimating()
            tableView.isHidden = false
            self.users = users
            tableView.reloadData()
            
        case .failure(let error):
            loadingView.stopAnimating()
            showError(error)
        }
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        queryClient.invalidateQuery(key: "users")
        setupQuery()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "加载失败",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "重试", style: .default) { [weak self] _ in
            self?.refreshData()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = users[indexPath.row]
        let detailVC = UserDetailViewController(userId: user.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
```

### 创建用户视图控制器

```swift
class CreateUserViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    // MARK: - Properties
    private let queryClient = QueryClient()
    private let mutationClient: MutationClient
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        self.mutationClient = MutationClient(queryClient: queryClient)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "创建用户"
        createButton.addTarget(self, action: #selector(createUserTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func createUserTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "错误", message: "请填写姓名和邮箱")
            return
        }
        
        let request = CreateUserRequest(name: name, email: email)
        
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
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.showError("创建失败: \(error.localizedDescription)")
            case .loading:
                self?.showLoading()
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    private func showLoading() {
        createButton.isEnabled = false
        loadingView.startAnimating()
    }
    
    private func hideLoading() {
        createButton.isEnabled = true
        loadingView.stopAnimating()
    }
    
    private func showSuccess(_ message: String) {
        hideLoading()
        let alert = UIAlertController(title: "成功", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        hideLoading()
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
```

## 总结

通过以上指南，您可以在 UIKit 项目中充分利用 ReactQueryForiOS 库的功能。主要优势包括：

1. **简洁的 API**: 与 SwiftUI 版本保持一致的 API 设计
2. **强大的缓存**: 自动缓存和过期管理
3. **错误处理**: 完善的错误处理和重试机制
4. **类型安全**: 完全类型安全的 API
5. **性能优化**: 智能的内存管理和并发控制

记住始终在主线程上更新 UI，并妥善管理 Combine 订阅的生命周期。 