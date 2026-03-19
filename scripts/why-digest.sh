#!/usr/bin/env bash
# /why digest — generates a weekly team summary from decision entries
# Creates decisions/DIGEST-YYYY-WNN.md with team patterns, flag trends, and highlights
# No dependencies. Just bash + awk/grep.
#
# Usage: why-digest.sh [decisions-dir] [weeks-back]
#   decisions-dir: path to decisions/ folder (default: decisions)
#   weeks-back:    how many weeks back to cover (default: 1)

set -euo pipefail

DECISIONS_DIR="${1:-decisions}"
WEEKS_BACK="${2:-1}"

if [ ! -d "$DECISIONS_DIR" ]; then
  echo "No decisions directory found at: $DECISIONS_DIR"
  echo "Usage: why-digest.sh [decisions-dir] [weeks-back]"
  exit 1
fi

# Calculate date range
DAYS=$((WEEKS_BACK * 7))
if date -v-${DAYS}d +%Y-%m-%d &>/dev/null; then
  CUTOFF=$(date -v-${DAYS}d +%Y-%m-%d)
  TODAY=$(date +%Y-%m-%d)
  WEEK_NUM=$(date +%V)
  YEAR=$(date +%Y)
else
  CUTOFF=$(date -d "-${DAYS} days" +%Y-%m-%d)
  TODAY=$(date +%Y-%m-%d)
  WEEK_NUM=$(date +%V)
  YEAR=$(date +%Y)
fi

DIGEST_FILE="$DECISIONS_DIR/DIGEST-${YEAR}-W${WEEK_NUM}.md"

# Collect entries in range
total=0
score_sum=0
score_count=0
flags_raw=""
roles_raw=""
role_scores=""
entries=""
quick_count=0
full_count=0
tags_raw=""

for file in "$DECISIONS_DIR"/*.md; do
  [ -f "$file" ] || continue
  name=$(basename "$file")
  [ "$name" = ".gitkeep" ] && continue
  # Skip other digest files
  case "$name" in DIGEST-*) continue;; esac

  file_date=$(awk '/^---$/{n++; next} n==1 && /^date:/{print $2; exit}' "$file")
  [ -z "$file_date" ] && continue
  [[ "$file_date" < "$CUTOFF" ]] && continue

  total=$((total + 1))

  # Title
  title=$(grep '^# ' "$file" | head -1 | sed 's/^# //')

  # Score
  score=$(awk '/^---$/{n++; next} n==1 && /^health_score:/{print $2; exit}' "$file")
  if [ -n "$score" ] && [ "$score" -eq "$score" ] 2>/dev/null; then
    score_sum=$((score_sum + score))
    score_count=$((score_count + 1))
  fi

  # Mode
  mode=$(awk '/^---$/{n++; next} n==1 && /^mode:/{print $2; exit}' "$file")
  [ "$mode" = "quick" ] && quick_count=$((quick_count + 1))
  [ "$mode" = "full" ] && full_count=$((full_count + 1))

  # Role
  role=$(awk '/^---$/{n++; next} n==1 && /^role:/{$1=""; print; exit}' "$file" | xargs)
  if [ -n "$role" ]; then
    roles_raw="$roles_raw|$role"
    if [ -n "$score" ] && [ "$score" -eq "$score" ] 2>/dev/null; then
      role_scores="${role_scores}${role}:${score}\n"
    fi
  fi

  # Flags
  file_flags=$(grep -m1 '^Flags:' "$file" 2>/dev/null | sed 's/^Flags: //' || true)
  if [ -n "$file_flags" ] && [ "$file_flags" != "none" ]; then
    flags_raw="$flags_raw $file_flags"
  fi

  # Tags
  file_tags=$(awk '/^---$/{n++; next} n==1 && /^tags:/{$1=""; gsub(/[\[\]]/, ""); print; exit}' "$file" | xargs)
  if [ -n "$file_tags" ]; then
    tags_raw="$tags_raw, $file_tags"
  fi

  # Build entry line
  score_display="${score:-?}"
  role_display=""
  [ -n "$role" ] && role_display=" ($role)"
  entries="${entries}\n| ${file_date} | [${title}]($(basename "$file")) | ${score_display}/10 | ${mode:-?}${role_display} |"
done

# Calculate average
if [ "$score_count" -gt 0 ]; then
  avg=$(awk "BEGIN {printf \"%.1f\", $score_sum / $score_count}")
else
  avg="—"
fi

# Top flags
if [ -n "$flags_raw" ]; then
  top_flags=$(echo "$flags_raw" | tr ',' '\n' | tr ' ' '\n' | grep -o '[a-z-]*(' | tr -d '(' | sort | uniq -c | sort -rn | head -5 | awk '{printf "- `%s` (%d occurrences)\n", $2, $1}')
else
  top_flags="- None"
fi

# Top tags
if [ -n "$tags_raw" ]; then
  top_tags=$(echo "$tags_raw" | tr ',' '\n' | tr ' ' '\n' | grep -v '^$' | sort | uniq -c | sort -rn | head -5 | awk '{printf "`%s` ", $2}')
else
  top_tags="—"
fi

# Role breakdown
role_section=""
if [ -n "$roles_raw" ]; then
  role_section=$(echo "$roles_raw" | tr '|' '\n' | grep -v '^$' | sort | uniq -c | sort -rn | awk '{printf "- **%s**: %d decisions\n", $2, $1}')
  if [ -n "$role_scores" ]; then
    role_avg=$(printf "$role_scores" | awk -F: '
      NF==2 {sum[$1]+=$2; count[$1]++}
      END {for (r in sum) printf "- **%s**: avg score %.1f\n", r, sum[r]/count[r]}
    ' | sort)
    role_section="${role_section}

### Score by role
${role_avg}"
  fi
fi

# Write the digest
cat > "$DIGEST_FILE" << EOF
---
type: digest
week: ${YEAR}-W${WEEK_NUM}
period: ${CUTOFF} to ${TODAY}
decisions_count: ${total}
avg_score: ${avg}
---

# Team Digest — Week ${WEEK_NUM}, ${YEAR}

**Period:** ${CUTOFF} to ${TODAY}

## Summary

- **Decisions logged:** ${total} (${quick_count} quick, ${full_count} full)
- **Average health score:** ${avg}
- **Top areas:** ${top_tags}

## Decisions

| Date | Decision | Score | Mode |
|------|----------|-------|------|$(printf "$entries")

## Recurring flags

${top_flags}

$(if [ -n "$role_section" ]; then
echo "## Team participation"
echo ""
echo "$role_section"
fi)

## Patterns & observations

<!--
  This section is for the team to fill in during retros/standups.
  Questions to discuss:
  - Are recurring flags pointing to a systemic issue?
  - Are scores trending up or down? Why?
  - Which decisions should be referenced in future work?
  - Is the rubric still calibrated to what the team values?
-->

*Add team observations here during retro.*
EOF

echo "Digest written to: $DIGEST_FILE"
echo ""
echo "  Period:     $CUTOFF to $TODAY"
echo "  Decisions:  $total ($quick_count quick, $full_count full)"
echo "  Avg score:  $avg"
echo ""
