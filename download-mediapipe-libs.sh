#!/bin/bash

# MediaPipe 库下载脚本
# 用于下载屏幕检测器所需的依赖库到本地

LIB_DIR="$(cd "$(dirname "$0")" && pwd)/mediapipe-libs"
mkdir -p "$LIB_DIR"

echo "📦 开始下载 MediaPipe 库..."
echo "📁 保存目录：$LIB_DIR"
echo ""

# 库列表和版本
declare -A LIBS=(
    ["face_mesh.js"]="https://cdn.jsdelivr.net/npm/@mediapipe/face_mesh@0.4.1633559619/face_mesh.js"
    ["camera_utils.js"]="https://cdn.jsdelivr.net/npm/@mediapipe/camera_utils@0.3.1628249851/camera_utils.js"
    ["drawing_utils.js"]="https://cdn.jsdelivr.net/npm/@mediapipe/drawing_utils@0.3.1628249851/drawing_utils.js"
)

# 备用 CDN
declare -A BACKUP_CDNS=(
    ["face_mesh.js"]="https://unpkg.com/@mediapipe/face_mesh@0.4.1633559619/face_mesh.js"
    ["camera_utils.js"]="https://unpkg.com/@mediapipe/camera_utils@0.3.1628249851/camera_utils.js"
    ["drawing_utils.js"]="https://unpkg.com/@mediapipe/drawing_utils@0.3.1628249851/drawing_utils.js"
)

download_with_retry() {
    local filename=$1
    local url=$2
    local backup_url=$3
    local output="$LIB_DIR/$filename"
    
    echo "⬇️  下载 $filename..."
    
    # 尝试主 CDN
    if curl -L -s --connect-timeout 30 --max-time 120 -o "$output" "$url"; then
        if [ -s "$output" ]; then
            size=$(wc -c < "$output" | xargs)
            echo "   ✓ 下载成功 ($size bytes)"
            return 0
        fi
    fi
    
    # 尝试备用 CDN
    echo "   ⚠️  主 CDN 失败，尝试备用源..."
    if curl -L -s --connect-timeout 30 --max-time 120 -o "$output" "$backup_url"; then
        if [ -s "$output" ]; then
            size=$(wc -c < "$output" | xargs)
            echo "   ✓ 下载成功 (备用源，$size bytes)"
            return 0
        fi
    fi
    
    echo "   ❌ 下载失败"
    return 1
}

# 下载所有库
failed=0
for filename in "${!LIBS[@]}"; do
    if ! download_with_retry "$filename" "${LIBS[$filename]}" "${BACKUP_CDNS[$filename]}"; then
        ((failed++))
    fi
done

echo ""
echo "================================"
if [ $failed -eq 0 ]; then
    echo "✅ 所有库下载完成！"
    echo ""
    echo "📋 文件列表:"
    ls -lh "$LIB_DIR"
    echo ""
    echo "💡 使用方法:"
    echo "   1. 打开 screen-detector.html"
    echo "   2. 或者运行：node start-server.js"
else
    echo "⚠️  $failed 个库下载失败，请检查网络连接"
    echo ""
    echo "💡 建议:"
    echo "   - 检查网络连接"
    echo "   - 暂时关闭代理/VPN"
    echo "   - 使用 CDN 版本（HTML 已包含回退方案）"
fi
echo "================================"
