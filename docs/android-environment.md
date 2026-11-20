# Android 开发环境

开始配置：2026-11-19；验证完成：2026-11-20。工作目录 `E:\shuati`。Android 工具检查、符号链接、原生编译、最小 Tauri APK 打包及签名验证已通过。本轮授权为创建开发环境，不包含业务实现、真实 AI 配置、服务器部署或向手机安装应用。

## 使用方法

在项目根目录打开 PowerShell，执行：

```powershell
. ./scripts/enter-env.ps1
./scripts/check-env.ps1
./scripts/smoke-env.ps1
./scripts/smoke-tauri.ps1
```

第一条必须保留开头的点和空格，激活当前终端的项目环境；新终端需重新执行。`smoke-env` 仅检查离线 ARM64 编译链接；`smoke-tauri` 构建不含业务功能的 APK，首次会从官方仓库下载 Rust/Gradle 依赖，需要完整 MSVC。脚本不修改系统或用户 PATH，不覆盖其他项目的 Java/Rust 设置。

环境配置位于已忽略的 `build/environment.json`，当前复用本机 `D:\应用` 的完整 JDK 21。工具版本记录在 [android-toolchain.json](../config/android-toolchain.json)，Rust 另由根目录 [rust-toolchain.toml](../rust-toolchain.toml) 固定。

## GitHub 保存范围与新机器准备

GitHub 保存环境脚本、工具版本清单、Rust 配置、最小 Tauri 检查工程的依赖锁文件、环境配置示例及本文档。SDK/NDK、JDK/MSVC、Rust 安装目录、下载件、缓存、日志和测试 APK 保留在本机已忽略的 `build/` 或原安装位置，不作为 Git 源文件上传；签名密钥、账号凭据和私人数据不上传。

换到新机器时，按版本表及官方来源重新安装或定位工具，再将配置示例复制为本机配置，并修改 `javaHome` 为实际 JDK 目录：

```powershell
New-Item -ItemType Directory -Path build -Force
Copy-Item -LiteralPath config/environment.example.json -Destination build/environment.json
```

已有本机配置时不要直接覆盖。其余工具按本说明放置到 `build/tools` 对应目录；完成 Windows 开发者模式设置后，依次执行环境激活、`check-env.ps1`、`smoke-env.ps1` 和 `smoke-tauri.ps1`。克隆代码仓库不会自动安装这些外部工具。

## 目录与版本

| 工具 | 版本 / 位置 | 当前结果 |
|---|---|---|
| Node | 复用 v24.15.0 | 可执行 |
| JDK | 复用完整 JDK 21.0.6 | `javac` 可用，不另装 Java |
| pnpm | 10.34.9，`build/tools/node-tools` | 项目专用，不覆盖系统 pnpm 11 |
| Tauri CLI | 2.11.4，`build/tools/node-tools` | 最小 Android 检查工程构建通过，尚无业务应用工程 |
| Rust / Cargo | 1.99.1，`build/tools/rustup`、`build/tools/cargo` | 安装并验证，含 rustfmt / clippy |
| Rust Android target | `aarch64-linux-android` | 安装成功，ARM64 编译链接已通过 |
| Android CLI | Command-line Tools 23.0，`build/tools/android-sdk` | 下载并校验后安装；新版提供 `android.exe sdk` 命令 |
| Android SDK | API 36 / Build Tools 36.0.0 及 35.0.0 | `android.jar`、aapt2、apksigner 可用；35.0.0 对应生成工程的 AGP 默认要求 |
| Android NDK | 27.0.12077973 / clang 18.0.1 | ARM64 编译器和链接器可用 |
| Gradle | 8.14.3，`build/cache/gradle` | 通过 Tauri 检查工程的官方 wrapper 下载，JDK 21 启动成功 |
| ADB | Platform Tools 37.0.1 | 可执行，当前未连接设备 |
| Windows C++ / MSVC | Build Tools 2022 17.14.45 / MSVC 14.44，`build/tools/msvc` | 安装完整、可启动、无需重启；Rust 宿主与 Android 原生库编译已通过 |

