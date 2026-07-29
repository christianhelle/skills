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

- **Linux/macOS:** `curl` and `unzip`
- **Windows:** PowerShell 5.1+
- Internet access to `github.com`

### One-liner

**Linux/macOS:**
```bash
curl -fsSL https://christianhelle.com/skills/install | bash
```

**Windows (PowerShell):**
```powershell
irm https://christianhelle.com/skills/install.ps1 | iex
```

### From a local clone

**Bash:**
```bash
./install.sh
```

**PowerShell:**
```powershell
.\install.ps1
```

### Options

**Bash:**
```bash
./install.sh [--skill <name>] [--tag <ref>] [--force] [--whatif]
```

**PowerShell:**
```powershell
.\install.ps1 [-Skill <string[]>] [-Tag <string>] [-Force] [-WhatIf]
```

| Param / Flag | Default | Description |
|--------------|---------|-------------|
| `-Skill` / `--skill` | all skills | One or more skill names to install (repeatable in bash) |
| `-Tag` / `--tag` | `main` | Git tag or branch to install from (auto-detected) |
| `-Force` / `--force` | off | Overwrite existing skills without prompting |
| `-WhatIf` / `--whatif` | off | Dry run — show what would be installed |

### Examples

```bash
# Install everything from the main branch
./install.sh

# Install only nano-commits
./install.sh --skill nano-commits

# Pin to a specific tag, overwrite without confirmation
./install.sh --tag v1.0.0 --force

# Preview what would be installed
./install.sh --whatif
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
