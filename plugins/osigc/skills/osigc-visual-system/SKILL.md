---
name: osigc-visual-system
description: Sistema visual de la landing beta.osigc.cloud (osigc-beta), réplica MEDIDA del template Framer Consultia. Úsala antes de tocar tokens, colores, tipografía, tarjetas o estilos de ESA landing. Avisa de las trampas: nombres de token remapeados (coal=blanco, night=crema, paper=negro), azul de acción #2067AC, pesos y letter-spacing negativos, epígrafe en pastilla. OJO: esto NO es el sistema de marca corporativo OSIGC (navy/Plus Jakarta) — para la web pública osigc.com y componentes de marca usa osigc-design, no esta. NO para backend, copy, ni diseño genérico.
---

# Sistema visual de osigc-beta (template Consultia)

Sistema **medido** (Playwright + getComputedStyle a 1440/390 px), no inventado.
Fuente de verdad en el repo de la landing: `SISTEMA-VISUAL-CONSULTIA.md` —
**léelo antes** de tocar un token o discutir una decisión visual.

> Distinto de `osigc-design`: aquélla es la marca corporativa OSIGC (navy, Plus
> Jakarta Sans). Ésta es la réplica del template Consultia para osigc-beta.

## Tokens remapeados (despistan)
- `coal` = **blanco**
- `night` = **crema `#F5F4F0`**
- `paper` = **negro `#1A1A1A`**
- Un logo/texto "blanco" heredado del tema anterior queda invisible: cuidado.

## Color de acción
- Azul del logo `#2067AC` (única desviación deliberada del template, owner 2026-07-23).
- **Azul = acción** (botones, estado activo, marcas de "sí").
  **Negro = superficie** (tarjetas oscuras, sección de contraste, titulares).
- No pintes de azul una superficie ni de negro un botón.

## Tipografía / detalles que delatan una réplica mala
- Titulares a **peso 500** (no 700), letter-spacing **−0,05em**.
- Letter-spacing **negativo hasta en el cuerpo** (−0,03em).
- Epígrafe de sección = **pastilla crema en caja normal**, nunca versalitas espaciadas.
- Tarjetas **sin borde**: fondo + sombra, nada más.

## Infra
- Logo en un solo sitio: `src/components/ui/Logo.jsx` (todas las páginas lo usan).
- Despliegue: skill `osigc-deploy`. Verifica la UI en pantalla, no con grep.
