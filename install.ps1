#Requires -Version 5.1

<#
.SYNOPSIS
    Install agent skills from christianhelle/skills

.DESCRIPTION
    Downloads skills from the christianhelle/skills repository and installs them
    to ~/.agents/skills/. Skills are directories containing a SKILL.md file.
    When run interactively, prompts you to choose which skills to install.

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

function Get-SkillDescription {
    param([string]$SkillMdPath)
    if (-not (Test-Path $SkillMdPath)) { return "" }

    $content = Get-Content $SkillMdPath -Raw
    $inFrontmatter = $false
    $capturing = $false
    $folded = ""

    foreach ($line in ($content -split "`n")) {
        $line = $line.TrimEnd("`r")
        if ($line -match '^---$') {
            if ($inFrontmatter) { break }
            $inFrontmatter = $true
            continue
        }
        if (-not $inFrontmatter) { continue }

        if ($line -match '^description:\s*(.*)') {
            $value = $Matches[1].Trim()
            if ($value -match '^>\s*(.*)') {
                # Folded scalar — capture subsequent indented lines
                $folded = $Matches[1].Trim()
                $capturing = $true
                continue
            }
            # Single-line: return first sentence
            $periodIdx = $value.IndexOf('.')
            if ($periodIdx -gt 0) { return $value.Substring(0, $periodIdx + 1) }
            return $value
        }

        if ($capturing) {
            if ($line -match '^\s+(.*)') {
                if ($folded) {
                    $folded += " " + $Matches[1].Trim()
                } else {
                    $folded = $Matches[1].Trim()
                }
            } else {
                $periodIdx = $folded.IndexOf('.')
                if ($periodIdx -gt 0) { return $folded.Substring(0, $periodIdx + 1) }
                return $folded
            }
        }
    }

    if ($capturing -and $folded) {
        $periodIdx = $folded.IndexOf('.')
        if ($periodIdx -gt 0) { return $folded.Substring(0, $periodIdx + 1) }
        return $folded
    }
    return ""
}

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

    # ---- interactive selection ----
    # Show interactive prompt when:
    #   - No -Skill flags were given
    #   - Not in -WhatIf mode
    #   - Running in an interactive session (not piped)
    if ($Skill.Count -eq 0 -and -not $WhatIf -and [Environment]::UserInteractive) {
        Write-Host ""
        Write-Host "  Available skills:" -ForegroundColor White
        Write-Host ""

        $skillDescriptions = @{}
        for ($i = 0; $i -lt $AllSkills.Count; $i++) {
            $s = $AllSkills[$i]
            $md = Join-Path $s.FullName "SKILL.md"
            $desc = Get-SkillDescription -SkillMdPath $md
            $skillDescriptions[$s.Name] = $desc
            $num = $i + 1
            $padded = "{0,2}" -f $num
            if ($desc) {
                Write-Host "    $padded) " -NoNewline -ForegroundColor Yellow
                Write-Host ("{0,-24}" -f $s.Name) -NoNewline -ForegroundColor Cyan
                Write-Host $desc -ForegroundColor DarkGray
            } else {
                Write-Host "    $padded) " -NoNewline -ForegroundColor Yellow
                Write-Host $s.Name -ForegroundColor Cyan
            }
        }

        Write-Host ""
        Write-Host "  Press Enter to install all, type skill numbers (e.g. 1,2)," -ForegroundColor DarkGray
        Write-Host "  'all' to install everything, or 'none' to skip:" -ForegroundColor DarkGray
        Write-Host "  > " -NoNewline -ForegroundColor White
        $userInput = Read-Host

        if ($userInput) {
            $normalized = $userInput.Trim().ToLower()

            if ($normalized -eq 'none' -or $normalized -eq 'n') {
                Write-Host "  No skills selected. Skipping installation." -ForegroundColor Yellow
                exit 0
            }

            if ($normalized -eq 'all' -or $normalized -eq 'a' -or $normalized -eq '') {
                # Keep all — no filter
            } else {
                $selected = @()
                $parts = $normalized -split ',' | ForEach-Object { $_.Trim() }
                foreach ($part in $parts) {
                    if ($part -match '^\d+$') {
                        $idx = [int]$part - 1
                        if ($idx -ge 0 -and $idx -lt $AllSkills.Count) {
                            $selected += $AllSkills[$idx]
                        } else {
                            Write-Host "  Warning: '$part' is not a valid skill number, skipping." -ForegroundColor DarkYellow
                        }
                    } else {
                        Write-Host "  Warning: '$part' is not a valid number, skipping." -ForegroundColor DarkYellow
                    }
                }

                if ($selected.Count -eq 0) {
                    Write-Host "  No valid skills selected. Skipping installation." -ForegroundColor Yellow
                    exit 0
                }

                $AllSkills = $selected
                Write-Host ""
                Write-Host "  Installing $($AllSkills.Count) selected skill(s)..." -ForegroundColor Cyan
            }
        }
        Write-Host ""
    }

    # ---- filter by -Skill flag ----
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

    # ---- install ----
    $Installed = 0
    $Skipped = 0
    $Errors = 0

    # ---- single overwrite prompt for existing skills ----
    if (-not $WhatIf -and -not $Force) {
        $Existing = @()
        foreach ($Dir in $AllSkills) {
            $DestPath = Join-Path $DestRoot $Dir.Name
            if (Test-Path $DestPath) {
                $Existing += $Dir.Name
            }
        }

        if ($Existing.Count -gt 0) {
            if ($Existing.Count -eq 1) {
                Write-Host "  '$($Existing[0])' already exists. Overwrite? [y/N] " -NoNewline -ForegroundColor White
            } else {
                Write-Host "  $($Existing.Count) skill(s) already exist: $($Existing -join ', ')" -ForegroundColor White
                Write-Host "  Overwrite all? [y/N] " -NoNewline -ForegroundColor White
            }
            $overwriteAnswer = Read-Host

            if ($overwriteAnswer -ne 'y' -and $overwriteAnswer -ne 'Y') {
                Write-Host "  Skipping existing skills." -ForegroundColor Yellow
                $AllSkills = $AllSkills | Where-Object { $_.Name -notin $Existing }
                if ($AllSkills.Count -eq 0) {
                    Write-Host "  Nothing new to install." -ForegroundColor Yellow
                    exit 0
                }
            }
        }
    }

    foreach ($Dir in $AllSkills) {
        $SkillName = $Dir.Name
        $DestPath = Join-Path $DestRoot $SkillName

        if ($WhatIf) {
            $Exists = Test-Path $DestPath
            $action = if ($Exists) { "would overwrite" } else { "would install" }
            Write-Host "  $action : $SkillName" -ForegroundColor DarkCyan
            $Installed++
            continue
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
