# /why

A human judgment registry for AI-assisted development.

## The problem

AI writes code now. It writes a lot of it, and it writes it fast. The old signals that distinguished good engineers from average ones are dissolving. Clean commit history? Claude can do that. Sensible architecture? Claude has opinions. Tests, docs, types? Auto-generated.

What AI can't do is explain *why you told it no*.

The most valuable thing a developer does in an AI-assisted workflow isn't writing code. It's overriding suggestions, rejecting approaches, choosing constraints, and making tradeoffs that require context the model doesn't have. That judgment is invisible unless you capture it.

`/why` captures it.

## What it does

`/why` is a Claude Code skill that creates structured records of human technical decisions. Every time you override Claude, reject an approach, or make an architectural call, `/why` walks you through five questions:

1. What problem were you solving?
2. What did Claude suggest that you rejected, and why?
3. What did you decide and what was your reasoning?
4. What parts of the output did you write or override yourself?
5. What would break this, and do you understand why?

Your answers are saved as markdown files in a `/decisions` directory. Claude fills in metadata (date, branch, files). You provide the reasoning. Always.

## Why this matters

An engineer's `/decisions` folder is a body of work that can't be faked. It shows:

- **Technical taste** — what you choose not to use matters as much as what you build
- **Context awareness** — decisions that account for team size, infra constraints, timeline
- **Ownership of tradeoffs** — you know what could break and why you accepted the risk
- **Signal in a noisy world** — when everyone's code looks the same, the reasoning behind it is what separates you

This is your audit trail. For yourself, for your team, for anyone who inherits your code and needs to know why it's shaped the way it is.

## Install

Copy the `why/` directory into your project:

```
your-project/
  .claude/
    skills/
      why/
        SKILL.md
        decisions/
          .gitkeep
        examples/
          example-decision.md
```

Or clone and symlink:

```bash
git clone https://github.com/your-username/why.git ~/.claude-skills/why
ln -s ~/.claude-skills/why your-project/.claude/skills/why
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

When Claude detects these patterns, it starts the five-question flow.

### What gets created

Each decision becomes a file in `decisions/`:

```
decisions/
  2026-03-10-custom-session-handler.md
  2026-03-12-sqlite-over-postgres.md
  2026-03-14-manual-csv-parser.md
  2026-03-18-no-orm.md
```

Over time, this folder becomes a searchable record of every meaningful technical decision in your project, with full reasoning attached.

## Example entry

See [examples/example-decision.md](examples/example-decision.md) for a complete entry showing a developer who rejected a Redis-backed session store in favor of 40 lines of custom code, with reasoning documented across all five questions.

## Principles

- **Claude fills metadata, never answers.** The five questions are human-only.
- **No skipping.** All five questions, every time.
- **No editorializing.** The skill records. It doesn't judge.
- **Your words, verbatim.** Answers are stored exactly as written.

## License

MIT
