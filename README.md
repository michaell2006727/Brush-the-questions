# Brush-the-questions

基于 [Exameow](https://github.com/heshengtao/exameow) 规划的个人刷题应用：首版优先 Android APK，使用用户已有的 iQOO 真机测试，iOS 后续支持。采用 Vue 3 + Tauri 移动客户端连接个人服务器，保留文档原题和原答案，经校对后入库，保存进度并按需查看 AI 讲解，不能以手机网页代替应用交付。

**当前阶段：需求评审与 Android 开发环境准备已完成。工具、符号链接、ARM64 原生编译、最小 Tauri APK 打包及签名验证均通过。测试 APK 只验证环境；尚未引入 Exameow 业务源码、开发刷题功能或部署服务。**

- [产品需求文档](PRD.md)：首版范围、页面、业务规则、数据与接口边界、验收清单。
- [开发协作规范](AGENTS.md)：开发目录、分支、数据保护、AI 边界、验证和发布规则。
- [上游核查记录](docs/upstream-review.md)：已核实的 Exameow 架构与改造差距。
- [Android 环境与验证](docs/android-environment.md)：本机工具位置、激活命令、验证证据和剩余项。

## 工作目录与远端

- 本地：`E:\shuati`
- `origin`：`https://github.com/michaell2006727/Brush-the-questions.git`
- `upstream`：`https://github.com/heshengtao/exameow.git`（已 fetch 固定提交供核查；尚未合并上游历史或检出业务源码）

按用户要求，GitHub 和本地分支统一使用中文名称：

| 分支 | 用途 | 保存位置 |
|---|---|---|
| `安卓环境搭建与验证` | 当前完整文档、环境配置与验证脚本；GitHub 默认分支 | GitHub 与本地 |
| `安卓首版需求` | 优先交付 Android、以 iQOO 验收的需求调整快照 | 仅本地 |
| `产品需求文档` | 项目早期 PRD 与协作规范快照 | 仅本地 |
| `前端` | 用户已有的中文分支，保留原名和提交；目前没有刷题业务实现 | 仅本地 |

尚未单独建立正式主分支，后续由用户决定发布及主分支初始化方式。新分支也使用能直接说明用途的中文名称。

## 上游与许可证

Exameow 采用 Apache-2.0。本轮仅研究其公开资料及部分源码；后续引入代码时必须同时保留其许可证、版权及第三方声明，记录基线提交和本项目修改。

私人样本、题库、数据库、附件和密钥不进入 Git。实际运行和测试指南将在引入源码并验证命令后补充。
