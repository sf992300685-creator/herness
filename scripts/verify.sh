#!/usr/bin/env bash
# 全量验证门：前端 + 后端 lint/类型/分层/测试。
# 这是"验证→自修回路"的核心：驱动器跑这个，失败就把输出回传 agent 自修，通过才能 commit。
# 用法：bash scripts/verify.sh
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
fail=0

run() {
  echo ""
  echo "==> $*"
  if "$@"; then
    echo "  ✓ ok"
  else
    echo "  ✗ FAIL: $*"
    fail=1
  fi
}

echo "=== 前端 ==="
if [[ -d frontend/node_modules ]]; then
  run bash -c 'cd frontend && pnpm lint'
  run bash -c 'cd frontend && pnpm check:types'
  run bash -c 'cd frontend && pnpm check:deps'
  run bash -c 'cd frontend && pnpm test:run'
else
  echo "  ⚠ 前端依赖未装，跳过（先：cd frontend && pnpm install）"
fi

echo ""
echo "=== 后端 ==="
if [[ -d backend/.venv ]]; then
  run bash -c 'cd backend && uv run ruff check .'
  run bash -c 'cd backend && uv run ruff format --check .'
  run bash -c 'cd backend && uv run mypy app'
  run bash -c 'cd backend && uv run lint-imports'
  run bash -c 'cd backend && uv run pytest -q'
else
  echo "  ⚠ 后端依赖未装，跳过（先：cd backend && uv sync --extra dev）"
fi

echo ""
if [[ $fail -eq 0 ]]; then
  echo "✅ verify 全绿——可以 commit"
else
  echo "❌ verify 有失败——驱动器应把上面错误回传 agent 自修后重跑"
fi
exit $fail
