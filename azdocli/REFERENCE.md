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

### `azdocli repos branches`

List branches in a repository. The default branch is marked in the output.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <REPO>` | Yes | Repository name or ID |
| `-p, --project <NAME>` | No | Team project |
| `--filter <TEXT>` | No | Only list branches whose names contain this text |
| `--top <N>` | No | Maximum number of branches to return |

```bash
azdocli repos branches --id MyRepo
azdocli repos branches --id MyRepo --filter feature --top 20
```

### `azdocli repos commits`

List a repository's commit history. The repository's default branch is used unless `--branch` is specified.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-i, --id <REPO>` | Yes | | Repository name or ID |
| `-p, --project <NAME>` | No | default | Team project |
| `-b, --branch <BRANCH>` | No | default branch | Branch to read history from |
| `--author <NAME>` | No | *(none)* | Only list commits by this author |
| `--path <PATH>` | No | *(none)* | Only list commits that touch this path |
| `--top <N>` | No | `25` | Maximum number of commits to return |

```bash
azdocli repos commits --id MyRepo
azdocli repos commits --id MyRepo --branch develop --author "Alex Smith" --path src --top 50
```

### `azdocli repos files`

List files and folders in a repository without cloning it. The default branch is used unless `--branch` is specified.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-i, --id <REPO>` | Yes | | Repository name or ID |
| `-p, --project <NAME>` | No | default | Team project |
| `--path <PATH>` | No | `/` | Folder to list |
| `-b, --branch <BRANCH>` | No | default branch | Branch to read from |
| `-r, --recursive` | No | `false` | List the whole tree instead of only immediate children |

```bash
azdocli repos files --id MyRepo
azdocli repos files --id MyRepo --path /src --branch develop --recursive
```

### `azdocli repos file`

Print a file's contents to standard output. The default branch is used unless `--branch` is specified.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <REPO>` | Yes | Repository name or ID |
| `-p, --project <NAME>` | No | Team project |
| `--path <PATH>` | Yes | Path of the file |
| `-b, --branch <BRANCH>` | No | Branch to read from |

```bash
azdocli repos file --id MyRepo --path /README.md
azdocli repos file --id MyRepo --path /src/main.rs --branch develop
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

### `azdocli repos pr work-item`

List, link, or unlink work items associated with an existing pull request.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `list` | `-r, --repo <NAME>`, `-i, --id <PR_ID>`, `-p, --project <NAME>` | List linked work items with their type, state, and title |
| `add` | `-r, --repo <NAME>`, `-i, --id <PR_ID>`, `--work-item <ID>` (repeatable or comma-separated), `-p, --project <NAME>` | Link work item(s) |
| `remove` | `-r, --repo <NAME>`, `-i, --id <PR_ID>`, `--work-item <ID>` (repeatable or comma-separated), `-p, --project <NAME>` | Unlink work item(s) |

Already-linked work items are reported and skipped when using `add`.

```bash
azdocli repos pr work-item list --repo MyRepo --id 123
azdocli repos pr work-item add --repo MyRepo --id 123 --work-item 42 --work-item 43
azdocli repos pr work-item remove --repo MyRepo --id 123 --work-item 42
```

### `azdocli repos pr complete`

Merge a pull request.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-r, --repo <NAME>` | Yes | | Repository name |
| `-i, --id <PR_ID>` | Yes | | Pull request ID (numeric) |
| `--merge-strategy <STRATEGY>` | No | *(server default)* | e.g. `squash` |
| `--delete-source-branch` | No | `false` | Delete source branch after merge |
| `--auto-complete` | No | `false` | Complete automatically once policies pass |
| `--bypass-policy` | No | `false` | Complete despite failing branch policies |
| `--bypass-reason <TEXT>` | No | *(none)* | Reason recorded when bypassing policy |
| `-y, --yes` | No | `false` | Skip confirmation |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli repos pr complete --repo MyRepo --id 123 --merge-strategy squash --delete-source-branch
azdocli repos pr complete --repo MyRepo --id 123 --auto-complete --yes
azdocli repos pr complete --repo MyRepo --id 123 --bypass-policy --bypass-reason "hotfix"
```

### `azdocli repos pr abandon`

Close a pull request without merging.

| Flag | Required | Description |
|------|----------|-------------|
| `-r, --repo <NAME>` | Yes | Repository name |
| `-i, --id <PR_ID>` | Yes | Pull request ID (numeric) |
| `-y, --yes` | No | Skip confirmation |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli repos pr abandon --repo MyRepo --id 123 --yes
```

