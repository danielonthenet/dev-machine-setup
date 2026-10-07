# ADR Writing Guidelines

## Org Rationale — The Advice Process

Software architecture decisions are among the most impactful choices an engineering team can make. Traditional top-down decision-making leads to bottlenecks, lack of ownership, and missed innovation. The **Advice Process** offers a decentralised, collaborative, and transparent alternative.

**The Rule:** anyone can make an architectural decision.
**The Qualifier:** before making the decision, the decision-taker must consult two groups:
1. Everyone who will be meaningfully affected by the decision
2. People with expertise in the area

This is not seeking permission — it is taking advice into consideration when designing a solution. If advice is not followed for valid reasons, document why and factor in change management with affected teams.

### Why Use the Advice Process for Architecture Changes?
- **Empowers Engineers:** those closest to the problem take ownership, fostering autonomy and accountability
- **Leverages Collective Wisdom:** diverse perspectives reduce blind spots and biases
- **Promotes Transparency:** decisions are documented and shared openly, creating a culture of trust
- **Encourages Learning:** small failures are embraced as opportunities to improve
- **Reduces Bottlenecks:** decentralised decision-making accelerates progress while maintaining quality

---

## ADR Lifecycle & Statuses

| Status      | Meaning                                                                 |
|-------------|-------------------------------------------------------------------------|
| Draft       | Initial creation — not yet shared for feedback                          |
| Proposed    | Ready for sharing and collaborative discussion                          |
| Adopted     | Decision finalised and accepted                                         |
| Rejected    | Decision finalised and rejected                                         |
| Superseded  | Replaced by a newer ADR (link to replacement)                           |
| Retired     | No longer required; decision has been reversed                          |

> When an ADR is **Adopted**, mark any impacted existing ADRs as **Superseded**.

### Immutability Rule

**Never edit an Adopted ADR in place.** Once accepted, an ADR is a historical record of a decision made at a specific point in time. If the decision needs to change:
1. Create a new ADR documenting the revised decision
2. Mark the old ADR as **Superseded** with a link to the new one
3. The new ADR should state which decision it replaces and why the original is now invalid

Editing an accepted ADR in place destroys the historical record and makes it impossible to understand how thinking evolved.

### Review Cadence

All ADRs should be reviewed periodically. Annual review is the minimum. ADRs containing volatile facts — cost projections, vendor support levels, performance benchmarks, team structure assumptions — should flag those specific facts as time-sensitive. When reviewing, ask:
- Have the assumptions underlying the decision changed?
- Did the decision produce the expected consequences?
- Should this ADR be Superseded, Retired, or reaffirmed?

---

## Steps to Adopt the Advice Process

### 1. Define the Problem and Create an ADR
Set status to **Draft**. Capture context, options, and reasoning before a decision is made.

### 2. Seek Advice Early and Broadly
- Share the ADR Draft with stakeholders
- Ask open-ended questions: *"What risks do you see?"*, *"Are there better alternatives?"*
- Actively seek dissenting opinions
- Distinguish between those who are **Consulted** (subject-matter experts in two-way dialogue who shape the decision) and those who are **Informed** (stakeholders who need to know the outcome). Both groups must be identified; neither should be conflated with the other

### 3. Use Architecture Principles and Technology Radar
- Reference high-level architecture principles to evaluate options
- Use the Technology Radar to understand current standards, past practices, and emerging tech
- If a decision contravenes a principle, document why and justify the deviation

### 4. Engage in Collaborative Discussions
Set status to **Proposed**. Organise 1:1s, team meetings, or Architecture Forum sessions to refine the decision. Capture all advice, even if not followed, and explain reasoning.

### 5. Make the Decision and Document It
Set status to **Adopted** or **Rejected**. The ADR should:
- Clearly state the decision and reasoning
- Highlight non-intuitive or unconventional aspects
- Address how advice was incorporated or why certain advice was not followed

### 6. Revisit and Learn from Decisions
All decisions are point-in-time. Periodically review past ADRs:
- Did the decision achieve the desired outcomes?
- Were the context and criteria well-understood at the time?
- What lessons can be applied to future decisions?

Set status to **Retired** if the ADR is no longer required after necessary reversal changes are made.

---

## Scope — Decisions Worth an ADR

