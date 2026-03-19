# Team Guide

How to roll `/why` out to a team so it actually gets used.

## Install

Run the installer in your project root:

```bash
git clone https://github.com/marcusrein/why.git /tmp/why-install
bash /tmp/why-install/scripts/why-init.sh
```

Or curl it directly:

```bash
curl -sL https://raw.githubusercontent.com/marcusrein/why/main/scripts/why-init.sh -o /tmp/why-init.sh
bash /tmp/why-init.sh
```

This creates `.claude/skills/why/` with the skill, default rubric, and an empty decisions directory.

## Who uses /why and how

Different roles make different kinds of decisions. The tool adapts.

### CTO / VP Engineering

**When to use:** Architecture calls, vendor selection, build-vs-buy, technology bets, org-wide standards.

**Mode:** Full mode (`/why`). These decisions are expensive to reverse and affect the whole org. The five questions force you to articulate what you're betting on and what could break.

**What the health check catches:** Decisions based on "industry best practice" without grounding in your specific context. Irreversible choices made without acknowledging they're irreversible. Strategy decisions where the threat model or competitive landscape wasn't considered.

**Example flags:** `cargo-culting(med)`, `irreversible-yolo(high)`, `unscoped-work(med)`

### Staff / Senior Engineer

**When to use:** System design decisions, API contracts, infrastructure choices, significant refactors, cross-team technical decisions.

**Mode:** Full mode for cross-cutting decisions. Quick mode for implementation-level overrides.

**What the health check catches:** Unstated assumptions about scale, traffic patterns, or team capacity. Blind spots in failure modes. Over-confidence on untested claims.

**Example flags:** `no-evidence(med)`, `security-gap(high)`, `type-safety-gap(med)`

### Mid-level Engineer

**When to use:** Library choices, implementation approaches, refactoring decisions, pattern selection, performance tradeoffs within a service.

**Mode:** Quick mode is usually enough. Use full mode when the decision affects other team members or changes a shared interface.

**What the health check catches:** Assumptions about how upstream/downstream systems behave. Decisions that work locally but create problems at scale. Copying patterns without understanding why they exist.

**Example flags:** `unscoped-work(med)`, `recency-bias(low)`, `premature-abstraction(med)`

### Junior Engineer

**When to use:** Any time you override Claude's suggestion and you're not sure if your reasoning is sound. Any time you make a choice you'd want to explain in code review.

**Mode:** Quick mode. The single question — "What did you decide and why?" — is a forcing function for articulating reasoning. That's the skill being built.

**What the health check catches:** Over-confidence without evidence. Under-confidence on things you actually understand. Decisions made by copying Stack Overflow without adapting to context.

**Example flags:** `no-evidence(high)`, `confidence-mismatch(med)`, `cargo-culting(low)`

## How to review decisions

Decision review works like code review but for reasoning.

### In PRs

When a PR includes a decision entry, review the reasoning, not just the code. Ask:

- Does the evidence match the claim?
- Are there assumptions the author didn't surface?
- Would you flag different blind spots?

This is especially valuable across experience levels. A senior reviewing a junior's decision entry can coach reasoning directly. A junior reviewing a senior's entry learns how experienced engineers think about tradeoffs.

### In retros / standups

Run `why-stats.sh` weekly:

```bash
bash scripts/why-stats.sh decisions 7
```

Look at:

- **Average score trending down?** The team might be moving too fast without thinking, or the rubric might be miscalibrated.
- **Same flags repeating?** That's a systemic issue. `no-evidence` showing up weekly means the team doesn't have good data access or isn't looking.
- **Low decision count?** Either decisions aren't happening (unlikely) or they're not being captured.
- **Role distribution:** Are only seniors logging decisions? Juniors benefit the most from the practice.

## Choosing a rubric

Start with `default`. After 2-4 weeks, look at your stats:

- If security flags dominate, switch to `security-focused`
- If over-engineering is the pattern, switch to `startup-velocity`
- If neither fits, write a custom rubric (see `docs/custom-rubrics.md`)

Set the rubric in SKILL.md:

```yaml
rubric: security-focused
```

The whole team uses the same rubric. This is intentional — it aligns how reasoning is evaluated.

## What healthy decisions/ folders look like

### After 1 month

- 10-20 entries
- Mix of quick and full mode
- Scores averaging 5-7 (this is normal — the point is improvement)
- A few expanded entries where flags prompted deeper thinking

### After 3 months

- 40-60 entries
- Score average trending up
- Recurring flags decreasing
- Team members referencing past decisions in PRs ("we decided X in decisions/2026-03-10-no-orm.md")
- Custom rubric in place reflecting team values

### After 6 months

- Decision entries referenced in architecture docs
- New team members reading the decisions/ folder during onboarding
- Rubric updated at least once based on what the team learned
- Stats integrated into retro workflow

## Anti-patterns

- **Treating it as busywork.** If people are writing "because I wanted to" as their reasoning, the tool isn't providing value. Fix the rubric or the team's understanding of why they're doing this.
- **Only seniors use it.** Juniors benefit the most. Make it part of onboarding.
- **Never reviewing entries.** Decision review is where the learning happens. Without it, entries are just files.
- **Gaming the score.** If people are writing verbose answers to get a high score, the rubric rewards the wrong thing. Tighten it.
- **Treating scores as performance metrics.** Scores measure reasoning quality on a single decision, not developer quality. Never use them in performance reviews.
