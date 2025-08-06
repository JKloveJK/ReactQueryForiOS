# 发布指南

本指南将详细介绍如何将 ReactQueryForiOS 库发布到 CocoaPods 和 Swift Package Manager。

## 发布到 CocoaPods

### 1. 准备工作

确保您已经完成了以下准备工作：

- [ ] 更新版本号
- [ ] 更新 CHANGELOG.md
- [ ] 运行测试确保所有测试通过
- [ ] 检查 podspec 文件配置

### 2. 验证 podspec

在发布之前，验证 podspec 文件：

```bash
# 验证 podspec 语法
pod spec lint ReactQueryForiOS.podspec

# 验证 podspec 并检查警告
pod spec lint ReactQueryForiOS.podspec --allow-warnings

# 验证 podspec 并检查网络
pod spec lint ReactQueryForiOS.podspec --allow-warnings --verbose
```

### 3. 创建 Git 标签

```bash
# 创建并推送标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 4. 发布到 CocoaPods

```bash
# 发布到 CocoaPods
pod trunk push ReactQueryForiOS.podspec --allow-warnings
```

### 5. 验证发布

发布后，验证库是否可用：

```bash
# 搜索库
pod search ReactQueryForiOS

# 检查库信息
pod spec cat ReactQueryForiOS
```

## 发布到 Swift Package Manager

### 1. 更新 Package.swift

确保 Package.swift 文件配置正确：

```swift
// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ReactQueryForiOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ReactQueryForiOS",
            targets: ["ReactQueryForiOS"])
    ],
    targets: [
        .target(
            name: "ReactQueryForiOS",
            dependencies: [],
            exclude: [
                "Demo",
                "Tests"
            ])
    ]
)
```

### 2. 创建 GitHub Release

1. 在 GitHub 上创建新的 Release
2. 使用语义化版本号（如 v1.0.0）
3. 添加详细的发布说明
4. 上传编译好的二进制文件（可选）

### 3. 验证 SPM 集成

```bash
# 测试 SPM 集成
swift package resolve
swift package test
```

## 版本管理

### 语义化版本

遵循语义化版本规范：

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

### 版本号更新

在发布新版本时，需要更新以下文件：

1. **ReactQueryForiOS.podspec**
   ```ruby
   spec.version = "1.0.0"
   ```

2. **Package.swift**
   ```swift
   // 版本号在 Git 标签中管理
   ```

3. **CHANGELOG.md**
   ```markdown
   ## [1.0.0] - 2024-01-01
   
   ### Added
   - 初始版本发布
   - 基本查询功能
   - SwiftUI 和 UIKit 支持
   ```

## 发布检查清单

### 发布前检查

- [ ] 所有测试通过
- [ ] 代码审查完成
- [ ] 文档更新完成
- [ ] 版本号更新
- [ ] CHANGELOG 更新
- [ ] podspec 验证通过
- [ ] 示例项目测试通过

### 发布后检查

- [ ] CocoaPods 搜索可用
- [ ] SPM 集成正常
- [ ] 示例项目编译通过
- [ ] 文档链接正确
- [ ] GitHub Release 创建

## 故障排除

### CocoaPods 发布问题

1. **验证失败**
   ```bash
   # 检查具体错误
   pod spec lint ReactQueryForiOS.podspec --verbose
   
   # 修复问题后重新验证
   pod spec lint ReactQueryForiOS.podspec --allow-warnings
   ```

2. **发布失败**
   ```bash
   # 检查网络连接
   pod trunk info
   
   # 重新发布
   pod trunk push ReactQueryForiOS.podspec --allow-warnings
   ```

### SPM 发布问题

1. **包解析失败**
   ```bash
   # 清理缓存
   swift package clean
   swift package reset
   
   # 重新解析
   swift package resolve
   ```

2. **编译错误**
   ```bash
   # 检查依赖
   swift package show-dependencies
   
   # 重新编译
   swift build
   ```

## 自动化发布

### GitHub Actions

创建 `.github/workflows/release.yml` 文件：

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test
        run: |
          swift test
          pod spec lint ReactQueryForiOS.podspec --allow-warnings

  release:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Release to CocoaPods
        run: |
          gem install cocoapods
          pod trunk push ReactQueryForiOS.podspec --allow-warnings
```

### 脚本化发布

创建 `scripts/release.sh` 脚本：

```bash
#!/bin/bash

# 检查参数
if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

VERSION=$1

# 更新版本号
sed -i '' "s/spec.version.*=.*\".*\"/spec.version = \"$VERSION\"/" ReactQueryForiOS.podspec

# 运行测试
swift test

# 验证 podspec
pod spec lint ReactQueryForiOS.podspec --allow-warnings

# 创建标签
git add .
git commit -m "Release version $VERSION"
git tag -a v$VERSION -m "Release version $VERSION"
git push origin main
git push origin v$VERSION

# 发布到 CocoaPods
pod trunk push ReactQueryForiOS.podspec --allow-warnings

echo "Release $VERSION completed!"
```

## 维护指南

### 定期维护

1. **依赖更新**
   ```bash
   # 检查过时的依赖
   pod outdated
   
   # 更新依赖
   pod update
   ```

2. **文档更新**
   - 更新 README.md
   - 更新示例代码
   - 更新 API 文档

3. **问题修复**
   - 监控 GitHub Issues
   - 及时响应用户反馈
   - 修复已知问题

### 长期支持

1. **版本支持策略**
   - 主版本：支持 2 年
   - 次版本：支持 1 年
   - 修订版本：支持 6 个月

2. **安全更新**
   - 及时修复安全漏洞
   - 发布安全补丁版本
   - 通知用户安全更新

## 联系信息

如果您在发布过程中遇到问题，请：

1. 检查 [GitHub Issues](https://github.com/JKloveJK/ReactQueryForiOS/issues)
2. 查看 [CocoaPods 文档](https://guides.cocoapods.org/)
3. 联系维护团队

## 许可证

本发布指南遵循 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。 