An ADR is warranted when a decision substantively affects:
- Functional or non-functional requirements
- Operational cost, scale, performance, or resilience
- Introduction or removal of core technology or deployment patterns
- Organisation-wide practices or cross-team dependencies

### When NOT to Write an ADR

Skip an ADR when **all** of the following are true:
- The decision is outside architectural scope — it does not affect structure, NFRs, inter-component interfaces, or cross-team dependencies
- The decision is single-developer and self-contained with minimal risk
- The scope, time, risk, and cost are all low simultaneously
- The decision is fully covered by an existing standard, policy, or platform default

Use judgement for temporary workarounds and experiments: if there is a meaningful risk that the "temporary" solution will become permanent, a lightweight ADR documenting that risk is worthwhile.

---

## Content Requirements per Section

### Decision Drivers
Before describing options, state the specific forces that shaped evaluation. These are distinct from Context (which describes the situation) — Decision Drivers are the explicit criteria used to compare options:
- Performance or latency requirements
- Cost constraints
- Team expertise or operational burden
- Time-to-delivery pressures
- Compliance, security, or policy constraints
- Alignment with Technology Radar or architecture principles

### Assumptions
List the assumptions the decision rests on. This is one of the most underused but highest-value sections. Unstated assumptions are the primary reason an ADR becomes misleading after conditions change — when an assumption is invalidated, the rationale becomes visibly questionable and the ADR should be revisited.

Examples: *"Assumes current traffic growth remains under 3× for the next 12 months"*, *"Assumes vendor X continues to support v2 API through 2025"*, *"Assumes the team has bandwidth to implement phase 2 within Q2"*

### Context
- Explain the situation: business/technical drivers, affected systems, user journeys, and known constraints
- **Write Context in value-neutral language — state facts, not advocacy.** If the Context reads like a justification for the decision, it will mislead future readers. The decision's merit should emerge from Options Considered and Decision, not from a biased setup
- Present relevant metrics (e.g., RPS, latency, cost, error rates, replica counts) where applicable
- Describe the current state clearly: bottlenecks, inefficiencies, or goals (cost savings, availability, simplicity)
- Include experimental results or benchmarks when the decision depends on performance characteristics (e.g., "SHA-1 for 64 MB takes 7.6 seconds; 100 GB takes ~3.5 hours")
- State explicit **Non-goals**: what this ADR deliberately does not decide
- List all options or paths considered with thorough reasoning and trade-offs **before** the final decision is introduced

### Options Considered

Each option must be presented individually and symmetrically. Use the following structure:

- **Label clearly**: `Option 1: [Descriptive name]`, `Option 2: [Descriptive name]`
- **Describe the approach**: what it involves technically, operationally, or architecturally
- **List explicit Pros and Cons** for every option — even the chosen one; this demonstrates the trade-off was considered
- **End each rejected option** with a one-line `Rejected because:` tied to a Decision Driver
- **Include technical specifics**: API details, component names, constraints, rate limits, edge cases
- Use code snippets, pseudocode, or SQL where it clarifies the approach (keep them brief and illustrative)

Example pattern:
> **Option 2: Direct write to destination with a managed connector**
>
> Uses connector tooling for schema mapping and writes directly to the target DB.
>
> **Pros:** No intermediate storage; leverages connector ecosystem
> **Cons:** Schema drift risk; limited support for custom transformations

### Decision
- Explain which option was selected and why it was preferred over the others
- Emphasise benefits, mitigated risks, alignment with requirements or roadmap goals
- **Use active voice and first person:** *"We choose to…"* or *"We collectively decided to go with Option 2 because…"* — never passive ("It was decided that…")
- Address why rejected options were not chosen — this prevents re-litigation later
- Highlight non-intuitive or surprising aspects of the decision — especially when advice was received and overruled
- Clearly state the classification/status after supporting argumentation

### Consequences

Split into positive and negative outcomes explicitly. Use a `Good:` / `Bad:` or `Benefits:` / `Risks:` structure:

- **Good/Benefits**: concrete wins — savings, simplification, capability unlocked, team clarity
- **Bad/Risks**: known downsides, delivery delays, temporary inconsistency, edge cases not yet addressed
- Include infrastructure savings, operational impact, reliability/UX effects, and required follow-up actions
- Address rollback: can this decision be reversed? If so, how? If not, state that explicitly
- Indicate whether a review or reassessment is scheduled
- If a risk is acknowledged but deferred, reference the `Future Improvements` section

