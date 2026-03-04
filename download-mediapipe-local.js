/**
 * 从国内 CDN 下载 MediaPipe 库到本地
 * 使用 BootCDN (bootcdn.net) - 国内访问速度快
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');

const LIB_DIR = path.join(__dirname, 'mediapipe-libs');

// 确保目录存在
if (!fs.existsSync(LIB_DIR)) {
  fs.mkdirSync(LIB_DIR, { recursive: true });
}

// 库列表（使用 BootCDN 国内源）
const libraries = [
  {
    name: 'face_mesh.js',
    url: 'https://cdn.bootcdn.net/ajax/libs/mediapipe/0.4.1633559619/face_mesh.js',
    fallback: [
      'https://lib.baomitu.com/mediapipe/0.4.1633559619/face_mesh.js',
      'https://cdn.staticfile.org/mediapipe/0.4.1633559619/face_mesh.js'
    ]
  },
  {
    name: 'camera_utils.js',
    url: 'https://cdn.bootcdn.net/ajax/libs/mediapipe/0.3.1628249851/camera_utils.js',
    fallback: [
      'https://lib.baomitu.com/mediapipe/0.3.1628249851/camera_utils.js',
      'https://cdn.staticfile.org/mediapipe/0.3.1628249851/camera_utils.js'
    ]
  },
  {
    name: 'drawing_utils.js',
    url: 'https://cdn.bootcdn.net/ajax/libs/mediapipe/0.3.1628249851/drawing_utils.js',
    fallback: [
      'https://lib.baomitu.com/mediapipe/0.3.1628249851/drawing_utils.js',
      'https://cdn.staticfile.org/mediapipe/0.3.1628249851/drawing_utils.js'
    ]
  }
];

function downloadFile(url, outputPath) {
  return new Promise((resolve, reject) => {
    console.log(`  下载：${url}`);
    
    const client = url.startsWith('https') ? https : http;
    
    const request = client.get(url, {
      timeout: 30000,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
      }
    }, (response) => {
      if (response.statusCode === 200) {
        const file = fs.createWriteStream(outputPath);
        response.pipe(file);
        
        file.on('finish', () => {
          file.close();
          const stats = fs.statSync(outputPath);
          console.log(`  ✓ 完成：${(stats.size / 1024).toFixed(2)} KB`);
          resolve(stats.size);
        });
      } else {
        console.log(`  ✗ 失败：HTTP ${response.statusCode}`);
        reject(new Error(`HTTP ${response.statusCode}`));
      }
    });
    
    request.on('error', (err) => {
      console.log(`  ✗ 错误：${err.message}`);
      reject(err);
    });
    
    request.on('timeout', () => {
      request.destroy();
      reject(new Error('Timeout'));
    });
  });
}

async function downloadWithFallback(lib) {
  const outputPath = path.join(LIB_DIR, lib.name);
  
  // 尝试主源
  try {
    const size = await downloadFile(lib.url, outputPath);
    if (size > 1000) {
      return true;
    }
  } catch (e) {
    console.log(`  尝试备用源...`);
  }
  
  // 尝试备用源
  for (const fallbackUrl of lib.fallback) {
    try {
      const size = await downloadFile(fallbackUrl, outputPath);
      if (size > 1000) {
        return true;
      }
    } catch (e) {
      continue;
    }
  }
  
  return false;
}

async function main() {
  console.log('📦 开始下载 MediaPipe 库到本地...\n');
  
  let successCount = 0;
  
  for (const lib of libraries) {
    console.log(`⬇️  下载 ${lib.name}...`);
    
    const success = await downloadWithFallback(lib);
    
    if (success) {
      successCount++;
      const stats = fs.statSync(path.join(LIB_DIR, lib.name));
      console.log(`  ✅ ${lib.name} 下载成功 (${(stats.size / 1024).toFixed(2)} KB)\n`);
    } else {
      console.log(`  ❌ ${lib.name} 下载失败\n`);
    }
  }
  
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`下载完成：${successCount}/${libraries.length} 个文件`);
  
  if (successCount === libraries.length) {
    console.log('\n🎉 所有库文件下载成功！');
    console.log(`📁 位置：${LIB_DIR}`);
  } else {
    console.log('\n⚠️  部分文件下载失败，请检查网络连接');
  }
}

main().catch(console.error);
