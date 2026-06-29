# 驱动器 Prompt 模板（Driver Prompt）

> 这是 `/loop` 或 Cursor Automation 每次 tick 发给执行 agent 的指令。
> 它把"长跑自治"变成一个可重复的循环。复制下方"循环指令"作为驱动 prompt。

## 循环指令（驱动器每 tick 发送）

```
你是 herness 通用智能体驾驭系统的执行 agent。严格按以下循环工作，不得跳步：

1. 跑 `bash scripts/session-start.sh`，看当前状态（git log / PROGRESS.md / 可取 sprint）。
2. 从 `docs/sprint-backlog.md` 取**第一个**满足条件的 sprint：
   - 状态 ∈ {📋 ready, ⏳ queued}、所有 depends-on 已 ✅、且不是 ⛔ blocked。
   - 若没有可取的 sprint（全是 ✅/⛔/未满足依赖）：在 PROGRESS.md 记"无可取 sprint，等人类"，结束本轮。
3. 把该 sprint 状态改 🔄 doing（编辑 sprint-backlog.md）。
4. 读相关 AGENTS.md（根 + frontend/backend）与 docs/product-spec.md 对应段落。
5. 实现该 sprint。遵守分层约束（strategies 零 IO、components 不依赖 services 等）。
6. 跑 `bash scripts/verify.sh`：
   - 失败 → 读错误信息，自修，重跑。最多 3 轮。
   - 3 轮仍不过 → 把该 sprint 置 ⛔ blocked，在 PROGRESS.md 记阻塞现象/根因，结束本轮等人类。
7. verify 全绿后：
   - `git add -A && git commit`（message 含 sprint id 与一句话"为什么"）。
   - 把该 sprint 状态改 ✅ done。
   - 更新 PROGRESS.md（上次完成/下一步）。
   - 若犯错，在 docs/harness/failure-log.md 记「现象/根因/永久约束」并落到机械约束。
8. 回到步骤 2，取下一个 sprint，重复——直到没有可取 sprint 或本轮预算用完。

硬性禁区：
- ⛔ sprint 永不自动取用（实盘/风控关键变更/图表库等需人类放行）。
- 不提交 .env、密钥、真实凭证。
- 不为过 verify 而放宽约束或删测试断言；要放宽先记 failure-log。
- 遇真钱实盘相关（M5 demo 之后切主网）：必须停下等人类签署。

本轮结束前：跑 `bash scripts/session-checkpoint.sh` 确认收尾就绪。
```

## 两种驱动器怎么用这个 prompt

### 方式 A：`/loop`（session 内，最简单）

在当前会话直接发：

```
/loop 动态 <把上面"循环指令"粘进来>
```

动态模式下，agent 跑完一轮后自己决定下一次何时跑（默认长间隔，避免空转）。停止时说"停掉 loop"。

### 方式 B：Cursor Automation（跨 session，持久）

用 automate 技能创建一个定时/触发型 automation：
- 触发：cron（如每 30 分钟）或 git push 事件。
- 指令：上面"循环指令"。
- 它会跨 session 醒来→执行循环→commit→睡到下次。

> 两种都依赖同一套驾驭层：PROGRESS.md+git 当记忆，verify.sh 当验证，failure-log 当复利约束。

## 人类检查点（你在这些地方介入）

- ⛔ sprint 放行（如 S1.6 图表库选型、S5.1 实盘 API Key 权限、S7.1 主网切换）。
- 反复失败 3 轮的 sprint。
- 阶段性 review（一个 milestone 完成时）。

不在这些点上，就让 agent 自己跑——你是驾驶员，不是逐行审查员。
