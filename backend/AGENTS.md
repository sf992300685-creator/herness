# backend/AGENTS.md — 后端局部指令

> 改后端任何代码前先读本文件。本文件是索引，深层规范在 [../docs/](../docs/)。

## 技术栈

- **Python 3.12+** + **FastAPI**
- 约束链：**Ruff**（lint + format）+ **mypy**（strict）+ **import-linter**（分层依赖）+ **pytest** + pre-commit + CI
- 依赖管理：`pyproject.toml`（推荐用 `uv` 或 `pip` + venv）

## 目录约定

```
backend/app/
├── main.py           ← FastAPI 应用入口（只做装配，不写业务）
├── api/              ← 路由层：接收请求、校验、调用 services、返回响应
├── services/         ← 业务逻辑层：编排领域行为，可读写 DB / 发外部调用
├── models/           ← 数据模型（ORM 模型、领域实体、DTO）
├── logic/       ← 量化策略：纯计算，不碰 IO
├── validators/         ← 回测引擎：策略验证门
└── core/             ← 横切关注点：config、安全、日志、依赖注入
```

## 分层规则（import-linter 强制）

依赖只能**向下**，禁止反向、禁止循环：

```
api  →  services  →  models
                ↘   strategies  →  models
                ↘   backtest    →  strategies, models
core ←  被各层依赖
```

- `api/` → 可依赖 `services/` `models/` `core/`，**禁止**直接操作 DB session 之外的 IO 逻辑写在 api 里
- `services/` → 可依赖 `models/` `logic/` `validators/` `core/`
- `logic/` → 只能依赖 `models/`，**禁止**依赖 `services/` `api/`，**禁止**做任何 IO（不发请求、不读写 DB）
- `validators/` → 可依赖 `logic/` `models/`
- 任何层禁止循环依赖

> 为什么：策略必须是**纯函数式**的可验证单元——同样的输入永远产出同样的信号。一旦策略层混入 IO，回测就不可复现，量化系统的可信度归零。

## 硬性约定

- **类型注解必填**：所有函数签名、路由、模型都要类型注解，mypy strict 必须 0 报错。
- **策略零 IO**：`logic/` 里不准出现 `requests`、`httpx`、DB 调用、`asyncio` 网络。策略输入是数据，输出是信号。
- **回测门**：任何策略改动或新增策略，必须通过 `validators/` 的回测用例才能合并。回测即测试。
- **配置走 core**：密钥、连接串、外部地址一律从环境变量读，经 `app/core/config.py`（pydantic-settings）集中管理。禁止散落硬编码。
- **路由要测试**：每个 API 端点至少一个 happy-path + 一个错误-path 的 pytest 用例（用 FastAPI TestClient）。

## 本地命令

```bash
cd backend
uv sync                     # 或 python -m venv .venv && pip install -e .
pytest -q                   # 跑测试
ruff check .                # lint
ruff format --check .       # 格式检查
mypy app                    # 类型检查
lint-imports                # import-linter 分层检查
```

## 禁区

- ❌ 不要在 `logic/` 里做任何 IO。
- ❌ 不要让 `models/` 反向依赖 `services/` 或 `api/`。
- ❌ 不要用 `# type: ignore` 绕过 mypy——必须记 [../docs/harness/failure-log.md](../docs/harness/failure-log.md) 说明理由。
- ❌ 不要在代码里硬编码密钥/连接串。
- ❌ 不要跳过回测门直接改策略。

## 索引

- 整体架构与分层动机 → [../docs/architecture.md](../docs/architecture.md)
- 模块职责 → [../docs/project-map.md](../docs/project-map.md)
- 踩坑记录 → [../docs/harness/failure-log.md](../docs/harness/failure-log.md)
- 全局工作约定 → [../AGENTS.md](../AGENTS.md)
