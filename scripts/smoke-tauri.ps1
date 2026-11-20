# Builds an isolated, business-free Tauri APK to verify the full Android toolchain.
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'enter-env.ps1')
$projectTauriSmoke = Join-Path $projectRoot 'build/tauri-environment-check'
$projectTauriLog = Join-Path $projectRoot 'build/logs/tauri-android-build.log'
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'build/logs') | Out-Null

function Write-SmokeFile {
    param([string]$RelativePath, [string]$Content)
    $smokeFilePath = Join-Path $projectTauriSmoke $RelativePath
    New-Item -ItemType Directory -Force -Path (Split-Path $smokeFilePath -Parent) | Out-Null
    [IO.File]::WriteAllText($smokeFilePath, $Content, [Text.UTF8Encoding]::new($false))
}

Write-SmokeFile 'src-tauri/Cargo.toml' @'
[package]
name = "android-toolchain-check"
version = "0.0.1"
edition = "2021"
[lib]
name = "android_toolchain_check_lib"
crate-type = ["staticlib", "cdylib", "rlib"]
[build-dependencies]
tauri-build = "=2.6.3"
[dependencies]
tauri = "=2.11.5"
[workspace]
'@
Write-SmokeFile 'src-tauri/build.rs' 'fn main() { tauri_build::build() }'
Write-SmokeFile 'src-tauri/src/lib.rs' @'
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .run(tauri::generate_context!())
        .expect("environment check app failed");
}
'@
Write-SmokeFile 'src-tauri/tauri.conf.json' @'
{
  "productName": "Android Environment Check",
  "version": "0.0.1",
  "identifier": "com.brushquestions.environmentcheck",
  "build": { "frontendDist": "../ui" },
  "app": { "windows": [{ "title": "Environment check" }] },
  "bundle": { "active": false }
}
'@
Write-SmokeFile 'ui/index.html' '<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Environment check</title><body><h1>Android environment check</h1><p>Toolchain validation only. No question bank or product features.</p></body></html>'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'fixtures/tauri-smoke.Cargo.lock') -Destination (Join-Path $projectTauriSmoke 'src-tauri/Cargo.lock') -Force

# Tauri's generated context needs a PNG even for this packaging-only check.
Add-Type -AssemblyName System.Drawing
$projectIconDirectory = Join-Path $projectTauriSmoke 'src-tauri/icons'
New-Item -ItemType Directory -Path $projectIconDirectory -Force | Out-Null
$projectIcon = [System.Drawing.Bitmap]::new(32, 32, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$projectIconGraphics = [System.Drawing.Graphics]::FromImage($projectIcon)
try {
    $projectIconGraphics.Clear([System.Drawing.Color]::FromArgb(255, 42, 90, 70))
    $projectIcon.Save((Join-Path $projectIconDirectory 'icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
} finally {
    $projectIconGraphics.Dispose()
    $projectIcon.Dispose()
}

$previousProjectJobs = $env:CARGO_BUILD_JOBS
try {
    $env:CARGO_BUILD_JOBS = '4'
    Push-Location -LiteralPath $projectTauriSmoke
    try {
        if (-not (Test-Path -LiteralPath 'src-tauri/gen/android/gradlew.bat')) {
            & tauri.cmd android init --ci --skip-targets-install
            if ($LASTEXITCODE -ne 0) { throw 'Tauri Android initialization failed' }
        }
        & tauri.cmd android build --debug --apk --target aarch64 --ci *> $projectTauriLog
        if ($LASTEXITCODE -ne 0) {
            Get-Content -LiteralPath $projectTauriLog -Tail 30
            throw "Tauri APK build failed. Log: $projectTauriLog"
        }
    } finally { Pop-Location }
} finally { $env:CARGO_BUILD_JOBS = $previousProjectJobs }

$projectCheckApk = Get-ChildItem -LiteralPath (Join-Path $projectTauriSmoke 'src-tauri/gen/android/app/build/outputs/apk') -Recurse -Filter '*debug.apk' | Select-Object -First 1
if (-not $projectCheckApk) { throw 'Build returned success without an APK' }
& (Join-Path $env:ANDROID_HOME 'build-tools/36.0.0/apksigner.bat') verify $projectCheckApk.FullName
if ($LASTEXITCODE -ne 0) { throw 'Generated APK signature verification failed' }
Get-FileHash -LiteralPath $projectCheckApk.FullName -Algorithm SHA256
Write-Host "PASS: signed ARM64 environment-check APK built: $($projectCheckApk.FullName)"
Write-Host 'This verifies packaging only, not phone installation or product acceptance.'
