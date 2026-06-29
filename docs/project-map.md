# 项目地图

> 每个模块的职责一句话。改公共接口/架构时同步更新本文件，否则会被熵管理脚本揪出来。

## 顶层

| 路径 | 职责 | 状态 |
|------|------|------|
| `AGENTS.md` | 驾驭层主指令索引 | ✅ |
| `PROGRESS.md` | 跨 session 状态持久化 | ✅ |
| `docs/` | 架构、地图、踩坑记录 | ✅ |
| `.github/workflows/ci.yml` | CI 验证门 | ✅ |
| `.pre-commit-config.yaml` | 提交前机械拦截 | ✅ |
| `scripts/entropy-gardener.sh` | 熵管理巡检 | ✅ |

## 前端 `frontend/`

| 路径 | 职责 | 状态 |
|------|------|------|
| `src/main.tsx` | 应用入口 | 🔜 骨架 |
| `src/App.tsx` | 根组件 | 🔜 骨架 |
| `src/pages/` | 页面级组件 | 待建 |
| `src/components/` | 可复用展示组件 | 待建 |
| `src/services/` | API 客户端封装（唯一发 HTTP 处） | 待建 |
| `src/hooks/` | 自定义 hooks | 待建 |
| `src/store/` | 状态管理 | 待建 |
| `src/types/` | 全局类型 | 待建 |
| `src/utils/` | 纯函数工具 | 待建 |

## 后端 `backend/`

| 路径 | 职责 | 状态 |
|------|------|------|
| `app/main.py` | FastAPI 装配入口 | 🔜 骨架 |
| `app/api/` | 路由层（协议） | 🔜 骨架 |
| `app/services/` | 业务逻辑层（编排+IO） | 待建 |
| `app/models/` | 数据模型 / DTO | 待建 |
| `app/logic/` | 业务逻辑（纯计算，零 IO） | 待建 |
| `app/validators/` | 校验器（逻辑验证门） | 待建 |
| `app/core/` | config / 安全 / 日志 / DI | 🔜 骨架 |
| `tests/` | pytest 用例 | 🔜 骨架 |

## 状态图例

- ✅ 已落地　🔜 骨架就位　待建：未开始

## 变更日志

- 2026-06-29：初始化项目地图，建立骨架。
