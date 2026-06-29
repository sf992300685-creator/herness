#!/usr/bin/env bash
# session 启动仪式：打印当前状态，让任意新 session 无状态接续。
# 用法：bash scripts/session-start.sh
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

echo "########## herness session 启动 ##########"
echo ""
echo "=== git 最近 5 条提交 ==="
git log --oneline -5 2>/dev/null || echo "(无提交)"
echo ""
echo "=== PROGRESS.md（前 40 行）==="
sed -n '1,40p' PROGRESS.md 2>/dev/null || echo "(无 PROGRESS.md)"
echo ""
echo "=== 可取用的 sprint（📋 ready）==="
grep -nE '^### S[0-9].*\| 📋' docs/sprint-backlog.md 2>/dev/null || echo "(无 ready sprint)"
echo ""
echo "=== 人类审批门（⛔ blocked，禁止自动取用）==="
grep -nE '^### S[0-9].*\| ⛔' docs/sprint-backlog.md 2>/dev/null || echo "(无)"
echo ""
echo "=== 工作树状态 ==="
git status --short
echo ""
echo "下一步：取第一个 📋 sprint（depends-on 全 ✅），按 docs/harness/driver-prompt.md 执行。"
