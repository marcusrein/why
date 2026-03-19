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

Both modes save structured markdown files to a `decisions/` directory with full metadata: date, time, branch, files, tags, role, rubric used, mode, and health score. Claude fills in the metadata. You provide the reasoning. Always.

Every entry gets an automatic **Reasoning Health Check** — a score from 1-10 and short flag tags that surface potential blind spots, unstated assumptions, or logical gaps in your reasoning. Scoring adapts to who's making the decision (role) and what rubric your team uses. Run `/why expand` to get the full breakdown appended to the entry.

## Install

### One command (recommended)

```bash
git clone https://github.com/marcusrein/why.git /tmp/why-install
bash /tmp/why-install/scripts/why-init.sh
```

Or curl the installer — it auto-clones the repo if needed:

```bash
curl -sL https://raw.githubusercontent.com/marcusrein/why/main/scripts/why-init.sh -o /tmp/why-init.sh
bash /tmp/why-init.sh
```

The installer creates this structure in your project:

```
your-project/
  CLAUDE.md                    # Updated with /why team context (created if missing)
  .claude/
    skills/
      why/
        SKILL.md               # The skill Claude Code reads
        decisions/              # Where entries land
          .gitkeep
        rubrics/
          default.md            # General-purpose scoring (4 dimensions, equal weights)
          security-focused.md   # 5 dimensions, blind spots at 40%
          startup-velocity.md   # 5 dimensions, evidence specificity at 40%
        examples/
          example-decision.md
  scripts/
    why-stats.sh                # Decision analytics (no dependencies, just bash)
    why-digest.sh               # Weekly team digest generator
```

The installer also adds a `/why` context block to your project's `CLAUDE.md`. This makes every Claude instance in the project decision-aware — Claude will check for prior decisions before suggesting approaches, surface contradictions, and reference the team's collective reasoning.

Decisions are tracked in git by default — they're the value. The installer asks if you want to exclude them instead.

### Manual install

Copy the files yourself following the structure above. Claude Code picks up `SKILL.md` automatically from `.claude/skills/why/`. If installing manually, add the CLAUDE.md snippet from `scripts/why-init.sh` to make Claude instances decision-aware.

## Usage

### Manual

Type `/why` in Claude Code to record a decision in full mode.

### Auto-trigger

The skill activates in quick mode when you use override language:

- "actually let's do..."
- "I don't want to use..."
- "instead let's..."
- "I'd rather..."
- "let's go with..."
- "override"
- "scratch that"
- "no, do it this way"
- "forget that approach"
- "I'm going to go with..."

Claude asks one question — *What did you decide and why?* — then saves the entry. Quick and out of the way.

### Setting your role

Role calibrates how the health check evaluates your reasoning. Set it explicitly:

- Say "I'm a junior engineer" or "CTO here" in conversation
- Run `/why role [role]` to set it for the session

Valid roles: `cto`, `staff`, `senior`, `mid`, `junior`. If you don't set a role, Claude infers it from the scope of the decision. Explicit always wins over inferred.

### What gets created

Each decision becomes a timestamped markdown file:

```
decisions/
  2026-03-10-custom-session-handler.md
  2026-03-12-sqlite-over-postgres.md
  2026-03-14-manual-csv-parser.md
  2026-03-18-no-orm.md
```

Entry frontmatter includes:

```yaml
date: 2026-03-15
time: 14:32
branch: feature/user-auth
files: [src/auth/session.ts, src/auth/middleware.ts]
tags: [dependency, architecture, security]
role: senior
rubric: default
mode: full
health_score: 8
```

### Reasoning Health Check

Every entry automatically gets a health check below the developer's answers:

```
Score: 8/10

Flags: session-fixation(med), team-coupling(low)

Related: [2026-03-12-auth-middleware.md]

Run /why expand for details.
```

The score is a weighted average across the active rubric's dimensions. Flags are short slugs with severity (`low`, `med`, `high`) that surface specific concerns. The `Related:` line appears when prior decisions in `decisions/` touch the same files, tags, or system area — linking the team's reasoning together over time. If a decision contradicts a prior one without acknowledgment, it gets flagged with `contradicts-prior(med)`. AI analysis never mixes into the developer's answers — it lives below a `---` separator.