Rust 和 NDK 版本参考已固定 Exameow 提交的移动发布工作流，避免直接采用更新 Rust 版本遇到其记录的构建脚本兼容问题。已核对 Tauri 生成工程使用 AGP 8.11.0、Gradle 8.14.3、compileSdk/targetSdk 36、minSdk 24；按 [AGP 官方兼容表](https://developer.android.com/build/releases/agp-8-11-0-release-notes) 同时补装其默认 Build Tools 35.0.0。该 minSdk 是检查工程的配置，不是已经证实所有 Android 7+ 手机兼容。

Tauri 检查工程的依赖锁文件在 `scripts/fixtures/tauri-smoke.Cargo.lock`，由已固定上游 Cargo.lock 为种子解析得到。实际检查曾发现“主库 2.11.5 + 自动解析的新运行库 2.12.x”编译不兼容，因此保留运行库 2.11.3 / runtime-wry 2.11.4 等上游组合；后续不要无理由删除锁文件或执行全量依赖升级。

检查工程通过自己的 `package.json` 脚本使用 `pnpm tauri` 初始化和构建。直接调用外部 `tauri.cmd` 初始化曾使 Gradle 回调错误生成为 `node tauri ...`，导致找不到脚本模块；已通过标准的包管理器入口重新生成并验证，不能把旧错误回调继续用于后续工程。

缓存设置：Gradle 位于 `build/cache/gradle`、Android 用户数据位于 `build/cache/android`，激活环境后的 npm 缓存位于 `build/cache/npm`。下载件和日志分别在 `build/downloads`、`build/logs`，不提交 Git。微软安装程序自身可能使用 Windows 的临时目录和系统组件目录，不能承诺 C 盘完全无写入。

## 已执行验证及其边界

- Rust、Cargo、pnpm、Tauri CLI、javac、ADB、NDK clang、aapt2 和 apksigner 的版本命令可用。
- `scripts/smoke-env.ps1` 使用不依赖外部 crates 的微型 Rust 项目，离线编译并链接 `aarch64-linux-android` 共享库；`llvm-readelf` 确认产物为 ELF64 / AArch64 / DYN。
- 检查脚本按是否存在 MSVC 和所需 SDK 文件判断完整性，缺项返回非零，不能仅靠部分版本命令成功来显示全部通过。
- 2026-11-20 核查 `vswhere`：MSVC 实例 `isComplete=true`、`isLaunchable=true`、`isRebootRequired=false`。此前的 `link.exe` 缺失已解决，固定上游依赖并补齐测试图标后，Tauri 原生库编译通过。
- 用户于 2026-11-20 手动开启 Windows Developer Mode，读取注册表值为 1，真实符号链接创建/读取检查已通过；此前的符号链接阻塞已解决。
- 最小 Tauri 工程已构建出 APK；`apksigner verify --verbose` 返回 `Verifies`，APK v2 签名验证通过，签名者数量为 1。`aapt2 dump badging` 核对包名、版本、target SDK 与 ARM64 原生库内容。未连接 iQOO，未完成手机安装和应用验收。

编译检查源文件、产物和 Cargo 缓存位于 `build/environment-smoke` 与 `build/cache/rust-smoke`，不属于产品功能或测试题库。

### 实际测试 APK

| 项目 | 结果 |
|---|---|
| 路径 | `build/tauri-environment-check/src-tauri/gen/android/app/build/outputs/apk/universal/debug/app-universal-debug.apk` |
| 包名 | `com.brushquestions.environmentcheck` |
| 版本 | `0.0.1`，versionCode 1 |
| target SDK / compile SDK | 36 / 36 |
| APK 实际原生 ABI | 仅 `arm64-v8a`，以 aapt2 输出为准；文件名中的 universal 不表示包含全部 CPU 架构 |
| 大小 | 131,988,265 字节，调试包 |
| SHA-256 | `E9FD51CBDDFF68A7A7052DC5E52B0239F4F16C8C8EB7CD97782341193539EC56` |
| 签名 | Android 调试签名，APK Signature Scheme v2 验证通过 |

该包仅显示环境检查页面，不含题库、登录、AI 或任何刷题业务；未安装到手机。后续重建可能改变 APK 哈希，需重新记录实际文件和验证结果。

## Windows 安装与权限记录

官方安装器位于 `build/downloads/vs_BuildTools.exe`，Authenticode 签名验证为 Microsoft Corporation、Valid。已完成 C++ x64/x86 工具和 Windows 11 SDK 安装，主工具路径在 E 盘。安装日志位于 Windows 临时目录 `dd_bootstrapper_*.log`、`dd_setup_*.log` 及 `dd_installer_elevated_*.log`。应以 setup/elevated 日志和组件状态判断结果，不能仅依据安装器 UI 的单个下载错误判断整体停止。

配置过程中尝试“停止当前安装进程并改用已有微软安装器重试”时被自动审批拒绝，返回仅为 `blocked by policy`，未给出详细理由。该操作未执行，也未拆分重试；原安装流程继续运行并最终完成，已不存在该安装阻塞。

Tauri Android 打包会创建 `.so` 符号链接，当前 E 盘为 NTFS，但 Windows Developer Mode 原值为 0。已准备 `scripts/enable-windows-devmode.ps1`，通过管理员确认后按 [微软官方方法](https://learn.microsoft.com/en-us/windows/advanced-settings/developer-mode) 仅将 `AllowDevelopmentWithoutDevLicense` 设为 1；脚本成功运行时会先把原值备份到已忽略的 `build/windows-devmode-before.json`。不启用 Device Portal、Device Discovery 或远程调试，不自动重启。

2026-11-20 最初的管理员启动返回“操作已被用户取消”；用户反馈没有看到提示。该脚本未执行、未生成原值备份，也没有重复发起提权。随后用户通过 Windows 设置手动开启开发者模式，已验证值为 1 且普通终端可创建符号链接。后续重新配置机器时，可在 Windows“设置 → 系统 → 高级 → 开发者选项”打开“开发者模式”（较旧系统为“为开发者”页面），或自行在管理员 PowerShell 运行：

```powershell
& E:/shuati/scripts/enable-windows-devmode.ps1
```

设置生效后，在普通项目 PowerShell 重新运行 `check-env.ps1` 和 `smoke-tauri.ps1`。本机现已通过环境检查、Rust 原生库编译、最小 APK 打包及签名验证，结果见上表；没有产品 APK。后续验收仍须区分环境检查、APK 打包、手机安装和业务验证。

## iQOO 连接时再做

创建电脑环境不需要手机型号。进行真机调试时：用支持数据传输的 USB 线连接手机，开启开发者选项和 USB 调试，在手机上确认信任这台电脑，然后运行：

```powershell
. ./scripts/enter-env.ps1
adb devices
./scripts/check-env.ps1 -RequireDevice
```

设备状态须为 `device`，`unauthorized` 表示手机尚未授权；不要尝试绕过授权。届时记录型号、Android / OriginOS / WebView 版本和 CPU 架构，决定实际 APK 兼容范围。当前没有设备在线，不能声称已连通或已安装。

## 获取来源和验证

- [Tauri 前置环境](https://v2.tauri.app/start/prerequisites/)
- [Android SDK 官方工具](https://developer.android.com/studio)
- [Google SDK 官方包清单](https://dl.google.com/android/repository/repository2-1.xml)
- [Rust 官方安装](https://rust-lang.org/tools/install/)
- [Microsoft Build Tools 安装参数](https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio)

Command-line Tools ZIP 按 Google 包清单 SHA-1 `57d04f2d75eb8e8fffc5000a987e5de4b5a63e9d` 校验；rustup-init 按官方 `.sha256` 校验，Rust 组件由 rustup 管理。Gradle ZIP 已与官方 `.sha256` 对照，摘要记录在版本配置中。SDK/NDK 通过 Google Android CLI 安装稳定包，没有使用随机第三方打包工具。下载时个别请求遇到 Windows 证书吊销服务离线，使用 curl 的 `--ssl-revoke-best-effort` 重试，未禁用 TLS 证书验证。

SQLite 随未来 Rust 后端实现引入，不需要为本轮单独创建公网数据库、生产账号或真实 Key。暂未安装 Android Studio、模拟器或 Docker；当前以命令行工具和后续 iQOO 真机为路线，服务端部署环境另行建立。

## Git 交付状态

环境脚本、版本配置、配置示例与本说明通过目标仓库的 `codex/android-environment` 分支保存，不推送或合并 `main`。此前 GitHub CLI 默认账号只有 `READ` 权限，Git 推送等待认证；本次已发现 Git Credential Manager 中保存的个人账号 `michaell2006727`，通过单次指定该账号完成写入权限校验，未切换其他项目使用的默认账号。

上传内容不包含本机安装工具、缓存、测试 APK、签名密钥和私人资料。完整环境的可重复性依靠版本清单、配置示例、官方安装来源及实际编译检查共同确认，不依靠上传整个工具安装目录。
