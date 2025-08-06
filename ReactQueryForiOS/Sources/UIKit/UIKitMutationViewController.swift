import UIKit
import Combine

/// UIKit 突变操作视图控制器示例
@available(iOS 15.0, *)
public class UIKitMutationViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleTextField = UITextField()
    private let contentTextView = UITextView()
    private let createButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let statusLabel = UILabel()
    
    // MARK: - Properties
    
    private let queryClient = QueryClient()
    private let mutationClient: MutationClient
    private var cancellables = Set<AnyCancellable>()
    private var isMutating = false {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initialization
    
    public init() {
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
        setupKeyboardHandling()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "突变操作 (UIKit)"
        
        // 设置标题输入框
        titleTextField.placeholder = "帖子标题"
        titleTextField.borderStyle = .roundedRect
        titleTextField.font = .systemFont(ofSize: 16)
        
        // 设置内容输入框
        contentTextView.font = .systemFont(ofSize: 16)
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 8
        contentTextView.text = "帖子内容..."
        contentTextView.textColor = .placeholderText
        
        // 设置按钮
        createButton.setTitle("创建帖子", for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 8
        createButton.addTarget(self, action: #selector(createPost), for: .touchUpInside)
        
        deleteButton.setTitle("删除测试帖子", for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.addTarget(self, action: #selector(deletePost), for: .touchUpInside)
        
        // 设置状态标签
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.font = .systemFont(ofSize: 14)
        
        // 设置加载视图
        loadingView.hidesWhenStopped = true
        
        // 布局
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleTextField)
        contentView.addSubview(contentTextView)
        contentView.addSubview(createButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(statusLabel)
        view.addSubview(loadingView)
        
        // 设置约束
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
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
            
            // Title TextField
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Content TextView
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(equalToConstant: 120),
            
            // Create Button
            createButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 20),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Delete Button
            deleteButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 16),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Loading View
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 设置 TextView 代理
        contentTextView.delegate = self
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
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func createPost() {
        guard let title = titleTextField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty,
              content != "帖子内容..." else {
            showAlert(title: "错误", message: "请填写标题和内容")
            return
        }
        
        let request = CreatePostRequest(title: title, content: content)
        
        mutationClient.mutateAndInvalidate(
            key: "create-post",
            mutationFn: { try await ExampleUsage.createPost(request: request) },
            invalidateQueries: ["posts"]
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            switch result {
            case .success(let post):
                self?.showSuccessAlert("帖子创建成功！\n标题: \(post.title)")
                self?.clearForm()
                
            case .failure(let error):
                self?.showErrorAlert("创建失败: \(error.localizedDescription)")
                
            case .loading:
                break
            }
        }
        .store(in: &cancellables)
    }
    
    @objc private func deletePost() {
        let alert = UIAlertController(
            title: "确认删除",
            message: "确定要删除测试帖子吗？",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.performDelete()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func performDelete() {
        mutationClient.mutateAndInvalidate(
            key: "delete-post",
            mutationFn: { try await ExampleUsage.deletePost(id: "test-id") },
            invalidateQueries: ["posts", "post:test-id"]
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            switch result {
            case .success:
                self?.showSuccessAlert("帖子删除成功！")
                
            case .failure(let error):
                self?.showErrorAlert("删除失败: \(error.localizedDescription)")
                
            case .loading:
                break
            }
        }
        .store(in: &cancellables)
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
    
    private func updateUI() {
        createButton.isEnabled = !isMutating
        deleteButton.isEnabled = !isMutating
        titleTextField.isEnabled = !isMutating
        contentTextView.isEditable = !isMutating
        
        if isMutating {
            loadingView.startAnimating()
            statusLabel.text = "正在处理..."
            statusLabel.textColor = .systemBlue
        } else {
            loadingView.stopAnimating()
            statusLabel.text = "准备就绪"
            statusLabel.textColor = .systemGreen
        }
    }
    
    private func clearForm() {
        titleTextField.text = ""
        contentTextView.text = "帖子内容..."
        contentTextView.textColor = .placeholderText
    }
    
    private func showSuccessAlert(_ message: String) {
        showAlert(title: "成功", message: message)
    }
    
    private func showErrorAlert(_ message: String) {
        showAlert(title: "错误", message: message)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

@available(iOS 15.0, *)
extension UIKitMutationViewController: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "帖子内容..." {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "帖子内容..."
            textView.textColor = .placeholderText
        }
    }
} 