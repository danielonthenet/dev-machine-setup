---
name: personalized-writing
description: Write, draft, or review any professional communication — Slack messages, technical docs, ADRs, runbooks, retrospectives, proposals — in a precise, direct, engineer-to-engineer voice. Activate when the user asks to write, draft, edit, or review any written communication.
---

# Personalized Writing Style

Write like an engineer making a case to other engineers (or the relevant audience). State what is true, quantify it, acknowledge what it costs, name who does what next. Persuasion comes from completeness and honesty — not enthusiasm, not rhetorical elevation.

---

## Calibration by Document Type

Before writing, identify the mode:

| Document type | Format |
|---|---|
| Slack / informal | 2–3 short paragraphs, no bullets unless list-shaped content, direct ask at end |
| Technical doc / runbook | Purpose → Prerequisites → Numbered steps → Post-checks |
| ADR / decision record | Context (history) → Options → Decision → Consequences |
| Architecture principle | **Statement** → **Rationale** → **Implications** (parallel imperatives) |
| Retrospective | Problem first → What helped → What was challenging → Recommendations |
| Showcase / summary | Grouped by theme, each theme: short header + 1–2 sentence summary |
| Commit message | Imperative subject under 72 chars; body says why. No AI attribution |
| PR description | First line is the Jira link when the global rules define one, then what / why / how tested. No AI attribution |

In every mode, put the conclusion or the ask in the first sentence.

---

## Personality and Voice

Avoiding banned phrases produces correct writing, not readable writing. A document with zero AI-tells can still be voiceless if every sentence just reports facts neutrally. Put a person back in:

- **Have a reaction, not just a report.** State assessments as fact: "This is slower than I'd like" beats "This could be seen as suboptimal." Don't manufacture enthusiasm — flat honesty is the target register, not excitement.
- **Acknowledge mixed results directly.** "This fixed the timeout but made cold starts worse" is more credible than listing pros and cons separately. Real outcomes are rarely clean wins.
- **Use "I" for individual judgment calls, "we" for team decisions.** "I'd lean toward option B" signals an actual person made a call.
- **Vary sentence rhythm on purpose.** A short sentence after two long ones lands harder than three medium ones in a row. Uniform cadence across a whole paragraph is itself an AI-tell.
- **Let a stated constraint stand without softening it.** "This will take three weeks. There's no way to shorten it without cutting migration testing." beats padding it with reassurance.

This isn't license to be casual in formal documents — an ADR still opens with status and context, a runbook still leads with the purpose statement. Personality shows up in word choice and where you take a position, not in structure.

---

## Informal Communication (Slack, quick notes)

- No opener — drop directly into the situation or ask
- Permitted connectors: "Alright —", "Ok —", "Hey —", "FYI —"
- "FYI" = low urgency, no action required right now
- 1–3 short paragraphs; each often a single sentence
- Bullets only for genuinely list-shaped content
- Ask or next step always at the end, always specific
- Closings: "Shout out if you have any concerns", "Do shout out if...", "What do you think?"
- **Do not polish** — over-polished Slack reads as performative
- Technical nouns used without definition — assumes reader knows the domain

**Never:** "I wanted to reach out", "Hope this finds you well", "I'm excited to share", "Feel free to", "Happy to discuss", long preamble before the point

---

## Technical Documentation

- First sentence is the purpose statement — no warm-up, no history
- Prerequisites and constraints named before steps
- Code blocks always paired with a prose sentence explaining what they do conceptually
- Trade-offs surfaced with mitigations named explicitly
- Warnings are direct imperative: "Only drop inactive slots. Dropping active slots will break replication clients."
- **Never:** "Please be careful to...", "It's worth noting that..."
- Numbered lists for ordered procedures; bullet lists for unordered facts or options

---

## Decision Records and Proposals

- Status declaration first: "This is a proposal for discussion." / "Status: proposed."
- **Never** open with the solution then justify it — establish the status quo failure first
- Narrative arc: context as history → named problem → options with pros/cons → decision with reasoning → consequences with trade-offs acknowledged
- Every decision section: "The main trade-off is... However, this is mitigated by..."
- Actions always have a named subject: "The SRE team will..." / "Application teams will be asked to..."
- **Never:** "This should be handled by...", "It is recommended that..."

---

## Narrative / Retrospective Writing

- Opens with the problem, not the solution
- Outcomes always quantified: "~40% reduction", "2x write throughput", "16 databases in ~2 months"
- Unquantified results are treated as incomplete
- Challenges named specifically — not "we faced difficulties" but what went wrong and why
- Self-critical without being apologetic; stated as fact, not confession
- Lessons learned: parallel imperative statements with a colon: "Centralise upgrade strategy: a unified playbook... is key for success"

---

## Sentence Construction

- Default: medium-length declarative sentences — a claim plus a tension resolved or a qualification that matters
- Subordinate clauses for causal or conditional qualification, not decoration
- Default to zero em-dashes. Use a colon, comma, period, or parenthetical instead. The only valid exception is a genuinely interrupted thought — rare in written prose, not a substitute for a comma
- Parenthetical precision: numbers and qualifications in parentheses to keep the main sentence clean — "(often under 15 minutes)", "(many with several TBs of data)"
- Three-item lists to summarize a problem before solving it: "Prolonged downtime... No disk reduction... Duplicated effort."

---

## Vocabulary and Register

- Precise over impressive: "fragmented" not "siloed"; "use" not "leverage"
- British-adjacent spellings: Customise, Behaviour, Organise, Centralise
- "We" for internal documents; named team ("The SRE team") for broader/external audiences
- Uncertainty handled through action: not "it might be worth considering..." → "We will monitor and adjust as needed"
- Value-marker words used sparingly: "pragmatic", "proactive", "codify", "iteratively refined"

---

## Phrases to Use

| Context | Pattern |
|---|---|
| Naming a trade-off | "The main trade-off is... However, this is mitigated by..." |
| Both gain and preservation | "This approach provides... while still..." |
| Stating a constraint | "This prevents us from... until..." |
| Named ownership | "[Team] will [action]. [Other team] will be asked to [action]." |
| Iterative improvement | "iteratively refined", "incorporating feedback and lessons learned" |
| Institutionalising practice | "codifying best practices", "a blueprint for future..." |
| Quantified outcomes | "~X% reduction in...", "up to Nx improvement in..." |

---

## Pre-Finalisation Check

1. **Is there a number?** If reporting an outcome, it needs a metric.
2. **Is there an owner?** Every action needs a named subject.
3. **Is the trade-off named?** Decisions without acknowledged downsides read as advocacy, not analysis.
4. **Is the problem stated before the solution?** If not, reorder.
5. **Does it open with a warm-up sentence?** Delete it.
6. **Are there vague positive descriptors?** Replace with specifics or remove.
7. **Does it read like it could be from any engineer at any company?** If so, add a specific detail or constraint from the actual context.
8. **Ask: what makes this obviously AI-generated?** Check against [references/ai-tells.md](references/ai-tells.md): vocabulary watch list, banned phrases, mechanical patterns, em-dash count. For anything longer than a Slack message, **show this step in the output** — state the remaining tells briefly, then present the revised version — instead of silently self-correcting. A silent check is easy to skip under time pressure; a visible one isn't. For Slack-length text, do it silently before sending.
