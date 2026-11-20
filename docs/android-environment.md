# Android 开发环境

验证日期：2026-11-20。工作目录：`E:\shuati`。

当前工具检查、符号链接、ARM64 原生编译、最小 Tauri APK 打包及签名验证均通过。尚未开发刷题业务、部署服务或完成 iQOO 真机验收。当前阶段不使用 Docker。

## 日常使用

在项目根目录打开 PowerShell：

```powershell
. ./scripts/enter-env.ps1
./scripts/check-env.ps1
./scripts/smoke-env.ps1
./scripts/smoke-tauri.ps1
```

| 命令 | 用途 |
|---|---|
| `. ./scripts/enter-env.ps1` | 激活当前终端的工具路径与缓存目录；新终端需重新执行，开头的点和空格不能省略 |
| `check-env.ps1` | 检查工具、SDK、Rust Android 目标、MSVC 及真实符号链接权限 |
| `smoke-env.ps1` | 离线编译并链接微型 ARM64 Android 共享库，核对 ELF 架构 |
| `smoke-tauri.ps1` | 构建不含业务的最小 Tauri APK 并验证签名，首次需要联网下载依赖 |

脚本只设置当前 PowerShell 进程环境，不修改系统或用户 PATH。版本配置见 [android-toolchain.json](../config/android-toolchain.json)，Rust 版本另由 [rust-toolchain.toml](../rust-toolchain.toml) 固定。

## 已验证版本与位置

| 工具 | 版本 | 本机位置 |
|---|---|---|
| Node | 24.15.0 | 复用本机安装 |
| 完整 JDK | 21.0.6 | `D:\应用`，包含 javac |
| pnpm | 10.34.9 | `build/tools/node-tools` |
| Tauri CLI | 2.11.4 | `build/tools/node-tools` |
| Rust / Cargo | 1.99.1，含 rustfmt / clippy | `build/tools/rustup`、`build/tools/cargo` |
| Rust Android target | `aarch64-linux-android` | 由本项目 rustup 管理 |
| Android Command-line Tools | 23.0 | `build/tools/android-sdk/cmdline-tools/latest` |
| Android SDK / Build Tools | API 36；36.0.0 和 35.0.0 | `build/tools/android-sdk` |
| Android NDK | 27.0.12077973，clang 18.0.1 | `build/tools/android-sdk/ndk/27.0.12077973` |
| Gradle | 8.14.3 | `build/cache/gradle`，由工程 wrapper 管理 |
| Android Gradle Plugin | 8.11.0 | 由生成的 Android 工程管理 |
| ADB / Platform Tools | 37.0.1 | `build/tools/android-sdk/platform-tools` |
| Windows C++ / MSVC | Build Tools 2022 17.14.45 / MSVC 14.44 | `build/tools/msvc`，含 Windows 11 SDK |

MSVC 安装完整且可启动，验证时无需重启。Tauri 生成工程使用 compileSdk/targetSdk 36、minSdk 24；这是测试工程配置，实际手机兼容性仍需真机确认。

Gradle、Android 用户数据和 npm 缓存分别位于 `build/cache/gradle`、`build/cache/android`、`build/cache/npm`。下载件和日志位于 `build/downloads`、`build/logs`。微软安装器仍可能使用 Windows 临时目录和共享组件目录。

## 本机配置与换电脑准备

本机配置为已忽略的 `build/environment.json`。新机器按上表和官方来源安装或定位工具，建立对应的 `build/tools` 目录，再创建配置：

```powershell
New-Item -ItemType Directory -Path build -Force
if (-not (Test-Path -LiteralPath build/environment.json)) {
    Copy-Item -LiteralPath config/environment.example.json -Destination build/environment.json
}
```

修改 `javaHome` 为真实完整 JDK 路径；已有配置不要覆盖。克隆 GitHub 仓库只获得脚本、版本清单、配置示例和锁文件，不会自动安装外部工具。

Windows 开发者模式须开启，使普通终端可以创建 Tauri 打包所需的 `.so` 符号链接。在 Windows 设置中开启“开发者模式”后，运行 `check-env.ps1` 验证。需要用脚本配置时，自行在管理员 PowerShell 运行：

