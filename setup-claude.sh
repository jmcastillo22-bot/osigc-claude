#!/usr/bin/env bash
# setup-claude.sh — deja una máquina (VPS o local) con el entorno Claude Code
# de Jose M. Castillo: plugins externos + MCP base + CLAUDE.md global + hook de
# seguridad. IDEMPOTENTE: seguro re-ejecutarlo (comprueba antes de actuar).
#
# Secretos: las claves MCP se guardan como REFERENCIA ${VAR}, nunca el valor en
# claro. El servidor las resuelve del entorno en runtime. Si la var no está,
# se avisa y se omite ese servidor (no se instala roto, no se inventa clave).
#
# Nada de pago: todos los plugins/MCP de este script son gratuitos/open. Si en
# el futuro se añade algo de pago, debe avisarse explícitamente aquí.

set -uo pipefail   # NO -e: un "ya existe" no debe abortar el resto.

CLAUDE_DIR="$HOME/.claude"
HOOK="$CLAUDE_DIR/hooks/guard-destructive.sh"
SETTINGS="$CLAUDE_DIR/settings.json"
GLOBAL_MD="$CLAUDE_DIR/CLAUDE.md"

c_ok()   { printf '  \033[32m✔\033[0m %s\n' "$1"; }
c_skip() { printf '  \033[2m•\033[0m %s\n' "$1"; }
c_warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
c_err()  { printf '  \033[31m✘\033[0m %s\n' "$1"; }
hdr()    { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

# ---------- preflight ----------
hdr "Preflight"
command -v claude >/dev/null 2>&1 || { c_err "falta el CLI 'claude' en PATH"; exit 1; }
command -v jq     >/dev/null 2>&1 || { c_err "falta 'jq'"; exit 1; }
command -v npx    >/dev/null 2>&1 || c_warn "falta 'npx' (node) — los MCP por npx no arrancarán hasta instalarlo"
c_ok "claude $(claude --version 2>/dev/null | head -1)"
mkdir -p "$CLAUDE_DIR/hooks"

# ---------- helpers idempotentes ----------
mp_present() { claude plugin marketplace list 2>/dev/null | grep -qF "$1"; }
add_marketplace() { # <source> <registered-name>
  if mp_present "$2"; then c_skip "marketplace $2 ya configurado"
  else claude plugin marketplace add "$1" >/dev/null 2>&1 \
       && c_ok "marketplace añadido: $2 ($1)" || c_err "no pude añadir marketplace $1"; fi
}
plugin_present() { claude plugin list 2>/dev/null | grep -qF "$1@"; }
install_plugin() { # <plugin@marketplace> <plugin-name>
  if plugin_present "$2"; then c_skip "plugin $2 ya instalado"
  else claude plugin install "$1" --scope user >/dev/null 2>&1 \
       && c_ok "plugin instalado: $1" || c_err "no pude instalar $1"; fi
}
mcp_present() { claude mcp list 2>/dev/null | grep -qE "^[[:space:]]*$1[[:space:]]*:"; }

# ---------- 1. plugins externos ----------
hdr "Plugins externos"
add_marketplace "anthropics/claude-plugins-official"     "claude-plugins-official"
add_marketplace "nextlevelbuilder/ui-ux-pro-max-skill"   "ui-ux-pro-max-skill"
install_plugin  "superpowers@claude-plugins-official"    "superpowers"
install_plugin  "frontend-design@claude-plugins-official" "frontend-design"
install_plugin  "ui-ux-pro-max@ui-ux-pro-max-skill"      "ui-ux-pro-max"

# ---------- 2. MCP base (claves por env var, nunca en claro) ----------
hdr "Servidores MCP"
# Sin clave:
if mcp_present playwright; then c_skip "playwright ya configurado"
else claude mcp add -s user playwright -- npx -y @playwright/mcp@latest >/dev/null 2>&1 \
     && c_ok "playwright añadido" || c_err "no pude añadir playwright"; fi

# context7 (CONTEXT7_API_KEY):
if mcp_present context7; then c_skip "context7 ya configurado"
elif [ -z "${CONTEXT7_API_KEY:-}" ]; then
  c_warn "CONTEXT7_API_KEY no está en el entorno → omito context7 (export la var y re-ejecuta)"
else
  # Comillas simples: se guarda la REFERENCIA, no el valor.
  claude mcp add -s user context7 -e 'CONTEXT7_API_KEY=${CONTEXT7_API_KEY}' \
    -- npx -y @upstash/context7-mcp >/dev/null 2>&1 \
    && c_ok "context7 añadido (clave por \${CONTEXT7_API_KEY})" || c_err "no pude añadir context7"
fi

# github (GITHUB_PERSONAL_ACCESS_TOKEN):
if mcp_present github; then c_skip "github ya configurado"
elif [ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
  c_warn "GITHUB_PERSONAL_ACCESS_TOKEN no está en el entorno → omito github (export la var y re-ejecuta)"
else
  claude mcp add -s user github -e 'GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN}' \
    -- npx -y @modelcontextprotocol/server-github >/dev/null 2>&1 \
    && c_ok "github añadido (token por \${GITHUB_PERSONAL_ACCESS_TOKEN})" || c_err "no pude añadir github"
fi

# ---------- 3. CLAUDE.md global (crear si falta; no pisar el existente) ----------
hdr "CLAUDE.md global"
if [ -f "$GLOBAL_MD" ]; then c_skip "$GLOBAL_MD ya existe (no se toca)"
else
  cat > "$GLOBAL_MD" <<'MD'
# Reglas globales — Jose M. Castillo García

Aplican a TODAS las sesiones y proyectos. Reglas universales únicamente;
nada específico de un proyecto concreto.

## Idioma y tono
- Responde en el idioma en que te escribo: español por defecto, inglés si escribo en inglés.
- Tono profesional y directo, sin filler ni hedging.
- Análisis con criterio: causa raíz + validaciones + impactos. Si discrepo, lo digo.

## Seguridad de infraestructura
- NINGUNA operación destructiva sin backup explícito previo Y mi aprobación.
  Incluye, como mínimo: `rm -rf`, `DROP`/`DELETE`/`TRUNCATE` de BD, `restart`/`stop`
  de contenedores o servicios, `rsync`/deploy/promote a producción, migraciones de
  esquema o datos.
- Ante la duda sobre si una acción es destructiva o irreversible: PROPÓN y ESPERA.
  No la ejecutes para "verificar".
- La aprobación es por acción y contexto: aprobar algo una vez no autoriza repetirlo
  ni extiende a operaciones parecidas.

## Secretos
- NUNCA escribir tokens, contraseñas, claves API ni credenciales en claro en ningún
  fichero (código, config, compose, docs, reports) ni en el chat.
- Referenciar siempre variables de entorno o ficheros de secretos con permisos 600.
- Si detecto un secreto en claro, lo señalo como regresión en vez de propagarlo.

## Estilo de trabajo
- Confirmaciones breves: resultados, diffs y puntos críticos. No resumir lo obvio.
- Actuar cuando ya tengo los datos; no pedir confirmación para lo no crítico.
- Propagar cualquier corrección a TODOS los ficheros afectados, no solo al primero.
- Parar tras 2 intentos fallidos del mismo comando: reportar y esperar input.
- No refactorizar fuera del scope ni añadir dependencias sin justificar.
MD
  c_ok "CLAUDE.md global creado"
fi

# ---------- 4. hook de seguridad (crear si falta + cablear en settings) ----------
hdr "Hook de seguridad PreToolUse"
if [ -x "$HOOK" ]; then c_skip "$HOOK ya existe y es ejecutable"
else
  cat > "$HOOK" <<'SH'
#!/usr/bin/env bash
# Guardarraíl: pide confirmación explícita ante comandos destructivos en producción.
# Salida JSON (exit 0) según hooks PreToolUse. NO bloquea lecturas, /home/claude ni beta.
INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0
ask() { jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'; exit 0; }
is_prod() { printf '%s' "$CMD" | grep -Eqi '/opt/(odoo19|osigc|n8n)|/etc/nginx|/var/www|public_html|osigcodoo|(erp|crm|admin)\.osigc|148\.230\.108\.106|odoo19|postgres16|(^|[^a-z])n8n([^a-z]|$)'; }
is_safe_scope() { printf '%s' "$CMD" | grep -Eqi '/home/claude|beta' && ! is_prod; }
REASON=""
if printf '%s' "$CMD" | grep -Eq '(^|[^a-zA-Z])rm[[:space:]]' && printf '%s' "$CMD" | grep -Eq -- '(-[a-zA-Z]*r|--recursive)' && printf '%s' "$CMD" | grep -Eq -- '(-[a-zA-Z]*f|--force)'; then
  REASON="rm recursivo+forzado (-rf): borrado irreversible."; fi
if [ -z "$REASON" ] && printf '%s' "$CMD" | grep -Eqi '(^|[^a-z])dropdb([^a-z]|$)|drop[[:space:]]+database'; then
  REASON="DROP DATABASE / dropdb: destrucción de base de datos."; fi
if [ -z "$REASON" ] && printf '%s' "$CMD" | grep -Eqi '(^|[^a-z])truncate([^a-z]|$)'; then
  REASON="TRUNCATE: vaciado irreversible de tabla."; fi
if [ -z "$REASON" ] && printf '%s' "$CMD" | grep -Eqi 'docker(-compose)?([[:space:]]|$)' && printf '%s' "$CMD" | grep -Eqi '(restart|stop|(^|[^a-z])rm([^a-z]|$)|down)' && printf '%s' "$CMD" | grep -Eqi 'odoo19|postgres16|(^|[^a-z])n8n([^a-z]|$)'; then
  REASON="docker restart/stop/rm/down sobre odoo19/postgres16/n8n: corta producción y la sesión SSO."; fi
if [ -z "$REASON" ] && printf '%s' "$CMD" | grep -Eqi '(^|[^a-z])(rsync|scp)([^a-z]|$)' && is_prod; then
  REASON="rsync/scp hacia producción: despliegue sobreescribe ficheros en vivo."; fi
[ -z "$REASON" ] && exit 0
is_safe_scope && exit 0
ask "BLOQUEADO para confirmación: $REASON Regla global: ninguna operación destructiva en este VPS de producción sin BACKUP explícito previo y aprobación. Haz pg_dump/snapshot primero y confirma manualmente si procede."
SH
  chmod +x "$HOOK"
  c_ok "guard-destructive.sh creado (+x)"
fi
# Cablear en settings.json sin pisar otras claves
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
if jq -e --arg h "$HOOK" '.hooks.PreToolUse[]?.hooks[]?|select(.command==$h)' "$SETTINGS" >/dev/null 2>&1; then
  c_skip "hook ya cableado en settings.json"
else
  tmp=$(mktemp)
  jq --arg h "$HOOK" '.hooks.PreToolUse = ((.hooks.PreToolUse // []) + [{"matcher":"Bash","hooks":[{"type":"command","command":$h,"timeout":5}]}])' \
     "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS" && c_ok "hook cableado en settings.json" || c_err "no pude cablear el hook"
fi

# ---------- 5. SMOKE TEST ----------
hdr "SMOKE TEST"
echo "— Plugins instalados:"; claude plugin list 2>/dev/null | grep -E '❯|Status|Scope' | sed 's/^/    /'
echo "— Servidores MCP (estado / health-check):"; claude mcp list 2>/dev/null | sed 's/^/    /'
echo "— CLAUDE.md global:"
[ -f "$GLOBAL_MD" ] && c_ok "presente: $GLOBAL_MD ($(wc -l < "$GLOBAL_MD") líneas)" || c_err "FALTA $GLOBAL_MD"
echo "— Hook de seguridad:"
if [ -x "$HOOK" ] && jq -e --arg h "$HOOK" '.hooks.PreToolUse[]?.hooks[]?|select(.command==$h)' "$SETTINGS" >/dev/null 2>&1; then
  c_ok "activo: ejecutable + cableado PreToolUse(Bash)"
else c_err "hook NO activo (script o cableado ausente)"; fi
echo "— Secretos en claro (debe decir: solo referencias \${...}):"
CFG="$HOME/.claude.json"
if [ -f "$CFG" ]; then
  for k in CONTEXT7_API_KEY GITHUB_PERSONAL_ACCESS_TOKEN; do
    v=$(jq -r --arg k "$k" '[.. | objects | .env? // empty | .[$k]? // empty] | first // ""' "$CFG" 2>/dev/null)
    [ -z "$v" ] && { c_skip "$k: no configurado"; continue; }
    case "$v" in
      *'${'*) c_ok "$k almacenado como referencia: $v" ;;
      *)      c_err "$k almacenado en CLARO en $CFG — REVISAR" ;;
    esac
  done
else c_skip "$CFG no existe aún"; fi

hdr "FIN"
echo "Nota: plugins/MCP nuevos cargan al iniciar la PRÓXIMA sesión de claude."
echo "Todo lo instalado es gratuito/open. Nada de pago se ha tocado."
