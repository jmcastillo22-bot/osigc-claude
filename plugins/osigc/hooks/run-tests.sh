#!/usr/bin/env bash
# Stop hook. Adaptive: detects the test runner for the session's cwd project and
# blocks the turn from ending ONLY if a real suite exists and fails.
# If no suite exists -> warn on stderr and exit 0 (never block).
# Versioned target: repo osigc-claude.
set -u

payload="$(cat)"

# Avoid infinite loop: if we already blocked once, let it stop.
active="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print("1" if json.load(sys.stdin).get("stop_hook_active") else "0")
except Exception: print("0")' 2>/dev/null)"
[ "$active" = "1" ] && exit 0

cwd="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("cwd","") or "")
except Exception: print("")' 2>/dev/null)"
[ -z "$cwd" ] && cwd="$PWD"
cd "$cwd" 2>/dev/null || exit 0

warn() { printf '[tests] %s\n' "$1" >&2; }
# Emit a block decision back to Claude Code (prevents the turn from ending).
block() {
  python3 - "$1" <<'PY'
import json,sys
print(json.dumps({"decision":"block","reason":sys.argv[1]}))
PY
  exit 0
}

runner=""; cmd=""

# 1) Node project with a REAL test script (not the npm placeholder).
if [ -f package.json ]; then
  ts="$(python3 -c 'import json;print(json.load(open("package.json")).get("scripts",{}).get("test",""))' 2>/dev/null)"
  case "$ts" in
    ""|*"no test specified"*) : ;;   # no real suite
    *) runner="npm"; cmd="npm test --silent" ;;
  esac
fi

# 2) Odoo module: a __manifest__.py with a tests/ dir.
if [ -z "$runner" ] && [ -f __manifest__.py ] && [ -d tests ]; then
  mod="$(basename "$cwd")"
  warn "Módulo Odoo '$mod' detectado con tests/, pero necesito el comando/DB reales (odoo-bin -d <db> --test-tags $mod). No lo ejecuto a ciegas."
  exit 0
fi

# 3) Python pytest suite.
if [ -z "$runner" ]; then
  if { [ -f pytest.ini ] || [ -f tox.ini ] || [ -d tests ] || grep -q "\[tool.pytest" pyproject.toml 2>/dev/null; } && command -v pytest >/dev/null 2>&1; then
    runner="pytest"; cmd="pytest -q"
  fi
fi

if [ -z "$runner" ]; then
  warn "Sin suite de tests detectada en $cwd — no bloqueo."
  exit 0
fi

out="$(eval "$cmd" 2>&1)"; rc=$?
if [ $rc -ne 0 ]; then
  block "Tests fallan ($cmd) en $cwd. No termino el turno hasta que pasen:
$(printf '%s' "$out" | tail -40)"
fi
exit 0
