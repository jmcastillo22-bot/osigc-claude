---
description: Revisa un addon de Odoo 19 — fail-open en webhooks, secretos hardcodeados, footgun limit=0 y APIs eliminadas en v19.
argument-hint: <ruta>
---
Revisa el addon de Odoo 19 en **$ARGUMENTS**. Reporta por `fichero:línea` con causa raíz y fix concreto.

1. **Fail-open en webhooks/controllers**: el token/firma debe validarse ANTES de actuar y rechazar (no continuar) si falta o no coincide. Marca cualquier `except: pass`, `try` que se traga el error de auth, o ruta `auth='public'` que muta datos sin verificar.
2. **Secretos hardcodeados**: contraseñas, tokens, API keys o URLs con credencial en `.py`/XML/`data`. Deben venir de `ir.config_parameter` o variable de entorno, nunca en el código.
3. **Footgun `limit=0`**: en el ORM de Odoo `search(..., limit=0)` significa SIN límite (devuelve todo), no "ninguno". Revisa paginaciones, `search`/`search_read` y APIs que pasen un `limit` calculado.
4. **APIs eliminadas/cambiadas en v19**: `name_get()` (→ `_compute_display_name`/`display_name`), `@api.one`, `fields.Selection` sin `string`, métodos `_compute` sin `@api.depends`, vistas con atributos retirados.

Si encuentras un patrón, búscalo en TODO el addon, no solo en la primera aparición.
