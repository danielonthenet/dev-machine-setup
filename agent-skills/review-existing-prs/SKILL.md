---
name: review-existing-prs
description: Review existing pull requests, diffs, and already-authored changes and present findings in a comment-ready format. Use when the user asks to review an existing PR, turn findings into GitHub review comments, or wants file-anchored comments for a change that already exists. Especially use when the user wants comments anchored by file path and nearby context instead of line numbers.
---

# Review Existing Prs

## Overview

Present PR review findings in a form the user can paste directly into GitHub review comments or use as a checklist while commenting. Favor precise, item-specific comments over broad summaries.

## Review Workflow

Find the originating Jira ticket or spec (branch name, PR description, commits). Report missing requirements and unrequested scope separately from code issues. Check the PR description's first line is the Jira link required by the global rules.

If the PR is over ~300 changed lines or mixes refactor and feature, say so as the first finding and suggest a split.

List findings first, ordered by severity, each prefixed `blocking`, `should-fix` or `nit`. Keep nits out of blocking items.

Only report what you verified in the diff or code; mark the rest `unverified` and say what would confirm it. Cover untrusted input at boundaries, secrets in diffs or logs, and missing error paths.

Keep each finding discrete. Do not merge unrelated problems into one comment.

Anchor each finding to a real file and a short context snippet from the changed area.

Use line numbers only when the user explicitly wants line-number references. Otherwise prefer file path plus nearby context.

For YAML, JSON, Markdown, and config reviews, anchor comments on the surrounding keys or fields rather than synthetic line references.

## Output Format

Use this structure for comment-ready findings:

```text
[Num]. <short issue title or field name>

File: path/to/file

Context:
<2-3 lines before>
<target lines>
<2-3 lines after>

Comment:
> <review comment text>
```

Wrap the context in a fenced code block when formatting would help readability.

Prefer a narrow title that matches the exact issue, such as `oncall_briefing`, `rollback_plan`, or `missing test coverage`.

## Comment Quality

State what is wrong with the current change.

State why the current evidence, implementation, or wording is insufficient.

State what would satisfy the review point when that is clear. For structural problems name the concrete remedy (extract, delete the wrapper, reuse the existing helper), not just "this is complex".

Keep comments direct and specific. Avoid filler, praise, or generic phrasing.

When reviewing evidence-based PRs, distinguish between:

- Link exists, but does not contain the required artifact.
- Artifact exists, but is incomplete or still marked WIP.
- Artifact is the wrong type for the gate item.

## Anchoring Rules

Quote only the minimum surrounding context needed to identify placement.

Prefer 2-3 lines before and after the target area.

If the user asks for line-number-free comments, always use `File` and `Context` anchors instead of numeric locations.

If the exact target line is unstable, anchor on the nearest stable block such as the enclosing YAML keys or Markdown subsection.

## Empty Review

If no findings are discovered, say so explicitly.

After that, mention any residual risk or verification gap briefly.
