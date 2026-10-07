---
name: adr-writer
description: Drafts and reviews Architecture Decision Records (ADRs) using the Advice Process, the Draft/Proposed/Adopted lifecycle and the canonical ADR template. Use when the user asks to write, draft, structure, improve or review an ADR, an architecture decision, a design-decision write-up, or decide whether a decision needs an ADR.
---

# ADR Writer

Produce an ADR that an engineer unfamiliar with today's constraints can act on 6-18 months from now. Full standards live in [references/adr-guidelines.md](references/adr-guidelines.md); read it before drafting anything non-trivial.

## Workflow

1. **Check an ADR is warranted.** Skip only if the decision is outside architectural scope, single-developer, low on scope/time/risk/cost, and already covered by a standard (guidelines: "Scope"). Otherwise continue.
2. **Gather inputs.** Ask for anything missing: problem, constraints, options considered, owner/team, who is Consulted (experts) vs Informed (stakeholders). Do not invent facts, metrics or names; mark unknowns as open items.
3. **Draft** using the canonical structure in the guidelines (Status, Decision Drivers, Assumptions, Context, Options Considered, Decision, Consequences, plus Advice / Release Sequence / Open Items / Related Docs / Future Improvements when they apply). Start at status **Draft**.
4. **Self-check** against the rules below, fix, then output.

## Rules that are easy to miss

- **Context is neutral.** Facts only; the case for the decision belongs in Options and Decision.
- **Every option gets Pros and Cons**, including the chosen one, presented symmetrically.
- **Decision is active, first person** ("We choose..."), says why rejected options lost, and names the discriminating factors for *this* system. "Well-known and widely adopted" is not a rationale.
- **Assumptions are explicit**; flag time-sensitive facts (cost, vendor support, benchmarks).
- **Never edit an Adopted ADR in place.** Write a new ADR and mark the old one Superseded with a link.
- **Titles** are action- or problem-framed (`[ADR] Lifecycle management for archived data`), never vague (`ADR: Backend decision`).
- Always keep `Questions / Open Items` when unknowns exist; never leave an ADR with no decision and no rationale.

## Output

Return the full ADR as a single markdown document, with no commentary outside it. If asked to write it into a repo, match that repo's existing ADR directory, numbering and headings; surface conflicts rather than inventing a scheme. If creating a Confluence page is requested, confirm before publishing anywhere.
