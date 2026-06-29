# herness 通用智能体驾驭系统

> 用 **驾驭工程（Harness Engineering）** 的方式开发：人类掌舵，智能体执行。

前后端分离的量化交易研究与执行平台。

- **前端**：React + Ant Design（Vite + TypeScript strict）
- **后端**：Python + FastAPI（Ruff + mypy strict + import-linter 分层）
- **仓库**：monorepo

## 驾驭层（这是本项目的核心）

本项目不是从"写业务代码"开始，而是先搭好**驾驭层**——让 AI 智能体在约束里可靠地写代码。三维度：

| 维度 | 落地 |
|------|------|
| 上下文工程 | `AGENTS.md`（根 + 前后端）、`docs/`、`PROGRESS.md` |
| 架构约束 | 前端 ESLint/Prettier/TS strict/dependency-cruiser；后端 Ruff/mypy/import-linter；pre-commit + CI |
| 熵管理 | `scripts/entropy-gardener.sh`、`docs/harness/failure-log.md`、`PROGRESS.md` |

核心原则：**智能体每次犯错，都工程化为一条永久约束。** 修环境，不换模型。

详见 [AGENTS.md](AGENTS.md)。

## 目录结构

```
herness-trading-system/
├── AGENTS.md            # 驾驭层主指令
├── PROGRESS.md          # 跨 session 状态
├── docs/                # 架构 / 地图 / 踩坑记录
├── frontend/            # React + AntD
├── backend/             # Python + FastAPI
├── .github/workflows/   # CI 验证门
├── scripts/             # 熵管理脚本
└── .cursor/rules/       # Cursor 持久规则
```

## 快速开始

### 后端

```bash
cd backend
python -m venv .venv && source .venv/bin/activate   # 或 uv venv && source .venv/bin/activate
pip install -e ".[dev]"                               # 或 uv sync --extra dev
pytest -q                                             # 测试
uvicorn app.main:app --reload                         # 启动
```

### 前端

```bash
cd frontend
pnpm install
pnpm dev          # 开发服务器
pnpm test         # 测试
```

### 驾驭层巡检

```bash
bash scripts/entropy-gardener.sh          # 熵管理巡检
pre-commit run --all-files                # 提交前检查（需先 pre-commit install）
```

## 给 AI 智能体的说明

如果你是接手本项目的 AI 智能体：**请先读 [AGENTS.md](AGENTS.md)，再读 [PROGRESS.md](PROGRESS.md)。** 然后按 AGENTS.md 的"开工前必做"执行。

## 状态

阶段 1：驾驭层骨架 ✅（业务代码待在约束下逐步生成）
