param([switch]$RequireDevice)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'enter-env.ps1')
$missing = [System.Collections.Generic.List[string]]::new()
$projectVersions = Get-Content -LiteralPath (Join-Path $projectRoot 'config/android-toolchain.json') -Raw | ConvertFrom-Json

function Test-ProjectTool {
    param([string]$Name, [string]$Executable, [string[]]$Arguments)
    if (-not (Get-Command $Executable -ErrorAction SilentlyContinue)) {
        $missing.Add($Name)
        Write-Host "MISSING $Name"
        return
    }
    $toolOutput = & $Executable @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        $missing.Add($Name)
        Write-Host "FAILED $Name : $($toolOutput -join ' ')"
        return
    }
    Write-Host "OK $Name : $(($toolOutput | Select-Object -First 2) -join ' ')"
}

Test-ProjectTool 'Node' 'node' @('--version')
Test-ProjectTool 'pnpm' 'pnpm.cmd' @('--version')
Test-ProjectTool 'JDK compiler' (Join-Path $env:JAVA_HOME 'bin/javac.exe') @('-version')
Test-ProjectTool 'Rust' 'rustc' @('--version')
Test-ProjectTool 'Cargo' 'cargo' @('--version')
Test-ProjectTool 'Tauri CLI' 'tauri.cmd' @('--version')
Test-ProjectTool 'ADB' 'adb' @('version')
Test-ProjectTool 'Android native compiler' (Join-Path $env:NDK_HOME 'toolchains/llvm/prebuilt/windows-x86_64/bin/clang.exe') @('--version')

$requiredFiles = @(
    (Join-Path $env:ANDROID_HOME "platforms/android-$($projectVersions.androidApi)/android.jar"),
    (Join-Path $env:ANDROID_HOME "build-tools/$($projectVersions.androidBuildTools)/aapt2.exe"),
    (Join-Path $env:ANDROID_HOME "build-tools/$($projectVersions.androidGradleDefaultBuildTools)/aapt2.exe"),
    (Join-Path $env:ANDROID_HOME "build-tools/$($projectVersions.androidBuildTools)/apksigner.bat")
)
foreach ($requiredFile in $requiredFiles) {
    if (Test-Path -LiteralPath $requiredFile) { Write-Host "OK $requiredFile" }
    else { $missing.Add($requiredFile); Write-Host "MISSING $requiredFile" }
}

$rustupCommand = Get-Command 'rustup' -ErrorAction SilentlyContinue
if ($rustupCommand) {
    $installedTargets = & rustup target list --installed
    if ($projectVersions.rustTarget -notin $installedTargets) { $missing.Add('Rust Android target') }
    else { Write-Host "OK Rust target: $($projectVersions.rustTarget)" }
}

$projectVsWhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
if (Test-Path -LiteralPath $projectVsWhere) {
    $projectVcPath = & $projectVsWhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
}
if (-not $projectVcPath) { $missing.Add('MSVC C++ Build Tools'); Write-Host 'MISSING MSVC C++ Build Tools' }
else { Write-Host "OK MSVC: $projectVcPath" }

$projectSymlinkCheckDir = Join-Path $projectRoot 'build/symlink-check'
$projectSymlinkId = [Guid]::NewGuid().ToString('N')
$projectSymlinkSource = Join-Path $projectSymlinkCheckDir "source-$projectSymlinkId.txt"
$projectSymlinkPath = Join-Path $projectSymlinkCheckDir "link-$projectSymlinkId.txt"
New-Item -ItemType Directory -Path $projectSymlinkCheckDir -Force | Out-Null
try {
    'environment-check' | Set-Content -LiteralPath $projectSymlinkSource -Encoding UTF8
    New-Item -ItemType SymbolicLink -Path $projectSymlinkPath -Target $projectSymlinkSource -ErrorAction Stop | Out-Null
    if ((Get-Content -LiteralPath $projectSymlinkPath -Raw).Trim() -ne 'environment-check') {
        throw 'Symbolic link did not resolve correctly'
    }
    Write-Host 'OK Windows symbolic links'
} catch {
    $missing.Add('Windows symbolic-link permission (Developer Mode)')
    Write-Host "MISSING Windows symbolic-link permission: $($_.Exception.Message)"
} finally {
    foreach ($projectCheckFile in @($projectSymlinkPath, $projectSymlinkSource)) {
        if (Test-Path -LiteralPath $projectCheckFile) { Remove-Item -LiteralPath $projectCheckFile -Force }
    }
}

if (Get-Command adb -ErrorAction SilentlyContinue) {
    $deviceList = & adb devices
    Write-Host ($deviceList -join "`n")
    if ($RequireDevice -and -not ($deviceList | Where-Object { $_ -match '\tdevice$' })) {
        $missing.Add('Authorized Android device')
    }
}
if ($missing.Count -gt 0) {
    Write-Host "Environment incomplete: $($missing -join ', ')"
    exit 1
}
Write-Host 'PASS: Android build tools available. This does not certify a project APK or device acceptance.'
