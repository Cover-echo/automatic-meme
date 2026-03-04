# Git 使用指南 - 眨眼检测器项目

## 📚 基础命令

### 查看状态
```bash
git status
```

### 查看提交历史
```bash
git log --oneline
```

### 查看详细历史
```bash
git log
```

## 🔄 版本回滚

### 查看某个版本的文件
```bash
git checkout <commit-hash>
```

### 回到最新状态
```bash
git checkout main
```

### 撤销文件修改
```bash
git checkout -- <file>
```

### 回滚到某个版本
```bash
git reset --hard <commit-hash>
```

## 🌿 分支管理

### 创建分支
```bash
git branch <branch-name>
```

### 切换分支
```bash
git checkout <branch-name>
```

### 查看分支
```bash
git branch
```

### 删除分支
```bash
git branch -d <branch-name>
```

## 📸 快照与备份

### 手动快照（推荐）
```bash
./snapshot.sh "添加了新功能"
```

### 自动备份
```bash
./auto-backup.sh
```

### 查看所有标签
```bash
git tag
```

### 查看特定标签
```bash
git show snapshot-20260304-1200
```

## 🔍 查看差异

### 查看工作区与暂存区的差异
```bash
git diff
```

### 查看暂存区与最新提交的差异
```bash
git diff --cached
```

### 查看两个版本的差异
```bash
git diff <commit1> <commit2>
```

## 📦 常用场景

### 添加新文件
```bash
git add <file>
git commit -m "添加新文件"
```

### 修改已有文件
```bash
git add <file>
git commit -m "修改描述"
```

### 查看某个文件的历史
```bash
git log -- <file>
```

### 恢复误删的文件
```bash
git checkout HEAD -- <file>
```

## 🏷️ 标签管理

### 创建标签
```bash
git tag v1.0.0
```

### 删除标签
```bash
git tag -d v1.0.0
```

### 推送标签到远程
```bash
git push origin --tags
```

## ⚠️ 注意事项

1. **提交前检查**: 使用 `git status` 确认要提交的文件
2. **提交信息**: 写清楚修改内容，方便日后查找
3. **定期备份**: 使用 `./snapshot.sh` 创建重要节点的快照
4. **谨慎回滚**: `git reset --hard` 会永久删除提交，使用前请确认

## 🚀 快速开始

```bash
# 1. 查看当前状态
git status

# 2. 添加修改
git add .

# 3. 提交
git commit -m "修改说明"

# 4. 创建快照标签
./snapshot.sh "完成 XX 功能"
```

---

**项目位置**: `/Users/shumizu/.openclaw/workspace`  
**初始提交**: 眨眼检测器项目  
**备份策略**: 自动备份 + 手动快照
