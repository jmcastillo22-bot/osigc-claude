# Análisis crítico — Prompt Maestro CVH PRECAST v2 (12/09/2026)

Evidencia obtenida en esta sesión. Cada afirmación lleva su comprobación.

## 1. Bloqueantes de ejecución (no son opinión, son hechos de esta sesión)

### B1 — El directorio de trabajo NO es el proyecto que el prompt asume
El prompt dice: «pegar dentro del directorio raíz del proyecto (tema hijo + mu-plugin)
conectado a staging». El directorio real es `/home/user/osigc-claude`, que es el
**marketplace de plugins de Claude Code de OSIGC**:

```
.claude-plugin/marketplace.json
plugins/osigc/{skills,hooks,commands,.mcp.json}
plugins/design-craft/skills/{impeccable,emil-design-eng,design-taste-frontend}
setup-claude.sh
```

No existe `style.css`, ni `functions.php`, ni `lch-descargas.php`, ni `tests/`, ni `docs/`.
**Consecuencia:** la Fase 0 §5.1 (volcado del tema hijo y del mu-plugin) no tiene objeto
aquí. Hay que decidir dónde vive el repo del tema hijo antes de arrancar.

### B2 — No hay acceso a staging desde esta sesión
- `wp` (WP-CLI): no instalado (`which wp` sin salida).
- SSH: `~/.ssh` solo contiene un `known_hosts` vacío. Sin clave, sin config.
- Red: el proxy de agente **deniega por política** el CONNECT a los dos dominios.
  Evidencia en `$HTTPS_PROXY/__agentproxy/status`:
  ```
  connect_rejected  "gateway answered 403 to CONNECT (policy denial...)"  lch.osigc.cloud:443
  connect_rejected  "gateway answered 403 to CONNECT (policy denial...)"  lacasadehormigon.es:443
  ```

**Consecuencia directa sobre la Fase 0:** §5.1, §5.2, §5.3 (WP-CLI), §5.4 (capturas
Playwright, `impeccable detect` sobre URL, Lighthouse, test E2E del formulario) y el
punto §11.1 (extraer el hex del acento del SVG) son **inejecutables desde aquí**.
No es una limitación puntual: es la mitad de la fase.

### B3 — El calendario no cierra
Hoy 12/09/2026. Publicación prevista 17–18/09. Las fases 0→5 del prompt suman
7,5–8,5 días de trabajo declarados por el propio documento, con un gate y un OK tuyo
entre cada una. No caben en 5 días naturales (de los que 13 y 14 son fin de semana).
Hay que recortar alcance de forma explícita, no descubrirlo el día 17.

## 2. Errores factuales del prompt (§4, tabla de herramientas)

| Afirmación del prompt | Realidad verificada | Impacto |
|---|---|---|
| `npx impeccable detect <url> --viewport 390x844` | La CLI **no tiene `--viewport`**. Opciones reales: `--json --gpt --gemini --no-config --no-design-system --help` (`scripts/detector/cli/main.mjs:82-110`) | El comando del prompt no hace lo que se cree. La auditoría móvil declarada no existe tal cual. |
| `npx impeccable` (paquete npm) | No es un paquete npm instalable aquí. Está **vendorizado** en `plugins/design-craft/skills/impeccable/`. Invocación real: `node <ruta>/scripts/detect.mjs <url>` | Un `npx impeccable` fallará o bajará algo distinto. |
| «auditoría determinista (61 reglas)» | **44 reglas** registradas (`scripts/detector/registry/antipatterns.mjs`) | Dato del informe al comité erróneo. |
| Herramienta de navegador = Playwright | El modo URL de impeccable usa **Puppeteer** y lo importa dinámicamente: «puppeteer is required for URL scanning. Install: npm install puppeteer» (`engines/browser/detect-url.mjs:112-122`) | Dependencia de toolchain no contemplada. Chromium ya está en `/opt/pw-browsers`. |
| `DESIGN.md` como entrada del sistema | La skill impeccable exige **`PRODUCT.md`**: si falta, imprime `NO_PRODUCT_MD` y **para** (`SKILL.md`, Setup paso 1) | Si generas solo `DESIGN.md`, la skill se bloquea. Falta `PRODUCT.md` en los entregables. |

