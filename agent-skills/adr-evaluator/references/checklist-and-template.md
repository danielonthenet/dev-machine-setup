# Checklist, verdicts and template

## Evaluation checklist (internal reasoning aid, not output headers)

- **Structure first.** If Status, Decision, Consequences or at least 2 options with pros/cons are missing, say so and stop at "Needs more info".
- **Writer-rule breaches.** Flag biased Context, "widely adopted" rationale, empty trade-off, in-place edits of an Adopted ADR.
- **Supersession.** Does it supersede or contradict an Adopted ADR, and is that one marked Superseded with a link?
- **Core design correctness.** Does it solve the stated problem? Are alternatives fairly represented or is it a foregone conclusion?
- **Consistency with org patterns.** Is there already a standard mechanism to reuse instead of a parallel one (event pipelines, context/PII adapters, config, secrets)? Duplicate infrastructure is the most common finding; always check.
- **Blast radius and rollback.** What breaks, for whom? Is there a kill switch independent of the new system (a feature-flag ADR with no fallback if the flag service fails is circular)? Rollback without a deploy?
- **Availability and failure modes** under the org's real topology (from the org-context docs; e.g. central services vs independent regional clusters): init failure at cold start, vendor partition, stale config, partial regional outage. Graceful degradation or hard fail?
- **Security and privacy.** What crosses a trust boundary? Does it match existing sanitization contracts or add an unreviewed PII path? Do secrets in the sample match how they really reach the app (env literal vs secret-manager injected)?
- **Operational readiness** (golden signals: latency, traffic, errors, saturation) for the new dependency and what it fronts: metrics/spans, dashboard/alert, failure-mode-to-action table, on-call.
- **Rollout.** Shadow/canary, percentage rollout, abort criterion?
- **Cost.** Vendor spend, added latency/CPU/memory/network calls: quantified?
- **Testing.** Unit-testable in isolation? How is the dependency faked in CI?
- **Ownership and lifecycle.** Who owns it? Is the thing it replaces actually being removed, not just no longer recommended?
- **Internal consistency.** Do prose, code samples and Consequences agree (names, wiring into real entry points)? Drift is a real finding because people implement from samples.

## Verdicts

- **Approve**: sound; caveats informational.
- **Approve with conditions**: sound direction; enumerated caveats must be resolved before/during implementation.
- **Needs more info**: cannot assess until specific questions are answered; not a rejection.
- **Reject / reconsider**: core approach has a problem patching will not fix.

Pair with a **risk tier** (Low/Medium/High) driven by blast radius x reversibility, not by amount of work.

## Domain slugs (extend only when nothing fits)

`feature-flagging`, `frontend-architecture`, `telemetry-analytics`, `caching-data`, `edge-networking`, `auth-identity`, `ci-cd-deploy`, `observability-reliability`, `security-compliance`, `data-platform`, `messaging-queues`, `third-party-vendors`, `api-design`.

Domain = functional capability, not the authoring team, so cross-team duplication lands in the same folder. ADR slug = short kebab-case of the title (drop "ADR:" and filler).

## Output template

```markdown
---
title: <ADR title>
source: <Confluence URL>
evaluated: <yyyy-mm-dd>
domain: <domain-slug>
verdict: <Approve | Approve with conditions | Needs more info | Reject>
risk_tier: <Low | Medium | High>
---

## Summary
<3-6 sentences: what is decided, why, and the one existing-org-pattern fact that most changes how to read it.>

## Architecture
<Only if a diagram earns its place; one mermaid diagram. Otherwise omit this section.>

## Key issues
<Numbered, by severity, max ~8. Each: bolded one-line claim, then 1-2 sentences on why it matters with inline file:line or doc reference, phrased as a question to the author.>

## Recommendation
<2-4 sentences: verdict plus the one or two conditions that matter.>
```
