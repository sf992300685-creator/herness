# 架构蓝图

> 本文件讲清"为什么这样分层"。具体的约束规则在前后端 `AGENTS.md` 与各 lint 配置里机械执行。

## 总体架构

herness 是前后端分离的 monorepo：

```
┌─────────────────────────┐        ┌──────────────────────────────┐
│  frontend (React+AntD)  │  HTTP  │  backend (FastAPI)           │
│  Vite · TS strict       │ ─────→ │                              │
│                         │        │  api → services → models     │
│  pages → components     │        │            ↘ strategies      │
│       ↘ services(API)   │        │            ↘ backtest        │
└─────────────────────────┘        └──────────────────────────────┘
```

前后端各自有**分层依赖约束**，由机械工具强制（dependency-cruiser / import-linter），不靠口头约定。

## 为什么 monorepo

- 一套驾驭层（AGENTS.md、CI、约束）同时管前后端，复利效应最大化。
- 跨端改动（如接口契约）一个 PR 搞定，不必跨仓同步。
- 失败日志、进度文件前后端共享，知识不分裂。

## 为什么这样分层

### 后端：api → services → models，strategies 零 IO

量化系统的**可信度**建立在"回测可复现"上。如果策略层混入网络/DB 等 IO，同样的历史数据会因外部状态不同而跑出不同结果，回测就失去意义。

因此：

- `logic/` 是**纯计算**层：输入行情数据 + 参数，输出交易信号。无 IO、无副作用、可单测、可回测。
- `services/` 负责 IO 与编排：调数据源、读写 DB、把数据喂给策略、把信号送去执行。
- `api/` 只做协议层：校验入参、调用 services、组装响应。
- `validators/` 是策略的**验证门**：用历史数据驱动策略，断言绩效指标。

这套边界由 `import-linter` 的 contracts 机械强制（见 [../backend/.importlinter](../backend/.importlinter)）。

### 前端：pages → components，services 收口 IO

- `components/` 保持纯粹：只渲染，不调 API、不读全局 store。可独立测试、可复用。
- `pages/` 组合 components + services + store，承载业务。
- `services/` 是唯一发 HTTP 请求的地方，后端地址走环境变量。

这套边界由 `dependency-cruiser` 强制（见 [../frontend/.dependency-cruiser.js](../frontend/.dependency-cruiser.js)）。

## 驾驭层架构（meta）

本项目的"工程"本身也是分层设计的：

```
上下文工程          架构约束              熵管理
(AGENTS.md/docs)   (lint/type/CI 门)    (failure-log/园丁/PROGRESS)
   ↓ 信息            ↓ 机械拦截            ↓ 持续对抗退化
   喂给 agent        阻止坏代码            防止腐烂
```

三者的关系：上下文告诉 agent **该做什么**，约束保证它**只能做对的**，熵管理保证**环境不随时间退化**。缺一不可。

## 待补充

- 数据存储选型（时序数据可能用专用的时序库，待阶段 2 决策）
- 部署架构（待阶段 3 容器化时定）
- 行情数据源接入方案（待业务推进时定）
