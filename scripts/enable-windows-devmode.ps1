# Requires an elevated PowerShell. Changes only the developer-mode DWORD.
# Microsoft reference: https://learn.microsoft.com/en-us/windows/advanced-settings/developer-mode
$ErrorActionPreference = 'Stop'
$projectPrincipal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $projectPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script from an elevated PowerShell to enable Windows Developer Mode for Tauri symlinks.'
}
$projectRoot = Split-Path $PSScriptRoot -Parent
$projectDevModeKey = 'HKLM:/SOFTWARE/Microsoft/Windows/CurrentVersion/AppModelUnlock'
$projectBackupPath = Join-Path $projectRoot 'build/windows-devmode-before.json'
New-Item -ItemType Directory -Path (Join-Path $projectRoot 'build/logs') -Force | Out-Null
if (-not (Test-Path -LiteralPath $projectBackupPath)) {
    $projectOldValue = Get-ItemPropertyValue -LiteralPath $projectDevModeKey -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue
    @{ existed = ($null -ne $projectOldValue); value = $projectOldValue } |
        ConvertTo-Json | Set-Content -LiteralPath $projectBackupPath -Encoding UTF8
}
if (-not (Test-Path -LiteralPath $projectDevModeKey)) {
    New-Item -Path $projectDevModeKey -Force | Out-Null
}
New-ItemProperty -LiteralPath $projectDevModeKey -Name AllowDevelopmentWithoutDevLicense -Value 1 -PropertyType DWord -Force | Out-Null
$projectDevModeValue = Get-ItemPropertyValue -LiteralPath $projectDevModeKey -Name AllowDevelopmentWithoutDevLicense
if ($projectDevModeValue -ne 1) { throw 'Windows Developer Mode did not become enabled' }
'Windows Developer Mode DWORD set to 1; no Device Portal or Device Discovery settings changed.' |
    Set-Content -LiteralPath (Join-Path $projectRoot 'build/logs/windows-devmode.log') -Encoding UTF8
