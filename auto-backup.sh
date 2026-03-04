#!/bin/bash
cd /Users/shumizu/.openclaw/workspace
git add .
git commit -m "Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
git tag backup-$(date +%Y%m%d-%H%M)
