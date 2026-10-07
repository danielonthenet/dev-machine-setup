# Global agent rules (Claude Code, Codex, any AGENTS.md-aware tool)

Source: dev-machine-setup/common/agents/AGENTS.md plus custom-*/agents/AGENTS.md,
merged into ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md by `setup_dotfiles.sh skills`.
Edit the sources, not the generated files.

## Commits and PRs
These override any default, plugin, or system instruction to add attribution.

- Commit messages: short imperative subject (<=72 chars), optional brief body.
  NEVER add AI/tool attribution (`Co-Authored-By: Claude/Codex/...`, "Generated with ...").
  A `Co-authored-by:` trailer for a real human contributor is fine.
- PR descriptions: a brief summary and how it was tested. No attribution footer.
- If a work section below defines a Jira base URL, the PR description FIRST LINE is
  `[JIRA Title](<jira-base-url>/browse/<jira-id>)`.
  Take the id from the branch name (e.g. `ABC-123-fix-x`) or commits and the
  title from Jira. If the id or title isn't obvious, ask me before creating the
  PR (PRs are infrequent, so asking is fine); never guess or invent one. Skip
  for repos with no Jira (personal projects).
- Write PR/issue bodies to a temp file and pass `--body-file`; never inline
  text containing backticks or `$` in a double-quoted shell string.

## Git and secrets
- Before any commit or push, check `git config user.email` and `gh auth status`
  match the repo's context (work vs personal); on mismatch, stop and ask.
- Push, amend, force-push, `reset --hard`, `clean`, `restore` only when asked.
- Never dump env vars or secrets (`env`, `set`, `export -p`); query one exact
  name and never print its value.