### `/why expand`

Run `/why expand` and the detailed analysis gets appended to the most recent decision file:

- **Flag breakdown** — one sentence per flag explaining what was detected
- **Assumptions surfaced** — implicit assumptions stated explicitly
- **Blind spots** — failure modes the developer didn't address
- **Confidence calibration** — where certainty matched or exceeded evidence

## Rubrics

Rubrics define how decisions are scored. Each rubric has weighted dimensions and role-specific calibration guidance. Ships with three:

| Rubric | Optimizes for | Dimensions | Key weight |
|--------|--------------|------------|------------|
| `default` | General-purpose reasoning | 4: evidence, assumptions, blind spots, confidence | Equal (25% each) |
| `security-focused` | Security posture | 5: evidence, assumptions, blind spots, threat model awareness, confidence | Blind spots at 40% |
| `startup-velocity` | Speed and pragmatism | 5: evidence, assumptions, blind spots, reversibility assessment, confidence | Evidence at 40% |

Set your team's rubric in SKILL.md frontmatter:

```yaml
rubric: security-focused
```

The skill resolves rubrics relative to the SKILL.md file location (`rubrics/[name].md` in the same directory). Falls back to `default` if the specified rubric doesn't exist.

Write your own rubric for your team's values. See [docs/custom-rubrics.md](docs/custom-rubrics.md).

### Role calibration

Every rubric includes a `Role calibration` section that adjusts which dimensions matter most based on who's making the decision. This varies by rubric — here's how the three shipped rubrics differ:

**Default rubric:**
- **CTO/Executive** — Evidence specificity weighs heavier. These decisions are expensive to reverse.
- **Staff/Senior** — All dimensions weighted equally. Expected to articulate tradeoffs explicitly.
- **Mid-level** — Assumption awareness is the key signal. Are they aware of what they don't know?
- **Junior** — Confidence calibration matters most. Appropriate uncertainty scores higher than false confidence.

**Security-focused rubric:**
- **CTO/Executive** — Threat model awareness is paramount. Evidence should reference compliance, not just intuition.
- **Staff/Senior** — Blind spot severity is the primary signal. Should catch auth bypass and data exposure without prompting.
- **Mid-level** — Rewarded for flagging security concerns to seniors rather than solving alone.
- **Junior** — "I'm not sure if this is secure" scores higher than "this is fine."

**Startup-velocity rubric:**
- **Founder/CTO** — Evidence grounded in actual context (runway, user count, team size), not borrowed best practices. Reversibility assessment matters — founders make the hardest-to-undo choices.
- **Staff/Senior** — Pragmatism rewarded. "This is tech debt and I'm taking it on purpose" is a high-scoring answer.
- **Mid-level** — Are they building something that requires conditions the startup hasn't validated?
- **Junior** — Main signal: are they shipping or blocked trying to make it perfect?

Role calibration adjusts which dimensions matter most, not the overall scoring bar.

## Team coordination

When multiple team members install `/why` in the same repo, their decisions sync through git. Every Claude instance becomes aware of the team's collective reasoning.

### How it works

1. **The installer adds context to CLAUDE.md.** Every Claude instance in the project reads this on startup. It tells Claude to check `decisions/` for prior reasoning before suggesting approaches.

2. **Decisions cross-reference automatically.** When a new decision relates to files or tags from a prior entry, the health check includes a `Related:` line linking to those entries. If a decision contradicts a prior one without acknowledgment, it gets flagged with `contradicts-prior(med)`.

3. **Weekly digests aggregate patterns.** Run `why-digest.sh` to generate a team summary that Claude instances can read for context.

### Cross-instance awareness

When Sarah makes a decision about the auth system on Monday and commits it, David's Claude instance can reference it on Wednesday:

> "Note: Sarah decided to use in-memory sessions over Redis in [decisions/2026-03-15-custom-session-handler.md]. Your proposed change to add Redis would reverse that decision — is that intentional?"

This happens because CLAUDE.md tells every Claude instance to check `decisions/` before suggesting approaches. No MCP server, no shared backend — just git and markdown.

### Weekly digest

Generate a team summary:

```bash
bash scripts/why-digest.sh .claude/skills/why/decisions
```

