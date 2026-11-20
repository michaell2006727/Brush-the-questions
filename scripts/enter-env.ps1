# Dot-source this script: . ./scripts/enter-env.ps1
# Only changes the current PowerShell process; no machine/user PATH changes.
$projectRoot = Split-Path $PSScriptRoot -Parent
$configPath = Join-Path $projectRoot 'build/environment.json'
if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Local environment configuration missing: $configPath. See docs/android-environment.md."
}
$projectConfig = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$projectTools = Join-Path $projectRoot 'build/tools'
$env:JAVA_HOME = $projectConfig.javaHome
$env:ANDROID_HOME = Join-Path $projectTools 'android-sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:NDK_HOME = Join-Path $env:ANDROID_HOME "ndk/$($projectConfig.ndkVersion)"
$env:ANDROID_NDK_HOME = $env:NDK_HOME
$env:CARGO_HOME = Join-Path $projectTools 'cargo'
$env:RUSTUP_HOME = Join-Path $projectTools 'rustup'
$env:GRADLE_USER_HOME = Join-Path $projectRoot 'build/cache/gradle'
$env:ANDROID_USER_HOME = Join-Path $projectRoot 'build/cache/android'
$env:npm_config_cache = Join-Path $projectRoot 'build/cache/npm'
$projectPathEntries = @(
    (Join-Path $env:JAVA_HOME 'bin'),
    (Join-Path $projectTools 'node-tools/node_modules/.bin'),
    (Join-Path $env:CARGO_HOME 'bin'),
    (Join-Path $env:ANDROID_HOME 'cmdline-tools/latest/bin'),
    (Join-Path $env:ANDROID_HOME 'platform-tools'),
    (Join-Path $env:ANDROID_HOME "build-tools/$($projectConfig.buildTools)")
)
$env:PATH = (($projectPathEntries + ($env:PATH -split ';')) | Select-Object -Unique) -join ';'
Write-Host "Android project environment active: $projectRoot"
