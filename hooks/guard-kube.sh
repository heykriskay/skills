#!/usr/bin/env bash
#
# PreToolUse hook for Bash: denies `kubectl`/`oc` delete or apply against a
# context that isn't a local cluster. A permission rule can't do this because
# it only sees the command text, not which cluster the context points at.
# Local contexts: kind-*, k3d-*, minikube, docker-desktop, rancher-desktop,
# colima, crc*. Everything else counts as remote.

set -uo pipefail

cmd=$(jq -r '.tool_input.command // empty')
[[ $cmd =~ (^|[[:space:];|&\(])(kubectl|oc)[[:space:]] ]] || exit 0
tool=${BASH_REMATCH[2]}
[[ $cmd =~ [[:space:]](delete|apply)([[:space:]]|$) ]] || exit 0
verb=${BASH_REMATCH[1]}

if [[ $cmd =~ --context[=[:space:]]+([^[:space:]]+) ]]; then
  ctx=${BASH_REMATCH[1]}
elif [[ $cmd =~ (^|[[:space:]])oc[[:space:]] ]]; then
  ctx=$(oc config current-context 2>/dev/null)
else
  ctx=$(kubectl config current-context 2>/dev/null)
fi

case "$ctx" in
  kind-* | k3d-* | minikube | docker-desktop | docker-for-desktop | rancher-desktop | colima | crc*) exit 0 ;;
esac

reason="Blocked: $tool $verb against context '${ctx:-unknown}', which isn't a local cluster. Ask the user to run it."
jq -n --arg r "$reason" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
