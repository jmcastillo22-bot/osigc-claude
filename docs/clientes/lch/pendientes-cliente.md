# Pendientes de cliente — CVH PRECAST / La Casa de Hormigón
Consolida los 🟠 de `CORPORATE-CVH-PRECAST.md` y `CORPORATE-PARTICULARES.md`.
Actualizado 12/09/2026. Publicación prevista 17–18/09. Comité 24/09.

Regla del proyecto: **ningún dato de esta lista se inventa**. Mientras falte, la web
muestra placeholder ámbar visible (§9 del prompt maestro: un placeholder sin marcar es
gate bloqueante).

## A. Bloqueantes de publicación

### A.1 Identidad y legales
| # | Dato | Para qué | Pedir a |
|---|---|---|---|
| A1 | CIF de CVH PRECAST S.L. | Aviso legal y `vatID` del JSON-LD | Javi |
| A2 | **Decisión de teléfono canónico** | Hoy hay tres números (916 300 001 web, 630 55 90 60 directorios, 658 068 831 WhatsApp). Propuesta: 916 300 001 único público, 658 solo WhatsApp en la rama de particulares, retirar el 630 de directorios | Jose ↔ Javi |
| A3 | Garantía decenal y seguro de RC (compañía y cobertura) | Bloque de garantías de `/empresa/`; lo pregunta el promotor | Javi |

### A.2 Capacidad de fabricación (el argumento B2B que hoy no está en la web)
| # | Dato | Para qué |
|---|---|---|
| A4 | Ubicación y superficie de la planta | `/empresa/` bloque 1 y 3 |
| A5 | Capacidad productiva (m²/mes o viviendas/año) | Diferenciador frente a constructora tradicional |
| A6 | Plazo tipo por m²: semanas de fabricación + semanas de montaje | Es la ventaja del prefabricado y no se dice con números en ninguna página |
| A7 | Ámbito geográfico de montaje | Filtra leads fuera de zona antes del formulario |

### A.3 Datos técnicos de las fichas `/soluciones/`
| # | Dato | Ficha |
|---|---|---|
| A8 | Espesores SATE y sistema de junta | `/soluciones/fachadas/` |
| A9 | Cronología y coste de Bonanza (362 m²) y Valdemorillo (334 m²) | `/soluciones/construccion/` y `/obras/` |
| A10 | Ficha del módulo de aula: dimensiones, acabados, instalaciones | `/soluciones/aulas/` |
| A11 | **Decisión sobre `/soluciones/aulas/` sin obra de referencia** | No hay obra no residencial publicada. Opciones: ficha puramente técnica sin referencia, o usar obra residencial como prueba de proceso de fabricación. Hay que elegir, no dejarlo en placeholder |

### A.4 Rama de particulares
| # | Dato | Para qué |
|---|---|---|
| A12 | Qué incluye y qué NO el umbral de **220.000 €** (proyecto, licencias, cimentación, acometidas, urbanización) | `/particulares/precio/`. Hoy el umbral está escondido en el paso 3 del formulario |
| A13 | Alcance: llave en mano o hasta qué fase | `/particulares/` bloque 1 |
| A14 | ¿Hay financiación? ¿Con qué entidad? | `/particulares/faq/` |
| A15 | Modelos y m² publicables | `/particulares/modelos/` |

### A.5 Imagen
| # | Dato | Para qué |
|---|---|---|
| A16 | Fotos de obra en Media, por proyecto (Valdemorillo, Encinas-Torrelodones, Cuevas del Valle, Bonanza) con rutas | §6.7 del prompt maestro: fotografía real a sangre, sin stock. Sin foto → placeholder ámbar |
| A17 | Fotos de vivienda terminada para la rama de particulares | `/particulares/` |
| A18 | ¿Hay sesión fotográfica prevista antes del 17/09? | Condiciona si se publica con placeholder |
| A19 | Datos de Villalba y Pabellón La Moraleja | Hoy publicadas sin m² ni programa |

## B. Decisiones de Jose (no dependen del cliente)

| # | Decisión | Estado |
|---|---|---|
| B1 | Formulario: dos plantillas con esquema de medición único | **Resuelta 12/09.** Excepción aprobada a §3 del prompt maestro |
| B2 | Dónde vive el repo del tema hijo de `lch.osigc.cloud` | Abierta. Este repo (`osigc-claude`) es el marketplace de plugins, no el tema |
| B3 | Acceso SSH/WP-CLI a staging con usuario no privilegiado | Abierta. Sin él la Fase 0 §5.1–5.4 no se ejecuta |
| B4 | Hex del acento corporativo del SVG | Bloqueada por B3: el proxy deniega el acceso a `lch.osigc.cloud` |
| B5 | Recorte de alcance para llegar al 17–18/09 | Abierta. Las fases 0–5 suman 7,5–8,5 días y quedan 5 naturales, dos de fin de semana |
| B6 | `PRODUCT.md` además de `DESIGN.md` | Abierta. La skill impeccable para con `NO_PRODUCT_MD` si falta |

## C. Decisión contractual pendiente con el cliente

| # | Asunto | Por qué importa |
|---|---|---|
| C1 | ¿C1 se reporta **agregado** o **desglosado por puerta**? | La doble puerta mete leads de particular en el denominador. Si no se segmenta, un buen mes de B2C baja el KPI aunque el canal profesional mejore. Sin acuerdo, el informe del 24/09 es ambiguo |
| C2 | Cómo se cruza el numerador (operaciones orgánicas, vive en el CRM) con la atribución de GA4 | La web sola no puede calcular C1 |

## D. Fuera de la web (anotado, no se ejecuta en este proyecto)

| # | Asunto |
|---|---|
| D1 | Directorios externos publican el dominio erróneo `lacasadelhormigon.es` (con «del»). Corregir en cada ficha |
| D2 | Unificar el teléfono en directorios una vez decidido A2 |
| D3 | Recopilar los perfiles reales para el `sameAs` del JSON-LD, solo los que apunten al dominio correcto |
