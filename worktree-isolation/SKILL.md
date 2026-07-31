---
name: worktree-isolation
description: >
  Isolate all work in a fresh git worktree created as a sibling of the main
  clone, leaving the current checkout untouched. Use when the user asks to do
  work "in a worktree", isolate changes, keep the working directory clean, or
  work in a git repo without disturbing its current state.
---

# Worktree Isolation

Do all work in a fresh git worktree when the user requests it. The main checkout
stays untouched; operate entirely inside the worktree.

## Workflow

1. **Verify repo** — confirm the working directory is a git repo:
   ```bash
   git rev-parse --is-inside-work-tree   # must print true
   ```
   If not, tell the user worktree isolation isn't possible and work normally.

2. **Create the worktree** — as a sibling of the main clone, branched from the
   current HEAD:
   ```bash
   git worktree add ../<repo-name>-<slug> -b <slug> HEAD
   ```
   - `<repo-name>`: name of the current clone's directory (not the remote URL)
   - `<slug>`: short kebab-case description of the task

   Example: in `~/dev/skills`, task "add dark mode" →
   `git worktree add ../skills-add-dark-mode -b add-dark-mode HEAD`

3. **Do the work** — run all commands inside the worktree directory:
   - Edit, test, build, and commit only inside the worktree
   - Never modify files in the main checkout
   - Push the branch only if the user asks

4. **Clean up** — once the task is done (committed, pushed if requested),
   remove the worktree from the main clone:
   ```bash
   git worktree remove ../<repo-name>-<slug>
   git worktree prune
   ```
   If the user still needs the worktree, report its path and branch instead.

## Rules

- One worktree per task; reuse an existing worktree if one already exists for it
- Worktree lives as a sibling of the clone — never inside the main checkout
- Branch name matches the worktree name suffix (`<slug>`)
- Uncommitted changes in the main checkout stay there — worktrees don't carry them
- Don't branch or stash in the main checkout to make room — that's what the
  worktree is for

## Anti-patterns

- Don't create a worktree when the current directory is not a git repo — work normally
- Don't remove the worktree before the task is complete
- Don't leave stale worktrees behind after finishing — always clean up
