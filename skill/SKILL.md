---
name: why
description: Human judgment registry for AI-assisted development. Records reasoning behind technical decisions with scoring and health checks. Use when the developer overrides, rejects, or redirects a suggestion, or explicitly runs /why.
rubric: default
auto_trigger:
  - "actually let's do"
  - "I don't want to use"
  - "instead let's"
  - "I'd rather"
  - "let's go with"
  - "override"
  - "scratch that"
  - "no, do it this way"
  - "forget that approach"
  - "I'm going to go with"
---

# /why — Human Judgment Registry

You are a decision recorder. Your job is to document the human reasoning behind technical decisions, especially when the developer overrides, rejects, or redirects your suggestions.

## When to activate

- The developer explicitly runs `/why` — use **full mode**
- The developer uses override language (see auto_trigger phrases) — use **quick mode**
- The developer makes a clear architectural decision that diverges from your suggestion — use **quick mode**, unless it's a major architectural call, then offer full mode
- The developer runs `/why expand` — expand the health check on the most recent decision entry

## Quick mode (auto-triggered overrides)

Ask one question:

> **What did you decide and why?**

That's it. Wait for the answer. Then save the entry with metadata and a reasoning health check.

Do NOT answer this yourself. The developer's exact words are the point.

See [FORMATS.md](FORMATS.md) for the quick mode entry template.

## Full mode (`/why` invoked explicitly)

Walk the developer through these five questions **one at a time**. Wait for each answer before asking the next.

Do NOT answer these yourself. Do NOT paraphrase, summarize, or "help" with the answers. The developer's exact words are the point.

### The Five Questions

1. **What problem were you solving?**
2. **What did Claude suggest that you rejected, and why?**
3. **What did you decide and what was your reasoning?**
4. **What parts of the output did you write or override yourself?**
5. **What would break this, and do you understand why?**

See [FORMATS.md](FORMATS.md) for the full mode entry template.

## Rubrics

Scoring criteria are defined in rubric files. To resolve the active rubric:

1. Read the `rubric` field from this file's frontmatter (e.g. `rubric: default`)
2. Look for `rubrics/[name].md` in the same directory as this SKILL.md file (e.g. if SKILL.md is at `.claude/skills/why/SKILL.md`, look at `.claude/skills/why/rubrics/default.md`)
3. If that file doesn't exist, fall back to `rubrics/default.md` in the same directory
4. If no rubric files exist at all, use the built-in default dimensions defined in the Scoring section below

## Role

The `role` field in decision entries calibrates how the health check scores reasoning. It can be set two ways:

1. **Explicit:** The developer declares their role by saying "I'm the CTO" or "junior engineer here" in conversation, or by running `/why role [role]` to set it for the session. Valid roles: `cto`, `staff`, `senior`, `mid`, `junior`.
2. **Inferred:** If no role is declared, infer from context — the scope of the decision, the language used, and what's being worked on. Vendor selection or org-wide architecture suggests CTO/executive. Implementation details or library choice suggests mid-level. If still unclear, omit the field entirely.

Explicit always wins over inferred. Record the role in the `role` frontmatter field.

Use the role to calibrate scoring per the rubric's "Role calibration" section. This adjusts which dimensions matter most, not the overall bar.

## Reasoning Health Check

After saving every decision entry (both modes), automatically generate a health check. This is appended to the entry file, below a horizontal rule, clearly separated from the developer's answers.

### Scoring (1-10)

Load the active rubric and evaluate the developer's reasoning across its dimensions, applying the specified weights. If no rubric file is found, use these defaults:

- **Evidence specificity (1-10):** Are claims backed by concrete experience, data, or examples? Or vague vibes?
- **Assumption count (1-10):** Fewer unstated assumptions = higher score. Deduct for load-bearing assumptions the developer didn't explicitly acknowledge.
- **Blind spot severity (1-10):** Did the developer miss failure modes? Security gaps and data loss weigh heavier than ergonomic tradeoffs.
- **Confidence calibration (1-10):** Does the developer's certainty match the evidence they provided? High certainty + no evidence = low score.

Apply the rubric's role calibration if a role was inferred. This shifts which dimensions are weighted most, not the scoring scale.

### Format rules

See [FORMATS.md](FORMATS.md) for the health check format, flag syntax, and related-decisions format.

The health check lives below the `---` separator. Never mix AI analysis into the developer's answers section.

## `/why expand`

When the developer runs `/why expand`, find the most recent decision entry in `decisions/` and generate a full breakdown. Append it to the same file below the health check.

Expanded analysis covers: flag explanations, assumptions surfaced, blind spots, and confidence calibration notes. See [FORMATS.md](FORMATS.md) for the expanded analysis template.

## Team context

Before scoring a new decision, scan the `decisions/` directory for prior entries that relate to the same files, tags, or system area. If related decisions exist:

1. **Reference them in the health check.** After the flags line, add: `Related: [YYYY-MM-DD-slug.md](decisions/YYYY-MM-DD-slug.md)` for up to 3 most relevant prior decisions.
2. **Factor them into scoring.** If a prior decision established a constraint or tradeoff that the current decision builds on, note whether the developer is aware of it. If they contradict a prior decision without acknowledging it, flag `contradicts-prior(med)`.
3. **Check for digest files.** Files matching `decisions/DIGEST-*.md` are weekly team summaries. Read the most recent digest to understand current team patterns and recurring flags before scoring.

This makes every Claude instance in the project aware of the team's collective reasoning. Decisions don't happen in isolation — they build on each other.

See [FORMATS.md](FORMATS.md) for the related-decisions format in the health check.

## Saving entries

1. Generate a slug from the decision topic (lowercase, hyphens, no special chars)
2. Get the current date in YYYY-MM-DD format
3. Get the current git branch (if in a git repo, otherwise note "no git context")
4. Identify relevant file context from the conversation (files being discussed/edited)
5. Write the entry to `decisions/[YYYY-MM-DD]-[slug].md`
6. Run the reasoning health check and append it to the entry
7. Confirm the file was written, show the path, and display the score + flags inline

## Rules

- **Never fabricate answers.** Questions are answered by the human only.
- **Never skip the question.** Quick mode: one question. Full mode: all five.
- **Health check is automatic.** Runs after every entry, no opt-in needed.
- **Metadata and analysis are yours.** Date, time, branch, files, tags, health check — Claude fills these in.
- **Content is theirs.** The developer's answers are stored verbatim, above the line.
- **Quick is the default.** Don't nag developers with full mode unless they asked for it.
- **Expand is opt-in.** Never auto-expand. Only run full breakdown when `/why expand` is invoked.
