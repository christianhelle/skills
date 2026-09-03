# azdocli Reference

Complete command catalog for [azdocli](https://github.com/christianhelle/azdocli).

## Authentication & config

### `azdocli login`

Login to Azure DevOps with a Personal Access Token (PAT). Interactive prompts for org + PAT.

| Flag | Description |
|------|-------------|
| `--profile <NAME>` | Named credential profile (for `migrate`). Omit to use default store. |

```bash
azdocli login
azdocli login --profile my-org
```

### `azdocli logout`

Remove stored credentials and config.

```bash
azdocli logout
```

### `azdocli project [PROJECT_NAME]`

Set or view the default project (persisted in user config).

| Arg | Description |
|-----|-------------|
| `[PROJECT_NAME]` | If provided, sets the default. If omitted, shows current default. |

```bash
azdocli project MyProject   # set default
azdocli project             # view current default
```

## Repos

### `azdocli repos create`

Create a new repository.

| Flag | Required | Description |
|------|----------|-------------|
| `-n, --name <NAME>` | Yes | Repository name |
| `-p, --project <NAME>` | No | Team project (defaults to configured) |

```bash
azdocli repos create --name NewRepo
```

### `azdocli repos list`

List all repositories in a project.

| Flag | Required | Description |
|------|----------|-------------|
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli repos list
```

### `azdocli repos show`

Show repository details.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <REPO_NAME>` | Yes | Repository name (not GUID) |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli repos show --id MyRepo
```

### `azdocli repos delete`

Delete a repository.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-i, --id <REPO_NAME>` | Yes | | Repository name |
| `-p, --project <NAME>` | No | default | Team project |
| `--hard` | No | `false` | Permanent deletion |
| `-y, --yes` | No | `false` | Skip confirmation |

```bash
azdocli repos delete --id MyRepo
azdocli repos delete --id MyRepo --hard --yes
```

### `azdocli repos clone`

Clone all repositories from a project.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-p, --project <NAME>` | No | default | Team project |
| `-d, --target-dir <DIR>` | No | `.` | Target directory |
| `-y, --yes` | No | `false` | Skip confirmation |
| `-j, --parallel` | No | `false` | Clone in parallel |
| `--concurrency <N>` | No | `4` | Max concurrent clones (1-8) |

```bash
azdocli repos clone
azdocli repos clone --target-dir ./repos --yes --parallel --concurrency 8
```

### `azdocli repos pr list`

List pull requests for a repository.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-r, --repo <NAME>` | Yes | | Repository name |
| `--status <STATUS>` | No | `active` | `active`, `completed`, `abandoned`, or `all` |
| `--creator <IDENTITY>` | No | *(none)* | Filter by author; email, identity ID, or `@me` |
| `--reviewer <IDENTITY>` | No | *(none)* | Filter by reviewer; email, identity ID, or `@me` |
| `--source <BRANCH>` | No | *(none)* | Filter by source branch |
| `--target <BRANCH>` | No | *(none)* | Filter by target branch |
| `--top <N>` | No | *(none)* | Cap the number of results |
| `-p, --project <NAME>` | No | default | Team project |

```bash
azdocli repos pr list --repo MyRepo
azdocli repos pr list --repo MyRepo --status completed
azdocli repos pr list --repo MyRepo --creator @me --top 10
```

### `azdocli repos pr show`

Show details of a specific pull request.

| Flag | Required | Description |
|------|----------|-------------|
| `-r, --repo <NAME>` | Yes | Repository name |
| `-i, --id <PR_ID>` | Yes | Pull request ID (numeric) |
| `-p, --project <NAME>` | No | Team project |
| `--web` | No | Open in browser instead |

```bash
azdocli repos pr show --repo MyRepo --id 123
azdocli repos pr show --repo MyRepo --id 123 --web
```

### `azdocli repos pr create`

Create a new pull request.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-r, --repo <NAME>` | Yes | | Repository name |
| `-s, --source <BRANCH>` | Yes | | Source branch (auto-prefixed `refs/heads/`) |
| `--target <BRANCH>` | No | `main` | Target branch (auto-prefixed) |
| `-t, --title <TITLE>` | No | `Pull Request` | PR title |
| `-d, --description <DESC>` | No | *(none)* | PR description |
| `--draft` | No | `false` | Open as a draft |
| `--reviewer <IDENTITY>` | No | *(none)* | Repeatable; email, identity ID, or `@me` |
| `--work-item <ID>` | No | *(none)* | Repeatable; link a work item ID |
| `--label <LABEL>` | No | *(none)* | Repeatable |
| `--auto-complete` | No | `false` | Complete automatically once policies pass |
| `--delete-source-branch` | No | `false` | Delete source branch on completion |
| `-p, --project <NAME>` | No | default | Team project |

```bash
azdocli repos pr create --repo MyRepo --source feature/my-feature --target main --title "My Feature"
azdocli repos pr create --repo MyRepo --source bugfix/fix-login --title "Fix login" --description "Detailed description here"
azdocli repos pr create --repo MyRepo --source feature/my-feature --title "My Feature" \
  --draft --reviewer alice@example.com --work-item 1234 --label "needs-review"
azdocli repos pr create --repo MyRepo --source feature/my-feature --title "My Feature" \
  --auto-complete --delete-source-branch
```

### `azdocli repos pr update`

Update an existing pull request's title and/or description.

| Flag | Required | Description |
|------|----------|-------------|
| `-r, --repo <NAME>` | Yes | Repository name |
| `-i, --id <PR_ID>` | Yes | Pull request ID (numeric) |
| `-t, --title <TITLE>` | One of | New title |
| `-d, --description <DESC>` | One of | New description |
| `--description-file <PATH>` | One of | Read description from markdown file |
| `-p, --project <NAME>` | No | Team project |

> At least one of `--title`, `--description`, or `--description-file` is required. File contents take precedence over `--description`.

```bash
azdocli repos pr update --repo MyRepo --id 123 --title "New title" --description "New description"
azdocli repos pr update --repo MyRepo --id 123 --title "New title"
azdocli repos pr update --repo MyRepo --id 123 --description-file ./description.md
```

### `azdocli repos pr commits`

Show commits in a pull request.

| Flag | Required | Description |
|------|----------|-------------|
| `-r, --repo <NAME>` | Yes | Repository name |
| `-i, --id <PR_ID>` | Yes | Pull request ID (numeric) |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli repos pr commits --repo MyRepo --id 123
```

## Pipelines

### `azdocli pipelines list`

List all pipelines in a project.

| Flag | Required | Description |
|------|----------|-------------|
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli pipelines list
```

### `azdocli pipelines runs`

Show all runs (builds) of a pipeline.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <ID>` | Yes | Pipeline ID (numeric) |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli pipelines runs --id 42
```

### `azdocli pipelines show`

Show details of a specific pipeline build.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <ID>` | Yes | Pipeline ID (numeric) |
| `-b, --build-id <ID>` | Yes | Build ID (numeric) |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli pipelines show --id 42 --build-id 123
```

### `azdocli pipelines run`

Start a new pipeline run.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <ID>` | Yes | Pipeline ID |
| `-p, --project <NAME>` | No | Team project |

```
azdocli pipelines run --id 42
```

> **Note:** This command is registered but returns "not yet fully implemented".

## Boards (work items)

### `azdocli boards work-item list`

List work items assigned to the current user.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-p, --project <NAME>` | No | default | Team project |
| `--state <STATE>` | No | all | Filter by state (e.g., `Active`) |
| `--work-item-type <TYPE>` | No | all | Filter by type (e.g., `Bug`, `Task`) |
| `--limit <N>` | No | `50` | Max results |

```bash
azdocli boards work-item list
azdocli boards work-item list --state Active --work-item-type Bug --limit 20
```

### `azdocli boards work-item show`

Show details of a work item.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-i, --id <ID>` | Yes | | Work item ID (numeric) |
| `-p, --project <NAME>` | No | default | Team project |
| `--web` | No | `false` | Open in browser |

```bash
azdocli boards work-item show --id 123
azdocli boards work-item show --id 123 --web
```

### `azdocli boards work-item create`

Create a new work item. Subcommand selects the type.

| Subcommand | Description |
|------------|-------------|
| `bug` | Bug |
| `task` | Task |
| `user-story` | User Story |
| `feature` | Feature |
| `epic` | Epic |

| Flag | Required | Description |
|------|----------|-------------|
| `-t, --title <TITLE>` | Yes | Work item title |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli boards work-item create bug --title "Fix login issue"
azdocli boards work-item create user-story --title "Dark mode"
```

### `azdocli boards work-item update`

Update a work item.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <ID>` | Yes | Work item ID (numeric) |
| `-p, --project <NAME>` | No | Team project |
| `--title <TITLE>` | No | New title |
| `--description <DESC>` | No | New description |
| `--state <STATE>` | No | New state (e.g., `Resolved`, `Closed`) |
| `--priority <N>` | No | New priority (1-4) |

```bash
azdocli boards work-item update --id 123 --state Active --priority 2
```

### `azdocli boards work-item delete`

Delete a work item.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-i, --id <ID>` | Yes | | Work item ID (numeric) |
| `-p, --project <NAME>` | No | default | Team project |
| `--soft-delete` | No | `false` | Change state to `Removed` instead of permanent delete |

```bash
azdocli boards work-item delete --id 123
azdocli boards work-item delete --id 123 --soft-delete
```

## Projects

### `azdocli projects list`

List all team projects in the organization.

```bash
azdocli projects list
```

### `azdocli projects show`

Show a team project.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-p, --project <NAME>` | Yes | | Project name or ID |
| `--open` | No | `false` | Open in default browser |

```bash
azdocli projects show --project MyProject
azdocli projects show --project MyProject --open
```

### `azdocli projects create`

Create a new team project.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `--name <NAME>` | Yes | | Project name |
| `-d, --description <DESC>` | No | *(none)* | Description |
| `-s, --source-control <TYPE>` | No | `git` | `git` or `tfvc` |
| `--visibility <VIS>` | No | `private` | `private` or `public` |
| `-p, --process <PROCESS>` | No | default | Process template name or ID |
| `--open` | No | `false` | Open in browser after creation |

```bash
azdocli projects create --name NewProject --description "My new project"
azdocli projects create --name NewProject --source-control git --visibility private --open
```

### `azdocli projects delete`

Delete a team project.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `--id <ID>` | Yes | | Project ID |
| `-y, --yes` | No | `false` | Skip confirmation |

```bash
azdocli projects delete --id <project-id>
azdocli projects delete --id <project-id> --yes
```

> Project ID is a GUID — use `azdocli projects show --project Name` to get it.

## Users

### `azdocli user add`

Add a user to the organization.

| Flag | Required | Description |
|------|----------|-------------|
| `--email <EMAIL>` | Yes | User email (principal name) |
| `--license <TYPE>` | Yes | License type: `none`, `earlyAdopter`, `express`, `professional`, `advanced`, `stakeholder` |

```bash
azdocli user add --email user@company.com --license express
```

### `azdocli user list`

List users (excludes AAD group rule assignments).

```bash
azdocli user list
```

### `azdocli user show`

Show user details. Requires exactly one of `--id` or `--email`.

| Flag | Description |
|------|-------------|
| `--id <UUID>` | User ID (mutually exclusive with `--email`) |
| `--email <EMAIL>` | User email (mutually exclusive with `--id`) |

```bash
azdocli user show --email user@company.com
azdocli user show --id <uuid>
```

### `azdocli user remove`

Remove a user from the organization. Requires exactly one of `--id` or `--email`.

| Flag | Description |
|------|-------------|
| `--id <UUID>` | User ID |
| `--email <EMAIL>` | User email |

```bash
azdocli user remove --email user@company.com
```

### `azdocli user update`

Update a user's license type. Requires exactly one of `--id` or `--email`.

| Flag | Required | Description |
|------|----------|-------------|
| `--license <TYPE>` | Yes | New license type |
| `--id <UUID>` | One of | User ID |
| `--email <EMAIL>` | One of | User email |

```bash
azdocli user update --email user@company.com --license stakeholder
```

## Wiki

### `azdocli wiki list`

List wikis in a project.

| Flag | Required | Description |
|------|----------|-------------|
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli wiki list
```

### `azdocli wiki show`

Show wiki details. Auto-resolves if only one wiki exists.

| Arg/Flag | Required | Description |
|----------|----------|-------------|
| `[ID]` | No | Wiki ID or name |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli wiki show
azdocli wiki show MyWiki
```

### `azdocli wiki page list`

List pages in a wiki.

| Arg/Flag | Required | Default | Description |
|----------|----------|---------|-------------|
| `[PATH]` | No | `/` | Root path to list from |
| `-w, --wiki <ID>` | No | auto-resolve | Wiki ID or name |
| `-p, --project <NAME>` | No | default | Team project |

```bash
azdocli wiki page list
azdocli wiki page list /Home
```

### `azdocli wiki page show`

Show page content.

| Arg/Flag | Required | Description |
|----------|----------|-------------|
| `<PATH>` | Yes | Page path (e.g., `/My-Page`) |
| `-w, --wiki <ID>` | No | Wiki ID or name |
| `-p, --project <NAME>` | No | Team project |
| `--web` | No | Open in browser |

```bash
azdocli wiki page show /Getting-Started
azdocli wiki page show /Getting-Started --web
```

### `azdocli wiki page download`

Download page content to a file.

| Arg/Flag | Required | Default | Description |
|----------|----------|---------|-------------|
| `<PATH>` | Yes | | Page path |
| `--dir <DIR>` | No | `.` | Output folder |
| `--name <NAME>` | No | derived from path | Output file name |
| `--overwrite` | No | `false` | Overwrite existing file |
| `-w, --wiki <ID>` | No | auto-resolve | Wiki ID or name |
| `-p, --project <NAME>` | No | default | Team project |

```bash
azdocli wiki page download /Getting-Started --dir ./docs
```

### `azdocli wiki page search`

Search wiki content.

| Arg/Flag | Required | Default | Description |
|----------|----------|---------|-------------|
| `<QUERY>` | Yes | | Search query |
| `--show-contents` | No | `false` | Show content snippets |
| `-l, --limit <N>` | No | `3` | Max results |
| `-p, --project <NAME>` | No | default | Team project |

```bash
azdocli wiki page search "API key"
azdocli wiki page search "deploy" --show-contents --limit 10
```

### `azdocli wiki page move`

Move or rename a page.

| Arg/Flag | Required | Description |
|----------|----------|-------------|
| `<PATH>` | Yes | Current page path |
| `<NEW_PATH>` | Yes | New page path |
| `-w, --wiki <ID>` | No | Wiki ID or name |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli wiki page move /Old-Name /New-Name
```

## Migrate (experimental)

Cross-tenant team-project migration. Requires named credential profiles via `azdocli login --profile <name>`.

### `azdocli migrate project`

Migrate a single team project.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `--source-profile <NAME>` | Yes | | Source credential profile |
| `--target-profile <NAME>` | Yes | | Target credential profile |
| `--source <PROJECT>` | Yes | | Source team project name |
| `--target <PROJECT>` | No | source name | Target team project name |
| `--create-target` | No | `false` | Create target project if missing |
| `--phases <PHASES>` | No | all | Comma-separated phases to include |
| `--skip-phases <PHASES>` | No | none | Comma-separated phases to skip |
| `--dry-run` | No | `false` | Enumerate without writing |
| `--fail-fast` | No | `false` | Stop on first error |
| `--resume` | No | `false` | Continue from state file |
| `--state-file <PATH>` | No | auto | Override state-file path |
| `--output-dir <DIR>` | No | `./azdocli-migration-...` | Artifacts directory |
| `--concurrency <N>` | No | `4` | Max concurrent API calls per phase |
| `-y, --yes` | No | `false` | Skip confirmations |

```bash
azdocli migrate project --source-profile src --target-profile dst --source "OldProject" --create-target --dry-run
```

### `azdocli migrate batch`

Migrate multiple projects from a JSON manifest.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `--config <PATH>` | Yes | | Path to JSON manifest file |
| `--dry-run` | No | `false` | Enumerate only |
| `--fail-fast` | No | `false` | Stop on first project error |
| `--resume` | No | `false` | Continue from state files |
| `-y, --yes` | No | `false` | Skip confirmations |

```bash
azdocli migrate batch --config manifest.json --dry-run
```

### Available migration phases

`project`, `process`, `areas`, `iterations`, `teams_create`, `teams_configure`, `repos`, `wikis`, `variable_groups`, `service_connections`, `work_items`, `wi_links`, `wi_attachments`, `wi_comments`, `prs`, `pipelines_yaml`, `pipelines_classic`, `test_plans`, `dashboards`