### Advice to Affected Teams
- Use this section when the decision affects multiple teams or requires coordinated action
- Address each affected team directly: *"[Team X]: you will need to…"*
- Capture advice that was given during the advice process but not incorporated, and explain why

### Release / Implementation Sequence
- Required for multi-team or phased rollouts
- List steps in dependency order — which team/service goes first and why
- Include explicit rollback points (e.g., "at this step, reverting is still low-cost")
- Example: `1. Platform: ship user creation in the new service → 2. Data: deprecate the cron job → 3. Apps: force-upgrade to use the external ID`

### Questions / Open Items
- List unresolved questions, edge cases, or known unknowns at the time of writing
- Mark items as resolved or link to follow-up ADRs when they are closed
- Example: *"Is there a race condition if a file is modified between upload and integrity check? Assessed as rare; tracked in [ticket]."*

### Related Docs
- Link to PRDs, CRs, design docs, or Jira tickets that informed the decision
- Reference upstream ADRs this one supersedes or depends on
- Note **downstream implications**: decisions this ADR triggers that will require their own ADRs. Forward references prevent decisions from being made in isolation when they logically cascade

### Future Improvements
- Acknowledge known limitations of the current decision that will be addressed later
- Be specific: *"Enable SHA-1 computation in upload flow to eliminate the edge case of same-size modified files"*
- This section builds credibility — it shows awareness of trade-offs without blocking the decision

Each section should contain **2–6 well-developed paragraphs or lists**, using bullet points or sublists where helpful. Prioritise **reasoning before conclusion**.

---

## Depth & Specificity Standards

Match or exceed this benchmark level of detail:

> **Context:**
> - 120 image-service pods deployed across 5 regions (24 per region) is excessive and costly.
> - Load testing shows pods handle 40–300+ rps depending on endpoint weight.
> - Peak request rates per region are 50–140 rps, with only 6–7% of requests hitting the heaviest endpoint.
> - Provisioning 6 replicas per region is recommended despite 3–4 being sufficient for normal load.
>
> **Options Considered:**
> - Phase 1: Reduce replicas per region from 24 → 6.
> - Phase 2: Implement HPA.
> - Interim: Variable replica counts per region, particularly for low-volume regions.
>
> **Consequences:**
> - Node count reduced by 8 across 5 regions.
> - Freed 64 CPU cores and 160 GB RAM, saving ~$1,500/month.
> - Latency/error rates unaffected.
> - Follow-up: Consult the platform team for broader rollout validation.

Use this level of **quantitative reasoning, phased planning, explicit trade-offs, and operational results** wherever relevant.

### Y-Statement Quality Check

Before finalising an ADR, test it against the Y-statement format. If you cannot express the core logic in a single sentence, the ADR may lack clarity about the trade-off that was actually accepted:

> *"In the context of `<use case or situation>`, facing `<the core concern or constraint>`, we decided `<the chosen option>` to achieve `<the quality attribute or goal>`, accepting `<the downside or trade-off>`."*

**Example:**
> *"In the context of scaling image-service across 5 regions, facing excessive infrastructure cost from 24 replicas per region, we decided to reduce to 6 replicas per region to save ~$1,500/month, accepting the need for manual scaling if traffic unexpectedly spikes beyond 6× normal load."*

If the sentence feels vague or the "accepting" clause is empty, the consequences section needs more honesty about the downside.

---

## Title Naming Conventions

ADR titles should be prefixed consistently and descriptive enough to distinguish the decision without reading the body:

- `ADR: [Decision or problem statement]` — preferred format
- `ADR - [Title]` — also acceptable
- `[ADR] [Question or action]` — acceptable for exploratory/question-framed ADRs

**Good examples:**
- `ADR: Real-time user ID rename after user creation`
- `ADR - Lifecycle management for archived data`
- `[ADR] How to identify that a file is safe for deletion`

Titles should be action-oriented or problem-framed. Avoid vague titles like `ADR: Backend decision`.

---

## Canonical ADR Markdown Structure

The sections below are ordered by importance. **Bold sections are required**; others are situational but strongly recommended when applicable.

