#!/usr/bin/env bash
# /why installer — sets up the why skill in any project
# Run: bash why-init.sh [target-dir]

set -euo pipefail

TARGET="${1:-.}"
SKILL_DIR="$TARGET/.claude/skills/why"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "/why — installing into $TARGET"
echo ""

# Create directory structure
mkdir -p "$SKILL_DIR/decisions"
mkdir -p "$SKILL_DIR/rubrics"

# Copy SKILL.md
if [ -f "$REPO_DIR/SKILL.md" ]; then
  cp "$REPO_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
  echo "  ✓ SKILL.md"
else
  echo "  ✗ SKILL.md not found in $REPO_DIR"
  exit 1
fi

# Copy default rubric
if [ -f "$REPO_DIR/rubrics/default.md" ]; then
  cp "$REPO_DIR/rubrics/default.md" "$SKILL_DIR/rubrics/default.md"
  echo "  ✓ rubrics/default.md"
fi

# Copy additional rubrics if they exist
for rubric in "$REPO_DIR/rubrics/"*.md; do
  [ -f "$rubric" ] || continue
  name=$(basename "$rubric")
  [ "$name" = "default.md" ] && continue
  cp "$rubric" "$SKILL_DIR/rubrics/$name"
  echo "  ✓ rubrics/$name"
done

# Create .gitkeep in decisions
touch "$SKILL_DIR/decisions/.gitkeep"
echo "  ✓ decisions/"

# Copy scripts
mkdir -p "$TARGET/scripts"
if [ -f "$REPO_DIR/scripts/why-stats.sh" ]; then
  cp "$REPO_DIR/scripts/why-stats.sh" "$TARGET/scripts/why-stats.sh"
  chmod +x "$TARGET/scripts/why-stats.sh"
  echo "  ✓ scripts/why-stats.sh"
fi
if [ -f "$REPO_DIR/scripts/why-digest.sh" ]; then
  cp "$REPO_DIR/scripts/why-digest.sh" "$TARGET/scripts/why-digest.sh"
  chmod +x "$TARGET/scripts/why-digest.sh"
  echo "  ✓ scripts/why-digest.sh"
fi

# Copy example if it exists
if [ -d "$REPO_DIR/examples" ]; then
  mkdir -p "$SKILL_DIR/examples"
  cp "$REPO_DIR/examples/"*.md "$SKILL_DIR/examples/" 2>/dev/null && echo "  ✓ examples/" || true
fi

# Ask about .gitignore — default is to TRACK decisions (they're the value)
echo ""
echo "  Decisions are tracked in git by default (recommended for team review)."
read -rp "  Exclude decisions from git instead? (y/n) " ignore_choice
if [[ "$ignore_choice" =~ ^[Yy]$ ]]; then
  echo "" >> "$TARGET/.gitignore"
  echo "# /why decision entries (excluded from version control)" >> "$TARGET/.gitignore"
  echo ".claude/skills/why/decisions/*.md" >> "$TARGET/.gitignore"
  echo "!.claude/skills/why/decisions/.gitkeep" >> "$TARGET/.gitignore"
  echo "  ✓ Updated .gitignore — decisions excluded"
else
  echo "  ✓ Decisions will be tracked in git"
fi

# Add /why context to CLAUDE.md so all Claude instances are decision-aware
CLAUDE_MD="$TARGET/CLAUDE.md"
WHY_SNIPPET='## /why — Team Decision Context

When working in this project, be aware of the `decisions/` directory at `.claude/skills/why/decisions/`. It contains structured records of human technical decisions made during AI-assisted development.

**Before suggesting an approach:** Check if a prior decision in `decisions/` already addressed the same system, files, or tradeoff. If so, reference it and build on it rather than re-litigating.

**When a decision contradicts a prior one:** Surface it. "Note: this reverses the approach from decisions/2026-03-10-no-orm.md — is that intentional?"

**Weekly digests:** Files matching `decisions/DIGEST-*.md` summarize team patterns. Read the most recent digest to understand recurring flags and team focus areas.

**Decision stats:** Run `bash scripts/why-stats.sh .claude/skills/why/decisions` for analytics.'

if [ -f "$CLAUDE_MD" ]; then
  # Check if snippet already exists
  if grep -q '/why — Team Decision Context' "$CLAUDE_MD" 2>/dev/null; then
    echo "  — CLAUDE.md already has /why context"
  else
    echo "" >> "$CLAUDE_MD"
    echo "$WHY_SNIPPET" >> "$CLAUDE_MD"
    echo "  ✓ Updated CLAUDE.md with /why team context"
  fi
else
  echo "$WHY_SNIPPET" > "$CLAUDE_MD"
  echo "  ✓ Created CLAUDE.md with /why team context"
fi

echo ""
echo "Done. Run /why in Claude Code to record your first decision."
echo ""
echo "Rubrics installed:"
for rubric in "$SKILL_DIR/rubrics/"*.md; do
  [ -f "$rubric" ] || continue
  name=$(basename "$rubric" .md)
  echo "  - $name"
done
echo ""
echo "Set your team's rubric in SKILL.md by changing the rubric field."
echo "See docs/custom-rubrics.md for how to write your own."
echo ""
