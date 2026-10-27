---
name: azdocli
description: Interact with Azure DevOps via azdocli for repository browsing, PRs and linked work items, pipelines and runs, classic releases, Azure Artifacts feeds and Universal Packages, work items, area and iteration paths, projects, teams, and processes. Use when managing repositories, listing my pull requests, queueing or inspecting pipeline runs, releasing a specific build, downloading or publishing Universal Packages, querying or commenting on work items, managing sprints/iterations or area paths, discovering teams or process templates, or creating pull requests.
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
# Login (interactive — prompts for org + PAT; the PAT is stored encrypted and machine-bound)
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
| `--draft` | `false` | Open as a draft |
| `--reviewer` | *(none)* | Repeatable; email, identity ID, or `@me` |
| `--work-item` | *(none)* | Repeatable; link a work item ID |
| `--label` | *(none)* | Repeatable |
| `--auto-complete` | `false` | Merge automatically once policies pass |
| `--delete-source-branch` | `false` | Delete source branch on completion |

### PR lifecycle (view & update)

```bash
# List PRs in a repo, or across the whole project when --repo is omitted
azdocli repos pr list --repo "$REPO"
azdocli repos pr list

# My PRs (created by me + assigned to me for review), like the web "Mine" tab
azdocli repos pr list --mine
azdocli repos pr list --mine --status completed

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

# Read, link, or unlink work items on an existing PR
azdocli repos pr work-item list --repo "$REPO" --id 123
azdocli repos pr work-item add --repo "$REPO" --id 123 --work-item 42 --work-item 43
azdocli repos pr work-item remove --repo "$REPO" --id 123 --work-item 42

# Complete, abandon or reactivate
azdocli repos pr complete --repo "$REPO" --id 123 --merge-strategy squash --delete-source-branch
azdocli repos pr abandon --repo "$REPO" --id 123 --yes
azdocli repos pr reactivate --repo "$REPO" --id 123
```

> azdocli can create, update, review, discuss, and merge PRs — most edits no longer require the Azure DevOps web UI.

## Work item planning paths

Set iteration and area paths when creating or updating work items:

```bash
azdocli boards work-item create task --title "Write tests" \
  --iteration "MyProject\Sprint 1" --area "MyProject\Team A"
azdocli boards work-item update --id 123 \
  --iteration "MyProject\Sprint 1" --area "MyProject\Team A"
```

`--iteration` sets `System.IterationPath`; `--area` sets `System.AreaPath`.

Manage the paths themselves, and which ones a team uses, with `boards area` and `boards iteration`:

```bash
# Project-level trees
azdocli boards iteration project list --depth 2
azdocli boards iteration project create --name "Sprint 1" --start-date 2026-06-01 --finish-date 2026-06-14
azdocli boards area project create --name "Backend" --path "MyProject\Team A"

# Team-level assignments
azdocli boards iteration team list --team "Team A" --timeframe current
azdocli boards iteration team add --team "Team A" --path "MyProject\Sprint 1"
azdocli boards iteration team list-work-items --team "Team A" --path "MyProject\Sprint 1"
azdocli boards area team add --team "Team A" --path "MyProject\Team A" --include-sub-areas
```

`--path` accepts `\MyProject\Area\Team A`, `MyProject\Team A`, or a path relative to the project root.

## Pipelines (az pipelines–compatible)

`pipelines` commands use the same names and arguments as `az pipelines`. Run-level commands live under `pipelines runs`:

```bash
azdocli pipelines list --name "web*"
azdocli pipelines show --name web-ci
azdocli pipelines run --name web-ci --branch develop --variables env=staging --parameters image=ubuntu-latest
azdocli pipelines runs list --pipeline-ids 42 --result failed --top 10
azdocli pipelines runs show --id 123
azdocli pipelines runs logs --run-id 123 --log-id 7
azdocli pipelines runs artifact list --run-id 123
```

> Older forms (`pipelines runs --id`, `pipelines show --build-id`, `pipelines logs`, `pipelines artifacts`, `--variable a=1`) no longer work — see the mapping table in [REFERENCE.md](REFERENCE.md#pipelines).

## Releases & Artifacts

```bash
# Create a classic release of a specific build
azdocli releases definitions --name web
azdocli releases create --definition-id 5 --build-id 1234
azdocli releases show --id 87

# Azure Artifacts: feeds, packages, Universal Packages
azdocli artifacts feeds list
azdocli artifacts packages versions --feed tools --name cli
azdocli artifacts universal download --feed tools --name cli --version 1.2.3 --path ./cli
azdocli artifacts universal publish --feed tools --name cli --version 1.2.4 --path ./dist
```

Feeds are organization-scoped by default; pass `--project` (or `--scope project`) for a project feed.

## Other commands (quick reference)

| Group | What you'll commonly run |
|-------|--------------------------|
| **repos** | `azdocli repos list` — list repos; `repos show --id <name>` — repo details; `repos clone [--parallel]` — clone all repos; browse without cloning with `repos branches`, `repos commits`, `repos files`, and `repos file` |
| **pipelines** | `pipelines list/show/run` by ID or name; `pipelines runs list/show/logs`, `runs artifact list`, `runs tag list`; `folder list`; `variable list`; inspect `variable-group` and `service-connection` resources |
| **releases** | `releases definitions`, `list`, `show`, and `create --definition-id <id> --build-id <id>` for classic release pipelines |
| **artifacts** | `artifacts feeds list`; `packages list/versions`; `universal download/publish` |
| **boards work-item** | `azdocli boards work-item list` (mine by default; `--assigned-to <who>` or `--all`); create child items with `--parent`; set `--iteration` and `--area` paths on create or update; run `boards query --wiql <query>`; list types or read/add comments with `work-item types` and `work-item comment` |
| **boards area / iteration** | `boards area project ...`/`boards area team ...` and `boards iteration project ...`/`boards iteration team ...` to manage paths, team assignments, and default/backlog iterations |
| **projects** | `azdocli projects list`; discover teams with `projects teams`, members with `projects members --team <team>`, and templates with `projects processes` |

See [REFERENCE.md](REFERENCE.md) for the full command catalog with all flags and examples.
