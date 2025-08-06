import UIKit
import Combine

/// UIKit 用户详情视图控制器示例
@available(iOS 15.0, *)
public class UIKitUserDetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let createdAtLabel = UILabel()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let errorView = UIView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
    
    // MARK: - Properties
    
    private let userId: String
    private let queryClient = QueryClient()
    private let mutationClient: MutationClient
    private var cancellables = Set<AnyCancellable>()
    private var user: User?
    private var currentResult: QueryResult<User> = .loading
    
    // MARK: - Initialization
    
    public init(userId: String) {
        self.userId = userId
        self.mutationClient = MutationClient(queryClient: queryClient)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupQuery()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 设置头像
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.backgroundColor = .systemGray5
        
        // 设置标签
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        
        emailLabel.font = .systemFont(ofSize: 16)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        
        createdAtLabel.font = .systemFont(ofSize: 14)
        createdAtLabel.textColor = .tertiaryLabel
        createdAtLabel.textAlignment = .center
        
        // 设置加载视图
        loadingView.hidesWhenStopped = true
        
        // 设置错误视图
        errorView.isHidden = true
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        retryButton.setTitle("重试", for: .normal)
        retryButton.addTarget(self, action: #selector(retryQuery), for: .touchUpInside)
        
        // 布局
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(createdAtLabel)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        // 设置约束
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Avatar
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Name
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Email
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Created At
            createdAtLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            createdAtLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createdAtLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createdAtLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Loading View
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Error View
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        editButton.target = self
        editButton.action = #selector(editUser)
        navigationItem.rightBarButtonItem = editButton
    }
    
    // MARK: - Query Setup
    
    private func setupQuery() {
        let queryKey = QueryKeyBuilder.user(userId).stringValue
        
        queryClient.query(key: queryKey, queryFn: { try await ExampleUsage.fetchUser(id: self.userId) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.handleQueryResult(result)
            }
            .store(in: &cancellables)
    }
    
    private func handleQueryResult(_ result: QueryResult<User>) {
        currentResult = result
        
        switch result {
        case .loading:
            loadingView.startAnimating()
            errorView.isHidden = true
            scrollView.isHidden = true
            editButton.isEnabled = false
            
        case .success(let user):
            loadingView.stopAnimating()
            errorView.isHidden = true
            scrollView.isHidden = false
            editButton.isEnabled = true
            
            self.user = user
            updateUI(with: user)
            
        case .failure(let error):
            loadingView.stopAnimating()
            scrollView.isHidden = true
            errorView.isHidden = false
            editButton.isEnabled = false
            errorLabel.text = "加载失败: \(error.localizedDescription)"
        }
    }
    
    private func updateUI(with user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        createdAtLabel.text = "创建时间: \(formatter.string(from: user.createdAt))"
        
        // 加载头像
        if let avatarURL = user.avatar {
            // 这里可以使用 Kingfisher 或其他图片加载库
            // 为了演示，我们使用系统图标
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemBlue
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray
        }
    }
    
    // MARK: - Actions
    
    @objc private func retryQuery() {
        let queryKey = QueryKeyBuilder.user(userId).stringValue
        queryClient.invalidateQuery(key: queryKey)
        setupQuery()
    }
    
    @objc private func editUser() {
        guard let user = user else { return }
        
        let alert = UIAlertController(title: "编辑用户", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "姓名"
            textField.text = user.name
        }
        
        alert.addTextField { textField in
            textField.placeholder = "邮箱"
            textField.text = user.email
            textField.keyboardType = .emailAddress
        }
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self] _ in
            guard let self = self,
                  let nameField = alert.textFields?[0],
                  let emailField = alert.textFields?[1],
                  let name = nameField.text, !name.isEmpty,
                  let email = emailField.text, !email.isEmpty else {
                return
            }
            
            self.updateUser(name: name, email: email)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func updateUser(name: String, email: String) {
        let request = UpdateUserRequest(name: name, email: email)
        
        mutationClient.mutateAndInvalidate(
            key: "update-user",
            mutationFn: { try await ExampleUsage.updateUser(id: self.userId, request: request) },
            invalidateQueries: [QueryKeyBuilder.user(self.userId).stringValue]
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            switch result {
            case .success(let updatedUser):
                self?.user = updatedUser
                self?.updateUI(with: updatedUser)
                self?.showSuccessAlert("用户信息更新成功")
                
            case .failure(let error):
                self?.showErrorAlert("更新失败: \(error.localizedDescription)")
                
            case .loading:
                break
            }
        }
        .store(in: &cancellables)
    }
    
    private func showSuccessAlert(_ message: String) {
        let alert = UIAlertController(title: "成功", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Example Usage Extension

@available(iOS 15.0, *)
extension ExampleUsage {
    
    /// 更新用户信息
    public static func updateUser(id: String, request: UpdateUserRequest) async throws -> User {
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒延迟
        
        return User(
            id: id,
            name: request.name ?? "用户\(id)",
            email: request.email ?? "user\(id)@example.com",
            avatar: request.avatar,
            createdAt: Date()
        )
    }
} 