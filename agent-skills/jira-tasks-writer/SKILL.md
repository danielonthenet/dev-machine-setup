---
name: jira-tasks-writer
description: >-
  Write JIRA tasks and stories for technical, infrastructure, backend, or
  system work. Use when the user asks to create, draft, or write a Jira
  ticket, task, story, or issue. Examples: "write a Jira task for...", "draft
  a story for...", "create a ticket for...", "break this into Jira tasks".
---

# Jira Task & Story Writer

Write concise, outcome-focused Jira tasks and stories for technical work. Default to **Task** unless there's explicit stakeholder or team value that makes a Story appropriate.

---

## Task vs Story

| Type | Use when |
|---|---|
| **Task** (default) | Technical, infrastructure, backend, or system work with a clear deliverable |
| **Story** | There's explicit value for an internal stakeholder or team (not just the system) |

Never use "As a [persona]" for system/technical work. Only use it when explicitly requested for a user-facing story.

---

## Writing Rules

- Lead with **what needs to be done** and **why it matters** — not how to do it
- Keep scope to 1–5 days; split larger work into separate tasks
- Split by verifiable outcome (end-to-end slice), not by layer (not "DB", then "API", then "tests"); each ticket is checkable on its own
- Use the team's existing names for services and environments; don't invent new ones
- Reference other tickets as `[ID](<jira-base-url>/browse/ID)`; the base URL is in the global rules
- Avoid implementation detail unless needed for scope clarity
- State rationale only when the benefit isn't obvious
- Use specific, verifiable language — avoid "improve", "optimize" without a metric

---

## Process

1. **Review** the description. If context is missing or requirements are ambiguous, ask before writing.
2. **Identify** the deliverable and desired outcome.
3. **Determine** Task or Story.
4. **Write** the item using the format below.
5. **Define** 2–5 acceptance criteria that are verifiable, not implementation steps.

If the user provides multiple items, write each as a separate ticket with a `---` divider.

---

## Output Format

```markdown
### [Title: 5–10 words describing the deliverable]

**Type:** Task | Story

**Description**
2–3 sentences: what needs to be done and what outcome it achieves.

**Rationale** *(omit if benefit is obvious)*
Why this work is needed and what value it provides.

**Out of scope** *(omit if obvious)*
What this ticket deliberately does not cover.

**Acceptance Criteria**
- [ ] Verifiable outcome or system state
- [ ] Verifiable outcome or system state
- [ ] Documentation/testing criterion (if applicable)

**Blocked by:** ticket IDs *(omit if none)*
**Priority:** High | Medium | Low *(omit if not specified)*
**Estimated Effort:** XS | S | M | L | XL *(omit if not specified)*
```

---

## Acceptance Criteria Rules

- Each criterion describes an **outcome or state**, not a step taken
- Must be independently verifiable, and name how: command, dashboard, test or reviewer
- Include a testing/rollback criterion for risky changes (migrations, infra)
- 2 criteria minimum, 5 maximum

---

## Domain Tips

| Domain | What to include |
|---|---|
| Performance | Specific metric targets (latency, throughput, p99) |
| Security | Compliance requirement or threat model reference |
| Infrastructure | Environments affected (staging, prod); rollback criteria |
| Migrations | Data validation steps; rollback procedure |
| Integrations | Contract/interface definition |
| Monitoring | What to measure; alert thresholds and routing |

---

## Examples

### Upgrade Kubernetes cluster to v1.28

**Type:** Task

**Description**
Upgrade the production Kubernetes cluster from v1.25 to v1.28, including control plane and worker nodes, to maintain vendor support and access to security patches.

**Rationale**
v1.25 reaches end-of-life in Q2. Delay risks loss of security patch eligibility.

**Acceptance Criteria**
- [ ] Control plane and all worker nodes running v1.28
- [ ] All existing workloads healthy post-upgrade
- [ ] Rollback procedure documented and validated in staging
- [ ] Upgrade completed during scheduled maintenance window with zero data loss

**Priority:** High
**Estimated Effort:** L

---

### Implement disk usage alerting for production nodes

**Type:** Task

**Description**
Configure alerting to monitor disk usage across all production nodes and notify on-call engineers when thresholds are breached.

**Acceptance Criteria**
- [ ] Alert triggers at 80% disk usage per node
- [ ] Alert routes to PagerDuty and the on-call Slack channel, including node ID and current usage %
- [ ] Alerts visible in Grafana monitoring dashboard
- [ ] Alert validated in staging environment

**Priority:** Medium
**Estimated Effort:** S

---

### Enable auto-scaling for web application tier

**Type:** Story

**Description**
Implement horizontal auto-scaling for the web application tier to handle traffic spikes automatically and reduce risk of service degradation during peak usage.

**Rationale**
Fixed capacity has caused degraded performance during spikes (3 incidents in past quarter). Auto-scaling improves reliability without manual intervention.

**Acceptance Criteria**
- [ ] Auto-scaling configured on CPU and memory metrics (scale up at 70%, down at 30%)
- [ ] Minimum 3 replicas, maximum 15 replicas enforced
- [ ] Load test at 3x normal traffic demonstrates successful scale-up and scale-down
- [ ] Runbook updated with auto-scaling troubleshooting steps

**Priority:** High
**Estimated Effort:** M
