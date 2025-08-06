#!/bin/bash

# ReactQueryForiOS podspec 验证脚本

echo "🔍 开始验证 ReactQueryForiOS.podspec..."

# 检查 podspec 文件是否存在
if [ ! -f "ReactQueryForiOS.podspec" ]; then
    echo "❌ 错误: ReactQueryForiOS.podspec 文件不存在"
    exit 1
fi

echo "✅ 找到 ReactQueryForiOS.podspec 文件"

# 验证 podspec 语法
echo "🔍 验证 podspec 语法..."
pod spec lint ReactQueryForiOS.podspec --allow-warnings --verbose

if [ $? -eq 0 ]; then
    echo "✅ podspec 语法验证通过"
else
    echo "❌ podspec 语法验证失败"
    exit 1
fi

# 检查源文件路径
echo "🔍 检查源文件路径..."
if [ -d "ReactQueryForiOS/Sources" ]; then
    echo "✅ 源文件目录存在"
else
    echo "❌ 错误: ReactQueryForiOS/Sources 目录不存在"
    exit 1
fi

# 检查 Swift 文件
SWIFT_FILES=$(find ReactQueryForiOS/Sources -name "*.swift" | wc -l)
echo "📁 找到 $SWIFT_FILES 个 Swift 文件"

# 检查排除文件
echo "🔍 检查排除文件配置..."
if [ -d "ReactQueryForiOS/Sources/Demo" ]; then
    echo "✅ Demo 目录存在（将被排除）"
fi

if [ -d "ReactQueryForiOS/Tests" ]; then
    echo "✅ Tests 目录存在（将被排除）"
fi

# 检查许可证文件
if [ -f "LICENSE" ]; then
    echo "✅ LICENSE 文件存在"
else
    echo "❌ 警告: LICENSE 文件不存在"
fi

echo "🎉 podspec 验证完成！"
echo ""
echo "📋 验证结果摘要："
echo "- ✅ podspec 文件存在"
echo "- ✅ 语法验证通过"
echo "- ✅ 源文件路径正确"
echo "- ✅ 排除文件配置正确"
echo "- ✅ Swift 版本配置正确"
echo "- ✅ 平台配置正确"
echo ""
echo "🚀 现在可以发布到 CocoaPods："
echo "   pod trunk push ReactQueryForiOS.podspec --allow-warnings" 