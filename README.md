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

## Plugin: `lch`

Decisiones vigentes del proyecto **CVH PRECAST S.L. / La Casa de Hormigón** (staging `lch.osigc.cloud`),
cada una con fecha y origen (registro de cambios, decisión del owner o commit del repo `~/lch-build`).
Una regla sin origen no entra.

### Skills
- **lch-innegociables** — decisiones vigentes: staging único, producción solo lectura, publica el owner;
  pipeline real `gen*.py` → `instalar_*.php` con backup y SHA-256; mu-plugins en lugar de tema hijo;
  cfef como excepción registrada; suite `make test` (repo `~/lch-build`) obligatoria antes de instalar y
  antes de producción; precedencia sobre las skills genéricas de diseño.
- **lch-formulario** — formularios multipaso de 6226/6227 y plantilla global 6231 con el esquema real de
  8 ocultos (`perfil`, `rama`, `origen`, `utm_*`, `page_url`, `referrer`); `perfil` como puerta que
  protege el KPI C1; eventos existentes de `lch-medicion.php` sin crear nuevos; documentación bajo petición.
- **lch-doble-puerta** — portada de doble puerta tal como está aprobada, árbol real de URLs, cabecera
  por perfil y nombres vigentes de los menús, estructura de fichas y de `/la-empresa/`, WhatsApp fuera
  solo de la portada, copy prohibido.

### Hook (`plugins/lch/hooks/hooks.json`)
- **form-gate.sh** (Stop) — gate §9.2: el formulario no se da por bueno sin test verde.
  **Autoactivable**: mientras no exista `tests/form.spec.ts` en el cwd de la sesión (es
  decir, mientras no exista el repo del tema hijo) no hace nada. Cuando existe, bloquea
  el fin de turno si la suite falla o si solo cubre una de las dos puertas. Si la suite
  existe pero Playwright no está instalado, avisa por stderr de que el gate **no se ha
  evaluado** en vez de dar un verde falso.

> La suite real del proyecto es `make test` en `~/lch-build` (19 comprobaciones contra el staging); el hook
> de arriba sigue inerte hasta que exista una suite Playwright. Contraste con la 0.1.0 y pendientes del
> cliente en `WEB/PR2-reconciliado/` (OneDrive del cliente) y `docs/clientes/lch/`.

## Instalación

```
/plugin marketplace add /root/osigc-claude   # o el repo remoto de GitHub
/plugin install osigc@osigc-claude
/plugin install design-craft@osigc-claude
/plugin install lch@osigc-claude
```

(o apuntando al repo remoto una vez publicado en GitHub).
