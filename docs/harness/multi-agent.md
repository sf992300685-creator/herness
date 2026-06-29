# 多 Agent 协调层（Multi-Agent Coordination）

> 这是驾驭层的**第六块拼图**。单 agent 长跑（见 [driver-prompt.md](driver-prompt.md)）已能串行推进；本层在它之上加「分 lane 并行」，让多个 agent 同时干活而不互相踩。
>
> 设计原则与驾驭工程一致：**机械约束 > 口头约定**。并行安全不靠"大家自觉"，而靠 lane 文件域隔离 + 分支物理隔离 + `claim-check.sh` 校验 + `verify.sh` 合并门。

## 一、什么时候用多 agent，什么时候不用

| 场景 | 建议 |
|------|------|
| 只有一个可取 sprint（如现在 S1.2 是唯一 📋） | **单 agent**，多 agent 没东西可分 |
| 有 ≥2 个**不同 lane** 的可取 sprint | 多 agent，各占一个 lane |
| 高风险/实盘相关（M5 demo 之后、S7.1 主网） | **强制单 agent + 人工 review**，禁止并行 |
| 调研/查资料可以与写代码并行 | 派一个 research agent（只读） |

> 现实：本项目早期 sprint 多在 backend lane，真正能并行的窗口是「backend 写 M1 + research 查图表库/OKX 文档 + harness 修熵」。前端 lane 要等 S1.6（⛔）放行才有活。别为了"用多 agent"而强行拆——可取 sprint 不够时，单 agent 更高效。

## 二、角色

| 角色 | 数量 | 职责 | 不做 |
|------|------|------|------|
| **Driver（调度）** | 1 | 读 `session-start.sh`、按 lane 分配 sprint、合并 Worker 分支、更新 backlog 状态、在合并后的 main 上跑 verify | 尽量不写产品代码 |
| **Worker（执行）** | N | 在自己 lane 取一个 sprint、开分支、实现、自分支上 verify 全绿、commit、标完成等合并 | 不抢别的 lane 的 sprint、不碰 ⛔、不直接 merge 自己的分支到 main |
| **Review Worker（评审）** | 0–1 | 只读审 diff、跑 verify、按 rubric 打分、写 `docs/harness/reviews/**` | 不改产品代码、不 merge、不改 sprint 状态（M9：[m9-three-agent-runbook.md](m9-three-agent-runbook.md)） |
| **Human（你）** | 1 | 放行 ⛔、兼任 Driver merge、看 Review 分数、解合并冲突 | 不逐行盯每个 sprint |

记忆仍统一靠 `PROGRESS.md` + git + `sprint-backlog.md`，与单 agent 模式共用。

## 三、Lane 定义（并行安全的核心）

Lane 按**文件域不重叠**划分，保证不同 lane 的 agent 不会改同一个文件：

| Lane | 文件域 | 当前可取 sprint |
|------|--------|----------------|
| `backend` | `backend/**` | S1.2 / S1.3 / S1.4 / S1.5 / S2.x / S4.1 / S6.1 |
| `frontend` | `frontend/**` | S1.6(⛔) / S3.1 |
| `harness` | `docs/**`, `scripts/**`, 根配置, `.github/**`, `.cursor/**` | 熵管理、CI 验证、文档维护 |
| `research` | 只读全仓 + 写 `docs/research/**` | OKX API 调研、图表库对比、策略文献 |
| `review` | 只读全仓 + 写 `docs/harness/reviews/**` | M9 等 milestone 的 diff 评审与打分 |

**关键规则**：
- **同一 lane 内的 sprint 串行**（同一文件域，并行会撞）。
- **不同 lane 可并行**（文件域不重叠）。
- 想在 backend 内并行两个 sprint（如 S1.3 ‖ S1.4）？只有当 Driver 明确划定**子文件域不重叠**时才允许（如 S1.3 只动 `app/services/market/`、S1.4 只动 `app/services/ws/`），并在 backlog 注明 sub-lane。默认不开放，避免事故。

## 四、状态机扩展（在单 agent 基础上加两个字段）

每个 sprint 头部新增：

```
### S1.2 | OKX REST 历史 K 线客户端 + mock 测试 | 🔄
- lane: backend
- claimed-by: backend-worker-1 @ 2026-06-29T11:20+08:00
- branch: agent/backend-s1.2
```