### `azdocli repos pr reactivate`

Reopen an abandoned pull request.

| Flag | Required | Description |
|------|----------|-------------|
| `-r, --repo <NAME>` | Yes | Repository name |
| `-i, --id <PR_ID>` | Yes | Pull request ID (numeric) |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli repos pr reactivate --repo MyRepo --id 123
```

### `azdocli repos pr reviewers`

Manage pull request reviewers. Reviewers can be given as an email address, an identity ID, or `@me` for the signed-in user.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `list` | `-r, --repo`, `-i, --id`, `-p, --project` | List reviewers with their votes |
| `add` | `-r, --repo`, `-i, --id`, `--reviewer <IDENTITY>` (repeatable), `--required`, `-p, --project` | Add reviewer(s), optionally required |
| `remove` | `-r, --repo`, `-i, --id`, `--reviewer <IDENTITY>`, `-p, --project` | Remove a reviewer |
| `vote` | `-r, --repo`, `-i, --id`, `--vote <VOTE>`, `-p, --project` | Cast your own vote |

Valid votes: `approve`, `approve-with-suggestions`, `reset`, `wait-for-author`, `reject`.

```bash
azdocli repos pr reviewers list --repo MyRepo --id 123
azdocli repos pr reviewers add --repo MyRepo --id 123 --reviewer alice@example.com --required
azdocli repos pr reviewers remove --repo MyRepo --id 123 --reviewer alice@example.com
azdocli repos pr reviewers vote --repo MyRepo --id 123 --vote approve
```

### `azdocli repos pr threads`

Read the discussion on a pull request. System-generated threads are hidden unless `--all` is given.

| Flag | Required | Description |
|------|----------|-------------|
| `-r, --repo <NAME>` | Yes | Repository name |
| `-i, --id <PR_ID>` | Yes | Pull request ID (numeric) |
| `--all` | No | Include system-generated threads |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli repos pr threads --repo MyRepo --id 123
azdocli repos pr threads --repo MyRepo --id 123 --all
```

### `azdocli repos pr comment`

Write to pull request discussion threads.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `add` | `-r, --repo`, `-i, --id`, `--message <TEXT>`, `--file <PATH>`, `--line <N>`, `-p, --project` | Start a new thread, optionally anchored to a file/line |
| `reply` | `-r, --repo`, `-i, --id`, `--thread <ID>`, `--message <TEXT>`, `-p, --project` | Reply to an existing thread |
| `resolve` | `-r, --repo`, `-i, --id`, `--thread <ID>`, `--status <STATUS>`, `-p, --project` | Resolve a thread |

Valid thread statuses: `fixed`, `wont-fix`, `closed`, `by-design`, `active`, `pending`.

```bash
azdocli repos pr comment add --repo MyRepo --id 123 --message "Looks good to me"
azdocli repos pr comment add --repo MyRepo --id 123 --message "Needs a null check" --file "/src/main.rs" --line 42
azdocli repos pr comment reply --repo MyRepo --id 123 --thread 7 --message "Fixed in the latest push"
azdocli repos pr comment resolve --repo MyRepo --id 123 --thread 7
azdocli repos pr comment resolve --repo MyRepo --id 123 --thread 7 --status wont-fix
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

Show a pipeline's runs, including their state, result, and creation date.

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

Queue a new pipeline run.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-i, --id <ID>` | Yes | | Pipeline ID |
| `-p, --project <NAME>` | No | default | Team project |
| `-b, --branch <BRANCH>` | No | pipeline default branch | Branch to run the pipeline from |
| `--variable <NAME=VALUE>` | No | *(none)* | Pipeline variable; repeat for multiple variables |

```bash
azdocli pipelines run --id 42
azdocli pipelines run --id 42 --branch develop --variable environment=staging --variable verbose=true
```

### `azdocli pipelines logs`

List a run's logs or print one log to standard output.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <ID>` | Yes | Pipeline ID |
| `-p, --project <NAME>` | No | Team project |
| `-b, --build-id <ID>` | Yes | Run (build) ID |
| `--log-id <ID>` | No | Print this log instead of listing the run's logs |

