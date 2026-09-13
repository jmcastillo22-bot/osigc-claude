---
name: lch-formulario
description: Formulario y medición de lch.osigc.cloud (CVH PRECAST / La Casa de Hormigón). Úsala al tocar cualquier formulario del sitio, sus campos, las acciones tras envío, el evento de GA4, GTM o la atribución de leads. Fija las dos plantillas globales (particulares y profesionales) con un esquema único de 8 campos ocultos, el campo puerta que protege el KPI C1, y el gate de tests en 5 breakpoints. Avisa de que Elementor Forms no tiene condicionales nativas y los plugins están prohibidos. NO para formularios de otros proyectos ni para maquetación ajena al formulario.
---

# CVH PRECAST · Formulario y medición

El formulario es el objetivo del rediseño. Todo lo demás existe para llevar tráfico
cualificado hasta aquí. **No lo toques sin test automatizado.**

Lee antes `lch-innegociables`.

## Decisión estructural (owner, 12/09/2026)

**Dos plantillas globales de Elementor, un único esquema de medición.**

Elementor Forms **no tiene lógica condicional nativa** de campos y el proyecto prohíbe
instalar plugins. Por eso hay dos plantillas, `particulares` y `profesionales`, con
idénticos campos ocultos y el mismo evento de GA4.

Es una **excepción aprobada** al «formulario unificado global» del encargo original: lo
que sigue unificado es la medición, no la plantilla. No la revientes «simplificando» a
una sola plantilla con JS: un campo oculto por JS se sigue enviando y contamina el dato.

## Los 8 campos ocultos (esquema único en las dos plantillas)

| # | Campo | Valor |
|---|---|---|
| 1 | `origen` | slug con prefijo de puerta: `pro-fachadas`, `part-precio`, `part-home`… |
| 2 | `puerta` | `pro` \| `part` |
| 3 | `tipo_solucion` | `fachadas` \| `construccion` \| `aulas` \| `vivienda` \| `general` |
| 4 | `perfil_declarado` | valor del campo visible de rol (solo rama profesional) |
| 5 | `utm_source` | — |
| 6 | `utm_medium` | — |
| 7 | `utm_campaign` | — |
| 8 | `gclid_o_referrer` | primer referrer de sesión |

No metas `pagina_url`: GA4 ya lo aporta en `page_location` y el hueco lo necesita
`puerta`.

**Por qué `puerta` no es opcional.** El KPI contractual C1 cuenta operaciones orgánicas
sobre todos los presupuestos emitidos. Los leads de particular son más numerosos y de
ciclo más corto: sin segmentar por puerta, un buen mes de B2C **baja** C1 aunque el
canal profesional mejore. El campo protege la lectura del KPI.

## Campos visibles por puerta

**Profesionales:** nombre · empresa · rol (arquitecto / promotor / constructora /
administración / particular) · email · teléfono · tipo de proyecto · plazo objetivo ·
mensaje.

**Particulares:** nombre · email · teléfono · m² · tramo de presupuesto · ¿tienes
terreno? · ¿tienes proyecto? · ¿tienes licencia? · mensaje.

Las preguntas residenciales (tramo con mínimo 220.000 €, terreno, proyecto, licencia)
**no se borran del sitio: viven solo en la rama de particulares**. En el recorrido
profesional no aparecen, porque son el filtro que hoy expulsa al técnico municipal.

## Medición

Un único evento GA4 `form_submit` con parámetros `puerta`, `origen` y `tipo_solucion`.
No crees dos eventos: obligaría a duplicar triggers en el contenedor `GTM-W2X6WWKZ` y a
mantener dos conversiones, cuando un evento con parámetro se explora sin reconfigurar nada.

## Acciones tras envío

Solo email interno y/o CRM. **Ningún webhook a dominios de terceros**, en particular
nada hacia apralize ni impactoseo. Si encuentras uno, no lo toques: dilo y para.

## Gate de tests (bloqueante)

`tests/form.spec.ts` cubre **las dos plantillas × 5 breakpoints** (360, 390, 768, 1024,
1440). Por cada una verifica: envío correcto, los 8 campos ocultos presentes, valor de
`origen` correcto según la página, `puerta` correcta, evento GA4 recibido y mensaje de
éxito visible. Error inline y estado de envío visibles.

El gate no pasa si falla cualquiera de las dos plantillas. Son el doble de tests de lo
que contemplaba el plan original de la fase.
