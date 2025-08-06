import UIKit
import Combine

/// UIKit 网络服务视图控制器示例
@available(iOS 15.0, *)
public class UIKitNetworkServiceViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let urlTextField = UITextField()
    private let methodSegmentedControl = UISegmentedControl(items: ["GET", "POST", "PUT", "DELETE"])
    private let headersTextView = UITextView()
    private let bodyTextView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let responseTextView = UITextView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let statusLabel = UILabel()
    
    // MARK: - Properties
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    private var isRequesting = false {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initialization
    
    public init() {
        let baseURL = URL(string: "https://api.example.com")!
        self.networkService = NetworkService(
            baseURL: baseURL,
            headers: ["Content-Type": "application/json"],
            timeoutInterval: 15.0
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "网络服务 (UIKit)"
        
        // 设置 URL 输入框
        urlTextField.placeholder = "API 路径 (例如: /users)"
        urlTextField.borderStyle = .roundedRect
        urlTextField.font = .systemFont(ofSize: 16)
        urlTextField.text = "/test"
        
        // 设置方法选择器
        methodSegmentedControl.selectedSegmentIndex = 0
        
        // 设置请求头输入框
        headersTextView.font = .systemFont(ofSize: 14)
        headersTextView.layer.borderColor = UIColor.systemGray4.cgColor
        headersTextView.layer.borderWidth = 1
        headersTextView.layer.cornerRadius = 8
        headersTextView.text = "{\n  \"Authorization\": \"Bearer token\"\n}"
        headersTextView.textColor = .label
        
        // 设置请求体输入框
        bodyTextView.font = .systemFont(ofSize: 14)
        bodyTextView.layer.borderColor = UIColor.systemGray4.cgColor
        bodyTextView.layer.borderWidth = 1
        bodyTextView.layer.cornerRadius = 8
        bodyTextView.text = "{\n  \"name\": \"测试用户\",\n  \"email\": \"test@example.com\"\n}"
        bodyTextView.textColor = .label
        
        // 设置发送按钮
        sendButton.setTitle("发送请求", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
        
        // 设置响应显示框
        responseTextView.font = .systemFont(ofSize: 14)
        responseTextView.layer.borderColor = UIColor.systemGray4.cgColor
        responseTextView.layer.borderWidth = 1
        responseTextView.layer.cornerRadius = 8
        responseTextView.backgroundColor = .systemGray6
        responseTextView.isEditable = false
        responseTextView.text = "响应将显示在这里..."
        
        // 设置状态标签
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.font = .systemFont(ofSize: 14)
        
        // 设置加载视图
        loadingView.hidesWhenStopped = true
        
        // 布局
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(urlTextField)
        contentView.addSubview(methodSegmentedControl)
        contentView.addSubview(headersTextView)
        contentView.addSubview(bodyTextView)
        contentView.addSubview(sendButton)
        contentView.addSubview(responseTextView)
        contentView.addSubview(statusLabel)
        view.addSubview(loadingView)
        
        // 设置约束
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        methodSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        headersTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        responseTextView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            // URL TextField
            urlTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            urlTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            urlTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Method Segmented Control
            methodSegmentedControl.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 16),
            methodSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            methodSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            methodSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Headers TextView
            headersTextView.topAnchor.constraint(equalTo: methodSegmentedControl.bottomAnchor, constant: 16),
            headersTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headersTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headersTextView.heightAnchor.constraint(equalToConstant: 80),
            
            // Body TextView
            bodyTextView.topAnchor.constraint(equalTo: headersTextView.bottomAnchor, constant: 16),
            bodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bodyTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // Send Button
            sendButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Response TextView
            responseTextView.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 20),
            responseTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            responseTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            responseTextView.heightAnchor.constraint(equalToConstant: 200),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: responseTextView.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Loading View
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func sendRequest() {
        guard let path = urlTextField.text, !path.isEmpty else {
            showAlert(title: "错误", message: "请输入 API 路径")
            return
        }
        
        let method = getHTTPMethod()
        let headers = parseJSON(headersTextView.text)
        let body = parseJSON(bodyTextView.text)
        
        let endpoint = APIEndpoint(
            path: path,
            method: method,
            headers: headers,
            body: body
        )
        
        // 模拟网络请求（实际项目中会使用真实的 API）
        simulateNetworkRequest(endpoint: endpoint)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Helper Methods
    
    private func getHTTPMethod() -> HTTPMethod {
        switch methodSegmentedControl.selectedSegmentIndex {
        case 0: return .get
        case 1: return .post
        case 2: return .put
        case 3: return .delete
        default: return .get
        }
    }
    
    private func parseJSON(_ jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            return nil
        }
    }
    
    private func simulateNetworkRequest(endpoint: APIEndpoint) {
        isRequesting = true
        statusLabel.text = "正在发送请求..."
        statusLabel.textColor = .systemBlue
        
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.handleSimulatedResponse(endpoint: endpoint)
        }
    }
    
    private func handleSimulatedResponse(endpoint: APIEndpoint) {
        isRequesting = false
        
        let response: [String: Any] = [
            "success": true,
            "data": [
                "id": "123",
                "name": "模拟用户",
                "email": "mock@example.com",
                "createdAt": Date().timeIntervalSince1970
            ],
            "message": "请求成功",
            "endpoint": endpoint.path,
            "method": endpoint.method.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        do {
            let responseData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            let responseString = String(data: responseData, encoding: .utf8) ?? "无法解析响应"
            
            responseTextView.text = responseString
            statusLabel.text = "请求成功"
            statusLabel.textColor = .systemGreen
            
        } catch {
            responseTextView.text = "响应解析失败: \(error.localizedDescription)"
            statusLabel.text = "响应解析失败"
            statusLabel.textColor = .systemRed
        }
    }
    
    private func updateUI() {
        sendButton.isEnabled = !isRequesting
        urlTextField.isEnabled = !isRequesting
        methodSegmentedControl.isEnabled = !isRequesting
        headersTextView.isEditable = !isRequesting
        bodyTextView.isEditable = !isRequesting
        
        if isRequesting {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
} 