```powershell
& E:/shuati/scripts/enable-windows-devmode.ps1
```

该脚本先在 `build/windows-devmode-before.json` 备份原值，仅调整开发者模式 DWORD，不启用设备门户或设备发现，不自动提权或重启。本机目前已开启，无需重复设置。

## 构建约束

- 保留 `scripts/fixtures/tauri-smoke.Cargo.lock`，沿用上游兼容组合：Tauri 2.11.5、runtime 2.11.3、runtime-wry 2.11.4、tauri-build 2.6.3，避免无理由全量升级依赖。
- 通过工程 `package.json` 的 `pnpm tauri` 入口初始化和构建，确保生成正确的 Gradle 回调；`smoke-tauri.ps1` 已执行此流程。
- AGP 8.11.0 默认需要 Build Tools 35.0.0，因此与 36.0.0 一并保留。具体兼容关系见 [AGP 官方说明](https://developer.android.com/build/releases/agp-8-11-0-release-notes)。
- 生成的最小工程在 `build/tauri-environment-check`，离线原生检查工程在 `build/environment-smoke`；它们均为环境验证用途。

## 当前验证结果

已通过工具检查、真实符号链接创建/读取、ARM64 共享库编译链接、最小 Tauri APK 打包以及 APK v2 签名验证。`aapt2 dump badging` 已核对包名、版本、target SDK 和实际原生 ABI。

| 测试 APK 项目 | 结果 |
|---|---|
| 路径 | `build/tauri-environment-check/src-tauri/gen/android/app/build/outputs/apk/universal/debug/app-universal-debug.apk` |
| 包名 / 版本 | `com.brushquestions.environmentcheck` / `0.0.1`，versionCode 1 |
| 实际原生 ABI | 仅 `arm64-v8a`；universal 文件名不代表包含全部 CPU 架构 |
| target SDK / compile SDK | 36 / 36 |
| 大小 | 131,988,265 字节，调试包 |
| SHA-256 | `E9FD51CBDDFF68A7A7052DC5E52B0239F4F16C8C8EB7CD97782341193539EC56` |
| 签名 | Android 调试签名，APK Signature Scheme v2 验证通过 |

测试包只显示环境检查页面，不包含题库、登录、AI 或刷题功能，也未安装到手机。重建可能改变哈希，届时以实际文件和验证输出为准。

## iQOO 真机连接

真机调试时，用支持数据传输的 USB 线连接 iQOO，开启开发者选项和 USB 调试，在手机上确认授权，再执行：

```powershell
. ./scripts/enter-env.ps1
adb devices
./scripts/check-env.ps1 -RequireDevice
```

设备须显示为 `device`；`unauthorized` 表示手机尚未授权。连接后记录型号、Android / OriginOS / WebView 版本和 CPU 架构。当前尚未完成真机连接与安装验收。

## 保存范围与官方来源

GitHub 保存当前文档、脚本、版本配置、配置示例和依赖锁文件。工具安装目录、缓存、下载件、日志、测试 APK、密钥和私人资料不提交；旧草稿及一次性调研仅保留在本地已忽略目录。

- [Tauri 开发前置条件](https://v2.tauri.app/start/prerequisites/)
- [Android SDK 官方工具](https://developer.android.com/studio)
- [Google SDK 官方包清单](https://dl.google.com/android/repository/repository2-1.xml)
- [Rust 官方安装](https://rust-lang.org/tools/install/)
- [Microsoft Build Tools 安装说明](https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio)
- [Windows 开发者模式](https://learn.microsoft.com/en-us/windows/advanced-settings/developer-mode)

Command-line Tools ZIP 已按 Google 清单 SHA-1 `57d04f2d75eb8e8fffc5000a987e5de4b5a63e9d` 校验；rustup-init 和 Gradle ZIP 已按官方 SHA-256 校验，Gradle 摘要保存在版本配置中。SDK/NDK 使用 Google 官方 CLI 安装。
