#!/usr/bin/env bash
# Active-epics sidebar for herdr (aiki).
#
# Renders aiki's in-flight epics and refreshes on an interval. This is the
# pane body for the `epics` entry in herdr-plugin.toml.
#
# Production note: prefer aiki's push event stream (Named-FIFO) over polling,
# so the rail re-renders on task changes instead of on a timer.
#
# Usage:
#   render-epics.sh           # live loop (used by the herdr pane)
#   render-epics.sh --once    # render a single frame and exit (for testing)

set -u

INTERVAL="${AIKI_EPICS_REFRESH:-5}"
ONCE=0
[ "${1:-}" = "--once" ] && ONCE=1

# aiki queries are repo-scoped by cwd. herdr runs pane commands from the plugin
# dir (HERDR_PLUGIN_ROOT), which is not an aiki repo, so resolve the target repo
# explicitly. Open the pane with the focused workspace's repo via
# `herdr plugin pane open --env AIKI_REPO=<repo>` (or `--cwd <repo>`).
REPO="${AIKI_REPO:-$PWD}"
cd "$REPO" 2>/dev/null || true

render() {
  clear 2>/dev/null || printf '\033[2J\033[H'
  printf '\033[1m⚡ Active epics\033[0m  \033[2m(aiki · every %ss)\033[0m\n' "$INTERVAL"
  printf '\033[2m──────────────────────────────\033[0m\n'

  # "Active" = open or in-progress epics. aiki's `task list` appends a context
  # footer ("In Progress:" / "Ready (N):"); strip everything from there down.
  local out
  out="$(aiki task list --all --kind epic --status open,in_progress 2>/dev/null \
         | awk '/^In Progress:/{exit} NF{print}')"

  if [ -z "$out" ] || printf '%s' "$out" | grep -q '^Tasks (0)'; then
    printf '\033[2mNo active epics right now.\033[0m\n\n'
    printf 'Start one:\n  \033[36maiki epic add <plan.md>\033[0m\n'
  else
    printf '%s\n' "$out"
  fi
}

while true; do
  render
  [ "$ONCE" = 1 ] && break
  sleep "$INTERVAL"
done
