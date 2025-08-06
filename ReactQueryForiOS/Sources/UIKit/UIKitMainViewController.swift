import UIKit

/// UIKit 主导航控制器，展示所有 UIKit 示例
@available(iOS 15.0, *)
public class UIKitMainViewController: UINavigationController {
    
    // MARK: - Initialization
    
    public init() {
        let rootViewController = UIKitDemoViewController()
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// UIKit 演示视图控制器
@available(iOS 15.0, *)
public class UIKitDemoViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let demoSections = [
        ("基础功能", [
            ("用户列表", "展示基本的查询功能，包括加载、成功、失败状态"),
            ("用户详情", "展示单个数据的查询和突变操作"),
            ("创建帖子", "展示突变操作和表单处理")
        ]),
        ("高级功能", [
            ("网络服务", "展示网络层的使用和请求配置"),
            ("缓存策略", "展示不同的缓存配置"),
            ("错误处理", "展示错误处理和重试机制")
        ]),
        ("实用工具", [
            ("查询键构建器", "展示查询键的生成和管理"),
            ("配置示例", "展示各种配置选项"),
            ("性能优化", "展示性能优化技巧")
        ])
    ]
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "React Query iOS - UIKit 示例"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemoCell")
        
        // 添加刷新功能
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        // 模拟刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return demoSections.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoSections[section].1.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath)
        let demo = demoSections[indexPath.section].1[indexPath.row]
        
        cell.textLabel?.text = demo.0
        cell.detailTextLabel?.text = demo.1
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return demoSections[section].0
    }
    
    // MARK: - UITableViewDelegate
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let demo = demoSections[indexPath.section].1[indexPath.row]
        let viewController = createViewController(for: demo.0)
        
        if let viewController = viewController {
            pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createViewController(for demoName: String) -> UIViewController? {
        switch demoName {
        case "用户列表":
            return UIKitQueryViewController()
            
        case "用户详情":
            // 创建一个示例用户详情页面
            return UIKitUserDetailViewController(userId: "1")
            
        case "创建帖子":
            return UIKitMutationViewController()
            
        case "网络服务":
            return UIKitNetworkServiceViewController()
            
        case "缓存策略":
            return UIKitCacheStrategyViewController()
            
        case "错误处理":
            return UIKitErrorHandlingViewController()
            
        case "查询键构建器":
            return UIKitQueryKeyViewController()
            
        case "配置示例":
            return UIKitConfigViewController()
            
        case "性能优化":
            return UIKitPerformanceViewController()
            
        default:
            return nil
        }
    }
}

// MARK: - Additional UIKit View Controllers

@available(iOS 15.0, *)
public class UIKitCacheStrategyViewController: UIViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "缓存策略 (UIKit)"
        
        let label = UILabel()
        label.text = "缓存策略示例\n\n• 快速过期 (30秒)\n• 慢速过期 (30分钟)\n• 无限缓存"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

@available(iOS 15.0, *)
public class UIKitErrorHandlingViewController: UIViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "错误处理 (UIKit)"
        
        let label = UILabel()
        label.text = "错误处理示例\n\n• 网络错误\n• 解析错误\n• 重试机制"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

@available(iOS 15.0, *)
public class UIKitQueryKeyViewController: UIViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "查询键构建器 (UIKit)"
        
        let label = UILabel()
        label.text = "查询键示例\n\n• 基本查询键\n• 参数化查询键\n• 模式匹配"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

@available(iOS 15.0, *)
public class UIKitConfigViewController: UIViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "配置示例 (UIKit)"
        
        let label = UILabel()
        label.text = "配置示例\n\n• 查询配置\n• 网络配置\n• 缓存配置"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

@available(iOS 15.0, *)
public class UIKitPerformanceViewController: UIViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "性能优化 (UIKit)"
        
        let label = UILabel()
        label.text = "性能优化示例\n\n• 内存管理\n• 缓存策略\n• 并发控制"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
} 