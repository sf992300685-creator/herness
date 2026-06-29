#!/usr/bin/env bash
# session 收尾检查：确认状态文件在位、工作树是否干净。
# 用法：bash scripts/session-checkpoint.sh
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
ok=0

echo "=== 关键文件在位 ==="
for f in AGENTS.md PROGRESS.md docs/sprint-backlog.md docs/product-spec.md docs/harness/failure-log.md; do
  if [[ -f "$f" ]]; then echo "  ✓ $f"; else echo "  ✗ 缺 $f"; ok=1; fi
done

echo ""
echo "=== 工作树 ==="
if git diff --quiet && git diff --cached --quiet; then
  echo "  ✓ 干净（已提交）"
else
  echo "  ⚠ 有未提交改动——记得小步 commit，并同步更新 PROGRESS.md 与 sprint-backlog 状态"
fi

echo ""
echo "=== 是否有 🔄 doing 残留 ==="
if grep -qE '^### S[0-9].*\| 🔄' docs/sprint-backlog.md 2>/dev/null; then
  echo "  ⚠ 有 doing 状态残留，收尾前应置为 ✅ 或回退 📋"
  ok=1
else
  echo "  ✓ 无残留"
fi

echo ""
if [[ $ok -eq 0 ]]; then echo "✅ checkpoint 就绪"; else echo "⚠ checkpoint 有待处理项"; fi
exit $ok
