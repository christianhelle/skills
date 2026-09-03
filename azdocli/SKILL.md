---
name: azdocli
description: Interact with Azure DevOps via the azdocli CLI tool (repos, PRs, pipelines, boards, projects). Use when working with Azure DevOps, creating pull requests, managing repos, running pipelines, or querying boards. Use when user says "create a pull request".
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

### PR lifecycle (view & update)

```bash
# List PRs in a repo
azdocli repos pr list --repo "$REPO"

# Show PR details
azdocli repos pr show --repo "$REPO" --id 123

# Show commits in a PR
azdocli repos pr commits --repo "$REPO" --id 123

# Update PR title / description
azdocli repos pr update --repo "$REPO" --id 123 --title "New title"
azdocli repos pr update --repo "$REPO" --id 123 --description-file ./description.md
```

### PR review, discussion & merge

```bash
# Manage reviewers (email, identity ID, or @me)
azdocli repos pr reviewers add --repo "$REPO" --id 123 --reviewer alice@example.com
azdocli repos pr reviewers vote --repo "$REPO" --id 123 --vote approve

# Read and write comments
azdocli repos pr threads --repo "$REPO" --id 123
azdocli repos pr comment add --repo "$REPO" --id 123 --message "Looks good to me"
azdocli repos pr comment reply --repo "$REPO" --id 123 --thread 7 --message "Fixed"
azdocli repos pr comment resolve --repo "$REPO" --id 123 --thread 7

# Complete, abandon or reactivate
azdocli repos pr complete --repo "$REPO" --id 123 --merge-strategy squash --delete-source-branch
azdocli repos pr abandon --repo "$REPO" --id 123 --yes
azdocli repos pr reactivate --repo "$REPO" --id 123
```

> azdocli can create, update, review, discuss, and merge PRs — most edits no longer require the Azure DevOps web UI.

## Other commands (quick reference)

| Group | What you'll commonly run |
|-------|--------------------------|
| **repos** | `azdocli repos list` — list repos; `repos show --id <name>` — repo details; `repos clone [--parallel]` — clone all repos |
| **pipelines** | `azdocli pipelines list` — list pipelines; `pipelines runs --id <n>` — show pipeline runs |
| **boards work-item** | `azdocli boards work-item list` — my work items; `boards work-item create bug --title "..."` — create bug |
| **projects** | `azdocli projects list` — list team projects |

See [REFERENCE.md](REFERENCE.md) for the full command catalog with all flags and examples.
