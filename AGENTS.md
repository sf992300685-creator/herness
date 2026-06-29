# AGENTS.md — herness 通用智能体驾驭系统 · 驾驭层主指令

> 本文件是 AI 智能体在本仓库工作的**入口索引**，不是百科全书。
> 它指向深层文档与约束配置，并规定"怎么工作"。智能体开工前必读。

## 一、这个项目是什么

**herness 通用智能体驾驭系统**：一个**个人自用的加密货币量化交易系统**（OKX，现货 + U本位永续）。
覆盖行情数据、策略开发、回测、风控、实盘交易、因子研究、前端看板。

- **前端**：React + Ant Design（Vite + TypeScript，strict 模式）
- **后端**：Python + FastAPI（Ruff + mypy strict + 分层依赖约束）

**"做什么"的细节看 [docs/product-spec.md](docs/product-spec.md)——那是产品范围的唯一事实来源。**
技术栈是**手段**，不是目的。目的是用**驾驭工程（Harness Engineering）**的方式开发：人类掌舵、智能体执行。

## 二、驾驭工程在本项目的运作方式

核心公式：`Agent = Model + Harness`。模型负责推理，**驾驭层**负责模型之外的一切。本仓库的驾驭层由三件事构成（见 [docs/architecture.md](docs/architecture.md) 详解）：

| 维度 | 落地位置 | 作用 |
|------|---------|------|
| **上下文工程** | 本文件 + 前后端 `AGENTS.md` + [docs/](docs/) | 给智能体正确、可检索的信息 |
| **架构约束** | `frontend/` 与 `backend/` 下的 lint/类型/分层配置 + `.pre-commit-config.yaml` + [.github/workflows/ci.yml](.github/workflows/ci.yml) | 让坏代码**机械上过不了**，不靠口头约定 |
| **熵管理** | [scripts/entropy-gardener.sh](scripts/entropy-gardener.sh) + [docs/harness/failure-log.md](docs/harness/failure-log.md) + [PROGRESS.md](PROGRESS.md) | 持续对抗文档腐烂、依赖漂移、状态丢失 |

**最高原则：智能体每次犯错，都应被工程化为一条永久约束。** 修环境，不换模型。详见 [docs/harness/failure-log.md](docs/harness/failure-log.md)。

## 三、仓库地图

```
herness-trading-system/
├── AGENTS.md              ← 你在这里：主指令索引
├── PROGRESS.md            ← 跨 session 状态持久化（开工先读）
├── .cursor/rules/         ← Cursor 持久规则
├── docs/
│   ├── architecture.md    ← 架构蓝图与分层规则
│   ├── project-map.md     ← 项目地图（模块职责）
│   └── harness/failure-log.md  ← 失败模式记录 → 永久约束
├── frontend/              ← React + AntD（自带 AGENTS.md）
├── backend/               ← Python + FastAPI（自带 AGENTS.md）
├── .github/workflows/ci.yml  ← CI 验证门
├── scripts/entropy-gardener.sh  ← 熵管理巡检
└── .pre-commit-config.yaml  ← 提交前机械拦截
```

## 四、开工前必做（session 启动仪式）

每次新 session 开始，按顺序执行：

1. **读** [PROGRESS.md](PROGRESS.md) —— 了解上次进行到哪、下一步是什么。
2. **读** 你要改动目录下的 `AGENTS.md`（改前端读 `frontend/AGENTS.md`，改后端读 `backend/AGENTS.md`）。
3. **读** [docs/harness/failure-log.md](docs/harness/failure-log.md) —— 别重蹈历史覆辙。
4. **跑一次基线测试**确认环境正常：
   - 前端：`cd frontend && pnpm test --run`
   - 后端：`cd backend && pytest -q`
5. 然后才开始编码。

> 这个流程让每个 session 都"无状态"——任何一个 session 崩溃，下一个都能从最近 commit + PROGRESS.md 无缝恢复。

## 五、工作约定（硬性）

