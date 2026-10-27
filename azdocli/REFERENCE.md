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

The PAT is never stored in plaintext: `~/.azdocli/credentials.json` and `~/.azdocli/profiles/*.json` hold an encrypted value (`enc:v1:...`) bound to the machine (DPAPI on Windows, AES-256-GCM on macOS/Linux). A copied credentials file does not work on another machine — run `azdocli login` there again. Plaintext credentials from older versions are re-encrypted automatically on next read.

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

List pull requests for a repository, or across every repository in the project when `--repo` is omitted. Output includes draft state and creation date.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-r, --repo <NAME>` | No | *(all repos)* | Repository name; omit to list across the whole project |
| `--status <STATUS>` | No | `active` | `active`, `completed`, `abandoned`, or `all` |
| `--mine` | No | `false` | PRs you created and PRs assigned to you for review (with your vote), in separate sections — like the web portal's "Mine" tab. Conflicts with `--creator`/`--reviewer` |
| `--creator <IDENTITY>` | No | *(none)* | Filter by author; email, identity ID, or `@me` |
| `--reviewer <IDENTITY>` | No | *(none)* | Filter by reviewer; email, identity ID, or `@me` |
| `-s, --source <BRANCH>` | No | *(none)* | Filter by source branch |
| `--target <BRANCH>` | No | *(none)* | Filter by target branch |
| `--top <N>` | No | `50` for non-active statuses | Cap the number of results (per section with `--mine`) |
| `-p, --project <NAME>` | No | default | Team project |

```bash
azdocli repos pr list --repo MyRepo
azdocli repos pr list                      # every repository in the project
azdocli repos pr list --mine
azdocli repos pr list --mine --status completed --repo MyRepo
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

The `pipelines` commands mirror the official `az pipelines` CLI: same command names and arguments for the read commands and `run`. Commands that change pipelines (`create`, `update`, `delete`, `folder create`, `runs tag add`, `variable-group create`), the `build`, `release`, `pool`, `agent` and `queue` groups, and global `--output`/`--query` are not supported. `--open` also accepts the alias `--web`.

> **Breaking change** — older azdocli versions used a different shape:
>
> | Before | Now |
> |--------|-----|
> | `pipelines runs --id 42` | `pipelines runs list --pipeline-ids 42` |
> | `pipelines show --id 42 --build-id 123` | `pipelines runs show --id 123` |
> | `pipelines logs --id 42 --build-id 123` | `pipelines runs logs --run-id 123` |
> | `pipelines artifacts --build-id 123` | `pipelines runs artifact list --run-id 123` |
> | `pipelines run --id 42 --variable a=1 --variable b=2` | `pipelines run --id 42 --variables a=1 b=2` |
> | `pipelines variable-group list --name x` | `pipelines variable-group list --group-name x` (`--name` still works) |
>
> `pipelines show` now shows the pipeline itself, not one of its runs.

### `azdocli pipelines list`

List pipelines in a project.

| Flag | Required | Description |
|------|----------|-------------|
| `-p, --project <NAME>` | No | Team project |
| `--name <NAME>` | No | Pipeline name; `*` is a wildcard |
| `--folder-path <PATH>` | No | Only pipelines under this folder |
| `--top <N>` | No | Max results |
| `--query-order <ORDER>` | No | `ModifiedAsc`, `ModifiedDesc`, `NameAsc`, `NameDesc`, `None` |
| `--repository <NAME_OR_ID>` | No | Only pipelines using this repository |
| `--repository-type <TYPE>` | No | Requires `--repository`; `tfsgit` (default), `git`, `github`, `githubenterprise`, `bitbucket`, `svn`, `tfsversioncontrol` |

```bash
azdocli pipelines list
azdocli pipelines list --name "web*" --folder-path team/web --top 10 --query-order NameAsc
azdocli pipelines list --repository owner/repo --repository-type github
```

### `azdocli pipelines show`

Show a pipeline by ID or name.

| Flag | Required | Description |
|------|----------|-------------|
| `-i, --id <ID>` | One of | Pipeline ID |
| `--name <NAME>` | One of | Pipeline name (ignored if `--id` is given) |
| `--folder-path <PATH>` | No | Disambiguate pipelines with the same name |
| `-p, --project <NAME>` | No | Team project |
| `--open` | No | Open the pipeline in the browser |

```bash
azdocli pipelines show --id 42
azdocli pipelines show --name web-ci --folder-path team/web
azdocli pipelines show --id 42 --open
```

### `azdocli pipelines run`

