# Links ~/.claude/rules to the rules/ folder of this repo (Windows, no admin needed).
# Usage: powershell -ExecutionPolicy Bypass -File .\setup.ps1
# Safe to run again: existing files are backed up, never deleted.

$ErrorActionPreference = 'Stop'

$repoRules = Join-Path $PSScriptRoot 'rules'
$claudeDir = Join-Path $env:USERPROFILE '.claude'
$rulesLink = Join-Path $claudeDir 'rules'
$claudeMd  = Join-Path $claudeDir 'CLAUDE.md'
$stamp     = Get-Date -Format 'yyyyMMdd-HHmmss'

if (-not (Test-Path $repoRules)) { throw "Folder not found: $repoRules" }
New-Item -ItemType Directory -Force $claudeDir | Out-Null

# 1. ~/.claude/rules -> junction to repo/rules
if (Test-Path $rulesLink) {
    $item = Get-Item $rulesLink -Force
    if ($item.LinkType -in 'Junction', 'SymbolicLink') {
        $target = @($item.Target)[0]
        if ($target -and ((Resolve-Path $target).Path -eq (Resolve-Path $repoRules).Path)) {
            Write-Host "OK   rules already linked to $repoRules"
        } else {
            # Removing a link only removes the link, not the folder it points to.
            [IO.Directory]::Delete($rulesLink)
            Write-Host "INFO removed old link (was -> $target)"
        }
    } else {
        $backup = "$rulesLink.bak-$stamp"
        Rename-Item $rulesLink $backup
        Write-Host "BAK  existing rules folder -> $backup"
    }
}
if (-not (Test-Path $rulesLink)) {
    New-Item -ItemType Junction -Path $rulesLink -Target $repoRules | Out-Null
    Write-Host "OK   created junction $rulesLink -> $repoRules"
}

# 2. ~/.claude/CLAUDE.md: its content now lives in rules/general.md.
#    Keep it only for PC-specific notes; otherwise back it up to avoid loading rules twice.
if (Test-Path $claudeMd) {
    $backup = "$claudeMd.bak-$stamp"
    Rename-Item $claudeMd $backup
    Write-Host "BAK  existing CLAUDE.md -> $backup (move any PC-specific notes back into a new CLAUDE.md)"
}

Write-Host ""
Write-Host "Loaded rule files:"
Get-ChildItem $rulesLink -Filter *.md | ForEach-Object { Write-Host "  - $($_.Name)" }
Write-Host "Restart Claude (or open a new session) to load the rules."
