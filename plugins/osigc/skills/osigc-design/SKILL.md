---
name: osigc-design
description: Diseño y frontend de marca OSIGC / osigc.com. Úsala al crear o editar la web pública, landing, home, footer, CTAs, secciones de precios/etapas, un Hero o componentes/páginas React+Vite+Tailwind del sitio — construir, restilizar o «que quede de marca». También al mencionar el azul/navy corporativo, gradientes, hover/focus o la tipografía de marca (Plus Jakarta Sans / Inter, o arreglar Arial). Vale en cualquier repo del sitio (p. ej. osi-website). Impone tokens de Tailwind, nunca hex sueltos. Ante la duda sobre la apariencia web de OSIGC, úsala. NO para backend, SQL, tests, migraciones de build, exportar logos/imágenes, slides ni diseño genérico ajeno a OSIGC.
---

# OSIGC · Sistema de diseño

Garantiza que cualquier interfaz de la marca se vea OSI Global: navy/azul coherente,
tipografía de marca y, sobre todo, **tokens en vez de valores sueltos**. El objetivo
de fondo es que el diseño escale sin deriva: un color o una fuente se cambian en un
sitio y se propagan, en lugar de quedar dispersos en cientos de clases.

## Stack
React 19 + Vite + TypeScript + Tailwind 3 (utilidades en JSX, sin CSS Modules).
`framer-motion` para animación, `lucide-react` para iconos.

## Regla 1 — Tokens primero (lo más importante)
`tailwind.config.js` es la **única fuente de verdad** de color. Define escalas
`brand` (navy/azul, base `brand-600 #0D4D8C`), `accent` y `dark`.

- Usa clases de token: `bg-brand-600`, `text-brand-900`, `border-brand-200`.
- **Prohibido el hex suelto en `className`**: nada de `bg-[#0D4D8C]`, `text-[#212121]`,
  `border-[#DCE5F2]`. Un arbitrary value rompe la trazabilidad y se desincroniza del resto.
- ¿Falta un color? **Añade el token** a `tailwind.config.js` (con su escala) y úsalo.
  No metas el hex en la clase “solo por esta vez”.
- Antes de escribir un color, mira qué tokens existen en `tailwind.config.js`. No
  copies aquí la tabla de hex: cámbiala/léela en el config para que no haya dos verdades.

## Regla 2 — Tipografía de marca
Objetivo: **Plus Jakarta Sans** para display/títulos e **Inter** para texto. Ambas
se cargan ya en `index.html`. Aplica vía tokens de fuente en `tailwind.config.js`
(`fontFamily.display` / `fontFamily.sans`) y clases `font-display` / `font-sans`.

> Deuda conocida: hoy `fontFamily` apunta a `Arial`. Si la tocas, alinéala a
> Plus Jakarta (display) / Inter (texto); no propagues Arial como si fuera la convención.

## Regla 3 — Color de marca y foco
Navy base `brand-600 #0D4D8C`. El foco accesible (`:focus-visible`) usa el navy de marca.
Mantén contraste AA sobre el fondo claro `#F7F9FC` (que también debería vivir como token de superficie).

## Cómo aplicar en una tarea
1. Lee `tailwind.config.js` para conocer los tokens vigentes.
2. Construye con clases de token; si falta un color/fuente, primero amplía el config.
3. Si tocas un fichero con hex sueltos preexistentes (`pages/*.tsx`), tokenízalos de paso.
4. Anima con los keyframes ya definidos (`fade-in`, `slide-up`, `float`) antes de inventar nuevos.
