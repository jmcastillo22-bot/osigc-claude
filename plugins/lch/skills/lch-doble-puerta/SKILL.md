---
name: lch-doble-puerta
description: Arquitectura de contenido, navegación y copy de lch.osigc.cloud (CVH PRECAST / La Casa de Hormigón). Úsala al escribir o reestructurar páginas, portada, hubs, fichas de /soluciones/, /la-empresa/, menús, CTAs o textos. Fija la portada de doble puerta tal como está aprobada (6225), el árbol real de URLs, la cabecera por perfil (6324 + lch-nav.php), los menús y sus nombres vigentes, la documentación bajo petición, dónde aparece WhatsApp, y el copy prohibido. Cada regla con fecha y origen. NO para copy de OSI Global Consulting.
---

# CVH PRECAST · Doble puerta, estructura y copy

Lee antes `lch-innegociables`. Para formularios y medición, `lch-formulario`.

## Portada (6225, `page_on_front`)

- **Es una pantalla de dos puertas a pantalla completa** (`elementor_canvas`, sin cabecera del tema),
  particulares a la izquierda y profesionales a la derecha, ambas con foto y velo oscuro, marco
  dorado, títulos «Quiero construir mi sueño» / «Construyo para mis clientes», subtítulos de una
  línea, botones «Ver modelos y precios» / «Ver soluciones y obras» (#BBA478), logo del componente
  `lch-logo.php` con la marca como H1, sin WhatsApp ni banner de cookies. Decisión del owner sobre la
  maqueta A del 20/08. *Registro 10/09 (portada v4 → v7); owner 10/09.* La home anterior 124 sigue
  íntegra en `/inicio/` (`lch_prev_page_on_front`).
- La portada no cambia sin OK explícito del owner. *Gate 7 de `lch-innegociables`.*

## Árbol real de URLs (13/09)

```
/                                   6225 portada doble puerta
/particulares/                      6226 hub particulares (modelos, precio por m², proceso, reseñas, descargas, formulario)
/profesionales/                     6227 hub profesionales (soluciones, obras, documentación por formulario, formulario)
/soluciones/                        6238 índice
  /soluciones/construccion/         6240 estructura y muros CVH
  /soluciones/fachadas-prefabricadas/ 6239 fachadas CV+H
  /soluciones/aulas-prefabricadas/  6241 aulas · referencia: Colegio El Dragón (8 fotos reales)
  /soluciones/vivienda-bonanza/     6242 · /soluciones/vivienda-valdemorillo/ 6243 (casos)
/preguntas-frecuentes/              6244 (90 preguntas; un solo FAQPage por página)
/la-empresa/                        3359 capa corporativa (reescrita 13/09) · /quienes-somos/ 1325 = Equipo
/contacto/ 1328 · legales 1588/1589/1590 · /nuestras-casas/ 979 listado legacy de obras
/gracias/<doc>/ y /descarga/        circuito de descarga firmada
Páginas legacy de delegaciones y tipos de casa: se conservan con la plantilla 6231 y FAQ propia
```
*Registro 08/09, 11/09 (bloques C, F, G), 13/09 (bloque E).* No existen `/obras/`, `/empresa/`,
`/particulares/precio/` ni `/soluciones/fachadas/`: no las crees.

## Cabecera y menús (6324 + `lch-nav.php`)

- Cabecera Elementor 6324 con `[lch_nav]`: una sola fila con logo, menú del perfil activo, «La
  empresa» (menú Común: Equipo, Prensa, Delegaciones, Preguntas frecuentes, Blog, Contacto) y CTA
  corto («Pide presupuesto» / «Reunión técnica»). Sin conmutador en la cabecera: el cambio de perfil
  es la píldora flotante de `lch-perfil.php`, guardada en `localStorage` y forzada en
  `/particulares/`, `/profesionales/` y `/soluciones/`. Transparente sobre el hero solo en los dos
  hubs. Tel y WhatsApp solo en la barra móvil. *Owner 11/09 (v2 y v3); owner 13/09 (una fila).*
- Menús WP: Común 40 · Particulares 41 · Profesionales 42 · Legacy 39 (sin ubicación). Nombres
  vigentes en Particulares: **Nuestros modelos**, **Proyectos recientes**, El sistema CVH Precast,
  Precio y plazos, Cerca de ti; en Profesionales: Para tu perfil, Soluciones, El sistema CVH Precast,
  **Proyectos recientes**, Documentación técnica. «Obras realizadas» y «Nuestras casas» ya no se usan
  como título; el hijo «Todas las obras realizadas» se añadió y se retiró el 13/09. Imagen del
  desplegable «El sistema CVH Precast» = adjunto 2452. *Owner 13/09; `textos-e*.php`, `menu-img.php`.*
- No usar la clase `lch-cta` en la cabecera (la llevan los botones de la portada); el CTA de cabecera
  es `lch-hcta`. *Registro 11/09.*
- Migas de Rank Math alineadas con el menú del perfil (un solo BreadcrumbList). *Registro 11/09.*

## Fichas `/soluciones/` (estructura instalada)

Intro con kicker, H1 y foto → Planos y secciones → Características técnicas (tabla, celdas en ámbar)
→ Cómo se ejecuta (4 pasos) → **Proyectos recientes** → Precio orientativo (banda por m², en ámbar) →
Preguntas frecuentes → Recibir dossier técnico (plantilla 6233, por formulario) → ¿Hablamos del
proyecto? (botón al formulario de profesionales + WhatsApp) → `Product` JSON-LD. *Registro 11/09
(bloque C); títulos 13/09.*

## `/la-empresa/` (3359)

Hero → Quiénes somos (tabla de identidad) → Qué fabricamos (4 tarjetas) → Capacidad y plazos →
Proyectos recientes → Reconocimientos y pertenencia → Garantías y cobertura → Contacto directo (NAP
con los tres teléfonos). 12 huecos ámbar (CIF, año, planta, capacidad, plazo tipo, ámbito, garantías,
certificaciones, horario, AECI). *Registro 13/09 (bloque E).*

## WhatsApp y CTAs

- Botón flotante de WhatsApp (`lch-whatsapp.php`) en todas las páginas **excepto la portada**; también
  como CTA de texto (`wa_cta()`) en el cierre de fichas, casos y hubs, incluido el profesional.
  *Registro 10/09 (v3); bloque C 11/09.*
- CTAs con destino concreto: `/particulares/#formulario`, `/profesionales/#formulario`,
  `/profesionales/#documentacion`, fichas, `wa.me/34658068831`. Una descarga = un formulario, nunca
  un enlace abierto a PDF. *Owner 08/09.*

## Copy

Directo y técnico. Un dato verificado vale más que un adjetivo; si no está confirmado, ámbar.

**Prohibido:** «soluciones integrales», «compromiso con la calidad», «vivienda de tus sueños»,
«materiales de máxima calidad», «hogar con el que siempre has soñado», «pide tu asesoramiento
gratuito». **Prohibida la cadencia de IA:** antítesis «no es X, es Y», tricolon rítmico, abuso del
guion largo, aperturas «Imagina…», cierres motivacionales vacíos. *Prompt maestro §6.9, aceptado por
el owner el 12/09.*

Cada dato pendiente se escribe en la página como instrucción «JAVI: …» en ámbar para que el cliente
lo incorpore en su ventana de edición (11–19/09, congelación 18/09 18:00). *Owner 08/09; plan v3.1.*

## Imagen

Fotos reales de la mediateca; las provisionales llevan la nota borrable «📷 Foto provisional… JAVI».
Las imágenes generadas del blog (5985, 5986, 5850, 5395, 2452) solo como provisionales y marcadas.
Sin animaciones de entrada en contenedores. *Registro 10/09 (16 fotos provisionales), 11/09.*