- **改动前先读**：动任何模块前，先读该模块及其 `AGENTS.md`。
- **约束优先于意图**：lint/类型/分层规则报错时，**改代码去满足约束**，绝不放宽约束来迁就代码。约束要放宽，必须先在 [docs/harness/failure-log.md](docs/harness/failure-log.md) 记录理由。
- **小步提交**：每完成一个可验证的小步就 commit，commit message 描述"为什么"。Git 历史是状态持久层。
- **测试先行或同步**：新增功能必须带测试；修 bug 必须先写能复现的测试。量化策略改动必须过 [回测门](backend/app/validators/)。
- **不要绕过 CI**：本地提交前跑 `pre-commit run --all-files`。CI 红了不许合并。
- **文档随代码走**：改了公共接口/架构，同步改 [docs/project-map.md](docs/project-map.md)。过时文档是熵，会被熵管理脚本揪出来。

## 六、禁区（绝对不要做）

- ❌ 不要在 `backend/app/logic/` 里直接读写数据库或发网络请求——策略层必须通过 `services/` 层。分层由 import-linter 强制。
- ❌ 不要在 `frontend/src/` 里直接调 `fetch`/`axios` 访问后端——必须走 `services/` 封装的 API 客户端。
- ❌ 不要为让测试通过而删除或弱化已有测试断言。
- ❌ 不要提交真实密钥、API Key、账户凭证。配置走环境变量 + `backend/app/core/config.py`。
- ❌ 不要在量化策略里引入未经过回测验证的"优化"。

## 七、犯错时怎么办

1. 在 [docs/harness/failure-log.md](docs/harness/failure-log.md) 追加一条：**现象 / 根因 / 永久约束**。
2. 把那条"永久约束"落到机械可执行的地方——lint 规则、类型、CI 检查、或本文件的禁区。
3. 在 PROGRESS.md 记录这次教训。

> 每一次失败，都是 harness 的 bug，不是模型的 bug。修 harness，让它结构性不可能再犯。

## 八、长跑工作流（自治执行）

本驾驭层支持 agent 长时间自主跑，直到把项目落地。核心循环：

```
session-start.sh → 取下一个可取 sprint → 实现 → verify.sh → 失败自修(≤3轮) → commit + 更新状态 → 取下一个
```

关键产物：
- **任务来源**：[docs/sprint-backlog.md](docs/sprint-backlog.md) —— 永远知道下一步，⛔ 为人类审批门。
- **验证回路**：`bash scripts/verify.sh` —— 全量 lint/类型/分层/测试，失败回传自修。
- **状态持久化**：[PROGRESS.md](PROGRESS.md) + git 历史 —— 跨 session 接续。
- **驱动器指令**：[docs/harness/driver-prompt.md](docs/harness/driver-prompt.md) —— `/loop` 或 Automation 每 tick 发的循环指令。
- **仪式脚本**：`scripts/session-start.sh`（开工）、`scripts/session-checkpoint.sh`（收尾）。
- **熵管理**：`scripts/entropy-gardener.sh`（定期巡检）。

人类只在 ⛔ 审批门、反复失败、milestone review 介入；其余让 agent 自己跑。

## 九、索引：去哪里找什么

- 想了解整体架构与分层 → [docs/architecture.md](docs/architecture.md)
- 想知道"做什么"（产品范围/里程碑/风控）→ [docs/product-spec.md](docs/product-spec.md)
- 想知道下一步做什么（sprint 清单）→ [docs/sprint-backlog.md](docs/sprint-backlog.md)
- 想知道某模块职责 → [docs/project-map.md](docs/project-map.md)
- 想看前端的编码约束 → [frontend/AGENTS.md](frontend/AGENTS.md)
- 想看后端的编码约束 → [backend/AGENTS.md](backend/AGENTS.md)
- 想看历史踩坑 → [docs/harness/failure-log.md](docs/harness/failure-log.md)
- 想看当前进度 → [PROGRESS.md](PROGRESS.md)
- 想让 agent 一直跑 → [docs/harness/driver-prompt.md](docs/harness/driver-prompt.md)
