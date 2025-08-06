Pod::Spec.new do |spec|
  spec.name         = "ReactQueryForiOS"
  spec.version      = "1.0.0"
  spec.summary      = "一个类似 React Query 的 iOS Swift 库，提供强大的数据获取、缓存和状态管理功能"
  spec.description  = <<-DESC
  ReactQueryForiOS 是一个类似 React Query 的 iOS Swift 库，为 iOS 开发者提供强大的数据获取、缓存和状态管理功能。
  
  主要特性：
  - 智能缓存系统
  - 自动重试机制
  - 查询失效功能
  - 突变操作支持
  - SwiftUI 和 UIKit 集成
  - 类型安全
  - 完善的错误处理
  DESC

  spec.homepage     = "https://github.com/JKloveJK/ReactQueryForiOS"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "JKloveJK" => "your-email@example.com" }
  spec.platform     = :ios, "15.0"
  spec.source       = { :git => "https://github.com/JKloveJK/ReactQueryForiOS.git", :tag => "#{spec.version}" }

  spec.source_files = "ReactQueryForiOS/Sources/**/*.swift"
  spec.exclude_files = [
    "ReactQueryForiOS/Sources/Demo/**/*",
    "ReactQueryForiOS/Tests/**/*"
  ]

  spec.swift_version = "5.7"
  
  spec.frameworks = "Foundation", "Combine", "SwiftUI"
  

end 