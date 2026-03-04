#!/bin/bash

# ScreenDetector 快速启动脚本

echo "🚀 正在打开 ScreenDetector 项目..."
echo ""

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误：未找到 Xcode"
    echo "请先安装 Xcode 或 Xcode Command Line Tools"
    echo "运行：xcode-select --install"
    exit 1
fi

# 检查 Xcode 版本
XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo "✅ Xcode 版本：$XCODE_VERSION"
echo ""

# 打开项目
PROJECT_PATH="$(cd "$(dirname "$0")" && pwd)/ScreenDetector.xcodeproj"

if [ -d "$PROJECT_PATH" ]; then
    echo "📂 项目路径：$PROJECT_PATH"
    echo ""
    echo "🔧 正在 Xcode 中打开项目..."
    open "$PROJECT_PATH"
    echo ""
    echo "✅ 项目已在 Xcode 中打开！"
    echo ""
    echo "📝 下一步："
    echo "   1. 在 Xcode 中选择您的设备或模拟器"
    echo "   2. 配置签名（选择您的开发团队）"
    echo "   3. 点击运行按钮 (⌘R)"
    echo "   4. 在设备上允许摄像头权限"
    echo ""
    echo "📖 详细说明请查看 README.md"
else
    echo "❌ 错误：找不到项目文件"
    echo "路径：$PROJECT_PATH"
    exit 1
fi
