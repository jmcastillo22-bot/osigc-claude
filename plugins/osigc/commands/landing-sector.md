---
description: Landing page de sector con el sistema de diseño OSI Global y la oferta Etapa 1 (CRM 149€/mes).
argument-hint: <sector>
---
Genera una landing page de captación para el sector **$ARGUMENTS** (transporte/logística SME en España).

Diseño — aplica el sistema OSI Global (skill `osigc-design`):
- React + Vite + Tailwind; tokens primero, navy `brand-600`, Plus Jakarta Sans (display) + Inter (texto). Cero hex sueltos en `className`.

Oferta — Etapa 1:
- **CRM · 149 €/mes + setup**. CTA principal a reserva de diagnóstico (`cal.osigc.com/info/agendar-reunion`); CTA secundaria al pago Stripe Etapa 1.

Copy (skills `osigc-copy-b2b` + `osigc-odoo-whitelabel`):
- Español, tono humano, **"cartera comercial" (nunca "pipeline")**, dato/ejemplo real del sector.
- White-label: la tecnología es "plataforma OSIGC"; cero Odoo/open-source/stack interno.

Estructura sugerida: hero (problema del sector $ARGUMENTS) → dolor concreto → solución/CRM → precio Etapa 1 → prueba social → CTA reserva.
