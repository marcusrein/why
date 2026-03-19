---
name: default
description: General-purpose reasoning evaluation for technical decisions at any scope
---

## Dimensions

### Evidence specificity
Weight: 25%
1-3: Vague or absent. "I just think it's better." No references to data, past experience, or concrete tradeoffs.
4-6: Some reasoning but gaps. References experience without specifics. "We tried something like this before."
7-10: Concrete. Cites data, past incidents, measured tradeoffs, or specific constraints. "Our p99 latency is 200ms and this adds 50ms per request."

### Assumption count
Weight: 25%
1-3: Multiple unstated, load-bearing assumptions. The decision depends on things the developer didn't acknowledge.
4-6: Some assumptions surfaced, but key ones remain implicit. Developer is partially aware.
7-10: Assumptions are explicitly stated. Developer knows what they're betting on and says so.

### Blind spot severity
Weight: 25%
1-3: Missed critical failure modes — security gaps, data loss scenarios, or unrecoverable states.
4-6: Missed moderate concerns — performance edge cases, team scaling issues, maintenance burden.
7-10: Failure modes addressed or explicitly accepted as known risks with mitigation plans.

### Confidence calibration
Weight: 25%
1-3: High certainty with no evidence, or low certainty on well-understood problems. Mismatch between conviction and backing.
4-6: Mostly calibrated but some claims overshoot the evidence. "This will definitely work" without testing.
7-10: Certainty matches evidence. Hedges where appropriate. "I'm confident because X, less sure about Y."

## Role calibration

Scoring adjusts to the scope of the decision and the role of the person making it:

- **Executive/CTO decisions** (architecture, vendor, strategy): Evidence specificity weighs heavier — these decisions are expensive to reverse. Blind spots should account for org-wide impact, not just technical failure modes.
- **Senior/Staff engineer decisions** (system design, API contracts, infrastructure): All dimensions weighted equally. Expected to surface assumptions and articulate tradeoffs explicitly.
- **Mid-level engineer decisions** (implementation approach, library choice, refactoring): Assumption count is the key signal — are they aware of what they don't know? Lower bar on blind spots for decisions with small blast radius.
- **Junior engineer decisions** (code-level choices, pattern selection, tool usage): Confidence calibration matters most — are they appropriately uncertain? Evidence specificity bar is lower since they have less experience to cite. Reward explicit reasoning over correct reasoning.

## Flag severity guide

- **high**: Security gaps, data loss risk, decisions that affect other teams or are expensive to reverse
- **med**: Performance concerns, unstated assumptions on scaling, maintenance burden, missing test coverage
- **low**: Style preferences presented as technical decisions, minor scope creep, cosmetic tradeoffs
