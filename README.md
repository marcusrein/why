# /why

A human judgment registry for AI-assisted development.

## The problem

AI writes code now. It writes a lot of it, and it writes it fast. The old signals that distinguished good engineers from average ones are dissolving. Clean commit history? Claude can do that. Sensible architecture? Claude has opinions. Tests, docs, types? Auto-generated.

What AI can't do is explain *why you told it no*.

The most valuable thing a developer does in an AI-assisted workflow isn't writing code. It's overriding suggestions, rejecting approaches, choosing constraints, and making tradeoffs that require context the model doesn't have. That judgment is invisible unless you capture it.

`/why` captures it.

## What it does

`/why` is a Claude Code skill that creates structured records of human technical decisions. It has two modes:

**Quick mode** — triggers automatically when you override Claude mid-conversation ("scratch that", "I'd rather", "instead let's..."). Asks one question: *What did you decide and why?* Low friction. Takes 10 seconds.

**Full mode** — triggered explicitly with `/why`. Walks you through five questions:

1. What problem were you solving?
2. What did Claude suggest that you rejected, and why?
3. What did you decide and what was your reasoning?
4. What parts of the output did you write or override yourself?
5. What would break this, and do you understand why?

Both modes save structured markdown files to a `decisions/` directory. Claude fills in metadata (date, branch, files, inferred role). You provide the reasoning. Always.

Every entry gets an automatic **Reasoning Health Check** — a score from 1-10 and short flag tags that surface potential blind spots, unstated assumptions, or logical gaps in your reasoning. The scoring adapts to who's making the decision and what rubric your team uses. Run `/why expand` to get the full breakdown.

## Install

One command:

```bash
git clone https://github.com/marcusrein/why.git /tmp/why-install
bash /tmp/why-install/scripts/why-init.sh
```

This creates `.claude/skills/why/` in your project with the skill, rubrics, decisions directory, and copies `scripts/why-stats.sh` for analytics. Decisions are tracked in git by default (recommended for team review).

Or manually copy the skill:

```
your-project/
  .claude/
    skills/
      why/
        SKILL.md
        decisions/
        rubrics/
          default.md
        examples/
          example-decision.md
```

That's it. Claude Code picks up `SKILL.md` automatically.

## Usage

### Manual

Type `/why` in Claude Code at any point to record a decision.

### Auto-trigger

The skill activates automatically when you use phrases like:

- "actually let's do..."
- "I don't want to use..."
- "instead let's..."
- "I'd rather..."
- "scratch that"
- "let's go with..."

When Claude detects these patterns, it asks a single question: *What did you decide and why?* Quick and out of the way.

### What gets created

Each decision becomes a file in `decisions/`:

```
decisions/
  2026-03-10-custom-session-handler.md
  2026-03-12-sqlite-over-postgres.md
  2026-03-14-manual-csv-parser.md
  2026-03-18-no-orm.md
```

### Reasoning Health Check

Every entry automatically gets:

```
Score: 8/10

Flags: session-fixation(med), team-coupling(low)

Run /why expand for details.
```

The score is based on your team's active rubric. The default evaluates evidence specificity, unstated assumptions, blind spot severity, and confidence calibration. Scoring calibrates to the scope of the decision — a CTO's architecture call is evaluated differently than a junior's library choice.

### `/why expand`

Run `/why expand` and the detailed analysis gets appended to the most recent decision file — flag explanations, surfaced assumptions, blind spots, confidence notes.

## Rubrics

Rubrics define how decisions are scored. Ships with three:

| Rubric | Optimizes for | Key weight |
|--------|--------------|------------|
| `default` | General-purpose reasoning | Equal weights |
| `security-focused` | Security posture | Blind spots at 40% |
| `startup-velocity` | Speed and pragmatism | Evidence specificity at 40% |

Set your team's rubric in SKILL.md:

```yaml
rubric: security-focused
```

Write your own rubric for your team's values. See [docs/custom-rubrics.md](docs/custom-rubrics.md).

### Role calibration

Every rubric includes guidance on how scoring adjusts by role:

- **CTO/Executive** — Evaluated on evidence grounding and irreversibility awareness. Strategy decisions need data, not vibes.
- **Staff/Senior** — All dimensions weighted. Expected to surface assumptions and articulate tradeoffs explicitly.
- **Mid-level** — Assumption awareness is the key signal. Are they aware of what they don't know?
- **Junior** — Confidence calibration matters most. Appropriate uncertainty scores higher than false confidence.

Role can be declared explicitly ("I'm a junior engineer" or `/why role junior`) or inferred from context. Explicit always wins.

## Stats

Run `why-stats.sh` to see decision analytics:

```bash
bash scripts/why-stats.sh decisions 30
```

```
/why stats — last 30 days

Decisions logged:    14
Avg health score:    6.8
Score distribution:  ▓▓▓▓▓▓▓▓██░░ (1-3: 1, 4-7: 8, 8-10: 5)
Top flags:           unscoped-work(6), no-evidence(3), recency-bias(2)
Decisions this week: 3
```

No dependencies. Just bash. Runs anywhere.

## For teams

See [docs/team-guide.md](docs/team-guide.md) for:

- How different roles (CTO to junior) use `/why`
- How to review each other's decision entries
- How to use stats in retros and standups
- What a healthy `decisions/` folder looks like over time

## Why this matters

An engineer's `decisions/` folder is a body of work that can't be faked. It shows:

- **Technical taste** — what you choose not to use matters as much as what you build
- **Context awareness** — decisions that account for team size, infra constraints, timeline
- **Ownership of tradeoffs** — you know what could break and why you accepted the risk
- **Signal in a noisy world** — when everyone's code looks the same, the reasoning behind it is what separates you

This is your audit trail. For yourself, for your team, for anyone who inherits your code and needs to know why it's shaped the way it is.

## Example entry

See [examples/example-decision.md](examples/example-decision.md) for a complete entry showing a developer who rejected a Redis-backed session store in favor of 40 lines of custom code, with reasoning and health check.

## Principles

- **Claude fills metadata, never answers.** Questions are human-only.
- **Quick is the default.** Auto-triggers ask one question. Full mode is opt-in via `/why`.
- **Health check is automatic.** Score and flags on every entry. No extra prompts.
- **Expand is opt-in.** Full breakdown only when you run `/why expand`.
- **Your words, verbatim.** Answers are stored exactly as written, above the line. AI analysis lives below.
- **Rubrics are swappable.** Scoring adapts to what your team values.
- **Role-aware scoring.** The same rubric evaluates different roles at appropriate scope.

## Project structure

```
why/
  SKILL.md                    # Claude Code skill definition
  README.md                   # This file
  LICENSE                     # MIT
  decisions/                  # Where entries land
  examples/                   # Example entries
  rubrics/
    default.md                # General-purpose scoring
    security-focused.md       # For security-conscious teams
    startup-velocity.md       # For teams optimizing for speed
  scripts/
    why-stats.sh              # Decision analytics
    why-init.sh               # One-command installer
  docs/
    custom-rubrics.md          # How to write your own rubric
    team-guide.md              # How to roll /why out to a team
```

## License

MIT
