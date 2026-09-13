#!/usr/bin/env bash
# Stop hook. Gate §9.2 del proyecto CVH PRECAST (lch.osigc.cloud):
# el formulario no se toca sin test verde en las DOS plantillas.
#
# Autoactivable: mientras no exista tests/form.spec.ts en el cwd de la sesión
# (es decir, mientras no exista el repo del tema hijo), no hace nada.
# Cuando existe, bloquea el fin de turno si la suite falla o si solo cubre una puerta.
# Versionado en: repo osigc-claude, plugin lch.
set -u

payload="$(cat)"

# Evita el bucle infinito: si ya bloqueamos una vez, dejamos terminar.
active="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print("1" if json.load(sys.stdin).get("stop_hook_active") else "0")
except Exception: print("0")' 2>/dev/null)"
[ "$active" = "1" ] && exit 0

cwd="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("cwd","") or "")
except Exception: print("")' 2>/dev/null)"
[ -z "$cwd" ] && cwd="$PWD"
cd "$cwd" 2>/dev/null || exit 0

SPEC="tests/form.spec.ts"

warn() { printf '[lch-form-gate] %s\n' "$1" >&2; }
block() {
  python3 - "$1" <<'PY'
import json,sys
print(json.dumps({"decision":"block","reason":sys.argv[1]}))
PY
  exit 0
}

# --- Condición de activación: el tema hijo con su suite todavía no existe ---
[ -f "$SPEC" ] || exit 0

# --- Innegociable: el gate cubre las dos plantillas de la doble puerta ---
# Dos plantillas (particulares y profesionales), esquema único de 8 ocultos.
faltan=""
grep -q "'part'\|\"part\"\|part-" "$SPEC" 2>/dev/null || faltan="particulares"
grep -q "'pro'\|\"pro\"\|pro-"   "$SPEC" 2>/dev/null || faltan="${faltan:+$faltan y }profesionales"
if [ -n "$faltan" ]; then
  block "El gate del formulario exige las DOS plantillas y $SPEC no cubre: $faltan.
Cada plantilla verifica los 8 campos ocultos, el valor de 'origen' segun la pagina,
'puerta' correcta, evento GA4 y mensaje de exito. Ver la skill lch-formulario."
fi

# --- Runner disponible ---
if [ ! -d node_modules/@playwright/test ] && ! command -v playwright >/dev/null 2>&1; then
  warn "AVISO: existe $SPEC pero Playwright no esta instalado. El gate NO se ha evaluado."
  warn "Instala las dependencias del proyecto antes de dar por buena una entrega."
  exit 0
fi

out="$(npx --no-install playwright test "$SPEC" --reporter=line 2>&1)"; rc=$?
if [ $rc -ne 0 ]; then
  block "Gate §9.2: falla $SPEC. No termino el turno hasta que pase en las dos plantillas.
$(printf '%s' "$out" | tail -40)"
fi
exit 0
