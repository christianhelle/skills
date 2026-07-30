---
name: azdocli
description: Interact with Azure DevOps via the azdocli CLI tool (repos, PRs, pipelines, boards, projects). Use when working with Azure DevOps, creating pull requests, managing repos, running pipelines, or querying boards.
---

# azdocli

CLI tool for Azure DevOps: <https://github.com/christianhelle/azdocli>

## Quick start

### Installation

If `azdocli` is not installed, use the platform-appropriate one-liner:

| Platform | Command |
|----------|---------|
| Linux/macOS | `curl -fsSL https://christianhelle.com/azdocli/install \| bash` |
| Windows (PowerShell) | `iwr -useb https://christianhelle.com/azdocli/install.ps1 \| iex` |
| Cargo (any) | `cargo install azdocli` |
| Linux (Snap) | `snap install azdocli` |

Verify installation with `azdocli --version`.

### Login & config

```bash
# Login (interactive — prompts for org + PAT)
azdocli login

# Set a default project so --project is optional on all commands
azdocli project "MyProject"
```

All `--project` flags default to the configured project.

## Core scenario: creating a pull request

From your feature branch:

```bash
# Derive repo name from git remote
REPO=$(git remote get-url origin | sed 's/.*\/\(.*\)\.git/\1/')
BRANCH=$(git branch --show-current)

# Create PR targeting main
azdocli repos pr create \
  --repo "$REPO" \
  --source "$BRANCH" \
  --title "feat: add dark mode" \
  --description "Implements dark mode toggle"
```

| Flag | Default | Notes |
|------|---------|-------|
| `--target` | `main` | Target branch (auto-prefixed with `refs/heads/`) |
| `--title` | `Pull Request` | |
| `--description` | *(none)* | Optional |

### PR lifecycle (view only)

```bash
# List PRs in a repo
azdocli repos pr list --repo "$REPO"

# Show PR details
azdocli repos pr show --repo "$REPO" --id 123

# Show commits in a PR
azdocli repos pr commits --repo "$REPO" --id 123
```

> Approval and merge happen in the Azure DevOps web UI — azdocli is view + create only.

## Other commands (quick reference)

| Group | What you'll commonly run |
|-------|--------------------------|
| **repos** | `azdocli repos list` — list repos; `repos show --id <name>` — repo details; `repos clone [--parallel]` — clone all repos |
| **pipelines** | `azdocli pipelines list` — list pipelines; `pipelines runs --id <n>` — show pipeline runs |
| **boards work-item** | `azdocli boards work-item list` — my work items; `boards work-item create bug --title "..."` — create bug |
| **projects** | `azdocli projects list` — list team projects |

See [REFERENCE.md](REFERENCE.md) for the full command catalog with all flags and examples.
