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

## Instalación

```
/plugin marketplace add /root/osigc-claude
/plugin install osigc@osigc-claude
```

(o apuntando al repo remoto una vez publicado en GitHub).
