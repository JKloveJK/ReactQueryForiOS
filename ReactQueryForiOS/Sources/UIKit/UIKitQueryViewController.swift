import UIKit
import Combine

/// UIKit 查询视图控制器示例
@available(iOS 15.0, *)
public class UIKitQueryViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let errorView = UIView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    
    // MARK: - Properties
    
    private let queryClient = QueryClient()
    private var cancellables = Set<AnyCancellable>()
    private var users: [User] = []
    private var currentResult: QueryResult<[User]> = .loading
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupQuery()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "用户列表 (UIKit)"
        
        // 设置 TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        // 设置加载视图
        loadingView.hidesWhenStopped = true
        
        // 设置错误视图
        errorView.isHidden = true
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        retryButton.setTitle("重试", for: .normal)
        retryButton.addTarget(self, action: #selector(retryQuery), for: .touchUpInside)
        
        // 布局
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
    
    // MARK: - Query Setup
    
    private func setupQuery() {
        queryClient.query(key: "users", queryFn: { try await ExampleUsage.fetchUsers() })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.handleQueryResult(result)
            }
            .store(in: &cancellables)
    }
    
    private func handleQueryResult(_ result: QueryResult<[User]>) {
        currentResult = result
        
        switch result {
        case .loading:
            loadingView.startAnimating()
            errorView.isHidden = true
            tableView.isHidden = true
            
        case .success(let users):
            loadingView.stopAnimating()
            errorView.isHidden = true
            tableView.isHidden = false
            self.users = users
            tableView.reloadData()
            
        case .failure(let error):
            loadingView.stopAnimating()
            tableView.isHidden = true
            errorView.isHidden = false
            errorLabel.text = "加载失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        queryClient.invalidateQuery(key: "users")
        setupQuery()
        refreshControl.endRefreshing()
    }
    
    @objc private func retryQuery() {
        queryClient.invalidateQuery(key: "users")
        setupQuery()
    }
}

// MARK: - UITableViewDataSource

@available(iOS 15.0, *)
extension UIKitQueryViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }
}

// MARK: - UITableViewDelegate

@available(iOS 15.0, *)
extension UIKitQueryViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = users[indexPath.row]
        let detailVC = UIKitUserDetailViewController(userId: user.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
} 