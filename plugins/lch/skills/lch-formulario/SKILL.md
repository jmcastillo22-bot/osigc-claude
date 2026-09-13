---
name: lch-formulario
description: Formulario y medición de lch.osigc.cloud (CVH PRECAST / La Casa de Hormigón). Úsala al tocar cualquier formulario del sitio, sus campos, las acciones tras envío, los eventos GA4, GTM o la atribución de leads. Fija el esquema real de 8 campos ocultos (perfil, rama, origen, utm_source, utm_medium, utm_campaign, page_url, referrer), el campo perfil como puerta que protege el KPI C1, los formularios multipaso de 6226/6227 sobre cfef (excepción registrada), la plantilla global 6231, la documentación bajo petición y la suite de tests. Cada regla con fecha y origen. NO para formularios de otros proyectos.
---

# CVH PRECAST · Formulario y medición

El formulario es el objetivo del rediseño. **No se toca sin pasar `make test` antes y después.**
Lee antes `lch-innegociables`.

## Lo que hay instalado

- **Dos formularios multipaso** en `#formulario` de `/particulares/` (6226) y `/profesionales/`
  (6227), generados por `form_particulares()` / `form_profesionales()` en `gen.py`: una pregunta por
  paso, bloques de opción con letra, avance automático, pasos condicionales que se saltan solos
  (parcela, franquicia), «¿Cómo nos has conocido?» como paso de bloques, resumen y confirmación con
  WhatsApp. Lógica condicional con **Conditional Fields for Elementor Forms (cfef)**, excepción
  registrada. *Registro 10/09 (G2, formulario v2 y v3); owner 10/09.*
- **Plantilla global 6231 «LCH · Contacto unificado»** en las 38 páginas legacy y plantillas de
  delegación, sustituyendo al formulario 1444 que fugaba leads; `origen=delegacion:<slug>` lo pone
  `lch-form.php`. El campo `canal` es obligatorio con valor `formulario_web`. Los formularios de
  plantilla se envían con `post_id` = 6231. *Registro 10/09 (bloque A).*
- `lch-form.php` (mu-plugin): CSS del formulario, avance automático, contador, salto de pasos vacíos,
  resumen, confirmación. *Registro 10/09.*
- Acciones tras envío, **como en producción**: `save-to-database` + `email` a
  comercial@lacasadehormigon.es. En staging `00-disable-mail.php` devuelve OK sin enviar. Sin webhook
  n8n (el owner no lo activa en el prototipo; se resuelve en producción). *Registro 10/09; owner 10/09.*

## Los 8 campos ocultos (esquema único en 6226, 6227 y 6231)

| # | Campo | Valor | Origen |
|---|---|---|---|
| 1 | `perfil` | `particular` \| `profesional` · **es la puerta** | `gen.py:112`, 10/09 |
| 2 | `rama` | subrama elegida en el multipaso (p. ej. `Particular`, `Constructora`, `Franquicia`) | 10/09 |
| 3 | `origen` | página o `delegacion:<slug>` | 10/09 |
| 4 | `utm_source` | — | 10/09 |
| 5 | `utm_medium` | — | 10/09 |
| 6 | `utm_campaign` | — | 10/09 |
| 7 | `page_url` | URL de la página del envío | 10/09 |
| 8 | `referrer` | referrer de sesión | 10/09 |

Además, visible: `tipo_cliente` (rol declarado). El campo `perfil` cumple la función de «puerta»: el
KPI C1 (operaciones orgánicas / presupuestos emitidos) se distorsiona si los leads de particular no se
separan de los profesionales. La decisión contractual «C1 agregado o por puerta» sigue abierta con el
cliente. *Registro de Dependencias 13/09.* No renombrar campos ni añadir `puerta`/`tipo_solucion`:
romperían `lch-form.php`, la plantilla 6231 y la suite.

## Medición (`lch-medicion.php`)

- `dataLayer` + `window.lchTrack(evento, params)`; todos los eventos llevan `perfil`.
- Eventos existentes: `switch_perfil`, `form_submit`, `form_error`, `whatsapp_click` (con
  `ubicacion`), `descarga_catalogo` (con `documento`, `seccion`), `menu_click`, `cta_header_click`.
  **No se crean eventos nuevos**; lo nuevo se mide con parámetros de los existentes. *Registro 10/09 y
  11/09 (v1.2); owner 13/09.*
- GA4: flujo `G-4FH8CBTTF4` (línea base del programa), gtag directo bajo consentimiento Complianz
  (`statistics`), `debug_mode` en staging. Opción `lch_gtm_id` para pasar a un contenedor GTM propio;
  vacía hoy. `GTM-W2X6WWKZ` de producción sigue cargado por el tema. `G-78KLRFQKMV` es osigc.com: no
  usar. *Registro 10/09.*
- Pendiente: verificar los eventos en GA4 DebugView (necesita la clave del Basic Auth o producción).
  *Registro 10/09, pendiente abierto.*

## Documentación bajo petición

No hay descarga abierta de PDF: el profesional la pide por formulario y recibe un **enlace firmado**
(HMAC, 48 h, límite 10/IP/h, PDF estampado) por `lch-descargas.php` + `wp lch-dl alta|lista|enlace`.
Solo existe el documento «prueba» hasta que el cliente suba los dossieres. *Decisión de Javi 08/09;
registro 10–11/09 (bloque B).*

## Gate

`make test` desde `~/lch-build` incluye: envío de prueba por 6231 con los 8 ocultos en Envíos, y el
circuito de descarga 403/200/403/429. Cualquier cambio en formularios, `lch-form.php`,
`lch-medicion.php` o `lch-descargas.php` se instala solo con la suite en verde antes y después, backup
previo y fila en el registro. *13/09.*
