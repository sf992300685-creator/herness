# frontend/AGENTS.md — 前端局部指令

> 改前端任何代码前先读本文件。本文件是索引，深层规范在 [../docs/](../docs/)。

## 技术栈

- **React 18** + **Ant Design 5**
- 构建：**Vite**
- 语言：**TypeScript**（`tsconfig.json` strict 模式，禁止 any 蔓延）
- 测试：**Vitest** + **@testing-library/react**
- 约束链：ESLint（flat config）+ Prettier + dependency-cruiser 分层 + pre-commit + CI

## 目录约定

```
frontend/src/
├── main.tsx          ← 入口
├── App.tsx           ← 根组件
├── pages/            ← 页面级组件（路由对应）
├── components/       ← 可复用展示组件（不碰业务逻辑、不直接调 API）
├── services/         ← API 客户端封装（唯一允许发 HTTP 请求的地方）
├── hooks/            ← 自定义 hooks
├── store/            ← 状态管理
├── types/            ← 全局类型定义
└── utils/            ← 纯函数工具
```

## 分层规则（dependency-cruiser 强制）

- `pages/` → 可依赖 `components/` `services/` `hooks/` `store/`
- `components/` → 只能依赖 `utils/` `types/`，**禁止**依赖 `pages/` `services/` `store/`
- `services/` → 只能依赖 `types/` `utils/`
- 任何层都**禁止**循环依赖
- 禁止从 `components/` 直接 `fetch`/`axios` 调后端——必须走 `services/`

> 为什么：展示组件保持纯粹，业务变化集中在 pages/services，重构时不会牵一发动全身。

## 硬性约定

- **类型优先**：所有 props、API 响应、store 状态都要有显式类型。禁止 `any`，必要时用 `unknown` + 类型守卫。
- **API 调用走 services/**：见上方分层规则。后端基地址从环境变量 `VITE_API_BASE_URL` 读取。
- **组件写测试**：核心交互组件必须有 Vitest 用例；纯展示组件可选。
- **AntD 按需引入**：用 `antd` 的具名导入，别整个引入。
- **样式**：优先 AntD 的 token/theme；自定义样式用 CSS Modules，避免全局污染。

## 本地命令

```bash
cd frontend
pnpm install        # 装依赖
pnpm dev            # 开发服务器
pnpm build          # 生产构建
pnpm test           # 跑测试（watch）
pnpm test --run     # 跑测试（一次性）
pnpm lint           # ESLint
pnpm check:types    # tsc 类型检查
pnpm check:deps     # dependency-cruiser 分层检查
```

## 禁区

- ❌ 不要在 `components/` 里调 API 或读 store。
- ❌ 不要用 `any` 绕过类型。
- ❌ 不要直接改 `tsconfig.json` 放宽 strict 选项——要改先记 [../docs/harness/failure-log.md](../docs/harness/failure-log.md)。
- ❌ 不要把后端基地址硬编码——走环境变量。

## 索引

- 整体架构与分层动机 → [../docs/architecture.md](../docs/architecture.md)
- 模块职责 → [../docs/project-map.md](../docs/project-map.md)
- 踩坑记录 → [../docs/harness/failure-log.md](../docs/harness/failure-log.md)
- 全局工作约定 → [../AGENTS.md](../AGENTS.md)
