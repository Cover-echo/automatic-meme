#!/bin/bash
# 从多个国内源尝试下载 MediaPipe 库
# 优先级：BootCDN > 七牛云 > 直接 npm 包

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/mediapipe-libs"

echo "📦 开始下载 MediaPipe 库到本地..."
echo "📁 目标目录：$LIB_DIR"
mkdir -p "$LIB_DIR"

# 尝试多个源
declare -A SOURCES
SOURCES=(
  ["face_mesh"]="https://cdn.bootcdn.net/ajax/libs/mediapipe/0.4.1633559619/face_mesh.js"
  ["camera_utils"]="https://cdn.bootcdn.net/ajax/libs/mediapipe/0.3.1628249851/camera_utils.js"
  ["drawing_utils"]="https://cdn.bootcdn.net/ajax/libs/mediapipe/0.3.1628249851/drawing_utils.js"
)

download_with_fallback() {
  local name=$1
  local output=$2
  shift 2
  local urls=("$@")
  
  for url in "${urls[@]}"; do
    echo "  尝试：$url"
    if curl -L -o "$output" --silent --connect-timeout 10 --speed-time 15 --speed-limit 500 "$url"; then
      # 验证文件大小（至少要有几 KB）
      local size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null || echo 0)
      if [ "$size" -gt 1000 ]; then
        return 0
      fi
    fi
  done
  return 1
}

echo ""
echo "⬇️  下载 face_mesh.js..."
if download_with_fallback "face_mesh" "$LIB_DIR/face_mesh.js" \
  "https://cdn.bootcdn.net/ajax/libs/mediapipe/0.4.1633559619/face_mesh.js" \
  "https://cdn.staticfile.org/mediapipe/0.4.1633559619/face_mesh.js" \
  "https://lib.baomitu.com/mediapipe/0.4.1633559619/face_mesh.js"; then
  echo "  ✓ face_mesh.js 下载成功"
else
  echo "  ✗ face_mesh.js 所有源均失败"
fi

echo ""
echo "⬇️  下载 camera_utils.js..."
if download_with_fallback "camera_utils" "$LIB_DIR/camera_utils.js" \
  "https://cdn.bootcdn.net/ajax/libs/mediapipe/0.3.1628249851/camera_utils.js" \
  "https://cdn.staticfile.org/mediapipe/0.3.1628249851/camera_utils.js" \
  "https://lib.baomitu.com/mediapipe/0.3.1628249851/camera_utils.js"; then
  echo "  ✓ camera_utils.js 下载成功"
else
  echo "  ✗ camera_utils.js 所有源均失败"
fi

echo ""
echo "⬇️  下载 drawing_utils.js..."
if download_with_fallback "drawing_utils" "$LIB_DIR/drawing_utils.js" \
  "https://cdn.bootcdn.net/ajax/libs/mediapipe/0.3.1628249851/drawing_utils.js" \
  "https://cdn.staticfile.org/mediapipe/0.3.1628249851/drawing_utils.js" \
  "https://lib.baomitu.com/mediapipe/0.3.1628249851/drawing_utils.js"; then
  echo "  ✓ drawing_utils.js 下载成功"
else
  echo "  ✗ drawing_utils.js 所有源均失败"
fi

echo ""
echo "📊 文件验证："
for file in face_mesh.js camera_utils.js drawing_utils.js; do
  if [ -f "$LIB_DIR/$file" ]; then
    size=$(ls -lh "$LIB_DIR/$file" | awk '{print $5}')
    echo "  $file: $size"
  else
    echo "  $file: 不存在"
  fi
done

echo ""
echo "✅ 下载完成！"
