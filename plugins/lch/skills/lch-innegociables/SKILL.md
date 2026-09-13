---
name: lch-innegociables
description: Innegociables del proyecto CVH PRECAST S.L. / La Casa de Hormigón (lch.osigc.cloud). Úsala ANTES de tocar nada del sitio: CSS, tema hijo, mu-plugin, plantillas de Elementor, redirecciones o contenido. Fija que el entorno de trabajo es staging y no lacasadehormigon.es, prohíbe instalar plugins de WordPress y editar _elementor_data, exige registro de cambios con SHA-256 y define los quality gates bloqueantes. Manda sobre cualquier skill genérica de diseño (impeccable, design-taste-frontend, emil-design-eng): ante conflicto, gana esta. NO para otros proyectos del estudio (para osigc.com usa osigc-design; para beta.osigc.cloud usa osigc-visual-system).
---

# CVH PRECAST · Innegociables

Rediseño de `lch.osigc.cloud` para CVH PRECAST S.L. (marca: La Casa de Hormigón),
fabricante de vivienda y edificación prefabricada de hormigón en Boadilla del Monte,
bajo dirección de OSI Global Consulting. Objetivo contractual: subir la conversión del
canal orgánico C1. **Cada decisión de diseño se justifica por su efecto en el
formulario, no por estética.**

## Regla 1 — El sitio de trabajo es staging

| Entorno | URL | Qué se puede hacer |
|---|---|---|
| Diseño | `https://lch.osigc.cloud` | Todo el trabajo |
| Publicado | `https://lacasadehormigon.es` | **Solo lectura**, como baseline de comparación |

No modifiques producción. Si una tarea te lleva allí, **para y pregunta**. Publicar lo
hace el owner (Jose), nunca tú.

## Regla 2 — Nada de dependencias nuevas

Prohibido sin gate formal del owner: instalar plugins de WordPress, añadir librerías JS
o CSS, o meter servicios externos. Excluidos explícitamente: OneDrive/M365, servicios
externos de PDF, n8n para documentos y cualquier MCP que escriba en WordPress
(Elementor MCP, EMCP, Respira, elementor-mcp-agent).

Descartados, no los propongas: Skiper UI, Vengeance UI, Animaster Lib, taste-skill,
skills de Figma, MCPs de Apple HIG.

**Todo cambio de diseño es CSS/JS en el tema hijo o en el mu-plugin.**

## Regla 3 — No se edita `_elementor_data`

Única excepción: cambios de texto vía WP-CLI `search-replace --dry-run --precise`, con
backup previo y flush del CSS de Elementor después. El `--dry-run` va siempre primero.

Las 10 redirecciones 301 ya están verificadas (single hop, hashes registrados). No las
alteres sin motivo, y si las tocas, re-verifícalas.

## Regla 4 — Registro de cambios

Toda modificación deja: SHA-256 antes y después, ruta del fichero, motivo y método de
verificación. Sin esa entrada, el cambio no está terminado.

## Regla 5 — Esta skill gana a las skills genéricas

`impeccable`, `design-taste-frontend` y `emil-design-eng` son criterio, no autoridad.
Cuando choquen con el sistema de diseño del proyecto, gana el sistema de diseño.

Conflicto conocido y activo: `design-taste-frontend` documenta Liquid Glass y
glassmorphism (`SKILL.md` §118, §356, §1105). **El `DESIGN.md` de este proyecto lo
prohíbe**: sin degradados, sin glassmorphism, sin sombras difusas, sin overlays oscuros
con texto centrado. Si una skill te lo propone, descártalo y dilo en una línea.

Dos avisos sobre `impeccable` verificados en el repo:
- El modo URL usa **Puppeteer** (no Playwright) y hay que instalarlo aparte.
- La skill **exige `PRODUCT.md`**: sin él imprime `NO_PRODUCT_MD` y para. `DESIGN.md`
  solo no arranca el flujo.
- `palette.mjs` **inventa una paleta de marca** si no encuentra tokens committeados.
  Commitea los tokens de CVH antes de invocarla, o te propondrá un color que no es el
  de la marca.

## Regla 6 — Quality gates (bloqueantes)

Un cambio no está terminado si se cumple cualquiera de estas:

1. El detector reporta un P0/P1 nuevo.
2. Falla cualquier test de `tests/form.spec.ts`, en **cualquiera de las dos plantillas**
   de formulario (ver `lch-formulario`).
3. El diff visual muestra cambios fuera del alcance declarado.
4. Hay un placeholder sin marcar en ámbar.
5. Se ha añadido una dependencia, plugin o servicio externo.
6. Falta la entrada del registro de cambios con hashes.
7. Se ha tocado producción.

## Regla 7 — No inventes datos del cliente

Los datos técnicos y comerciales que faltan están en `docs/clientes/lch/pendientes-cliente.md`.
Mientras falten: **placeholder ámbar visible**, nunca una cifra plausible. Aplica a
espesores, plazos, costes, capacidad de producción, alcance del precio y m² de modelos.

## Datos verificados de la marca

- Logo SVG: `/wp-content/uploads/2025/05/logo-cvh.svg` (también favicon).
- Isotipo: `/wp-content/uploads/2025/05/isotipo-NUEVO-LOGO-s-300x300-1.webp`.
- **Acento corporativo: pendiente.** Se extrae del SVG
  (`grep -oE '#[0-9a-fA-F]{6}' logo-cvh.svg | sort -u`) y lo valida el owner antes de usarse.
- Paleta base: fondo `#F5F4F1`, texto `#1A1A1A`, gris hormigón `#8C8C88`.
- Contacto: 916 300 001 · WhatsApp 658 068 831 · comercial@lacasadehormigon.es ·
  C/ Francisco Alonso 2, Centro de Empresas de Boadilla, 28660 Boadilla del Monte.
  El 630 55 90 60 aparece en directorios y está pendiente de unificar.
- Prueba social: miembro de AECI · El Mundo «Mejores ideas 2025» · Premio Liderazgo en
  Construcciones Modulares de Hormigón (La Razón / Proarquitectura).
- Obras con datos: Valdemorillo 334 m² (4 hab, 3 baños) · Encinas-Torrelodones 284/4/3 ·
  Cuevas del Valle 212/2/3 · Bonanza 362/3/3. **Todas residenciales**: no hay obra no
  residencial publicada, así que `/soluciones/aulas` no tiene referencia que enseñar.
- Al publicar: retirar el crédito «Desarrollado por Impacto SEOMarketing» y comprobar
  que ninguna acción de formulario apunta a dominios de terceros.

## Contexto documental

`docs/clientes/lch/` en el repo `osigc-claude`: análisis del prompt maestro, capa
corporativa, doble puerta y pendientes de cliente. Léelos antes de proponer estructura
o contenido.
