---
name: lch-innegociables
description: Decisiones vigentes del proyecto CVH PRECAST S.L. / La Casa de Hormigón (staging lch.osigc.cloud). Úsala ANTES de tocar nada del sitio: páginas generadas, mu-plugins, plantillas de Elementor, menús, redirecciones o contenido. Cada regla lleva fecha y origen (fila del registro de cambios, decisión del owner o commit del repo ~/lch-build); una regla sin origen no existe. Fija el entorno (staging), el pipeline real de trabajo (gen.py → instalar_*.php con backup y hash, mu-plugins), la suite de tests obligatoria y la precedencia sobre las skills genéricas de diseño. NO para otros proyectos del estudio (osigc.com → osigc-design; beta.osigc.cloud → osigc-visual-system).
---

# CVH PRECAST · Decisiones vigentes

Prototipo de la nueva web de CVH PRECAST S.L. (marca La Casa de Hormigón, Boadilla del Monte) en el
staging `lch.osigc.cloud`, dirigido por OSI Global Consulting. Objetivo contractual: conversión del
canal orgánico (indicador C1). **Cada decisión de diseño se justifica por su efecto en el formulario.**

Formato de cada regla: **qué** · *origen (fecha)*. Origen = fila de `WEB/REGISTRO-CAMBIOS-lch.md`,
decisión del owner (Jose M. Castillo) con fecha, o commit/tag del repo `~/lch-build`. Si una regla
nueva no puede citar origen, no se añade.

## 1 · Entorno

- **Staging `lch.osigc.cloud` es el único sitio de trabajo.** Producción `lacasadehormigon.es` es solo
  lectura, como baseline. Publica el owner, nunca la sesión. *Plan v3.1 §12–13 aceptado por el
  cliente el 08/09; registro «Entorno de pruebas… Producción no se toca».*
- El MVP se construye EN lch, sin refresh desde producción. Contraseñas actuales de lch no se cambian.
  *Owner, 08/09.*
- `blog_public=0` y Basic Auth en nginx. Las capturas sin la clave del Basic Auth se hacen por el
  backend Apache `148.230.108.106:8443` (túnel + `WEB/herramientas/lch-proxy.py`). *Registro 10/09.*
- Producción se toca solo en las dos ventanas del plan (mantenimiento y publicación), con backup,
  restore point y rollback a los 90 min; sus fechas son salida obligatoria de la validación del 20/09
  y aún no existen. *Plan v3.1 §13; registro de Dependencias 13/09.*

## 2 · Cómo se trabaja (pipeline real)

- **Las páginas nuevas se generan por programa**: `gen*.py` (helpers en `lchlib.py`) escribe el
  `_elementor_data` en JSON y `instalar_*.php` lo instala por `wp eval-file` como usuario `user`,
  idempotente por slug o por ID, con hash SHA-256 antes/después y el JSON previo guardado en una opción
  `lch_*_prev`. Después, `wp elementor flush_css`. No se edita `_elementor_data` a mano ni en el editor
  de Elementor desde una sesión. *Registro 08/09 (gen.py → instalar.php), 11/09 (bloque C:
  gen_c.py/instalar_c.php), 13/09 (gen_e.py/instalar_e.php); tag `staging-2026-09-13-bloqueE`.*
- **Cambios de texto en páginas ya instaladas**: script PHP por `wp eval-file` con reemplazo textual,
  comprobación de JSON válido y hash antes/después (`textos-e*.php`). Nunca `search-replace` global.
  *Registro 13/09.*
- **No hay tema hijo propio.** Todo el comportamiento vive en mu-plugins: `lch-perfil`, `lch-form`,
  `lch-medicion`, `lch-nav`, `lch-logo`, `lch-descargas`, `lch-schema`, `lch-whatsapp`,
  `00-disable-mail`. Todos son byte-idénticos a `~/lch-build/build/` (comprobado `cmp` el 13/09).
  *Commit `d3cac52`.*
- **Backup antes de cada bloque** con `backup-*.sh` (BD, mu-plugins, .htaccess, wp-config, privado,
  uploads, `_elementor_data` de las páginas clave, SHA256SUMS) en `/root/backups/lch-full-<fecha>`.
  *Registro 10/09 (`lch-full-20260910-155402`), 11/09 (`-20260911-100356`), 13/09 (`-20260913-180154`).*
- **Suite de tests obligatoria**: `make test` desde `~/lch-build` (ver §5). Se pasa antes de cada
  instalación en staging y antes de cada ventana de producción. *Commit de `tests/` del 13/09.*
- El código al servidor va por `scp` y se valida (`php -l`, `node --check`, `json.load`); nunca
  heredoc con comillas por ssh. *Incidente 10/09 (memoria del owner).*
- Repo `~/lch-build` (fuera de OneDrive): `main` = estado del staging; tags `staging-<fecha>[-bloque]`;
  documentos de la sesión cloud en la rama `docs/pr2`. Copias de trabajo en
  `WEB/herramientas/` del OneDrive del cliente. *Owner, 13/09; commits `071bca0`, `d3cac52`, `8fff34e`.*

## 3 · Dependencias y plugins

