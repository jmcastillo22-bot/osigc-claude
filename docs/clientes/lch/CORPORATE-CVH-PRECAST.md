# Capa corporativa — CVH PRECAST S.L. / La Casa de Hormigón
Para `lch.osigc.cloud`. Estado: **aprobado e incorporado el 12/09/2026** (Jose M. Castillo).
Fecha 12/09/2026. Todo dato marcado 🟠 está pendiente de confirmación del cliente y
**no se publica** hasta tenerlo. Nada de lo de aquí inventa cifras técnicas.

---

## 1. Identidad verificada (fuente: §2 del prompt maestro)

| Campo | Valor | Estado |
|---|---|---|
| Razón social | CVH PRECAST S.L. | Verificado |
| Marca comercial | La Casa de Hormigón | Verificado |
| Actividad | Fabricación de vivienda y edificación prefabricada de hormigón | Verificado |
| Domicilio | C/ Francisco Alonso 2, Centro de Empresas de Boadilla, 28660 Boadilla del Monte (Madrid) | Verificado |
| Teléfono web | 916 300 001 | Verificado |
| Teléfono directorios | 630 55 90 60 | Verificado, **en conflicto** |
| WhatsApp | 658 068 831 | Verificado |
| Email comercial | comercial@lacasadehormigon.es | Verificado |
| Dominio canónico | lacasadehormigon.es | Verificado |
| Dominio erróneo en terceros | lacasadelhormigon.es | A corregir fuera de la web |
| CIF | 🟠 | Necesario para aviso legal |
| Año de constitución | 🟠 | Da antigüedad en el bloque corporativo |
| Planta de fabricación (ubicación y superficie) | 🟠 | Es el argumento B2B más fuerte que no está en la web |
| Capacidad productiva (m²/mes o viviendas/año) | 🟠 | Idem |
| Nº de personas en plantilla | 🟠 | Opcional |
| Seguro de responsabilidad civil / garantía decenal | 🟠 | Lo pregunta el promotor |
| Certificaciones de producto o sistema (CE, ISO) | 🟠 | Si no hay, no se menciona |

**Decisión pendiente NAP (§F3 del análisis):** propongo **916 300 001 como único
teléfono público** en web, JSON-LD, pie y directorios, con el 658 068 831 solo como
WhatsApp etiquetado, y retirar el 630 55 90 60 de los directorios. Un negocio con tres
números repartidos pierde llamadas y desdibuja la ficha de empresa en Google.

## 2. Prueba social disponible (y cómo se usa)

| Activo | Uso propuesto | Ubicación |
|---|---|---|
| Miembro de AECI (`AECI_Logo_Negativo_RGB_240702_Web.png`) | Bloque de pertenencia sectorial, logo + una línea de qué implica | Home, pie, fichas |
| El Mundo, «Mejores ideas 2025» | Galardón con medio y año visibles | Home, página de empresa |
| Premio Liderazgo en Construcciones Modulares de Hormigón (La Razón / Proarquitectura) | Idem | Home, página de empresa |
| Obras con datos: Valdemorillo 334 m²/4/3 · Encinas-Torrelodones 284/4/3 · Cuevas del Valle 212/2/3 · Bonanza 362/3/3 | Rejilla de obra ejecutada con m² y programa | Home, `/obras/`, fichas |
| Villalba, Pabellón La Moraleja | Solo si llegan datos 🟠 | — |

Regla: el premio se cita con medio y año. Un sello sin fecha ni entidad lo lee el
técnico como decorado.

## 3. Arquitectura de información propuesta

> **Revisado 12/09 tras confirmarse que la portada es de doble puerta.** El árbol de
> esta sección se sustituye por el de `CORPORATE-PARTICULARES.md` §2, que añade los hubs
> `/particulares/` y `/profesionales/`. Lo de aquí sigue siendo válido en todo lo demás.

Lo que hoy falta no es una página más de producto, es la ruta de validación del
proveedor. Estructura mínima:

