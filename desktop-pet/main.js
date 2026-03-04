const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 300,
    height: 400,
    frame: false,  // 无边框
    transparent: true,  // 透明背景
    alwaysOnTop: true,  // 始终置顶
    skipTaskbar: true,  // 不显示在任务栏
    resizable: false,
    movable: true,  // 可拖动
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });

  mainWindow.loadFile('index.html');
  
  // 开发时打开 DevTools
  // mainWindow.webContents.openDevTools();
  
  // 防止窗口被调整大小
  mainWindow.setResizable(false);
  mainWindow.setMaximizable(false);
  mainWindow.setMinimizable(false);
  
  // 窗口始终在所有工作区显示
  mainWindow.setVisibleOnAllWorkspaces(true);
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// 监听来自渲染进程的关闭请求
ipcMain.on('close-window', () => {
  app.quit();
});

// 监听拖动窗口请求
ipcMain.on('minimize-window', () => {
  mainWindow.minimize();
});
