# osigc-claude

Marketplace de plugins de Claude Code de **OSI Global Consulting**.

## Plugin: `osigc`

Empaqueta la marca, el white-label y el copy B2B de OSIGC, más los MCP por defecto del equipo.

### Skills
- **osigc-design** — sistema de diseño: tokens navy/azul, Plus Jakarta Sans + Inter, React+Vite+Tailwind, tokens primero (cero hex sueltos).
- **osigc-odoo-whitelabel** — toda la tecnología se presenta como producto OSIGC; cero referencias a Odoo/OpenERP, "open source" o stack interno.
- **osigc-copy-b2b** — copy B2B humano para LinkedIn/email/web; "cartera comercial" (ES), sin cadencia de IA, frases concretas del SME de transporte.

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