```
/                         Home B2B: qué fabricamos, para quién, obra y capacidad
/soluciones/fachadas      Ficha técnica (§7 Fase 3)
/soluciones/construccion  Ficha técnica
/soluciones/aulas         Ficha técnica  ← sin obra publicada (ver F4)
/obras/                   Índice de obra ejecutada con filtro por tipo y m²
/obras/<slug>             Ficha de obra: m², programa, plazo 🟠, sistema empleado
/empresa/                 ★ NUEVA. Capa corporativa (§4)
/contacto/                Formulario unificado + NAP + mapa
/aviso-legal/ /privacidad/ /cookies/   Legales (TCF ya presente)
```

`/empresa/` es la página que hoy no existe y que pide el público objetivo. No es
relleno institucional: es donde el promotor comprueba si puede firmar con esta empresa.

## 4. Contenido de `/empresa/` (bloques, en orden)

1. **Quiénes somos.** Fabricante, no intermediario. Sede en Boadilla del Monte.
   Planta 🟠. Antigüedad 🟠.
2. **Qué fabricamos.** Vivienda y edificación prefabricada de hormigón, con el sistema
   constructivo descrito en términos técnicos 🟠 (espesores, sistema de junta, acabados).
3. **Capacidad y plazos.** Capacidad productiva 🟠 y plazo tipo por m² 🟠. Es el dato
   que más pesa en la decisión del promotor y hoy no está en ninguna página.
4. **Obra ejecutada.** Las cuatro obras con datos, enlazando a `/obras/`.
5. **Reconocimientos y pertenencia.** AECI + los dos premios, con medio y año.
6. **Garantías y cobertura.** Seguro, garantía decenal 🟠, ámbito geográfico 🟠.
7. **Contacto directo.** Teléfono canónico, email, dirección, horario 🟠.

## 5. Boilerplate corporativo (para pie, notas de prensa, JSON-LD y directorios)

**Versión corta (una línea, pie y directorios):**
> CVH PRECAST S.L. fabrica vivienda y edificación prefabricada de hormigón desde
> Boadilla del Monte (Madrid). Marca: La Casa de Hormigón.

**Versión media (≈60 palabras, `/empresa/` y perfiles):**
> CVH PRECAST S.L. es un fabricante de vivienda y edificación prefabricada de hormigón
> con sede en Boadilla del Monte. Trabaja con arquitectos, promotores y constructoras
> en obra residencial y en equipamiento. Es miembro de AECI y ha recibido el
> reconocimiento de El Mundo a las mejores ideas de 2025 y el Premio Liderazgo en
> Construcciones Modulares de Hormigón (La Razón / Proarquitectura).

**Versión larga (≈120 palabras):** queda pendiente de los datos 🟠 de planta, capacidad
y antigüedad. Sin ellos sería relleno, y el prompt maestro prohíbe el relleno.

## 6. JSON-LD de organización (borrador, vía tema hijo, no plugin)

```json
{
  "@context": "https://schema.org",
  "@type": "GeneralContractor",
  "name": "La Casa de Hormigón",
  "legalName": "CVH PRECAST S.L.",
  "url": "https://lacasadehormigon.es/",
  "logo": "https://lacasadehormigon.es/wp-content/uploads/2025/05/logo-cvh.svg",
  "telephone": "+34916300001",
  "email": "comercial@lacasadehormigon.es",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "C/ Francisco Alonso 2, Centro de Empresas de Boadilla",
    "postalCode": "28660",
    "addressLocality": "Boadilla del Monte",
    "addressRegion": "Madrid",
    "addressCountry": "ES"
  },
  "memberOf": { "@type": "Organization", "name": "AECI" },
  "award": [
    "El Mundo — Mejores ideas 2025",
    "Premio Liderazgo en Construcciones Modulares de Hormigón (La Razón / Proarquitectura)"
  ],
  "vatID": "PENDIENTE-CIF",
  "sameAs": []
}
```
Notas: `sameAs` se rellena con los perfiles reales cuando se auditen los directorios
(y solo con los que apunten al dominio correcto). Se inyecta con `wp_head` desde
`functions.php` del tema hijo. **En staging debe ir con `noindex` o con la URL de
staging**, nunca publicando la URL de producción desde `lch.osigc.cloud`.

## 7. Pie corporativo (sustituye al crédito de Impacto SEOMarketing)

Columnas: identidad (isotipo + boilerplate corto) · soluciones · empresa y obra ·
contacto (NAP canónico) · legales. Línea inferior:
`© 2026 CVH PRECAST S.L. — Todos los derechos reservados` + enlaces legales.
Sin crédito de desarrollador, según §7 Fase 5.

