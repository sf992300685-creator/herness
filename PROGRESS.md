# 项目进度 (PROGRESS.md)

> 本文件是跨 session 的状态持久化介质，由智能体在每个 session 结束前（或 checkpoint）更新。

## 当前状态
- [x] 阶段 1：驾驭层骨架就位（通用 Harness 模版已装配）
- [ ] 阶段 2：业务模型与路由开发
- [ ] 阶段 3：前端看板搭建

## 待办清单 (Sprint Backlog)
- [ ] 初始化通用后端 API 路由
- [ ] 接入并完善数据库 ORM / 数据层服务
- [ ] 编写前端 Mock 数据与页面基础框架

## 历史踩坑与经验总结
- 本模板使用 Harness Engineering (驾驭工程) 模式开发，严禁在 `app/logic` 目录中混入任何 IO 逻辑，请使用 `verify.sh` 或 `import-linter` 强制检查。
