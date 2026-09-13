---
name: lch-doble-puerta
description: Arquitectura de contenido y copy de lch.osigc.cloud (CVH PRECAST / La Casa de Hormigón). Úsala al escribir o reestructurar páginas, portada, hubs, fichas de /soluciones/, CTAs o textos del sitio. Fija que la portada es de doble puerta (particulares y profesionales) y que enruta en vez de vender, sin pantalla de selección previa; define el árbol de páginas, la estructura fija de las fichas técnicas, la taxonomía de CTAs y el copy prohibido. NO para copy de OSI Global Consulting (usa osigc-copy-b2b) ni para otros sitios del estudio.
---

# CVH PRECAST · Doble puerta, estructura y copy

Lee antes `lch-innegociables`. Para el formulario, `lch-formulario`.

## La portada es de doble puerta

Dos públicos con criterios de compra distintos: **particulares** que construyen su
vivienda y **profesionales** (arquitectos, promotores, constructoras, técnicos de
ayuntamiento) que compran capacidad técnica demostrada, plazos, fichas y obra ejecutada.

**La home enruta, no vende.** Quien convierte es cada hub.

1. Hero único de fabricante: qué se fabrica, dónde y con qué producción. Sin CTA de venta.
2. Bifurcación inmediata: dos bloques a la misma altura visual, sin jerarquía
   tipográfica entre ellos.
3. Obra ejecutada (común).
4. Capacidad y reconocimientos (común).
5. Cierre con los dos accesos repetidos.

**Prohibida la pantalla de selección previa** («soy particular / soy profesional» antes
de ver nada): cuesta LCP, parte el SEO de la portada y expulsa a quien aún no se ha
identificado con ninguna etiqueta.

Copy de la bifurcación, por intención y no por sujeto. El técnico municipal no se
autodenomina «profesional», pero sí reconoce «trabajo en un proyecto».

## Árbol de páginas

```
/                              Home de enrutado
/particulares/                 Hub B2C  (+ /proceso/ /modelos/ /precio/ /faq/)
/profesionales/                Hub B2B
/soluciones/fachadas/ · /construccion/ · /aulas/
/obras/ · /obras/<slug>        Común a las dos puertas
/empresa/                      Capa corporativa
/contacto/
Legales (aviso legal, privacidad, cookies)
```

Las cuatro obras residenciales con datos trabajan para las dos puertas: al particular le
prueban resultado, al profesional le prueban proceso y control de producción.

## Estructura fija de una ficha `/soluciones/`

Hero con foto de obra → 3 cifras clave → tabla técnica → proceso en 4 pasos → obra de
referencia → CTA «Descargar ficha técnica» (enlace firmado vía mu-plugin) → formulario.

`/soluciones/aulas` no tiene obra de referencia publicada. Decisión pendiente del owner:
ficha puramente técnica sin referencia, u obra residencial como prueba de proceso de
fabricación. No la rellenes por tu cuenta.

## CTAs: uno por intención, nunca seis al mismo destino

| Puerta | Momento | CTA | Destino |
|---|---|---|---|
| Común | Hero home | Ver obra ejecutada | `/obras/` |
| Part. | Tras precio | Solicitar presupuesto de mi vivienda | Form `part-precio` |
| Part. | Lateral | Preguntar por WhatsApp | wa.me/34658068831 |
| Pro. | Tras tabla técnica | Descargar ficha técnica de fachadas | Enlace firmado |
| Pro. | Cierre de ficha | Solicitar presupuesto de aulas | Form `pro-aulas` |
| Pro. | Empresa | Hablar con el equipo técnico | `/contacto/` |

El WhatsApp es canal de particular: en el hub profesional no aparece. Cada CTA de
descarga nombra el documento concreto.

## Copy

Directo y técnico. CTAs concretos con el nombre de lo que se descarga o se pide.

**Prohibido:** «soluciones integrales», «compromiso con la calidad», «vivienda de tus
sueños», «materiales de máxima calidad», «hogar con el que siempre has soñado», «pide tu
asesoramiento gratuito».

**Prohibida la cadencia de IA:** antítesis «no es X, es Y», tricolon rítmico, abuso del
guion largo, aperturas «Imagina…», cierres motivacionales vacíos.

Un dato verificado vale más que un adjetivo: «334 m² en Valdemorillo» funciona donde
«máxima calidad» no dice nada. Si el dato no está confirmado, placeholder ámbar.

## Imagen y movimiento

Fotografía real de obra a sangre. Sin stock, sin ilustraciones. Sin foto → placeholder
ámbar y aviso.

Revelado al scroll ≤ 300 ms, `ease-out`, `IntersectionObserver`, respetando
`prefers-reduced-motion`. Sin parallax, sin bounce. Feedback en `pointerdown`. El motion
no puede bloquear el LCP: objetivo móvil LCP < 2,5 s, CLS < 0,1, INP < 200 ms.
