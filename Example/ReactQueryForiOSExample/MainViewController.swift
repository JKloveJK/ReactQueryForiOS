import UIKit
import ReactQueryForiOS

class MainViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let demoSections = [
        ("SwiftUI 示例", [
            ("用户列表", "展示 SwiftUI 中的基本查询功能"),
            ("帖子列表", "展示 SwiftUI 中的列表查询"),
            ("创建帖子", "展示 SwiftUI 中的突变操作")
        ]),
        ("UIKit 示例", [
            ("用户列表", "展示 UIKit 中的基本查询功能"),
            ("用户详情", "展示 UIKit 中的单个数据查询"),
            ("创建帖子", "展示 UIKit 中的突变操作"),
            ("网络服务", "展示网络层的使用")
        ]),
        ("高级功能", [
            ("查询键构建器", "展示查询键的生成和管理"),
            ("缓存策略", "展示不同的缓存配置"),
            ("错误处理", "展示错误处理和重试机制")
        ])
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "ReactQueryForiOS 示例"
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return demoSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoSections[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath)
        let demo = demoSections[indexPath.section].1[indexPath.row]
        
        cell.textLabel?.text = demo.0
        cell.detailTextLabel?.text = demo.1
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return demoSections[section].0
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let demo = demoSections[indexPath.section].1[indexPath.row]
        let viewController = createViewController(for: demo.0, section: indexPath.section)
        
        if let viewController = viewController {
            pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createViewController(for demoName: String, section: Int) -> UIViewController? {
        switch section {
        case 0: // SwiftUI 示例
            return createSwiftUIViewController(for: demoName)
        case 1: // UIKit 示例
            return createUIKitViewController(for: demoName)
        case 2: // 高级功能
            return createAdvancedViewController(for: demoName)
        default:
            return nil
        }
    }
    
    private func createSwiftUIViewController(for demoName: String) -> UIViewController? {
        // 这里可以创建 SwiftUI 视图的 UIHostingController
        // 为了简化，我们返回一个占位符
        let placeholderVC = UIViewController()
        placeholderVC.title = demoName
        placeholderVC.view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "SwiftUI 示例: \(demoName)\n\n这个示例展示了在 SwiftUI 中使用 ReactQueryForiOS 的方法。"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: placeholderVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: placeholderVC.view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: placeholderVC.view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: placeholderVC.view.trailingAnchor, constant: -20)
        ])
        
        return placeholderVC
    }
    
    private func createUIKitViewController(for demoName: String) -> UIViewController? {
        switch demoName {
        case "用户列表":
            return UIKitQueryViewController()
        case "用户详情":
            return UIKitUserDetailViewController(userId: "1")
        case "创建帖子":
            return UIKitMutationViewController()
        case "网络服务":
            return UIKitNetworkServiceViewController()
        default:
            return createPlaceholderViewController(title: demoName, description: "UIKit 示例")
        }
    }
    
    private func createAdvancedViewController(for demoName: String) -> UIViewController? {
        switch demoName {
        case "查询键构建器":
            return UIKitQueryKeyViewController()
        case "缓存策略":
            return UIKitCacheStrategyViewController()
        case "错误处理":
            return UIKitErrorHandlingViewController()
        default:
            return createPlaceholderViewController(title: demoName, description: "高级功能示例")
        }
    }
    
    private func createPlaceholderViewController(title: String, description: String) -> UIViewController {
        let placeholderVC = UIViewController()
        placeholderVC.title = title
        placeholderVC.view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "\(title)\n\n\(description)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: placeholderVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: placeholderVC.view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: placeholderVC.view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: placeholderVC.view.trailingAnchor, constant: -20)
        ])
        
        return placeholderVC
    }
} 