#!/usr/bin/env bash
#
# Claude Code status line:
#   1. where:  model · 📁 dir · 🌿 branch* · PR #n
#   2. usage:  context % · limit % · week % · $cost · duration
#   3. modes:  agent · worktree · vim (only when one is set)
# Reads the session JSON on stdin: https://code.claude.com/docs/en/statusline
# Parts whose field is missing are left out. `*` = uncommitted changes.
# "limit" is the 5-hour usage limit of your Claude plan.

CYAN='\033[36m' GREEN='\033[32m' YELLOW='\033[33m' RED='\033[31m'
DIM='\033[2m' RESET='\033[0m'

# One jq call. \x1f (not tab) separates fields so empty ones survive `read`.
IFS=$'\x1f' read -r model dir pct cost duration limit week agent worktree vim pr_num pr_url < <(
  jq -r '[.model.display_name, .workspace.current_dir, .context_window.used_percentage,
          .cost.total_cost_usd, .cost.total_duration_ms,
          .rate_limits.five_hour.used_percentage, .rate_limits.seven_day.used_percentage,
          .agent.name, .worktree.name, .vim.mode, .pr.number, .pr.url]
         | map(if . == null then "" else tostring end) | join("\u001f")'
)
# Colour for a percentage: green < 70, yellow 70-89, red >= 90.
color() {
  local p=${1%.*}
  if ((p >= 90)); then printf '%s' "$RED"
  elif ((p >= 70)); then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

sep="${DIM} · ${RESET}"

# --- Row 1: where -------------------------------------------------------------
row1="${CYAN}${model}${RESET}${sep}📁 ${dir##*/}"

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
if [[ -n $branch ]]; then
  [[ -n $(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | head -1) ]] && branch+="*"
  row1+="${sep}🌿 $branch"
fi

# OSC 8 makes the PR number clickable in terminals that support it.
[[ -n $pr_num ]] && row1+="${sep}\033]8;;${pr_url}\aPR #${pr_num}\033]8;;\a"

# --- Row 2: usage -------------------------------------------------------------
p=${pct%.*}
p=${p:-0}
row2="context $(color "$p")${p}%${RESET}"
[[ -n $limit ]] && row2+="${sep}limit $(color "$limit")${limit%.*}%${RESET}"
[[ -n $week ]] && row2+="${sep}week $(color "$week")${week%.*}%${RESET}"
[[ -n $cost ]] && row2+="${sep}${YELLOW}$(printf '$%.2f' "$cost")${RESET}"
[[ -n $duration ]] && row2+="${sep}$((duration / 60000))m"

# --- Row 3: modes -------------------------------------------------------------
modes=()
[[ -n $agent ]] && modes+=("agent $agent")
[[ -n $worktree ]] && modes+=("worktree $worktree")
[[ -n $vim ]] && modes+=("vim $vim")

printf '%b\n' "$row1" "$row2"
if ((${#modes[@]})); then
  row3=$(printf ' · %s' "${modes[@]}")
  printf '%b\n' "${DIM}${row3:3}${RESET}"
fi
