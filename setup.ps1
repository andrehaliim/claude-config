# Links ~/.claude/rules and each skill in skills/ to this repo (Windows, no admin needed).
# Usage: powershell -ExecutionPolicy Bypass -File .\setup.ps1
# Safe to run again: existing files are backed up, never deleted.

$ErrorActionPreference = 'Stop'

$repoRules    = Join-Path $PSScriptRoot 'rules'
$repoSkills   = Join-Path $PSScriptRoot 'skills'
$claudeDir    = Join-Path $env:USERPROFILE '.claude'
$rulesLink    = Join-Path $claudeDir 'rules'
$skillsDir    = Join-Path $claudeDir 'skills'
$skillsBackup = Join-Path $claudeDir 'skills-backup'
$claudeMd     = Join-Path $claudeDir 'CLAUDE.md'
$stamp        = Get-Date -Format 'yyyyMMdd-HHmmss'

if (-not (Test-Path $repoRules)) { throw "Folder not found: $repoRules" }
New-Item -ItemType Directory -Force $claudeDir | Out-Null

# Makes $Link a junction to $Target. An existing real folder is moved to $BackupPath.
function Set-Junction([string]$Link, [string]$Target, [string]$BackupPath) {
    $name = Split-Path $Link -Leaf
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -in 'Junction', 'SymbolicLink') {
            $current = @($item.Target)[0]
            if ($current -and (Test-Path $current) -and
                ((Resolve-Path $current).Path -eq (Resolve-Path $Target).Path)) {
                Write-Host "OK   $name already linked to $Target"
                return
            }
            # Removing a link only removes the link, not the folder it points to.
            [IO.Directory]::Delete($Link)
            Write-Host "INFO removed old $name link (was -> $current)"
        } else {
            New-Item -ItemType Directory -Force (Split-Path $BackupPath) | Out-Null
            Move-Item $Link $BackupPath
            Write-Host "BAK  existing $name folder -> $BackupPath"
        }
    }
    New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    Write-Host "OK   created junction $Link -> $Target"
}

# 1. ~/.claude/rules -> junction to repo/rules
Set-Junction $rulesLink $repoRules "$rulesLink.bak-$stamp"

# 2. ~/.claude/skills/<name> -> junction to repo/skills/<name>, one per skill.
#    ~/.claude/skills itself stays a normal folder so skills from other sources keep working.
#    Backups go to ~/.claude/skills-backup, because a copy left inside ~/.claude/skills
#    would be loaded as a duplicate skill.
if (Test-Path $repoSkills) {
    New-Item -ItemType Directory -Force $skillsDir | Out-Null
    Get-ChildItem $repoSkills -Directory | ForEach-Object {
        Set-Junction (Join-Path $skillsDir $_.Name) $_.FullName `
            (Join-Path $skillsBackup "$($_.Name).bak-$stamp")
    }
}

# 3. ~/.claude/CLAUDE.md: its content now lives in rules/general.md.
#    Keep it only for PC-specific notes; otherwise back it up to avoid loading rules twice.
if (Test-Path $claudeMd) {
    $backup = "$claudeMd.bak-$stamp"
    Rename-Item $claudeMd $backup
    Write-Host "BAK  existing CLAUDE.md -> $backup (move any PC-specific notes back into a new CLAUDE.md)"
}

Write-Host ""
Write-Host "Loaded rule files:"
Get-ChildItem $rulesLink -Filter *.md | ForEach-Object { Write-Host "  - $($_.Name)" }
if (Test-Path $repoSkills) {
    Write-Host "Linked skills:"
    Get-ChildItem $repoSkills -Directory | ForEach-Object { Write-Host "  - $($_.Name)" }
}
Write-Host "Restart Claude (or open a new session) to load the rules and skills."
