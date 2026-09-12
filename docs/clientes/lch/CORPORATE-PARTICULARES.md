# Doble puerta — rama PARTICULARES (B2C) y arbitraje con PROFESIONALES (B2B)
Para `lch.osigc.cloud`. Estado: **aprobado e incorporado el 12/09/2026** (Jose M. Castillo).
Fecha 12/09/2026. 🟠 = dato pendiente de cliente, no se publica sin confirmar.

> Corrige el encuadre del prompt maestro: §2.1 trata el contenido B2C como defecto a
> eliminar («hero y ~80% orientado a B2C»). Con portada de doble puerta el defecto no es
> que exista la rama B2C, es que **hoy no hay puerta**: hay un único embudo residencial
> por el que el técnico municipal no pasa. Se conservan las dos, separadas y medidas.

---

## 1. La decisión de arquitectura (y el error que hay que evitar)

El fallo típico de la doble puerta es la **pantalla de selección previa**: entrar y tener
que elegir «soy particular / soy profesional» antes de ver nada. Cuesta LCP, parte el
SEO de la home y expulsa al visitante que aún no se ha identificado con ninguna
etiqueta. No se hace.

Estructura propuesta de la home:

1. **Hero único de fabricante** (vale para los dos públicos): qué se fabrica, dónde y
   con qué producción. Sin CTA de venta todavía.
2. **Bifurcación explícita inmediata**, dos bloques a la misma altura visual, sin
   jerarquía tipográfica entre ellos:
   - *Quiero construir mi vivienda* → `/particulares/`
   - *Proyecto profesional o equipamiento* → `/profesionales/`
3. **Obra ejecutada** (común, sirve de prueba a las dos ramas).
4. **Capacidad de fabricación y reconocimientos** (común: AECI, El Mundo 2025, La Razón /
   Proarquitectura).
5. Cierre con los dos accesos repetidos.

La home no convierte: **enruta**. Quien convierte es cada hub. Así la home puede
posicionar por marca y por «hormigón prefabricado» sin competir contra sus propios hubs.

## 2. Árbol completo con las dos ramas

```
/                              Home de enrutado (doble puerta)
/particulares/                 ★ Hub B2C
  /particulares/proceso/       De la primera llamada a la entrega
  /particulares/modelos/       Modelos y m² sobre obra real 🟠
  /particulares/precio/        Qué incluye y qué no; umbral de entrada
  /particulares/faq/           Terreno, licencias, financiación, plazos 🟠
/profesionales/                ★ Hub B2B
  /soluciones/fachadas/
  /soluciones/construccion/
  /soluciones/aulas/
/obras/  ·  /obras/<slug>      Común a las dos puertas
/empresa/                      Capa corporativa (documento anterior)
/contacto/                     Formulario, NAP, mapa
Legales
```

Las obras residenciales con datos (Valdemorillo 334 m², Encinas-Torrelodones 284 m²,
Cuevas del Valle 212 m², Bonanza 362 m²) trabajan para las dos puertas: al particular le
prueban resultado, al profesional le prueban proceso y control de producción. Es el
argumento que tapa parcialmente el hueco de `/soluciones/aulas`, que sigue sin obra
publicada (F4 del análisis).

## 3. Contenido del hub `/particulares/`

El particular decide por certidumbre, no por ficha técnica. Bloques, en orden:

1. **Qué compras.** Vivienda de hormigón prefabricado fabricada en planta 🟠 y montada
   en tu parcela. Llave en mano o hasta qué fase 🟠.
2. **Precio y umbral de entrada.** El formulario actual ya declara un mínimo de
   **220.000 €** por tramos: ese umbral es información útil y se publica como criterio
   de entrada, no como filtro escondido en el paso 3 de un formulario. Qué incluye y qué
   no (proyecto, licencias, cimentación, acometidas, urbanización) 🟠.
3. **Plazo.** Semanas de fabricación + montaje sobre obra real 🟠. Es la ventaja del
   prefabricado y hoy no se dice con números.
4. **Proceso en pasos.** Visita y viabilidad de parcela → anteproyecto → contrato →
   fabricación → montaje → entrega. Con responsable y duración por paso 🟠.
5. **Terreno, licencia y financiación.** Las tres preguntas que hoy están dentro del
   formulario se convierten en **contenido** que resuelve la duda antes de pedir datos.
6. **Obra ejecutada residencial** con m² y programa.
7. **Formulario de particulares** + WhatsApp **658 068 831** como canal visible. El
   WhatsApp es un canal de particular, no de promotora: aquí sí, en el hub B2B no.

## 4. Los campos que se mueven, no se borran

Corrige la §8 del documento corporativo anterior. Nada se elimina del sitio: se reubica
por puerta.

| Pregunta actual | Rama particulares | Rama profesionales |
|---|---|---|
| m² a construir | Sí, campo libre | No (lo sustituye tipo de proyecto) |
| Tramo de presupuesto (mín. 220.000 €) | Sí, pero publicado antes en `/particulares/precio/` | **No** |
| ¿Tienes terreno? | Sí | No |
| ¿Tienes proyecto? | Sí | No (se da por hecho) |
| ¿Tienes licencia? | Sí | No |
| Empresa / rol | No | Sí, obligatorio |
| Tipo de proyecto (fachada, obra completa, equipamiento) | No | Sí |
| Plazo objetivo | Opcional | Sí |

## 5. Formulario: dos plantillas, un esquema de medición

