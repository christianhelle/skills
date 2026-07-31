#Requires -Version 5.1

<#
.SYNOPSIS
    Install agent skills from christianhelle/skills

.DESCRIPTION
    Downloads skills from the christianhelle/skills repository and installs them
    to ~/.agents/skills/. Skills are directories containing a SKILL.md file.

.PARAMETER Skill
    One or more skill names to install. Defaults to all skills.

.PARAMETER Tag
    Git tag or branch to install from. Defaults to "main". Auto-detects
    whether the value is a tag or branch.

.PARAMETER Force
    Overwrite existing skills without prompting.

.PARAMETER WhatIf
    Show what would be installed without making changes.

.EXAMPLE
    irm https://christianhelle.com/skills/install.ps1 | iex

.EXAMPLE
    .\install.ps1 -Skill nano-commits

.EXAMPLE
    .\install.ps1 -Tag v1.0.0 -Force
#>

param(
    [string[]] $Skill = @(),
    [string] $Tag = "main",
    [switch] $Force,
    [switch] $WhatIf
)

$Repo = "christianhelle/skills"
$DestRoot = Join-Path ([Environment]::GetFolderPath("UserProfile")) ".agents" "skills"

# ---- temp workspace ----
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "skills-install-$([System.Guid]::NewGuid().ToString("N"))"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$ZipPath = Join-Path $TempDir "archive.zip"

try {
    # ---- download (authenticated via gh for private repos) ----
    Write-Host "Resolving '$Tag' ..." -ForegroundColor DarkGray

    $Headers = @{}
    $UseGh = Get-Command gh -ErrorAction SilentlyContinue
    if ($UseGh) {
        $Token = gh auth token 2>$null
        if ($LASTEXITCODE -eq 0) {
            $Headers["Authorization"] = "Bearer $Token"
            Write-Host "  (authenticated via gh)" -ForegroundColor DarkGray
        }
    }

    # resolve archive URL (tag first, fall back to branch)
    $TagUrl = "https://github.com/$Repo/archive/refs/tags/$Tag.zip"
    $BranchUrl = "https://github.com/$Repo/archive/refs/heads/$Tag.zip"
    try {
        $null = Invoke-WebRequest -Uri $TagUrl -Method Head -Headers $Headers -SkipCertificateCheck -ErrorAction Stop
        $ArchiveUrl = $TagUrl
        Write-Host "Found tag: $Tag" -ForegroundColor Green
    } catch {
        $ArchiveUrl = $BranchUrl
        Write-Host "Using branch: $Tag" -ForegroundColor Green
    }

    # ---- download ----
    Write-Host "Downloading archive ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ZipPath -Headers $Headers -SkipCertificateCheck

    # ---- extract ----
    Expand-Archive -Path $ZipPath -DestinationPath $TempDir
    $Extracted = Get-ChildItem -Path $TempDir -Directory |
        Where-Object { $_.Name -like "skills-*" } |
        Select-Object -First 1

    if (-not $Extracted) {
        Write-Error "Extracted archive does not contain a 'skills-*' root folder."
        exit 1
    }

    # ---- discover skills (dirs with SKILL.md) ----
    $AllSkills = Get-ChildItem -Path $Extracted.FullName -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } |
        Sort-Object Name

    if ($AllSkills.Count -eq 0) {
        Write-Host "No skills found in archive." -ForegroundColor Yellow
        exit 0
    }

    # ---- filter and install ----
    $Installed = 0
    $Skipped = 0
    $Errors = 0

    # Warn about unrecognised skill names
    if ($Skill.Count -gt 0) {
        $ValidNames = $AllSkills | ForEach-Object { $_.Name }
        $Unknown = $Skill | Where-Object { $_ -notin $ValidNames }
        if ($Unknown.Count -gt 0) {
            Write-Host "Unknown skill name(s): $($Unknown -join ', ')" -ForegroundColor DarkYellow
        }

        $AllSkills = $AllSkills | Where-Object { $_.Name -in $Skill }
        if ($AllSkills.Count -eq 0 -and $Unknown.Count -eq $Skill.Count) {
            Write-Host "No matching skills to install." -ForegroundColor Yellow
            exit 0
        }
    }

    if (-not (Test-Path $DestRoot)) {
        New-Item -ItemType Directory -Path $DestRoot -Force | Out-Null
    }

    foreach ($Dir in $AllSkills) {
        $SkillName = $Dir.Name
        $DestPath = Join-Path $DestRoot $SkillName
        $Exists = Test-Path $DestPath

        if ($WhatIf) {
            $action = if ($Exists) { "would overwrite" } else { "would install" }
            Write-Host "  $action : $SkillName" -ForegroundColor DarkCyan
            $Installed++
            continue
        }

        if ($Exists -and -not $Force) {
            $answer = Read-Host "  '$SkillName' already exists. Overwrite? [y/N]"
            if ($answer -ne "y" -and $answer -ne "Y") {
                Write-Host "  Skipped $SkillName" -ForegroundColor DarkYellow
                $Skipped++
                continue
            }
        }

        try {
            Copy-Item -Path $Dir.FullName -Destination $DestPath -Recurse -Force -ErrorAction Stop
            Write-Host "  Installed: $SkillName" -ForegroundColor Green
            $Installed++
        } catch {
            Write-Host "  Error writing $SkillName : $_" -ForegroundColor Red
            $Errors++
        }
    }

    # ---- summary ----
    Write-Host "`nSummary:" -ForegroundColor White
    Write-Host "  Installed: $Installed" -ForegroundColor Green
    Write-Host "  Skipped:   $Skipped" -ForegroundColor Yellow
    Write-Host "  Errors:    $Errors" -ForegroundColor $(if ($Errors -gt 0) { "Red" } else { "DarkGray" })

} finally {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}
