#!/usr/bin/env bash
# PostToolUse (Edit|Write). Adaptive, NON-BLOCKING: detects the linter of the
# edited file's project at runtime and reports. Always exits 0.
# Versioned target: repo osigc-claude.
set -u

payload="$(cat)"
file="$(printf '%s' "$payload" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path","") or "")
except Exception: print("")' 2>/dev/null)"

[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

# Find project root: nearest ancestor with a project marker.
dir="$(cd "$(dirname "$file")" 2>/dev/null && pwd)" || exit 0
root=""
d="$dir"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -f "$d/package.json" ] || [ -f "$d/pyproject.toml" ] || [ -f "$d/ruff.toml" ] || [ -f "$d/.ruff.toml" ]; then
    root="$d"; break
  fi
  d="$(dirname "$d")"
done
[ -z "$root" ] && exit 0

ext="${file##*.}"
report() { printf '[lint] %s\n' "$1"; }

case "$ext" in
  js|jsx|ts|tsx|mjs|cjs)
    if [ -x "$root/node_modules/.bin/eslint" ]; then
      out="$("$root/node_modules/.bin/eslint" "$file" 2>&1)"; rc=$?
      [ $rc -ne 0 ] && { report "eslint ($root):"; printf '%s\n' "$out"; }
    elif [ -x "$root/node_modules/.bin/oxlint" ]; then
      out="$("$root/node_modules/.bin/oxlint" "$file" 2>&1)"; rc=$?
      [ $rc -ne 0 ] && { report "oxlint ($root):"; printf '%s\n' "$out"; }
    elif command -v oxlint >/dev/null 2>&1; then
      out="$(oxlint "$file" 2>&1)"; rc=$?
      [ $rc -ne 0 ] && { report "oxlint:"; printf '%s\n' "$out"; }
    fi
    ;;
  py)
    if [ -f "$root/pyproject.toml" ] || [ -f "$root/ruff.toml" ] || [ -f "$root/.ruff.toml" ] || command -v ruff >/dev/null 2>&1; then
      if command -v ruff >/dev/null 2>&1; then
        out="$(ruff check "$file" 2>&1)"; rc=$?
        [ $rc -ne 0 ] && { report "ruff:"; printf '%s\n' "$out"; }
      fi
    fi
    ;;
esac

exit 0
