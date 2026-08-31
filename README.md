# Skills

Agent skills AI coding agent tooling.

Skills are directories containing a `SKILL.md` file that instructs an agent on domain knowledge, patterns, conventions, or workflows.

## Available Skills

| Skill | Description |
|-------|-------------|
| [azdocli](./azdocli) | Interact with Azure DevOps — repos, PRs, pipelines, boards, projects |
| [karpathy](./karpathy) | Behavioral guidelines to reduce common LLM coding mistakes — think before coding, simplicity first, surgical changes, goal-driven execution |
| [nano-commits](./nano-commits) | Autonomous nano-commit workflow — slice work into the smallest independently-testable logical groups |
| [tdd](./tdd) | Test-driven development — red-green-refactor loop, seam selection, and anti-pattern avoidance |
| [worktree-isolation](./worktree-isolation) | Do work in an isolated git worktree, leaving the main checkout untouched |

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

> When run via a one-liner, all skills are installed automatically (no interactive prompt).

### From a local clone

When run from a local clone, the installer prompts you to choose which skills to install:

**Bash:**
```bash
./install.sh
```

**PowerShell:**
```powershell
.\install.ps1
```

You'll see a numbered list of available skills and can select the ones you want:

```text
  Available skills:

     1) azdocli                  Interact with Azure DevOps via the azdocli CLI tool.
     2) karpathy                 Behavioral guidelines to reduce common LLM coding mistakes.
     3) nano-commits             Autonomous nano-commit workflow.
     4) worktree-isolation       Isolate all work in a fresh git worktree.

  Press Enter to install all, type skill numbers (e.g. 1,2),
  'all' to install everything, or 'none' to skip:
  >
```

- **Press Enter** — installs all skills (default)
- **Type `1,3`** — installs only those numbered skills
- **Type `all`** — installs everything
- **Type `none`** — skips installation

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
| `-Skill` / `--skill` | all skills | One or more skill names to install (repeatable in bash). Skips the interactive prompt |
| `-Tag` / `--tag` | `main` | Git tag or branch to install from (auto-detected) |
| `-Force` / `--force` | off | Overwrite existing skills without prompting |
| `-WhatIf` / `--whatif` | off | Dry run — show what would be installed. Skips the interactive prompt |

### Examples

```bash
# Interactive: shows a selection menu, installs all by default
./install.sh

# Install everything from the main branch (non-interactive)
curl -fsSL https://christianhelle.com/skills/install | bash

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
4. **In interactive mode:** shows a selection menu and filters to user's choices
5. Copies matching skills to `~/.agents/skills/<name>/`
6. Cleans up the temporary directory

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