Queue a pipeline run.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-i, --id <ID>` | One of | | Pipeline ID |
| `--name <NAME>` | One of | | Pipeline name (ignored if `--id` is given) |
| `--folder-path <PATH>` | No | | Disambiguate pipelines with the same name |
| `-p, --project <NAME>` | No | default | Team project |
| `-b, --branch <BRANCH>` | No | pipeline default | `main`, `refs/heads/main`, or `refs/tags/v1` |
| `--commit-id <SHA>` | No | | Commit to run on |
| `--variables <NAME=VALUE>...` | No | | Space-separated variables |
| `--parameters <NAME=VALUE>...` | No | | Space-separated template parameters |
| `--open` | No | `false` | Open the new run in the browser |

```bash
azdocli pipelines run --id 42
azdocli pipelines run --name web-ci --branch develop
azdocli pipelines run --id 42 --commit-id 1a2b3c4d
azdocli pipelines run --id 42 --variables environment=staging verbose=true --parameters image=ubuntu-latest
```

### `azdocli pipelines runs`

Inspect pipeline runs.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `list` | `-p, --project`, `--pipeline-ids <ID>...`, `--branch`, `--top <N>`, `--query-order`, `--reason`, `--result`, `--status`, `--requested-for <USER>`, `--tags <TAG>...` | List runs of the project or of specific pipelines. Without `--top` only the first page is shown (with a note when more exist) |
| `show` | `-i, --id <RUN_ID>`, `-p, --project`, `--open` | Show a run |
| `artifact list` | `--run-id <ID>`, `-p, --project` | List a run's artifacts (with download URLs) |
| `tag list` | `--run-id <ID>`, `-p, --project` | List a run's tags |
| `logs` | `--run-id <ID>`, `-p, --project`, `--log-id <ID>` | List a run's logs, or print one log to stdout (not part of `az pipelines`) |

Filter values:

- `--query-order`: `FinishTimeAsc`, `FinishTimeDesc`, `QueueTimeAsc`, `QueueTimeDesc`, `StartTimeAsc`, `StartTimeDesc`
- `--reason`: `all`, `batchedCI`, `buildCompletion`, `checkInShelveset`, `individualCI`, `manual`, `pullRequest`, `schedule`, `triggered`, `userCreated`, `validateShelveset`
- `--result`: `canceled`, `failed`, `none`, `partiallySucceeded`, `succeeded`
- `--status`: `all`, `cancelling`, `completed`, `inProgress`, `none`, `notStarted`, `postponed`

```bash
azdocli pipelines runs list
azdocli pipelines runs list --pipeline-ids 42 43 --top 10
azdocli pipelines runs list --branch main --result failed --query-order QueueTimeDesc
azdocli pipelines runs list --status inProgress --reason pullRequest
azdocli pipelines runs list --requested-for "someone@example.com" --tags nightly release
azdocli pipelines runs show --id 123 --open
azdocli pipelines runs artifact list --run-id 123
azdocli pipelines runs tag list --run-id 123
azdocli pipelines runs logs --run-id 123
azdocli pipelines runs logs --run-id 123 --log-id 7
```

### `azdocli pipelines folder list`

List the folders pipelines are organized in.

| Flag | Required | Description |
|------|----------|-------------|
| `-p, --project <NAME>` | No | Team project |
| `--path <PATH>` | No | Folder to list, along with folders under it |
| `--query-order <ORDER>` | No | `Asc`, `Desc`, `None` |

```bash
azdocli pipelines folder list
azdocli pipelines folder list --path team --query-order Asc
```

### `azdocli pipelines variable list`

List the variables defined on a pipeline in Azure DevOps (the pipeline editor's Variables button). Variables declared in YAML are not included; secret values are never returned.

| Flag | Required | Description |
|------|----------|-------------|
| `--pipeline-id <ID>` | One of | Pipeline ID |
| `--pipeline-name <NAME>` | One of | Pipeline name (ignored if `--pipeline-id` is given) |
| `-p, --project <NAME>` | No | Team project |

```bash
azdocli pipelines variable list --pipeline-id 42
azdocli pipelines variable list --pipeline-name web-ci
```

### `azdocli pipelines variable-group`

Inspect variable groups in a project.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `list` | `-p, --project`, `--group-name <TEXT>` (alias `--name`), `--top <N>`, `--query-order <Asc\|Desc>`, `--action <manage\|none\|use>` | List groups. `--group-name` matches as a substring, or as a pattern when it contains `*` |
| `show` | `-i, --group-id <ID>` (alias `--id`), `-p, --project` | Show a group's variables; unknown IDs are reported as not found |

Secret variable values are not returned by Azure DevOps and are displayed as `<secret>`.

```bash
azdocli pipelines variable-group list
azdocli pipelines variable-group list --group-name release --query-order Asc --top 10
azdocli pipelines variable-group list --group-name "release-*"
azdocli pipelines variable-group list --action use
azdocli pipelines variable-group show --group-id 7
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

