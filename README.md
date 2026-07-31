# osigc-claude

Marketplace de plugins de Claude Code de **OSI Global Consulting**.

## Plugin: `osigc`

Empaqueta la marca, el white-label y el copy B2B de OSIGC, más los MCP por defecto del equipo.

### Skills
- **osigc-design** — sistema de diseño: tokens navy/azul, Plus Jakarta Sans + Inter, React+Vite+Tailwind, tokens primero (cero hex sueltos).
- **osigc-odoo-whitelabel** — toda la tecnología se presenta como producto OSIGC; cero referencias a Odoo/OpenERP, "open source" o stack interno.
- **osigc-copy-b2b** — copy B2B humano para LinkedIn/email/web; "cartera comercial" (ES), sin cadencia de IA, frases concretas del SME de transporte.
- **osigc-deploy** — despliegue de beta.osigc.cloud: rutas del VPS, `deploy-beta.sh` aditivo (nunca `--clean` salvo publicación), trampas de assets/páginas generadas.
- **osigc-visual-system** — sistema visual de la landing osigc-beta (réplica del template Consultia): tokens remapeados (coal=blanco, paper=negro), azul de acción #2067AC. Distinto de la marca corporativa (osigc-design).

### Slash commands (`plugins/osigc/commands/`)
- **/landing-sector `<sector>`** — genera una landing de captación de sector (transporte/logística SME en España) con el sistema de diseño OSIGC y la oferta Etapa 1 (CRM 149€/mes). Aplica la skill `osigc-design`.
- **/odoo-addon-review `<ruta>`** — revisa un addon de Odoo 19 reportando por `fichero:línea`: fail-open en webhooks/controllers, secretos hardcodeados, footgun `limit=0` y APIs eliminadas en v19.
- **/post-linkedin `<tema>`** — redacta un post de LinkedIn en español, tono humano, sobre optimización de procesos, sin cadencia de IA y con el enlace en el primer comentario. Aplica la skill `osigc-copy-b2b`.

### Hooks (`plugins/osigc/hooks/hooks.json`)
Calidad determinista, adaptativos y por-proyecto:
- **lint-edited.sh** (PostToolUse Edit|Write) — detecta el linter del proyecto del archivo editado (eslint/oxlint/ruff) en runtime. No-bloqueante; sin linter → no hace nada.
- **run-tests.sh** (Stop) — detecta el test runner (`npm test` real / pytest / Odoo); bloquea el fin de turno solo si la suite existe y falla; sin suite → avisa y no bloquea.

### MCP por defecto (`plugins/osigc/.mcp.json`)
`context7`, `playwright`, `github`. **Sin secretos en claro**: las credenciales se
referencian por variable de entorno y deben existir en tu shell:

```bash
export CONTEXT7_API_KEY=...            # context7
export GITHUB_PERSONAL_ACCESS_TOKEN=... # github
# playwright no requiere credencial
```

## Plugin: `design-craft`

Pack de craft de diseño frontend (skills de terceros) para subir el nivel visual de cualquier web del estudio.

### Skills
- **emil-design-eng** — filosofía de pulido de UI de Emil Kowalski: detalles invisibles, animación con criterio, componentes que se sienten bien.
- **impeccable** — diseñar/auditar/pulir/optimizar interfaces con sistema de tokens; jerarquía visual, accesibilidad, motion, micro-interacciones, copy de UX (Apache 2.0).
- **design-taste-frontend** — anti-slop para landings, portfolios y rediseños; lee el brief, infiere la dirección correcta y evita lo que parece plantilla.

> Skills de terceros, incluidas verbatim conservando licencia y atribución originales.

## Instalación

```
/plugin marketplace add /root/osigc-claude   # o el repo remoto de GitHub
/plugin install osigc@osigc-claude
/plugin install design-craft@osigc-claude
```

(o apuntando al repo remoto una vez publicado en GitHub).

## `setup-claude.sh` — bootstrap del entorno

Deja una máquina (VPS o local) con el entorno Claude Code del equipo. **Idempotente**: seguro re-ejecutarlo (comprueba antes de actuar, no pisa lo existente). Qué hace:

1. **Preflight** — exige `claude` y `jq` en PATH; avisa si falta `npx`.
2. **Plugins externos** — añade los marketplaces `claude-plugins-official` y `ui-ux-pro-max-skill` e instala `superpowers`, `frontend-design` y `ui-ux-pro-max` (scope usuario).
3. **MCP base** — `playwright` (sin clave), `context7` y `github`. Las credenciales se guardan como **referencia `${VAR}`, nunca en claro**; si la env var no está, omite ese servidor y avisa.
4. **CLAUDE.md global** — crea `~/.claude/CLAUDE.md` con las reglas universales (idioma/tono, seguridad de infra, secretos, estilo de trabajo) solo si no existe; nunca pisa el tuyo.
5. **Hook de seguridad `PreToolUse`** — instala `guard-destructive.sh` y lo cablea en `settings.json`: pide confirmación ante `rm -rf`, `dropdb`/`DROP DATABASE`, `TRUNCATE`, `docker restart/stop/rm/down` sobre odoo19/postgres16/n8n y `rsync`/`scp` a producción. No bloquea lecturas ni el ámbito `/home/claude`/`beta`.
6. **Smoke test** — resume plugins, MCP, CLAUDE.md, hook y verifica que los secretos estén como referencia y no en claro.

```bash
export CONTEXT7_API_KEY=...             # opcional; sin ella se omite context7
export GITHUB_PERSONAL_ACCESS_TOKEN=... # opcional; sin ella se omite github
./setup-claude.sh
```

Todo lo que instala es gratuito/open. Los plugins y MCP nuevos cargan al iniciar la **próxima** sesión de `claude`.
