#!/usr/bin/env bash
# /why stats — decision analytics from markdown frontmatter
# No dependencies. Just bash + awk/grep.

set -euo pipefail

DECISIONS_DIR="${1:-decisions}"
DAYS="${2:-30}"

if [ ! -d "$DECISIONS_DIR" ]; then
  echo "No decisions directory found at: $DECISIONS_DIR"
  echo "Usage: why-stats.sh [decisions-dir] [days]"
  exit 1
fi

# Date threshold
if date -v-${DAYS}d +%Y-%m-%d &>/dev/null; then
  CUTOFF=$(date -v-${DAYS}d +%Y-%m-%d)  # macOS
else
  CUTOFF=$(date -d "-${DAYS} days" +%Y-%m-%d)  # Linux
fi

TODAY=$(date +%Y-%m-%d)
WEEK_AGO=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d "-7 days" +%Y-%m-%d)

total=0
week_count=0
score_sum=0
score_count=0
low_count=0
mid_count=0
high_count=0
flags_raw=""
roles_raw=""
# Role-specific score tracking (role:score pairs separated by newlines)
role_scores=""

for file in "$DECISIONS_DIR"/*.md; do
  [ -f "$file" ] || continue
  [ "$(basename "$file")" = ".gitkeep" ] && continue

  # Extract date from frontmatter
  file_date=$(awk '/^---$/{n++; next} n==1 && /^date:/{print $2; exit}' "$file")
  [ -z "$file_date" ] && continue
  [[ "$file_date" < "$CUTOFF" ]] && continue

  total=$((total + 1))

  # Week count
  if [[ "$file_date" > "$WEEK_AGO" || "$file_date" == "$WEEK_AGO" ]]; then
    week_count=$((week_count + 1))
  fi

  # Score
  score=$(awk '/^---$/{n++; next} n==1 && /^health_score:/{print $2; exit}' "$file")
  if [ -n "$score" ] && [ "$score" -eq "$score" ] 2>/dev/null; then
    score_sum=$((score_sum + score))
    score_count=$((score_count + 1))
    if [ "$score" -le 3 ]; then
      low_count=$((low_count + 1))
    elif [ "$score" -le 7 ]; then
      mid_count=$((mid_count + 1))
    else
      high_count=$((high_count + 1))
    fi
  fi

  # Flags
  file_flags=$(grep -m1 '^Flags:' "$file" 2>/dev/null | sed 's/^Flags: //' || true)
  if [ -n "$file_flags" ] && [ "$file_flags" != "none" ]; then
    flags_raw="$flags_raw $file_flags"
  fi

  # Role + role-score tracking
  role=$(awk '/^---$/{n++; next} n==1 && /^role:/{$1=""; print; exit}' "$file" | xargs)
  if [ -n "$role" ]; then
    roles_raw="$roles_raw|$role"
    if [ -n "$score" ] && [ "$score" -eq "$score" ] 2>/dev/null; then
      role_scores="${role_scores}${role}:${score}\n"
    fi
  fi
done

# Calculate average
if [ "$score_count" -gt 0 ]; then
  avg=$(awk "BEGIN {printf \"%.1f\", $score_sum / $score_count}")
else
  avg="—"
fi

# Build distribution bar
bar_total=$((low_count + mid_count + high_count))
if [ "$bar_total" -gt 0 ]; then
  bar_len=12
  low_blocks=$((low_count * bar_len / bar_total))
  mid_blocks=$((mid_count * bar_len / bar_total))
  high_blocks=$((bar_len - low_blocks - mid_blocks))
  bar=""
  for ((i=0; i<low_blocks; i++)); do bar="${bar}░"; done
  for ((i=0; i<mid_blocks; i++)); do bar="${bar}▓"; done
  for ((i=0; i<high_blocks; i++)); do bar="${bar}█"; done
  distribution="$bar (1-3: $low_count, 4-7: $mid_count, 8-10: $high_count)"
else
  distribution="—"
fi

# Top flags
if [ -n "$flags_raw" ]; then
  # Extract flag names (strip severity), count occurrences
  top_flags=$(echo "$flags_raw" | tr ',' '\n' | tr ' ' '\n' | grep -o '[a-z-]*(' | tr -d '(' | sort | uniq -c | sort -rn | head -5 | awk '{printf "%s(%d), ", $2, $1}' | sed 's/, $//')
else
  top_flags="—"
fi

# Role breakdown with average scores
role_detail=""
if [ -n "$roles_raw" ]; then
  role_breakdown=$(echo "$roles_raw" | tr '|' '\n' | grep -v '^$' | sort | uniq -c | sort -rn | awk '{$1=$1; count=$1; $1=""; sub(/^ /, ""); printf "%s(%d) ", $0, count}' | sed 's/ $//')
  # Compute avg score per role
  if [ -n "$role_scores" ]; then
    role_detail=$(printf "$role_scores" | awk -F: '
      NF==2 {sum[$1]+=$2; count[$1]++}
      END {for (r in sum) printf "  %s: %d decisions, avg score %.1f\n", r, count[r], sum[r]/count[r]}
    ' | sort -t: -k1)
  fi
else
  role_breakdown=""
fi

echo ""
echo "/why stats — last $DAYS days"
echo ""
echo "Decisions logged:    $total"
echo "Avg health score:    $avg"
echo "Score distribution:  $distribution"
echo "Top flags:           $top_flags"
echo "Decisions this week: $week_count"
if [ -n "$role_breakdown" ]; then
  echo "By role:             $role_breakdown"
fi
if [ -n "$role_detail" ]; then
  echo ""
  echo "Score by role:"
  echo "$role_detail"
fi
echo ""
