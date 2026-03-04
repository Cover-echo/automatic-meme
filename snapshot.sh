#!/bin/bash
cd /Users/shumizu/.openclaw/workspace
MESSAGE="${1:-Manual snapshot}"
git add .
git commit -m "$MESSAGE"
git tag snapshot-$(date +%Y%m%d-%H%M)
echo "✅ 快照已创建：snapshot-$(date +%Y%m%d-%H%M)"