**Restricción dura que hay que asumir antes de diseñar:** Elementor Forms **no tiene
lógica condicional nativa** de campos. Conseguirla exige un plugin, y §3 del prompt
maestro prohíbe instalar plugins. Quedan dos caminos:

- **A — DECIDIDA (owner, 12/09/2026):** dos plantillas globales de formulario, *particulares* y
  *profesionales*, con **idéntico esquema de 8 campos ocultos** y el mismo evento GA4.
  Es CSS/JS cero, no toca `_elementor_data` y cada plantilla se testea por separado.
- **B:** una plantilla única y ocultar/mostrar campos con JS del tema hijo. Más frágil,
  y un campo oculto por JS se sigue enviando: contamina el dato y exige limpieza en el
  handler. No compensa.

**Excepción aprobada a §3 del prompt maestro.** «Formulario unificado global» deja de
ser literal: lo único que se mantiene unificado es el **esquema de medición** (los 8
campos ocultos y el evento GA4), no la plantilla. Aprobado por el owner el 12/09/2026
por imposibilidad técnica de condicionales sin plugin. Consecuencia para la Fase 4:
`tests/form.spec.ts` cubre **las dos plantillas** en los 5 breakpoints, y el gate §9.2
no pasa si falla cualquiera de las dos.

### Esquema de 8 campos ocultos, revisado para doble puerta

| # | Campo | Valor | Cambio respecto a la v1 |
|---|---|---|---|
| 1 | `origen` | `pro-fachadas`, `part-precio`, `part-home`… | Prefijo de puerta en el slug |
| 2 | `puerta` | `pro` \| `part` | **Nuevo.** Ocupa el hueco de `pagina_url` |
| 3 | `tipo_solucion` | fachadas / construccion / aulas / vivienda / general | Añade `vivienda` |
| 4 | `perfil_declarado` | valor del campo visible de rol (solo rama pro) | Igual |
| 5 | `utm_source` | — | Igual |
| 6 | `utm_medium` | — | Igual |
| 7 | `utm_campaign` | — | Igual |
| 8 | `gclid_o_referrer` | primer referrer de sesión | Igual |

`pagina_url` sale del esquema: GA4 ya lo tiene en `page_location` y el KPI §8.3 («% de
leads con origen no residencial») necesita `puerta` como dimensión de primer nivel. Sin
ese campo, el volumen de particulares entierra la señal B2B en el mismo agregado y el
comité del 24/09 no puede leer el dato.

### Medición
Un único evento GA4 `form_submit` con parámetros `puerta`, `origen`, `tipo_solucion`.
Dos eventos distintos obligarían a tocar los triggers de GTM `GTM-W2X6WWKZ` dos veces y
a mantener dos conversiones. Un evento con parámetro se explora sin reconfigurar nada.

## 6. Copy de la bifurcación (dos variantes)

**A — por intención**
> Voy a construir mi casa → Vivienda prefabricada de hormigón, de la parcela a la entrega
> Trabajo en un proyecto → Fachadas, estructura y equipamiento para arquitectura y obra

**B — por sujeto**
> Particulares → Tu vivienda fabricada en planta y montada en tu parcela
> Arquitectos, promotores y administraciones → Fichas técnicas, plazos y capacidad de producción

A funciona mejor: el técnico municipal no se autodenomina «profesional», pero sí
reconoce «trabajo en un proyecto». Ninguna de las dos usa las fórmulas prohibidas en
§6.9 del prompt maestro.

## 7. CTAs por puerta (sustituye la tabla §9 del documento anterior)

| Puerta | Momento | CTA | Destino |
|---|---|---|---|
| Común | Hero home | Ver obra ejecutada | `/obras/` |
| Part. | Hub, tras precio | Solicitar presupuesto de mi vivienda | Form `part-precio` |
| Part. | Hub, lateral | Preguntar por WhatsApp | wa.me/34658068831 |
| Part. | FAQ | Ver si mi parcela es viable | Form `part-faq` |
| Pro. | Ficha, tras tabla técnica | Descargar ficha técnica de fachadas | Enlace firmado (mu-plugin) |
| Pro. | Ficha, cierre | Solicitar presupuesto de aulas | Form `pro-aulas` |
| Pro. | Empresa | Hablar con el equipo técnico | `/contacto/` |

Desaparece «Pide tu asesoramiento gratuito» repetido seis veces al mismo destino.

## 8. Impacto en el KPI contractual C1 (leer antes de aprobar)

C1 = operaciones orgánicas / **todos** los presupuestos emitidos. La doble puerta
aumenta el denominador con leads de particular, que son más numerosos y de ciclo más
corto. Dos consecuencias:

1. Si el numerador no se segmenta por `puerta`, un buen mes de particulares **baja** C1
   aunque el canal B2B mejore. El campo `puerta` no es un lujo de analítica: protege la
   lectura del KPI del contrato.
2. Hay que acordar con el cliente si C1 se reporta agregado o desglosado por puerta.
   Es decisión contractual, no técnica, y sin ella el informe del 24/09 es ambiguo.

## 9. Pendientes de cliente que añade esta rama

Bloqueantes: qué incluye y qué no el umbral de 220.000 € · plazo real de fabricación y
montaje · alcance (llave en mano o hasta qué fase) · si hay financiación y con quién ·
modelos y m² publicables · fotos de vivienda terminada por proyecto.
No bloqueantes: viabilidad de parcela como servicio previo · zona geográfica de montaje ·
FAQ de licencias por municipio.
