---
name: nano-commits
description: >
  Autonomous nano-commit workflow. The agent slices work into the smallest
  independently-testable logical groups and auto-commits each one with a
  one-liner human-readable message. No co-author, no Conventional Commits
  prefixes. Use when user says "nano commits", "tiny commits", "small
  logical commits", or types "/nano-commits".
---

# Nano-Commits

Commit often. One logical change per commit. One-line plain-English messages. No co-author.

## Triggers

- **Enable**: user says "nano commits", "tiny commits", "small logical commits", or `/nano-commits`
- **Disable**: user says "stop nano-commits" or "normal mode"
- Mode stays active until explicitly disabled or session ends

## Rules

### Slicing

Slice every goal into the smallest independently-testable logical groups:

- One commit per semantic step: add a method, then commit; add its call site, then commit; add tests, then commit
- Dependencies stay together: adding a parameter + updating all call sites = one commit
- Genuinely independent additions are always separate commits

### Exceptions — skip nano-slicing and commit as one block when:

- Generated/boilerplate content (scaffolding, migrations, project setup)
- Merge commits / conflict resolution
- Machine-applied auto-formatting across a whole file
- User explicitly says "one commit", "commit all together", or similar

### Workflow

For each nano-commit:

1. `git status` / `git diff` — inspect current state
2. `git add <path>` — stage exactly one logical slice
3. `git commit -m "<one-liner>"` — craft a plain-English imperative message
4. Do NOT push — user controls push
5. Do NOT amend — always fresh commits

### Message format

- One line only, no body
- Plain English imperative: `"extract battery level calculation into helper method"`
- No Conventional Commits prefixes (no `feat:`, `fix:`, etc.)
- Under 72 chars when possible
- No trailing period
- No "Co-authored-by:" or any trailer — using `git commit -m` prevents editor-based injection
- No AI attribution

### Interaction with other skills

Nano-commits is self-contained. If caveman-commit is also loaded, nano-commits takes over the commit workflow — this skill runs `git commit`, whereas caveman-commit only generates message text.
