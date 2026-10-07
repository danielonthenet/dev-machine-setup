---
name: adr-evaluator
description: Evaluates an existing Architecture Decision Record (Confluence ADR URL or page ID) from a senior SRE/architect perspective and writes a concise summary, key questions and a verdict. Use when the user asks to evaluate, assess, critique or prepare for the review of an ADR, or to check an ADR against existing org patterns and the real repos.
---

# ADR Evaluator

Deliverable: a short summary plus a ranked list of questions to raise with the ADR author, readable once, cold, before a review meeting. Not an essay.

Checklist, verdicts, domain vocabulary and the output template are in [references/checklist-and-template.md](references/checklist-and-template.md). Read it before evaluating.

## Guardrails

- **Read-only against Confluence and Jira.** Only fetch/search (`getConfluencePage`, `searchConfluenceUsingCql`, `search`, footer and inline comment getters). Never create/update pages or add comments, even if asked to "leave feedback". Output goes to local files.
- `gh` is read-only too (no `pr create`, no comments) unless the user explicitly asks.
- **Verify before trusting.** Org context can drift; when a finding is load-bearing ("no existing pattern for X"), grep the repo or re-check Confluence.

## Locations

Org-context docs, repo roots, the output directory and the index file are defined under "ADR evaluator" in the global rules (~/.claude/CLAUDE.md or ~/.codex/AGENTS.md). If undefined, ask once; default output is `./adr-evaluations/<domain-slug>/<yyyy-mm-dd>-<adr-slug>.md` (date = evaluation date) plus one new row in `INDEX.md` (date, domain, title, verdict, risk tier, link). Never write into the org-context docs; flag useful additions to the user.

## Process

1. **Fetch** the ADR (markdown) with footer and inline comments; reviewer pushback often holds the real objections.
2. **Context, in order:** (a) search the org-context docs; (b) CQL for prior/overlapping ADRs in the same domain, especially superseded ones or ones that set a pattern; (c) **grep the actual repos for the ADR's claims**: does the referenced hook/config exist, does it match the sample, is there a competing implementation. This step yields the highest-value findings.
3. **Summary** in plain language: what is decided, why, alternatives (or lack of), who/what changes, what the ADR is silent on.
4. **Run the checklist** internally; keep only categories with a real finding. Phrase each as a concrete, falsifiable question naming a file, config key, metric or failure mode.
5. **Optional cross-check with Codex** (if the codex-rescue agent is available): 2-3 rounds of independent critique, accept what holds up, push back on the rest, stop when a round adds nothing new. Keep notes in scratch space only.
6. **Write once**, using the template, reflecting only the validated end state.

## Output discipline

- Concise: summary 3-6 sentences, at most ~8 key issues ordered by severity, recommendation 2-4 sentences.
- One mermaid diagram only when a flow or system-overlap is faster to see than to read; otherwise omit the section.
- **Never narrate review history** ("first I thought X, then Codex said Y").
- Citations inline next to the claim, not in a separate section.
- Fewer, sharper questions beat an exhaustive dump.
