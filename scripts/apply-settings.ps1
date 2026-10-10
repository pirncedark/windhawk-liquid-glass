#requires -RunAsAdministrator
<#
  Applies the glass theme settings in ..\settings\*.json to Windhawk.
  Install the three mods from the Windhawk catalog first (see README).
  Safe to re-run. Does not touch any other mod.
#>
$ErrorActionPreference = 'Stop'
$root = Join-Path (Split-Path $PSScriptRoot -Parent) 'settings'
$base = 'HKLM:\SOFTWARE\Windhawk\Engine\Mods'

foreach ($f in Get-ChildItem $root -Filter *.json) {
    $cfg = Get-Content $f.FullName -Raw | ConvertFrom-Json
    $key = Join-Path $base $cfg.mod
    if (-not (Test-Path $key)) {
        Write-Warning "$($cfg.mod) is not installed in Windhawk yet - install it first, then re-run."
        continue
    }
    $sk = Join-Path $key 'Settings'
    New-Item $sk -Force | Out-Null
    foreach ($p in $cfg.settings.PSObject.Properties) {
        if ($p.Value -is [int] -or $p.Value -is [long]) {
            New-ItemProperty $sk -Name $p.Name -Value ([int]$p.Value) -PropertyType DWord -Force | Out-Null
        } else {
            New-ItemProperty $sk -Name $p.Name -Value ([string]$p.Value) -PropertyType String -Force | Out-Null
        }
    }
    $now = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    New-ItemProperty $key -Name SettingsChangeTime -Value $now -PropertyType DWord -Force | Out-Null
    Write-Host "OK  $($cfg.mod)"
}

Write-Host "Restarting Explorer so the mods reload..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep 3
if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }
Write-Host "Done."
