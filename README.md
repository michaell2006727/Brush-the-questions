# Brush-the-questions

基于 [Exameow](https://github.com/heshengtao/exameow) 规划的个人刷题应用：首版优先 Android APK，使用用户已有的 iQOO 真机测试，iOS 后续支持。采用 Vue 3 + Tauri 移动客户端连接个人服务器，保留文档原题和原答案，经校对后入库，保存进度并按需查看 AI 讲解，不能以手机网页代替应用交付。

**当前阶段：需求评审与 Android 开发环境准备已完成。工具、符号链接、ARM64 原生编译、最小 Tauri APK 打包及签名验证均通过。测试 APK 只验证环境；尚未引入 Exameow 业务源码、开发刷题功能或部署服务。**

- [产品需求文档](PRD.md)：首版范围、页面、业务规则、数据与接口边界、验收清单。
- [开发协作规范](AGENTS.md)：开发目录、分支、数据保护、AI 边界、验证和发布规则。
- [Android 环境与验证](docs/android-environment.md)：工具版本、安装位置、使用命令和验证结果。

## 工作目录与远端

- 本地：`E:\shuati`
- `origin`：`https://github.com/michaell2006727/Brush-the-questions.git`
- `upstream`：`https://github.com/heshengtao/exameow.git`（已 fetch 固定提交供核查；尚未合并上游历史或检出业务源码）

正式主分支固定为 `main`，也是 GitHub 默认分支，本地和 GitHub 均保留。除 `main` 外，其他分支全部使用能说明用途的中文名称；当前环境功能分支为 `安卓环境搭建与验证`。功能修改通过独立分支提交，由用户决定合并到 `main`。

## 上游与许可证

Exameow 采用 Apache-2.0。技术基线与必要改造见 [PRD 第 19 节](PRD.md#19-技术方案与上游改造)；后续引入代码时必须同时保留其许可证、版权及第三方声明，记录基线提交和本项目修改。

GitHub 只维护当前必要的文档、环境脚本与配置。旧草稿、临时调研、安装日志、私人样本、题库、数据库、附件和密钥不提交到 GitHub。
