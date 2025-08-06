# CocoaPods 安装指南

本指南将详细介绍如何通过 CocoaPods 安装和使用 ReactQueryForiOS 库。

## 安装步骤

### 1. 创建 Podfile

在您的 iOS 项目根目录下创建 `Podfile` 文件：

```ruby
# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'YourAppName' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for YourAppName
  pod 'ReactQueryForiOS', '~> 1.0.0'

  target 'YourAppNameTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'YourAppNameUITests' do
    # Pods for testing
  end

end
```

### 2. 安装依赖

在终端中执行以下命令：

```bash
# 安装 CocoaPods（如果还没有安装）
sudo gem install cocoapods

# 安装项目依赖
pod install
```

### 3. 打开项目

安装完成后，使用 `.xcworkspace` 文件打开项目：

```bash
open YourAppName.xcworkspace
```

**注意**: 不要使用 `.xcodeproj` 文件，必须使用 `.xcworkspace` 文件。

## 使用示例

### 基本使用

```swift
import UIKit
import ReactQueryForiOS
import Combine

class UserListViewController: UIViewController {
    
    // MARK: - Properties
    private let queryClient = QueryClient()
    private var cancellables = Set<AnyCancellable>()
    private var users: [User] = []
    
    // MARK: - UI Components
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupQuery()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "用户列表"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    private func setupQuery() {
        queryClient.query(key: "users", queryFn: { try await fetchUsers() })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .loading:
                    self?.showLoading()
                case .success(let users):
                    self?.hideLoading()
                    self?.users = users
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.hideLoading()
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    private func showLoading() {
        loadingView.startAnimating()
        tableView.isHidden = true
    }
    
    private func hideLoading() {
        loadingView.stopAnimating()
        tableView.isHidden = false
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

### SwiftUI 使用

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
                ProgressView("加载中...")
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
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("加载失败")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("重试") {
                        queryClient.invalidateQuery(key: "users")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("用户列表")
    }
}
```

### 突变操作

```swift
import UIKit
import ReactQueryForiOS
import Combine

class CreateUserViewController: UIViewController {
    
    // MARK: - Properties
    private let queryClient = QueryClient()
    private let mutationClient: MutationClient
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
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
    
    // MARK: - Setup
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
```

## 版本管理

### 指定版本

```ruby
# 使用特定版本
pod 'ReactQueryForiOS', '1.0.0'

# 使用版本范围
pod 'ReactQueryForiOS', '~> 1.0.0'  # 1.0.0 到 1.1.0 之间
pod 'ReactQueryForiOS', '>= 1.0.0'  # 1.0.0 及以上
pod 'ReactQueryForiOS', '~> 1.0'    # 1.0.x 版本
```

### 更新依赖

```bash
# 更新所有依赖
pod update

# 更新特定依赖
pod update ReactQueryForiOS
```

## 故障排除

### 常见问题

1. **编译错误**
   ```bash
   # 清理项目
   pod deintegrate
   pod install
   ```

2. **版本冲突**
   ```bash
   # 查看依赖树
   pod dependency
   
   # 强制更新
   pod update --repo-update
   ```

3. **缓存问题**
   ```bash
   # 清理 CocoaPods 缓存
   pod cache clean --all
   pod install
   ```

### 调试技巧

1. **检查安装**
   ```bash
   # 验证 podspec
   pod spec lint ReactQueryForiOS.podspec --allow-warnings
   
   # 检查依赖
   pod dependency
   ```

2. **查看日志**
   ```bash
   # 详细安装日志
   pod install --verbose
   ```

## 最佳实践

### 1. 版本锁定

在生产环境中，建议锁定特定版本：

```ruby
pod 'ReactQueryForiOS', '1.0.0'
```

### 2. 依赖管理

定期更新依赖以获取安全修复和新功能：

```bash
# 检查更新
pod outdated

# 更新依赖
pod update
```

### 3. 团队协作

确保团队成员使用相同的依赖版本：

```bash
# 提交 Podfile.lock
git add Podfile.lock
git commit -m "Update dependencies"
```

## 支持

如果您在使用过程中遇到问题，请：

1. 检查 [GitHub Issues](https://github.com/JKloveJK/ReactQueryForiOS/issues)
2. 查看 [文档](https://github.com/JKloveJK/ReactQueryForiOS)
3. 提交新的 Issue 描述您的问题

## 许可证

ReactQueryForiOS 使用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。 