```bash
azdocli pipelines logs --id 42 --build-id 123
azdocli pipelines logs --id 42 --build-id 123 --log-id 7
```

### `azdocli pipelines artifacts`

List artifacts published by a pipeline run. The output includes artifact download URLs.

| Flag | Required | Description |
|------|----------|-------------|
| `-b, --build-id <ID>` | Yes | Run (build) ID |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli pipelines artifacts --build-id 123
```

### `azdocli pipelines variable-group`

Inspect variable groups in a project.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `list` | `-p, --project <NAME>`, `--name <TEXT>`, `--top <N>` | List groups, optionally filtering by name and limiting results |
| `show` | `-i, --id <ID>`, `-p, --project <NAME>` | Show a group's variables |

Secret variable values are not returned by Azure DevOps and are displayed as `<secret>`.

```bash
azdocli pipelines variable-group list
azdocli pipelines variable-group list --name release --top 10
azdocli pipelines variable-group show --id 7
```

### `azdocli pipelines service-connection`

Inspect service connections in a project.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `list` | `-p, --project <NAME>`, `--type <TYPE>` | List connections, optionally filtered by type |
| `show` | `-i, --id <ID>`, `-p, --project <NAME>` | Show a service connection |

```bash
azdocli pipelines service-connection list
azdocli pipelines service-connection list --type azurerm
azdocli pipelines service-connection show --id 00000000-0000-0000-0000-000000000000
```

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
| `--parent <ID>` | No | ID of a parent work item |
| `--iteration <PATH>` | No | Iteration path (`System.IterationPath`), e.g. `MyProject\Sprint 1` |
| `--area <PATH>` | No | Area path (`System.AreaPath`), e.g. `MyProject\Team A` |

```bash
azdocli boards work-item create bug --title "Fix login issue"
azdocli boards work-item create task --title "Write tests" --iteration "MyProject\Sprint 1" --area "MyProject\Team A"
azdocli boards work-item create user-story --title "Dark mode"
azdocli boards work-item create task --title "Write integration tests" --parent 1234
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

### `azdocli boards work-item types`

List the work item types available in a project.

| Flag | Required | Description |
|------|----------|-------------|
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli boards work-item types
azdocli boards work-item types --project MyProject
```

### `azdocli boards work-item comment`

Read or add comments on a work item.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `list` | `-i, --id <ID>`, `-p, --project <NAME>`, `--top <N>` | List comments, optionally limiting the number returned |
| `add` | `-i, --id <ID>`, `-p, --project <NAME>`, `-m, --message <TEXT>` | Add a comment |

```bash
azdocli boards work-item comment list --id 123
azdocli boards work-item comment list --id 123 --top 5
azdocli boards work-item comment add --id 123 --message "Reproduced on the staging build"
```

### `azdocli boards query`

Run a WIQL query and list the work items it returns.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-w, --wiql <QUERY>` | Yes | | WIQL query |
| `-p, --project <NAME>` | No | default | Team project |
| `--limit <N>` | No | `50` | Maximum number of work items to return |

```bash
azdocli boards query --wiql "SELECT [System.Id] FROM WorkItems WHERE [System.State] = 'Active'"
azdocli boards query --wiql "SELECT [System.Id] FROM WorkItems" --limit 10
```

## Projects

### `azdocli projects list`

List all team projects in the organization.

```bash
azdocli projects list
```

### `azdocli projects teams`

List teams in a project, optionally limiting results to teams you belong to.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-p, --project <NAME>` | No | default | Team project |
| `--mine` | No | `false` | List only teams you are a member of |
| `--top <N>` | No | *(none)* | Maximum number of teams to return |

```bash
azdocli projects teams
azdocli projects teams --mine --top 10
```

### `azdocli projects members`

List members of a team. Administrators are marked in the output.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-t, --team <NAME_OR_ID>` | Yes | | Team name or ID |
| `-p, --project <NAME>` | No | default | Team project |
| `--top <N>` | No | *(none)* | Maximum number of members to return |

```bash
azdocli projects members --team "MyProject Team"
azdocli projects members --team "MyProject Team" --project MyProject
```

### `azdocli projects processes`

List process templates available in the organization. Use the listed names or IDs with `projects create --process`.

```bash
azdocli projects processes
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
