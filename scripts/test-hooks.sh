#!/usr/bin/env bash
#
# Tests the hooks against throwaway projects: each check must exit 2 on a
# real failure and 0 otherwise. Languages whose toolchain is missing are
# skipped. Run by validate.sh.

set -uo pipefail

hooks="$(cd "$(dirname "${BASH_SOURCE[0]}")/../hooks" && pwd)"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fails=0

expect() { # expect <want-exit> <name> <hook> [args...] < stdin
  local want=$1 name=$2 got
  shift 2
  bash "$@" >/dev/null 2>&1
  got=$?
  if [[ $got == "$want" ]]; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s: exit %s, want %s\n' "$name" "$got" "$want"
    fails=1
  fi
}
cmd() { jq -n --arg c "$1" '{tool_input: {command: $c}}'; }
denied() { # denied <name> <command>: guard-kube must return a deny decision
  if [[ $(cmd "$2" | bash "$hooks/guard-kube.sh" | jq -r '.hookSpecificOutput.permissionDecision // empty') == deny ]]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s: not denied\n' "$1"
    fails=1
  fi
}
repo() { # repo <dir>: fresh git repo with everything committed
  git -C "$1" init -q && git -C "$1" add -A &&
    git -C "$1" -c user.email=t@t -c user.name=t commit -qm init
}

# guard-kube
expect 0 "kube: read-only command passes" "$hooks/guard-kube.sh" < <(cmd "kubectl get pods --context prod")
expect 0 "kube: delete on kind passes" "$hooks/guard-kube.sh" < <(cmd "kubectl delete pod x --context kind-dev")
denied "kube: delete on remote context" "kubectl delete pod x --context prod-eu"
denied "kube: oc apply on remote context" "cd app && oc apply -f a.yaml --context=prod"

# lint
printf '#!/usr/bin/env bash\necho "$(ls"\n' >"$tmp/bad.sh"
if command -v shellcheck >/dev/null; then
  expect 2 "lint: broken shell script" "$hooks/lint.sh" < <(jq -n --arg f "$tmp/bad.sh" '{tool_input: {file_path: $f}}')
fi
expect 0 "lint: unknown file type" "$hooks/lint.sh" < <(jq -n --arg f "$tmp/bad.sh.txt" '{tool_input: {file_path: $f}}')

# verify: Python (pytest)
if command -v pytest >/dev/null; then
  p="$tmp/py"
  mkdir -p "$p"
  printf '[project]\nname = "m"\n' >"$p/pyproject.toml"
  printf 'def double(x):\n    return x * 2\n' >"$p/m.py"
  printf 'from m import double\n\n\ndef test_double():\n    assert double(2) == 4\n' >"$p/test_m.py"
  repo "$p"
  expect 0 "verify: clean tree does nothing" "$hooks/verify.sh" full < <(jq -n --arg d "$p" '{cwd: $d}')
  sed 's/x \* 2/x * 3/' "$p/m.py" >"$p/m.tmp" && mv "$p/m.tmp" "$p/m.py"
  expect 2 "verify: touched test fails" "$hooks/verify.sh" touched < <(jq -n --arg d "$p" '{cwd: $d}')
  expect 2 "verify: full suite fails" "$hooks/verify.sh" full < <(jq -n --arg d "$p" '{cwd: $d}')
  git -C "$p" checkout -q m.py && printf '# note\n' >>"$p/m.py"
  expect 0 "verify: passing change" "$hooks/verify.sh" full < <(jq -n --arg d "$p" '{cwd: $d}')
fi

# verify: Go
if command -v go >/dev/null; then
  g="$tmp/go"
  mkdir -p "$g/calc"
  printf 'module example.com/calc\n\ngo 1.21\n' >"$g/go.mod"
  printf 'package calc\n\nfunc Add(a, b int) int { return a + b }\n' >"$g/calc/calc.go"
  printf 'package calc\n\nimport "testing"\n\nfunc TestAdd(t *testing.T) {\n\tif Add(2, 3) != 5 {\n\t\tt.Fatal("want 5")\n\t}\n}\n' >"$g/calc/calc_test.go"
  repo "$g"
  sed 's/a + b/a - b/' "$g/calc/calc.go" >"$g/calc/c.tmp" && mv "$g/calc/c.tmp" "$g/calc/calc.go"
  expect 2 "verify: go package test fails" "$hooks/verify.sh" touched < <(jq -n --arg d "$g" '{cwd: $d}')
fi

exit "$fails"
