# 🐾 小爪的桌宠 (Desktop Pet)

一个可爱的 macOS 桌面宠物，可以实时连接到 OpenClaw！

## ✨ 功能

- 🎨 可爱的粉色小动物形象
- 💬 实时显示 OpenClaw 会话消息
- 📍 可拖动到桌面任意位置
- 🔝 始终置顶，透明背景
- 👀 自动眨眼、挥手等动画
- 🔗 连接状态指示器

## 🚀 启动方式

```bash
cd desktop-pet
npm start
```

## 🎮 交互

- **点击宠物**：挥手打招呼，检查 OpenClaw 连接
- **拖动宠物**：移动到桌面任意位置
- **悬停显示控制按钮**：关闭/最小化窗口
- **自动轮询**：每 10 秒检查一次 OpenClaw 消息

## 🔧 自定义

### 修改宠物外观

编辑 `index.html` 中的 SVG 部分，可以改变：
- 颜色（fill 属性）
- 大小（viewBox 和容器尺寸）
- 表情（眼睛、嘴巴的路径）

### 修改轮询间隔

在 `index.html` 底部找到：
```javascript
setInterval(fetchMessages, 10000);  // 改为其他毫秒数
```

### 添加更多动画

在 CSS 中添加新的 `@keyframes` 动画，然后通过 JavaScript 切换 class。

## 📝 技术栈

- Electron (桌面应用框架)
- SVG (宠物渲染)
- OpenClaw CLI (会话连接)

## ⚠️ 注意事项

1. 需要先安装 OpenClaw 并登录
2. 宠物会每 10 秒调用一次 `openclaw sessions_list`
3. 关闭宠物请点击右上角的 ✕ 按钮

## 🎨 未来计划

- [ ] 支持 Lottie 动画
- [ ] 更多表情和状态
- [ ] 语音交互
- [ ] 自定义宠物皮肤
- [ ] 直接发送消息到 OpenClaw

---

Made with 💖 by 小爪 (Xiǎo Zhuǎ)
