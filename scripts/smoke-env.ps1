# Compiles a tiny ARM64 Android library; no business code or external AI calls.
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'enter-env.ps1')
$projectSmokeRoot = Join-Path $projectRoot 'build/environment-smoke'
New-Item -ItemType Directory -Path (Join-Path $projectSmokeRoot 'src') -Force | Out-Null
@'
[package]
name = "android_environment_smoke"
version = "0.0.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[workspace]
'@ | Set-Content -LiteralPath (Join-Path $projectSmokeRoot 'Cargo.toml') -Encoding UTF8
@'
#[no_mangle]
pub extern "C" fn environment_smoke() -> i32 { 42 }
'@ | Set-Content -LiteralPath (Join-Path $projectSmokeRoot 'src/lib.rs') -Encoding UTF8
$previousProjectTarget = $env:CARGO_TARGET_DIR
$previousProjectLinker = $env:CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER
try {
    $env:CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER = Join-Path $env:NDK_HOME 'toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android24-clang.cmd'
    $env:CARGO_TARGET_DIR = Join-Path $projectRoot 'build/cache/rust-smoke'
    & cargo build --offline --manifest-path (Join-Path $projectSmokeRoot 'Cargo.toml') --target aarch64-linux-android
    if ($LASTEXITCODE -ne 0) { throw 'Rust Android cross-compilation failed' }
    $projectLibrary = Join-Path $env:CARGO_TARGET_DIR 'aarch64-linux-android/debug/libandroid_environment_smoke.so'
    $readElf = Join-Path $env:NDK_HOME 'toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-readelf.exe'
    $elfHeader = & $readElf --file-header $projectLibrary
    if ($LASTEXITCODE -ne 0 -or -not ($elfHeader -match 'AArch64')) { throw 'Expected an Android ARM64 ELF library' }
    $elfHeader | Select-String 'Class:|Machine:|Type:'
    Write-Host "PASS Android ARM64 compile and link: $projectLibrary"
} finally {
    $env:CARGO_TARGET_DIR = $previousProjectTarget
    $env:CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER = $previousProjectLinker
}
