# Brush-the-questions

基于 [Exameow](https://github.com/heshengtao/exameow) 规划的个人手机刷题网页：保留文档原题和原答案，经校对后入库，在安卓和 iPhone 登录同一服务器继续练习，按需查看 AI 讲解。

**当前阶段：需求评审。仓库仅有文档与 Git 配置，尚未引入 Exameow 源码、实现业务或部署服务。**

- [产品需求文档](PRD.md)：首版范围、页面、业务规则、数据与接口边界、验收清单。
- [开发协作规范](AGENTS.md)：开发目录、分支、数据保护、AI 边界、验证和发布规则。
- [上游核查记录](docs/upstream-review.md)：已核实的 Exameow 架构与改造差距。

## 工作目录与远端

- 本地：`E:\shuati`
- `origin`：`https://github.com/michaell2006727/Brush-the-questions.git`
- `upstream`：`https://github.com/heshengtao/exameow.git`（仅登记地址，尚未导入上游历史）

本轮在 `codex/project-prd` 分支准备文档。空仓库尚无 `main` 基线，后续由用户决定首次发布和主分支初始化方式。

## 上游与许可证

Exameow 采用 Apache-2.0。本轮仅研究其公开资料及部分源码；后续引入代码时必须同时保留其许可证、版权及第三方声明，记录基线提交和本项目修改。

私人样本、题库、数据库、附件和密钥不进入 Git。实际运行和测试指南将在引入源码并验证命令后补充。