This creates `decisions/DIGEST-2026-W12.md` with:

- Decision count, mode breakdown, average score
- Table of all decisions with scores and roles
- Recurring flags across the team
- Participation by role with average scores
- A "Patterns & observations" section for the team to fill in during retros

Commit the digest so Claude instances can read it for team context.

Arguments: `why-digest.sh [decisions-dir] [weeks-back]`. Defaults to `decisions/` and 1 week.

## Stats

Run `why-stats.sh` against your decisions directory:

```bash
bash scripts/why-stats.sh .claude/skills/why/decisions 30
```

```
/why stats — last 30 days

Decisions logged:    14
Avg health score:    6.8
Score distribution:  ▓▓▓▓▓▓▓▓██░░ (1-3: 1, 4-7: 8, 8-10: 5)
Top flags:           unscoped-work(6), no-evidence(3), recency-bias(2)
Decisions this week: 3
By role:             senior(8) mid(4) junior(2)

Score by role:
  junior: 2 decisions, avg score 5.5
  mid: 4 decisions, avg score 6.2
  senior: 8 decisions, avg score 7.4
```

The role breakdown and score-by-role sections appear when entries have role data. No dependencies — just bash + awk. Runs on macOS and Linux.

Arguments: `why-stats.sh [decisions-dir] [days]`. Defaults to `decisions/` and 30 days.

## For teams

See [docs/team-guide.md](docs/team-guide.md) for:

- How different roles (CTO to junior) use `/why` — when to use quick vs full mode, what the health check catches for each role
- How to review each other's decision entries (like code review but for reasoning)
- How to use stats in retros and standups
- How to choose and customize a rubric for your team
- What a healthy `decisions/` folder looks like at 1 month, 3 months, 6 months
- Anti-patterns to avoid

## Why this matters

An engineer's `decisions/` folder is a body of work that can't be faked. It shows:

- **Technical taste** — what you choose not to use matters as much as what you build
- **Context awareness** — decisions that account for team size, infra constraints, timeline
- **Ownership of tradeoffs** — you know what could break and why you accepted the risk
- **Signal in a noisy world** — when everyone's code looks the same, the reasoning behind it is what separates you

This is your audit trail. For yourself, for your team, for anyone who inherits your code and needs to know why it's shaped the way it is.

**Scores are not performance metrics.** They measure reasoning quality on a single decision, not developer quality. Never use them in performance reviews. See the [team guide](docs/team-guide.md) anti-patterns section.

## Example entry

See [examples/example-decision.md](examples/example-decision.md) for a complete entry showing a senior engineer who rejected a Redis-backed session store in favor of 40 lines of custom code, with reasoning and health check.

## Principles

- **Claude fills metadata, never answers.** Questions are human-only.
- **Quick is the default.** Auto-triggers ask one question. Full mode is opt-in via `/why`.
- **Health check is automatic.** Score and flags on every entry. No extra prompts.
- **Expand is opt-in.** Full breakdown only when you run `/why expand`.
- **Your words, verbatim.** Answers are stored exactly as written, above the line. AI analysis lives below.
- **Rubrics are swappable.** Scoring adapts to what your team values.
- **Role-aware scoring.** Declare your role or let it be inferred. The same rubric evaluates different roles at appropriate scope.
- **Git is the database.** Everything is markdown files in your repo. No backend, no accounts, no infra.
- **Team-aware by default.** Every Claude instance reads CLAUDE.md and checks prior decisions before suggesting approaches.

## Project structure

```
why/
  SKILL.md                    # Claude Code skill definition
  README.md                   # This file
  LICENSE                     # MIT
  decisions/                  # Where entries land
  examples/
    example-decision.md       # Full mode entry with health check
  rubrics/
    default.md                # 4 dimensions, equal weights
    security-focused.md       # 5 dimensions, blind spots at 40%
    startup-velocity.md       # 5 dimensions, evidence at 40%
  scripts/
    why-stats.sh              # Decision analytics (bash, no deps)
    why-digest.sh             # Weekly team digest generator
    why-init.sh               # One-command installer
  docs/
    custom-rubrics.md         # How to write your own rubric
    team-guide.md             # How to roll /why out to a team
```

## License

MIT