- **No se instalan plugins de WordPress, librerías ni servicios externos sin decisión del owner con
  fecha.** *Plan v3.1 (fuera de alcance) y owner 08/09.*
- **Excepción registrada: Conditional Fields for Elementor Forms (cfef)**, ya instalado y usado por
  los formularios multipaso de 6226/6227 (`cfef_logic`/`cfef_repeater_data`). Se mantiene con
  actualización probada en staging antes de producción, como Elementor y su ecosistema (política de
  la propuesta de mantenimiento). *Registro 10/09 (G2); owner 10/09; anotado en la propuesta de
  mantenimiento de plugins el 13/09.*
- Excluidos: n8n para documentos (el owner no quiere activar n8n en el prototipo), OneDrive/M365,
  servicios externos de PDF y cualquier MCP que escriba en WordPress. *Owner, 10/09.*
- Fluent Forms descartado (su multipaso es de pago); Elementor Pro en staging no actualiza (licencia)
  y queda en 3.32.x. *Registro 10/09.*

## 4 · Datos, copy y registro

- **Ningún dato del cliente se inventa.** Lo que falte va como hueco ámbar visible «JAVI: …» (clase
  `lch-ambar`), que el cliente rellena en su ventana de edición. *Owner 08/09; 64 huecos el 13/09.*
- Pendientes del cliente: `docs/clientes/lch/pendientes-cliente.md` y su versión reconciliada en
  `WEB/PR2-reconciliado/`; el registro vivo de Dependencias en Notion manda sobre ambos. *13/09.*
- **Registro de cambios**: cada bloque deja fila en `WEB/REGISTRO-CAMBIOS-lch.md` (qué, dónde,
  reversión), hashes en `WEB/EVIDENCIA-hashes-<fecha>.txt`, capturas `captura-<fecha>-*.png` y fila en
  el «Registro vivo · Cambios web» de Notion. Sin eso el cambio no está terminado. *Desde el 10/09.*
- **Ningún formulario envía a terceros.** El webhook a `testv2.apralize.com` y los emails a
  `desarrollo@impactoseo.com` se cortaron en staging el 10/09 (bloque A); hay que repetirlo en
  producción en la ventana de publicación. El crédito «Desarrollado por Impacto SEOMarketing» del pie
  304 se retiró el 13/09. *Registro 10/09 y 13/09.*
- Marca: acento `#BBA478`, Site BG `#F4F0EC`, Soft BG `#ECE5DF`, Marcellus / Tenor Sans (kit 65 de
  Elementor); logo = componente `lch-logo.php` (isotipo SVG + texto con webfonts), favicon 6362,
  KG 6363, OG 6364. *Registro 11/09 (logotipo definitivo).*
- Identidad: CVH PRECAST S.L. · C/ Francisco Alonso 2, Centro de Empresas de Boadilla, 28660 Boadilla
  del Monte · comercial@lacasadehormigon.es · **tres teléfonos intencionados**: oficina 916 300 001
  (principal, `telephone` del JSON-LD), contacto 630 55 90 60, WhatsApp 658 068 831. El perfil de
  Google muestra el 630: lo corrige el cliente. *Owner, 13/09.*
- Prueba social: AECI, El Mundo «Mejores ideas 2025», Premio Liderazgo en Construcciones Modulares
  (La Razón / Proarquitectura). Obras con ficha: Bonanza 362 m², Valdemorillo 334 m² (visitable),
  Colegio El Dragón (aulas, 8 fotos reales). *Registro 11/09 (bloque C).*

## 5 · Gates bloqueantes

Un cambio no está terminado si:
1. `make test` no da 19/19 (o el número vigente) antes y después de instalar. *13/09.*
2. Falta backup previo, o falta la fila del registro con hashes. *10/09.*
3. Hay un dato inventado o un hueco sin ámbar. *08/09.*
4. Se ha añadido un plugin, librería o servicio sin decisión del owner con fecha. *08/09.*
5. Se ha tocado producción. *Plan v3.1.*
6. Un formulario apunta a un dominio de terceros. *10/09.*
7. La cabecera 6324, la portada 6225, el formulario o los menús cambian sin OK explícito del owner
   (son los componentes que el cliente no debe tocar y que el owner revisa uno a uno). *Guía de
   revisión del 10/09; órdenes del owner 11/09 y 13/09.*

## 6 · Esta skill gana a las skills genéricas

`impeccable`, `design-taste-frontend` y `emil-design-eng` son criterio, no autoridad. Conflicto
conocido: `design-taste-frontend` propone Liquid Glass y glassmorphism; el sistema de CVH no lleva
degradados, glassmorphism ni sombras difusas (kit 65; velo oscuro plano sobre foto en heros y
portada, aprobado el 10/09). Avisos verificados sobre `impeccable`: modo URL con Puppeteer, exige
`PRODUCT.md`, y `palette.mjs` inventa paleta si no hay tokens committeados; los tokens de CVH ya
están en `lchlib.py`/kit 65, así que no se invoca sin ellos. *Verificado en el repo el 12/09.*

Animaciones: las `_animation` de Elementor en contenedores dejan `.elementor-invisible` en Elementor
4.2; se retiraron y `animar()` las limpia. No reintroducir revelados al scroll sin probarlo en el
staging. *Registro 11/09.*
