# Exameow 上游核查与改造边界

核查日期：2026-11-19。目标仓库初始为空。本轮读取公开 README、前端 package.json、服务启动路由，以及固定提交下的共享类型、练习和错题 store。未克隆、构建或运行完整上游；以下是源码层面的事实与规划，不能当作兼容性测试结果。

## 上游基线

GitHub API 返回的 `main` 提交为 `17246a51fa81463b51bdedb62371f6a7e7c477d0`。README、前端依赖表和服务启动路由初次按 `main` 读取；共享类型与 store 按此提交读取。正式引入时应对全部文件统一固定版本并复核。

| 已核实事实 | 本项目影响 |
|---|---|
| Vue 3、TypeScript、Pinia 前端；Tauri、Workers、Axum 三种后端路径 | 按用户最新反馈，首版聚焦 Vue + Tauri 移动应用 + Axum 服务器，停用 Workers 与桌面发布目标 |
| `practice.ts` 将题库、会话和每题进度写入 localStorage | 必须新增个人题库和练习的服务器 API 与持久化，替换权威存储来源 |
| `wrongQuestions.ts` 也使用 localStorage，连续答对阈值为 3 | 可参考规则与 UI；不能原样作为跨设备错题存储 |
| 共享题型有 `single_choice`、`multi_choice`、`true_false`、`fill_blank`、`short_answer` | 保留题型枚举，增加缺答案、来源证据、人工审核、版本等结构 |
| `Question` 已有 `answer`、`analysis`、可选 `aiAnalysis`、章节及媒体关联 | 独立 AI 字段并非从零新增；需要扩展服务器保存、版本绑定与不可覆盖约束 |
| 图片类型注释指向 IndexedDB 本地字节存储 | 必须实现带鉴权的服务器附件存储与导出打包 |
| 自托管服务有 SQLite 考试中继，并定期清理过期考试 | 个人练习和题库不能复用临时考试的生命周期，不能随中继过期删除 |
| 服务挂载 generate、answer、judge、explain、search、fetch、chat、配置与公开考试路由，MCP 为可选挂载 | 逐一审查移除/收口；个人登录必须覆盖业务、文件、任务、配置和下载；首版关闭 MCP 及公开考试 |
| 启动路由的 CORS 允许任意来源；考试管理有独立 token | 不能直接视为统一个人登录；移动应用需受保护的设备会话与明确的跨域/请求策略 |
| README 声明 Apache-2.0 并列第三方许可证清单 | 引入源码同时保留原文声明，记录修改；本轮不声称已完成许可证迁移 |

## 复用评估

可参考：题卡、答题卡、章节筛选、导入列映射、图片展示、练习模式、错题规则、解析及导出工具。仍需验证具体函数是否保留字段和图片，不能直接判定“拿来即用”。

需要改造：文档原题提取替代生成流程、集中答案匹配及证据、OCR 的持久化任务、校对草稿、题库服务存储、统一登录、每题保存与冲突控制、模考服务器计时、版本快照、备份恢复，以及移动应用的文件选择、安全凭据、生命周期、签名安装和更新。用户已将初稿网页/PWA 交付调整为可安装应用，Tauri 客户端仍须统一使用服务器权威数据，不能保留上游本地题库作为主存储。

移动构建参考 Tauri 官方的 [开发前置条件](https://v2.tauri.app/start/prerequisites/)与 [Apple 分发文档](https://v2.tauri.app/distribute/app-store/)。iOS 构建需要 macOS/Xcode；分发方案及相应签名条件待用户环境核实。本轮仅核实文档可访问，未实际构建或安装任何应用。

需要关闭：AI 生成新题、自动补答案、AI 简答判分、搜题自动回答、通用 AI 聊天和公开考试中继；不对外暴露可绕过限制的 MCP 工具。

## 原始参考

- [项目说明](https://github.com/heshengtao/exameow/blob/17246a51fa81463b51bdedb62371f6a7e7c477d0/README.md)
- [前端依赖](https://github.com/heshengtao/exameow/blob/17246a51fa81463b51bdedb62371f6a7e7c477d0/frontend/package.json)
- [服务路由](https://github.com/heshengtao/exameow/blob/17246a51fa81463b51bdedb62371f6a7e7c477d0/packages/server/src/main.rs)
- [共享题型](https://github.com/heshengtao/exameow/blob/17246a51fa81463b51bdedb62371f6a7e7c477d0/packages/shared/src/types.ts)
- [题库与练习保存](https://github.com/heshengtao/exameow/blob/17246a51fa81463b51bdedb62371f6a7e7c477d0/frontend/src/stores/practice.ts)
- [错题规则](https://github.com/heshengtao/exameow/blob/17246a51fa81463b51bdedb62371f6a7e7c477d0/frontend/src/stores/wrongQuestions.ts)
- [许可证](https://github.com/heshengtao/exameow/blob/17246a51fa81463b51bdedb62371f6a7e7c477d0/LICENSE)

用户提供的 Claude Artifact 页面只能取得动态外壳，其正文接口返回 HTTP 403；用户已确认无法打开时直接编写。因此 PRD 按用户需求独立组织，没有声称使用或复刻该页面模板。开发规范仅借鉴用户截图的组织方式，未照搬 Woodugo 的业务与发布规则。