**状态规则升级**：
- 旧：「同一时刻全局只允许一个 🔄」
- 新：「**每个 lane 同时最多一个 🔄**；跨 lane 可多个 🔄」
- 每个 🔄 **必须有** `claimed-by` 和 `branch`，否则 `claim-check.sh` 报错。
- ⛔ sprint 永不自动取用，**与 lane 无关**——人类放行才能改回 📋。

## 五、分支与合并协议

```
main ──────────────────────────────────────── (Driver 维护)
  │
  ├─ agent/backend-s1.2   (Backend Worker)
  ├─ agent/harness-entropy (Harness Worker)
  └─ agent/research-charts (Research Worker, 只写 docs/research/)
```

**Worker 流程**：
1. 从 main 切分支：`git checkout -b agent/<lane>-<sprint-id>`。
2. 在分支上实现 + `bash scripts/verify.sh` 自修到全绿。
3. `git commit`（分支上）。
4. 在 backlog 把 sprint 标 🔄、填 `claimed-by` + `branch`。
5. 不自己 merge——通知 Driver（或等 Driver 定期拉分支）。

**Driver 合并流程**：
1. `git fetch` / 切到 main，`git merge --no-ff agent/<lane>-<sprint-id>`。
2. **在合并后的 main 上**再跑一次 `bash scripts/verify.sh`（合并可能引入冲突回归）。
3. 全绿 → 把 sprint 置 ✅、更新 PROGRESS、`git push`（若有远端）。
4. 红 → 优先让原 Worker 在其分支修；冲突解不了 → 置 ⛔ 等人类。
5. 删已合并分支。

> 合并门是双保险：Worker 自分支绿 ≠ 合并后绿（别人可能改了同区域）。Driver 必须在 main 复验。

## 六、一个完整协调 tick（Driver 视角）

```
1. bash scripts/session-start.sh         # 看状态
2. bash scripts/claim-check.sh           # 校验当前并行状态合法
3. 看 backlog：哪些 lane 有可取 sprint（📋 且 depends-on ✅ 且非 ⛔）
4. 对每个有空闲 sprint 的 lane，派/唤醒一个 Worker（贴对应 prompt 模板）
5. 等 Worker 在分支上完成 + 自分支 verify 绿
6. 逐个 merge 到 main，每次 merge 后跑 verify
7. 更新 backlog 状态（✅）+ PROGRESS
8. 回到 1，直到没有可取 sprint 或本轮预算用完
9. 收尾：bash scripts/session-checkpoint.sh
```

## 七、Prompt 模板（可直接粘贴）

### 7.1 Driver 调度 prompt

```
你是 herness 多 agent 协调的 Driver。职责是分配、流转与合并，不写产品代码。

每轮：
1. bash scripts/session-start.sh 看状态。
2. bash scripts/claim-check.sh，若有违规先修。
3. 扫 docs/sprint-backlog.md，对每个有空闲可取 sprint（📋、depends-on ✅、非 ⛔）的 lane，
   派一个 Worker（贴 7.2/7.3/7.4 对应 prompt），一个 lane 至多一个在跑。
4. Worker 在 agent/<lane>-<sprint-id> 分支完成后，指派 Review Agent 评审。
   - 若 Review 结论为 ❌ 打回修复：只要自修/复评重试不超过 3 次，Driver 必须自动分发给对应 Worker 修复重跑，并在分支上自验。严禁在此处停机会话问人类。
   - 若 Review 结论为 ✅ 或 ⚠️：你切 main、merge --no-ff、跑 bash scripts/verify.sh。全绿才在 backlog 中置为 ✅ 并更新 PROGRESS。
   - 若发生合并冲突、或自修/复评重试 > 3 次仍为 ❌：则置为 ⛔ 挂起，此时才停机会话并交由人类拍板。
5. 没有可取 sprint 或预算用完 → bash scripts/session-checkpoint.sh 收尾。

铁律：⛔ 永不自动放行；同 lane 不并发；merge 后必须复验；Review 打回时必须闭环自修，不可提早向人类交枪。
```

### 7.2 Backend Worker prompt

