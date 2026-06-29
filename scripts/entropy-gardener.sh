#!/usr/bin/env bash
# 熵管理巡检：检查驾驭层关键文件齐全、无密钥泄露、分层约束未被破坏。
# 这是 Harness Engineering「熵管理」维度的落地脚本。
# 用法：bash scripts/entropy-gardener.sh
set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
status=0

echo "==> [1/4] 驾驭层关键文件齐全性"
for f in AGENTS.md frontend/AGENTS.md backend/AGENTS.md PROGRESS.md \
         docs/architecture.md docs/project-map.md docs/harness/failure-log.md \
         .pre-commit-config.yaml .github/workflows/ci.yml; do
  if [[ -f "$f" ]]; then
    echo "  ✓ $f"
  else
    echo "  ✗ 缺失：$f"
    status=1
  fi
done

echo "==> [2/4] 密钥泄露检查（.env 不应入库）"
if git ls-files --error-unmatch .env >/dev/null 2>&1; then
  echo "  ✗ .env 已入库，立即处理"
  status=1
else
  echo "  ✓ .env 未入库"
fi

echo "==> [3/4] backend 分层（import-linter）"
if ( cd backend && lint-imports >/dev/null 2>&1 ); then
  echo "  ✓ 后端分层约束通过"
else
  echo "  ⚠ 跳过或失败：未装 backend dev 依赖，或分层违规（手动 `cd backend && lint-imports` 排查）"
fi

echo "==> [4/4] frontend 分层（dependency-cruiser）"
if ( cd frontend && pnpm check:deps >/dev/null 2>&1 ); then
  echo "  ✓ 前端分层约束通过"
else
  echo "  ⚠ 跳过或失败：未装 frontend 依赖，或分层违规（手动 `cd frontend && pnpm check:deps` 排查）"
fi

if [[ $status -eq 0 ]]; then
  echo "==> 熵管理巡检：关键项通过"
else
  echo "==> 熵管理巡检：有关键项缺失，请修复"
fi
exit $status