```markdown
# ADR: [Title of the Decision]

**Status:** [Draft | Proposed | Adopted | Rejected | Superseded | Retired]
**Date:** [YYYY-MM-DD]
**Responsible Team:** [Team name]
**Owner:** [Name or role]
**Authors:** [Name(s)]
**Consulted:** [Subject-matter experts in two-way dialogue]
**Informed:** [Stakeholders notified of outcome]

## Decision Drivers

- ...

## Assumptions

- ...

## Context

...

## Options Considered

### Option 1: [Name]

[Description]

**Pros:**
- ...

**Cons:**
- ...

### Option 2: [Name]

[Description]

**Pros:**
- ...

**Cons:**
- ...

## Decision

...

## Consequences

**Good:**
- ...

**Bad / Risks:**
- ...

## Advice to Affected Teams

[Team A]: ...
[Team B]: ...

## Release / Implementation Sequence

1. [Team or service] — [action]
2. ...

## Questions / Open Items

- [ ] [Unresolved question or edge case]

## Related Docs

- [PRD / design doc / Jira ticket / CR]

## Future Improvements

- [Known limitation + planned remediation]
```

Not every section is needed for every ADR. Use your judgement:
- Simple single-team decisions may skip `Advice`, `Release Sequence`, and `Future Improvements`
- Exploratory or early-stage ADRs may have `Decision: TBD` with options still being evaluated
- Always include `Questions / Open Items` when unknowns exist — don't let them silently linger

---

## Output Format

- Return the full ADR as a **single markdown document** — no explanations, headings, or commentary outside the ADR itself
- Maintain traceability, clarity, and narrative logic
- Written to be understandable and actionable **6–18 months from now** by engineers unfamiliar with today's constraints

---

## Sources & References

- Michael Nygard's original ADR template (2011) — cognitect.com
- MADR (Markdown Architectural Decision Records) — adr.github.io
- AWS Prescriptive Guidance: Architectural Decision Records
- Google Cloud Architecture Decision Record guidance
- [Scaling the Practice of Architecture, Conversationally](https://martinfowler.com/articles/scaling-architecture-conversationally.html) — Martin Fowler
- Zdun et al., "Sustainable Architectural Decisions" — InfoQ / IEEE
- Tyree & Akerman extended ADR template
- Joel Parker Henderson ADR repository (github.com/joelparkerhenderson/architecture-decision-record)
- ThoughtWorks Technology Radar — ADR recommendations
- Modern Architecture Knowledge Management (AKM) best practices

---

## Best Practices

- Foster a safe environment for open, honest discussion
- Amplify quieter voices and seek diverse perspectives
- Avoid centralised control — trust the team to make decisions
- Celebrate small failures as learning opportunities; share learnings openly
- Always complete the ADR — skipping documentation loses transparency and learning

## Common Pitfalls to Avoid

- **Skipping documentation:** leads to lack of transparency and missed learning. Verbal decisions and meeting notes are not ADRs — they get forgotten.
- **Excluding key stakeholders:** missing voices causes blind spots and resistance
- **Rushing the process:** take time to gather advice and evaluate options thoroughly
- **Fear of failure:** don't let the fear of mistakes prevent experimentation
- **No decision made:** fear of choosing incorrectly leads to an ADR with no decision, no rationale, and indefinitely "Proposed" status — the problem gets re-discussed repeatedly without resolution
- **Unjustified decisions:** a decision is recorded but no reasoning is given. This is the single most common failure mode and causes the same discussions to repeat
- **Biased Context:** writing the Context section as advocacy for the chosen option rather than a neutral statement of facts. Context must describe the situation; the case for the decision belongs in Options Considered and Decision
- **Commonsense rationale:** "We chose this because it's well-known and widely adopted" is not a rationale. The ADR must explain the discriminating factors specific to *this* system, *this* team, and *this* moment
- **Editing accepted ADRs:** modifying an adopted ADR in place destroys the historical record. Always create a new ADR and mark the old one Superseded
- **Treating ADRs as after-the-fact paperwork:** low-effort ADRs written solely for compliance, after the decision was already made informally, produce documentation without real reasoning. Write the ADR during the decision process, not after
- **Participation capture:** the same small group of "usual suspects" dominating every advisory discussion. Actively surface quieter voices and include affected teams who may not self-advocate
