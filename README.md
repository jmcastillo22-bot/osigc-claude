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

Innegociables del proyecto **CVH PRECAST S.L. / La Casa de Hormigón** (`lch.osigc.cloud`).
Guardarraíles de cliente: fija el entorno, las prohibiciones y los gates para que una
sesión nueva no tenga que redescubrirlos.

### Skills
- **lch-innegociables** — staging (`lch.osigc.cloud`) es el único entorno de trabajo;
  producción es solo baseline de lectura. Prohibido instalar plugins de WordPress y
  editar `_elementor_data`. Registro de cambios con SHA-256 y los 7 quality gates
  bloqueantes. **Manda sobre las skills genéricas de diseño.**
- **lch-formulario** — dos plantillas globales (particulares y profesionales) con un
  esquema único de 8 campos ocultos, el campo `puerta` que protege el KPI C1, evento
  GA4 único y gate de tests en 2 plantillas × 5 breakpoints.
- **lch-doble-puerta** — la portada enruta en vez de vender, sin pantalla de selección
  previa. Árbol de páginas, estructura fija de las fichas `/soluciones/`, taxonomía de
  CTAs y copy prohibido.

### Hook (`plugins/lch/hooks/hooks.json`)
- **form-gate.sh** (Stop) — gate §9.2: el formulario no se da por bueno sin test verde.
  **Autoactivable**: mientras no exista `tests/form.spec.ts` en el cwd de la sesión (es
  decir, mientras no exista el repo del tema hijo) no hace nada. Cuando existe, bloquea
  el fin de turno si la suite falla o si solo cubre una de las dos puertas. Si la suite
  existe pero Playwright no está instalado, avisa por stderr de que el gate **no se ha
  evaluado** en vez de dar un verde falso.

> Contexto documental en `docs/clientes/lch/`. Los datos pendientes del cliente viven en
> `docs/clientes/lch/pendientes-cliente.md`: mientras falten, placeholder ámbar, nunca
> una cifra inventada.

## Instalación

```
/plugin marketplace add /root/osigc-claude   # o el repo remoto de GitHub
/plugin install osigc@osigc-claude
/plugin install design-craft@osigc-claude
/plugin install lch@osigc-claude
```

(o apuntando al repo remoto una vez publicado en GitHub).