## Releases (classic)

Work with classic release pipelines — mainly to create a release that deploys a *specific* build rather than the latest one.

| Subcommand | Flags | Description |
|------------|-------|-------------|
| `definitions` | `--name <TEXT>`, `-p, --project` | List release definitions (name substring filter) |
| `list` | `-d, --definition-id <ID>`, `--top <N>`, `-p, --project` | List releases, optionally for one definition |
| `show` | `-i, --id <ID>`, `-p, --project` | Show a release and the status of each stage |
| `create` | `-d, --definition-id <ID>` (required), `-b, --build-id <ID>` (required), `-a, --artifact-alias <ALIAS>`, `--description <TEXT>`, `-p, --project` | Create a release of a build. The build is pinned to the definition's primary build artifact, or to `--artifact-alias` when the definition links several builds |

An unknown alias, or a definition without a primary build artifact, reports the aliases you can choose from.

```bash
azdocli releases definitions --name web
azdocli pipelines runs list --pipeline-ids 42          # find the build to release
azdocli releases create --definition-id 5 --build-id 1234
azdocli releases create --definition-id 5 --build-id 1234 --artifact-alias _web-ci --description "Hotfix for #321"
azdocli releases list --definition-id 5 --top 10
azdocli releases show --id 87
```

## Artifacts

Browse Azure Artifacts feeds and transfer Universal Packages (mirrors `az artifacts universal`).

Every `artifacts` command takes the feed scope flags:

| Flag | Default | Description |
|------|---------|-------------|
| `--scope <organization\|project>` | `organization` | Where the feed lives; `--scope project` alone uses the default project |
| `-p, --project <NAME>` | | Project of a project-scoped feed (implies `--scope project`) |

| Command | Flags | Description |
|---------|-------|-------------|
| `feeds list` | scope flags | List feeds in the organization, or only those of a project |
| `packages list` | `--feed <NAME_OR_ID>` (required), `--protocol <upack\|nuget\|npm\|maven\|pypi\|cargo>`, `--name <TEXT>` | List a feed's packages |
| `packages versions` | `--feed` (required), `-n, --name <PACKAGE>` (required), `--protocol` | List a package's versions; `--protocol` disambiguates same-named packages |
| `universal download` | `--feed`, `-n, --name`, `-v, --version`, `--path <DIR>` (all required), `--file-filter <GLOB>` | Download a Universal Package natively (no extra tools). Paths escaping `--path` are refused |
| `universal publish` | `--feed`, `-n, --name`, `-v, --version`, `--path <DIR>` (all required), `-d, --description` | Publish a directory via Microsoft's ArtifactTool (downloaded on first use, cached in `~/.azdocli/tools/ArtifactTool/<version>`) |

Universal Packages require Azure DevOps Services (`https://dev.azure.com`); they are not available on Azure DevOps Server.

```bash
azdocli artifacts feeds list
azdocli artifacts feeds list --project MyProject
azdocli artifacts packages list --feed tools --protocol upack --name cli
azdocli artifacts packages versions --feed tools --name cli
azdocli artifacts universal download --feed tools --name cli --version 1.2.3 --path ./cli --file-filter "*.dll"
azdocli artifacts universal publish --feed tools --name cli --version 1.2.4 --path ./dist --description "CLI tools"
```

## Boards (work items)

### `azdocli boards work-item list`

List work items assigned to the current user (default), to someone else, or to anyone.

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `-p, --project <NAME>` | No | default | Team project |
| `--assigned-to <PERSON>` | No | `@me` | Display name or email; conflicts with `--all` |
| `--all` | No | `false` | All work items in the project, whoever they are assigned to |
| `--state <STATE>` | No | all | Filter by state (e.g., `Active`) |
| `--work-item-type <TYPE>` | No | all | Filter by type (e.g., `Bug`, `Task`) |
| `--limit <N>` | No | `50` | Max results |

```bash
azdocli boards work-item list
azdocli boards work-item list --assigned-to "jane@contoso.com"
azdocli boards work-item list --all --state Active
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
| `--iteration <PATH>` | No | New iteration path (`System.IterationPath`) |
| `--area <PATH>` | No | New area path (`System.AreaPath`) |

```bash
azdocli boards work-item update --id 123 --state Active --priority 2
azdocli boards work-item update --id 123 --iteration "MyProject\Sprint 1" --area "MyProject\Team A"
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

### `azdocli boards area`

Manage a project's area paths and the areas each team owns. `--path` accepts the absolute form (`\MyProject\Area\Team A`), the work-item form (`MyProject\Team A`), or a path relative to the project root (`Team A`). All commands take `-p, --project`.