## 8. Formulario unificado: esquema propuesto de los 8 campos ocultos (§F2)

> **SUSTITUIDO** por `CORPORATE-PARTICULARES.md` §5: con doble puerta entra el campo
> `puerta` y sale `pagina_url`. Se conserva aquí solo como traza de la v1.

El prompt los exige pero no los define. Propuesta, con el `origen` ya previsto:

| # | Campo | Valor | Para qué |
|---|---|---|---|
| 1 | `origen` | slug de página o delegación | Atribución por página, KPI §8.3 |
| 2 | `pagina_url` | URL completa del envío | Depuración de atribución |
| 3 | `tipo_solucion` | fachadas / construccion / aulas / general | Segmentación del lead |
| 4 | `perfil_declarado` | valor del campo visible de rol | Separar B2B de residencial |
| 5 | `utm_source` | — | Canal |
| 6 | `utm_medium` | — | Canal; permite aislar el **orgánico** del KPI C1 |
| 7 | `utm_campaign` | — | Campaña |
| 8 | `gclid_o_referrer` | primer referrer de sesión | Rescata el orgánico sin UTM |

Sin 5–7 no se puede separar «operaciones orgánicas» del resto, y el KPI C1 del contrato
se queda sin numerador trazable desde la web.

**Campos visibles B2B (§7 Fase 4)** — los campos residenciales **no se eliminan del
sitio, se mueven al hub de particulares** (ver `CORPORATE-PARTICULARES.md` §4): nombre · empresa · rol (arquitecto / promotor /
constructora / administración / particular) · email · teléfono · tipo de proyecto ·
mensaje. Fuera del recorrido profesional: tramos de presupuesto con mínimo 220.000 €,
¿tienes terreno?, ¿tienes licencia? Esas tres preguntas son el filtro residencial que
hoy expulsa al técnico municipal.

## 9. Taxonomía de CTAs (hoy: seis veces la misma a `/contacto/`)

> **SUSTITUIDO** por `CORPORATE-PARTICULARES.md` §7 (CTAs separados por puerta).

| Momento | CTA | Destino |
|---|---|---|
| Hero home | Ver obra ejecutada | `/obras/` |
| Hero home (secundario) | Solicitar presupuesto | `/contacto/` |
| Ficha de solución, tras tabla técnica | Descargar ficha técnica de fachadas | Enlace firmado (mu-plugin) |
| Ficha de solución, cierre | Solicitar presupuesto de aulas | Formulario con `origen` de la ficha |
| Bloque de empresa | Hablar con el equipo técnico | `/contacto/` |

Regla: un CTA de descarga por ficha, con nombre del documento. «Pide tu asesoramiento
gratuito» desaparece del recorrido profesional.

## 10. Copy corporativo — dos variantes de hero (§7 Fase 1)

> Con doble puerta el hero de portada **no vende, enruta**: ver
> `CORPORATE-PARTICULARES.md` §1 y §6. Estas dos variantes pasan a ser el hero del hub
> `/profesionales/`.

**A — capacidad de fabricación**
> H1: Fabricamos vivienda y equipamiento de hormigón prefabricado
> Sub: Producción propia en Madrid para arquitectos, promotores y administraciones.
> Fichas técnicas, plazos cerrados y obra ejecutada que se puede visitar.

**B — plazo y obra**
> H1: Hormigón prefabricado, de proyecto a obra terminada
> Sub: 334 m² en Valdemorillo, 362 m² en Bonanza. Vivienda, fachadas y aulas con
> control de producción en planta.

Ambas evitan lo prohibido en §6.9 y dicen en cinco segundos qué se fabrica y para quién.
La variante B usa solo datos ya verificados en §2 del prompt maestro.

## 11. Datos pendientes de cliente (para `docs/pendientes-cliente.md`)

Bloqueantes de publicación: CIF · teléfono canónico decidido · capacidad y plazo tipo ·
espesores SATE · cronología y coste de Bonanza y Valdemorillo · ficha del módulo de aula ·
garantía decenal · fotos de obra en Media por proyecto · decisión sobre `/soluciones/aulas`
sin obra de referencia (F4).
No bloqueantes: año de constitución · plantilla · certificaciones · horario · `sameAs`.
