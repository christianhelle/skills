# Skills

Agent skills for [opencode](https://opencode.ai) and other AI-agent tooling.

Skills are directories containing a `SKILL.md` file that instructs an agent on domain knowledge, patterns, conventions, or workflows.

## Available Skills

| Skill | Description |
|-------|-------------|
| [nano-commits](./nano-commits) | Autonomous nano-commit workflow — slice work into the smallest independently-testable logical groups |

*More coming.*

## Installation

### Prerequisites

- **PowerShell 7+** (cross-platform: Windows, macOS, Linux)
- Internet access to `github.com`

### Quick install (all skills)

```powershell
irm https://raw.githubusercontent.com/christianhelle/skills/main/install-skills.ps1 | iex
```

### Selective install

```powershell
# Install specific skills only
irm https://raw.githubusercontent.com/christianhelle/skills/main/install-skills.ps1 | iex powershell -c "& { install-skills nano-commits }"
```

### From a local clone

```powershell
.\install-skills.ps1
```

### Options

```powershell
.\install-skills.ps1 [-Skill <string[]>] [-Tag <string>] [-Force] [-WhatIf]
```

| Param | Default | Description |
|-------|---------|-------------|
| `-Skill` | all skills | One or more skill names to install |
| `-Tag` | `main` | Git tag or branch to install from (auto-detected) |
| `-Force` | off | Overwrite existing skills without prompting |
| `-WhatIf` | off | Dry run — show what would be installed |

### Examples

```powershell
# Install everything from the main branch
.\install-skills.ps1

# Install only nano-commits
.\install-skills.ps1 -Skill nano-commits

# Pin to a specific tag, overwrite without confirmation
.\install-skills.ps1 -Tag v1.0.0 -Force

# Preview what would be installed
.\install-skills.ps1 -WhatIf
```

### How it works

1. Downloads the repo archive as `.zip` from GitHub (no git required)
2. Extracts to a temporary directory
3. Scans for subdirectories containing `SKILL.md` (each is a skill)
4. Copies matching skills to `~/.agents/skills/<name>/`
5. Cleans up the temporary directory

The installation is **additive** — it never removes skills already present in `~/.agents/skills/`.

## Creating a Skill

Create a directory with a `SKILL.md` file:

```
my-skill/
  SKILL.md
  references/       # (optional) supporting reference documents
    patterns.md
```

The `SKILL.md` frontmatter `description` field is critical — it's used by agents to match user questions to the right skill. Include key types, interfaces, and use cases.

See [nano-commits](./nano-commits/SKILL.md) for a complete example.
