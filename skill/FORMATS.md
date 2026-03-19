# Entry Formats

## Quick mode entry format

```markdown
---
date: YYYY-MM-DD
time: HH:MM
branch: [git branch or "no git context"]
files: [list of relevant files from conversation]
tags: [inferred from content, e.g. architecture, dependency, performance]
role: [inferred from context: cto, staff, senior, mid, junior — or omit if unclear]
rubric: [rubric name used for scoring]
mode: quick
health_score: [1-10]
---

# [Decision Title]

## What did you decide and why?
[Developer's exact answer]

---
## Reasoning Health Check (AI-generated)

Score: [X]/10

Flags: [tag(severity), tag(severity), ...]

Run `/why expand` for details.
```

## Full mode entry format

```markdown
---
date: YYYY-MM-DD
time: HH:MM
branch: [git branch or "no git context"]
files: [list of relevant files from conversation]
tags: [inferred from content, e.g. architecture, dependency, performance]
role: [inferred from context: cto, staff, senior, mid, junior — or omit if unclear]
rubric: [rubric name used for scoring]
mode: full
health_score: [1-10]
---

# [Decision Title]

## 1. What problem were you solving?
[Developer's exact answer]

## 2. What did Claude suggest that you rejected, and why?
[Developer's exact answer]

## 3. What did you decide and what was your reasoning?
[Developer's exact answer]

## 4. What parts of the output did you write or override yourself?
[Developer's exact answer]

## 5. What would break this, and do you understand why?
[Developer's exact answer]

---
## Reasoning Health Check (AI-generated)

Score: [X]/10

Flags: [tag(severity), tag(severity), ...]

Run `/why expand` for details.
```

## Health check format

The health check in the entry is exactly three lines:

1. `Score: X/10`
2. `Flags: tag(severity), tag(severity), ...`
3. `Run /why expand for details.`

Flag tags are short descriptive slugs with severity: `low`, `med`, or `high`. Examples: `recency-bias(low)`, `unscoped-work(med)`, `type-safety-gap(med)`, `no-evidence(high)`, `security-gap(high)`.

If there are no flags, write `Flags: none`. Keep moving.

When related decisions are found, add a `Related` line after the `Flags` line:

```
Score: 7/10

Flags: unscoped-work(med)

Related: [2026-03-10-api-contract.md], [2026-03-08-auth-middleware.md]

Run `/why expand` for details.
```

If no related decisions exist, omit the `Related` line.

## Expanded analysis format (`/why expand`)

```markdown
## Expanded Analysis (AI-generated)

### Flag breakdown
- **[flag-tag]([severity]):** [One sentence explanation]

### Assumptions surfaced
- [Assumption 1]
- [Assumption 2]

### Blind spots
- [Blind spot 1]
- [Blind spot 2]

### Confidence calibration
[1-2 sentences on how the developer's certainty matched their evidence]
```

Write this directly into the decision file, appended after the health check section.