```
你是 qunt 的 Backend Worker。只接 lane: backend 的 sprint。
开工前先 bash scripts/session-start.sh。

单 sprint 流程：
1. 从 docs/sprint-backlog.md 取一个 backend lane 的 📋 sprint（depends-on ✅、非 ⛔）。
2. git checkout -b agent/backend-<sprint-id>。
3. 在 backlog 把它标 🔄，填 claimed-by: backend-worker-<n> @ <时间>、branch。
4. 读 backend/AGENTS.md（strategies 零 IO、分层）+ product-spec 对应段。
5. 实现。遵守 import-linter 分层。
6. bash scripts/verify.sh 自修到全绿（≤3 轮，仍不过置 ⛔ 等人类）。
7. git commit（分支上，message 含 sprint id）。
8. 在 backlog 注明「分支就绪待合并」，通知 Driver。不要自己 merge 到 main。
9. 取下一个 backend 📋 sprint 重复；没有就结束本轮。

铁律：不碰 frontend/、不碰 ⛔、不直接 merge、不提交密钥。
```

### 7.3 Frontend Worker prompt

```
你是 qunt 的 Frontend Worker。只接 lane: frontend 的 sprint。
开工前先 bash scripts/session-start.sh。

流程同 Backend Worker，但：
- 分支名 agent/frontend-<sprint-id>。
- 读 frontend/AGENTS.md：components 不依赖 services/store/pages（dependency-cruiser 强制）；
  调后端必须走 services/，禁直接 fetch/axios。
- S1.6 是 ⛔（图表库未定）——除非人类已放行改回 📋，否则不许动。

铁律：不碰 backend/、不碰 ⛔、不直接 merge。
```

### 7.4 Research Worker prompt（只读 + 写 docs/research/）

```
你是 qunt 的 Research Worker。只读模式 + 仅写 docs/research/**。
任务由 Driver 指定（如"对比 lightweight-charts vs ECharts vs AntD Charts"）。

流程：
1. git checkout -b agent/research-<topic>。
2. 调研，产出 docs/research/<topic>.md（结论 + 依据 + 给某个 sprint 的建议）。
3. 不改任何代码、不跑 verify、不碰 sprint 状态。
4. commit 到分支，通知 Driver 消化。
5. Driver/Human 据此把对应 ⛔ sprint 放行（如 S1.6 图表库决策）。

铁律：纯调研，不改产品代码，不替人类做 ⛔ 决策（只给建议）。
```

## 八、冲突与失败处理

| 情况 | 处理 |
|------|------|
| 两个 Worker 改了同一文件（跨 lane 漏划） | Driver merge 冲突 → 退回后开工的 Worker 调整；说明 lane 划分有漏，记 failure-log |
| 同 lane 出现两个 🔄 | `claim-check.sh` 报错 → 后开的那个回退为 📋 |
| 🔄 没有 claimed-by/branch | `claim-check.sh` 报错 → 补填 |
| Worker 3 轮自修不过 | 置 ⛔，PROGRESS 记阻塞，Driver 不再分配该 sprint |
| 合并后 verify 红 | 退回原 Worker 分支修；解不了置 ⛔ 等人类 |
| Reviewer 给出 ❌ 打回结论 | 由 Driver 自动重指派给对应 Worker 分支修复，并重新触发 Review。此闭环由 AI 内部自修（自修+复评重试上限 3 次），未达上限前禁止停机找人类。 |
| ⛔ 被误取 | 立即回退状态，记 failure-log「现象/根因/永久约束」 |

## 九、机械约束（不靠自觉）

1. `scripts/claim-check.sh` —— 校验并行状态合法（同 lane 不重 🔄、🔄 必有 claim/branch、⛔ 未被占）。
2. `scripts/verify.sh` —— 合并门，合并后必须复验。
3. git 分支 —— Worker 不直接 push main，Driver 统一合并。
4. import-linter / dependency-cruiser —— 跨 lane 误改也会被分层门拦下。

> 单 agent 模式仍是默认。多 agent 是"可取 sprint 跨 lane 充足"时才开的加速档；两者共用同一套状态文件与验证门，可随时切换。

## 十、和单 agent 模式的关系

- **单 agent** = 一个人兼 Driver + Worker，串行取 sprint。backlog 全局单 🔄。
- **多 agent** = Driver + N Worker，按 lane 并行。backlog 每 lane 单 🔄 + claim 字段。

切换：把 backlog 的「并行模式」开关打开（见 sprint-backlog.md 顶部），agent 按 [driver-prompt.md](driver-prompt.md) 的单/多模式选择走哪套。两套 prompt 都指向同一批 sprint 与同一道 verify 门。
