---
name: startup-velocity
description: For teams optimizing for speed and iteration. Tolerates more risk. Penalizes over-engineering harder than under-engineering.
---

## Dimensions

### Evidence specificity
Weight: 40%
1-3: No reasoning at all. Decision made on autopilot or cargo-culting a pattern from a larger company.
4-6: Some reasoning but borrowed from contexts that don't apply. "Netflix does it this way" when you have 50 users.
7-10: Evidence grounded in your actual situation. Cites your user count, runway, team size, or current bottleneck. "We have 3 months of runway and 200 users — correctness matters less than shipping."

### Assumption count
Weight: 10%
1-3: Completely unaware of what's being assumed. Building on sand without knowing it.
4-6: Aware of major assumptions but hasn't validated them. Acceptable if the cost of being wrong is low.
7-10: Assumptions stated and triaged. Knows which ones matter now vs. which ones can be wrong for 6 months.

### Blind spot severity
Weight: 20%
1-3: Missed something that would block shipping or cause data loss. These are the only blind spots that matter at this stage.
4-6: Missed scaling concerns or maintenance burden. Acceptable if you're pre-product-market-fit.
7-10: Knows what will break and has a rough plan for when it does. Not necessarily a fix — just awareness and a trigger point.

### Reversibility assessment
Weight: 15%
1-3: Made an irreversible decision (data model, public API, vendor lock-in) without acknowledging it.
4-6: Partially aware of lock-in. Some irreversible choices made with mild awareness.
7-10: Explicitly categorized decisions as reversible vs. irreversible. Spent more time on the irreversible ones.

### Confidence calibration
Weight: 15%
1-3: Over-engineering with high certainty about future requirements. "We'll definitely need microservices."
4-6: Moderate overreach. Building for scale you don't have yet, but the cost is low.
7-10: Appropriately uncertain about the future. Building for now with clear extension points. "This is a monolith because we don't know what to extract yet."

## Role calibration

- **Founder/CTO decisions**: Evidence specificity is everything. Are they making decisions based on their actual context (team size, runway, user count) or importing patterns from companies 100x their size? Reversibility assessment matters — founders make the hardest-to-undo choices.
- **Senior/Staff engineer decisions**: Blind spot severity focused on shipping blockers, not theoretical scale. Reward pragmatism. Penalize gold-plating. "This is tech debt and I'm taking it on purpose" is a 9/10 answer.
- **Mid-level engineer decisions**: Assumption count matters more here — are they building something that requires conditions the startup hasn't validated? Reward speed-conscious reasoning.
- **Junior engineer decisions**: Evidence specificity bar is lower. Main signal: are they shipping or are they blocked trying to make it perfect? Reward asking "is this good enough?" over spending days on edge cases.

## Velocity-specific flags

- `over-engineering(high)` — Building for scale/correctness you don't need yet. This is the cardinal sin.
- `cargo-culting(med)` — Copying patterns from big-company contexts that don't apply here
- `irreversible-yolo(high)` — Made a hard-to-reverse decision (data model, public API) without pausing to think
- `premature-abstraction(med)` — Abstracting before you have three concrete cases
- `gold-plating(low)` — Spending time on polish that doesn't affect users or velocity
- `unvalidated-assumption(med)` — Building on an assumption about users/market that hasn't been tested
- `shipping-blocker(high)` — Decision creates a dependency or blocker that slows the team
