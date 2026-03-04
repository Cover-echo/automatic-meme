#!/usr/bin/env node

/**
 * 屏幕检测器 - 本地服务器启动脚本
 * 
 * 使用方法:
 * 1. 确保已安装 Node.js
 * 2. 运行：node start-server.js
 * 3. 在浏览器打开：http://localhost:3000
 * 
 * 为什么需要本地服务器？
 * 现代浏览器出于安全考虑，要求摄像头权限只能在 HTTPS 或 localhost 环境下使用。
 * 直接双击打开 HTML 文件 (file:// 协议) 无法访问摄像头。
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const PORT = 3000;
const HTML_FILE = path.join(__dirname, 'screen-detector.html');

// 检查 HTML 文件是否存在
if (!fs.existsSync(HTML_FILE)) {
    console.error('❌ 错误：找不到 screen-detector.html 文件');
    console.error('请确保此脚本与 HTML 文件在同一目录下');
    process.exit(1);
}

// 创建 HTTP 服务器，支持静态文件服务
const server = http.createServer((req, res) => {
    const urlPath = req.url.split('?')[0]; // 移除查询参数
    
    // 主页面
    if (urlPath === '/' || urlPath === '/index.html') {
        fs.readFile(HTML_FILE, 'utf8', (err, data) => {
            if (err) {
                res.writeHead(500, { 'Content-Type': 'text/plain' });
                res.end('服务器错误：无法读取 HTML 文件');
                return;
            }
            res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
            res.end(data);
        });
        return;
    }
    
    // 静态文件服务（mediapipe-libs 目录）
    if (urlPath.startsWith('/mediapipe-libs/')) {
        const fileName = urlPath.replace('/mediapipe-libs/', '');
        const filePath = path.join(__dirname, 'mediapipe-libs', fileName);
        
        // 安全检查：防止目录遍历攻击
        const normalizedPath = path.normalize(filePath);
        const allowedDir = path.join(__dirname, 'mediapipe-libs');
        
        if (!normalizedPath.startsWith(allowedDir)) {
            res.writeHead(403, { 'Content-Type': 'text/plain' });
            res.end('403 - 禁止访问');
            return;
        }
        
        fs.readFile(normalizedPath, (err, data) => {
            if (err) {
                res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
                res.end(`404 - 文件不存在：${fileName}`);
                return;
            }
            
            // 设置正确的 Content-Type
            let contentType = 'application/javascript';
            if (fileName.endsWith('.css')) {
                contentType = 'text/css';
            } else if (fileName.endsWith('.wasm')) {
                contentType = 'application/wasm';
            } else if (fileName.endsWith('.data')) {
                contentType = 'application/octet-stream';
            } else if (fileName.endsWith('.binarypb')) {
                contentType = 'application/octet-stream';
            }
            
            res.writeHead(200, { 
                'Content-Type': contentType,
                'Cache-Control': 'no-cache' // 防止缓存，确保加载最新版本
            });
            res.end(data);
        });
        return;
    }
    
    // 其他路径返回 404
    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('404 - 页面未找到');
});

server.listen(PORT, 'localhost', () => {
    console.log('');
    console.log('✅ 服务器已启动！');
    console.log('');
    console.log(`📍 在浏览器中打开：http://localhost:${PORT}`);
    console.log('');
    console.log('💡 提示:');
    console.log('   - 按 Ctrl+C 停止服务器');
    console.log('   - 首次使用需要授予摄像头权限');
    console.log('');
    
    // 尝试自动打开浏览器
    const platform = process.platform;
    let openCommand;
    
    if (platform === 'darwin') {
        openCommand = `open http://localhost:${PORT}`;
    } else if (platform === 'win32') {
        openCommand = `start http://localhost:${PORT}`;
    } else {
        openCommand = `xdg-open http://localhost:${PORT}`;
    }
    
    exec(openCommand, (err) => {
        if (err) {
            console.log('🌐 请手动在浏览器中打开上面的地址');
        }
    });
});

server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
        console.error(`❌ 错误：端口 ${PORT} 已被占用`);
        console.error('请关闭占用该端口的程序，或修改脚本中的 PORT 值');
    } else {
        console.error('❌ 服务器错误:', err.message);
    }
    process.exit(1);
});
