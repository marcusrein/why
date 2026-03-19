# Custom Rubrics

Rubrics define how `/why` scores the reasoning behind decisions. The default rubric works for most teams, but you can customize it to match what your team actually values.

## Rubric format

A rubric is a markdown file in `rubrics/` with YAML frontmatter and dimension definitions:

```markdown
---
name: my-team-rubric
description: One line explaining what this rubric optimizes for
---

## Dimensions

### Dimension name
Weight: XX%
1-3: What a low score looks like
4-6: What a mid score looks like
7-10: What a high score looks like

### Another dimension
Weight: XX%
...
```

Weights must add up to 100%. You can have 3-6 dimensions.

## Role calibration

Every rubric should include a `## Role calibration` section that explains how scoring adjusts based on who is making the decision. A CTO making an architecture call is evaluated differently than a junior engineer choosing a library.

```markdown
## Role calibration

- **Executive/CTO decisions**: What matters most at this scope
- **Senior/Staff engineer decisions**: What matters most at this scope
- **Mid-level engineer decisions**: What matters most at this scope
- **Junior engineer decisions**: What matters most at this scope
```

This isn't about lowering the bar for juniors. It's about evaluating the right things at the right scope. A junior who says "I'm not sure about this" shows better reasoning than one who says "this is definitely correct" with no evidence. A CTO who cites specific business constraints shows better reasoning than one who defers to "industry best practice."

## Setting your rubric

In SKILL.md, set the `rubric` field in the frontmatter:

```yaml
rubric: security-focused
```

The skill looks for `rubrics/[name].md`. If the file doesn't exist, it falls back to `rubrics/default.md`.

## When to customize

**Security-focused team** — Your threat model matters more than your velocity. Weight blind spots and threat awareness heavily. Flag auth bypasses as high severity. See `rubrics/security-focused.md`.

**Startup optimizing for speed** — Over-engineering is worse than under-engineering. Weight evidence specificity (is this grounded in your actual context?) and penalize cargo-culting from big-company playbooks. See `rubrics/startup-velocity.md`.

**Infrastructure team** — You might add a "blast radius" dimension and weight it at 30%. A config change that affects all services is different from one that affects a single endpoint.

**Data team** — Add a "data integrity" dimension. Weight assumption count higher — unstated assumptions about data shape, freshness, or completeness are the most common source of bugs.

**Platform team** — Add a "backward compatibility" dimension. Your consumers can't always update immediately.

## Creating a rubric

1. Copy `rubrics/default.md` to `rubrics/your-name.md`
2. Adjust dimensions and weights to match what your team cares about
3. Write role calibration notes for your team's actual roles
4. Add team-specific flag examples if relevant
5. Set `rubric: your-name` in SKILL.md
6. Commit the rubric so the whole team uses it

## Tips

- Start with the default rubric for a few weeks. Look at what flags come up most. That tells you what to weight.
- Don't add more than 6 dimensions. Scoring gets noisy.
- Write the 1-3 descriptions as things your team actually says. "We've always done it this way" hits different than "vague reasoning."
- Review rubric weights quarterly. What your team values shifts as the product matures.