| Command | Flags | Description |
|---------|-------|-------------|
| `project list` | `--path`, `--depth <N>` (default `1`) | Show the area tree |
| `project show` | `--path` (required) | Show an area |
| `project create` | `--name` (required), `--path <PARENT>` | Create an area (under the root by default) |
| `project update` | `--path` (required), `--name <NEW>`, `--child-id <ID>` | Rename an area and/or move area `<ID>` (with children) under it; at least one of `--name`/`--child-id` |
| `project delete` | `--path` (required), `--reclassify-id <ID>` | Delete an area, moving its work items to area `<ID>` |
| `team list` | `--team` (required) | List the areas a team owns |
| `team add` | `--team`, `--path` (required), `--include-sub-areas [true\|false]`, `--set-as-default` | Give a team an area |
| `team update` | `--team`, `--path` (required), `--include-sub-areas [true\|false]`, `--set-as-default` | Change sub-area inclusion or make it the default; at least one change |
| `team remove` | `--team`, `--path` (required) | Take an area away from a team |

Adding an area a team already owns, or removing a team's default area, is refused.

```bash
azdocli boards area project list --depth 3
azdocli boards area project show --path "\MyProject\Area\Team A"
azdocli boards area project create --name "Backend" --path "MyProject\Team A"
azdocli boards area project update --path "MyProject\Team A\Backend" --name "Services"
azdocli boards area project update --path "MyProject\Team A" --child-id 15
azdocli boards area project delete --path "MyProject\Team A\Services" --reclassify-id 12
azdocli boards area team list --team "Team A"
azdocli boards area team add --team "Team A" --path "MyProject\Team A" --include-sub-areas --set-as-default
azdocli boards area team update --team "Team A" --path "MyProject\Team A" --include-sub-areas false
azdocli boards area team remove --team "Team A" --path "MyProject\Shared"
```

### `azdocli boards iteration`

Manage a project's iterations and the iterations each team works in. Paths follow the same rules as areas. Team commands that pick an iteration take either `--id <GUID>` or `--path`. All commands take `-p, --project`.

| Command | Flags | Description |
|---------|-------|-------------|
| `project list` | `--path`, `--depth <N>` (default `1`) | Show the iteration tree |
| `project show` | `--path` (required) | Show an iteration |
| `project create` | `--name` (required), `--path <PARENT>`, `--start-date`, `--finish-date` | Create an iteration; dates (`YYYY-MM-DD`) must be given together |
| `project update` | `--path` (required), `--name`, `--child-id <ID>`, `--start-date` + `--finish-date` | Rename, reschedule, or move iteration `<ID>` under it; at least one change |
| `project delete` | `--path` (required), `--reclassify-id <ID>` | Delete an iteration, moving its work items to `<ID>` |
| `team list` | `--team` (required), `--timeframe current` | List a team's iterations |
| `team add` | `--team`, `--id` or `--path` | Add an iteration to a team |
| `team remove` | `--team`, `--id` or `--path` | Remove an iteration from a team |
| `team list-work-items` | `--team`, `--id` or `--path` | List the work items in a team iteration |
| `team show-default-iteration` | `--team` | Show where new work items go |
| `team set-default-iteration` | `--team`, one of `--id`, `--path`, `--default-iteration-macro <MACRO>` | Set where new work items go (e.g. `@CurrentIteration`) |
| `team show-backlog-iteration` | `--team` | Show the team's backlog iteration |
| `team set-backlog-iteration` | `--team`, `--id` or `--path` | Set the team's backlog iteration |

```bash
azdocli boards iteration project list --depth 2
azdocli boards iteration project create --name "Sprint 1" --start-date 2026-06-01 --finish-date 2026-06-14
azdocli boards iteration project update --path "MyProject\Sprint 1" --start-date 2026-06-02 --finish-date 2026-06-15
azdocli boards iteration project update --path "MyProject\Sprint 1" --name "Sprint 01"
azdocli boards iteration project show --path "\MyProject\Iteration\Sprint 01"
azdocli boards iteration project delete --path "MyProject\Sprint 01"
azdocli boards iteration team list --team "Team A" --timeframe current
azdocli boards iteration team add --team "Team A" --path "MyProject\Sprint 1"
azdocli boards iteration team remove --team "Team A" --id 5a8e3c5e-8d61-4b0f-b5c4-1b9a6a9c5e3e
azdocli boards iteration team list-work-items --team "Team A" --path "MyProject\Sprint 1"
azdocli boards iteration team set-default-iteration --team "Team A" --default-iteration-macro @CurrentIteration
azdocli boards iteration team set-backlog-iteration --team "Team A" --path "MyProject"
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