El prompt también acierta en algo importante y conviene dejarlo escrito: la skill
impeccable, si detecta proyecto nuevo sin tokens, **genera una paleta propia**
(`scripts/palette.mjs`). Con la paleta de CVH ya definida en §6.3 hay que entrar por
la rama de «identity-preservation», es decir, con los tokens ya committeados antes de
invocarla. Si no, propone color de marca por su cuenta.

## 3. Lo que el prompt hace bien y hay que conservar sin tocar

1. La regla «staging es el sitio de trabajo» y la prohibición de tocar producción.
2. La prohibición de editar `_elementor_data` salvo texto vía WP-CLI con `--dry-run`.
3. El diagnóstico del sitio publicado (§2.5): hero B2C, embudo residencial con mínimo
   220.000 €, seis CTAs al mismo `/contacto/`, copy relleno. Es el núcleo del encargo.
4. Los quality gates §9 y el registro de cambios con SHA-256.
5. La prohibición de inventar cifras técnicas y el placeholder ámbar.
6. «Yo apruebo y publico; tú no.»

## 4. Lo que al prompt le falta y sí condiciona conversión

### F1 — No hay capa corporativa
El documento define paleta, tipografía y fichas de producto. No define **quién es la
empresa** en la web: bloque institucional, datos fiscales de pie, NAP canónico,
JSON-LD de organización, página de empresa, tratamiento de AECI y premios como prueba
social estructurada. Un arquitecto o un técnico municipal valida al proveedor antes de
pedir presupuesto. Sin capa corporativa, el formulario recibe menos envíos por mucho
que se rediseñe.

### F2 — Los 8 campos ocultos del formulario no están especificados
§3 dice «8 campos ocultos y slug de delegación en `origen`», y §7 Fase 4 dice «no tocar
sin test automatizado». No hay lista de los 8. Sin ella no se puede escribir
`tests/form.spec.ts` ni verificar el gate §9.2. Propuesta en el documento corporate.

### F3 — Conflicto NAP sin resolver
§2 registra dos teléfonos (916 300 001 en web, 630 55 90 60 en directorios), un
WhatsApp (658 068 831) y un dominio erróneo publicado por terceros
(`lacasadelhormigon.es`). Tres teléfonos distintos en un negocio B2B es fricción de
contacto y ruido de entidad para Google. Hay que fijar un canónico.

### F4 — Contradicción de alcance: público B2B sin obra B2B publicada
§1 fija el objetivo en arquitectos, promotores, constructoras y técnicos municipales.
§2 admite que **todas las obras publicadas son residenciales** y que no existe obra no
residencial. La ficha `/soluciones/aulas` no tiene ni una obra que enseñar. Se puede
resolver de dos maneras honestas (capacidad de fabricación demostrada + obra
residencial como prueba de proceso, o ficha de aulas puramente técnica sin referencia),
pero hay que decidirlo, no dejarlo al placeholder.

### F5 — El KPI C1 no es medible con lo que hay
§8 define C1 = operaciones orgánicas / presupuestos emitidos. El numerador vive en el
CRM del cliente, no en GA4. La web solo puede aportar el denominador parcial (envíos) y
la atribución de origen. Sin acuerdo de cómo se cruzan ambos, el KPI contractual no se
puede reportar el 24/09.

## 5. Sobre reutilizar la marca OSIGC (aviso)

Este repo contiene `osigc-design` (navy `#0D4D8C`, Plus Jakarta + Inter, React+Vite+
Tailwind) y `osigc-visual-system` (landing beta, azul `#2067AC`). **Nada de eso se
aplica a CVH PRECAST**: es la identidad de la consultora, no la del cliente, y el stack
ni siquiera coincide (WordPress + Elementor). Lo reutilizable es el **método**:
tokens primero sin hex sueltos, sistema visual medido en vez de inventado, reglas de
copy sin cadencia de IA, y disciplina de despliegue aditivo con OK del owner.
