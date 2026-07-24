---
name: osigc-deploy
description: Despliegue de beta.osigc.cloud (landing React/Vite/SSR en el VPS). Úsala al desplegar, publicar o subir cambios de osigc-beta al servidor, al tocar rutas del VPS o el script deploy-beta.sh, o ante dudas sobre dónde vive el sitio y cómo se publica. Cubre rutas exactas del servidor (fuente vs docroot), el modo aditivo del deploy y las trampas de assets acumulados y páginas generadas por build. NO para desplegar otros proyectos, para configurar Odoo/ERP en producción, ni para editar el contenido o el diseño del sitio (para el diseño usa osigc-visual-system).
---

# Despliegue de beta.osigc.cloud

Landing React/Vite/SSR de OSI Global Consulting. VPS por SSH:
`ssh root@148.230.108.106` (clave configurada, sin contraseña).

## Rutas (no adivinar)
- Fuente: `/home/user/web/beta.osigc.cloud/app` — **NO** `/var/www/beta` (no existe).
- Docroot: `/home/user/web/beta.osigc.cloud/public_html`.

## Desplegar
- Desde el fuente: `./deploy-beta.sh`. Es **aditivo**.
- NUNCA `--clean` salvo publicación final (borra el docroot).
- El script no toca `osigc.com`, que comparte servidor y resuelve a la misma IP.
- Producción solo tras validar en beta y con OK explícito del owner.

## Trampas
- El deploy aditivo acumula bundles viejos en `public_html/assets/`. Un `grep`
  sobre `assets/*.css` encuentra fuentes ya retiradas; mira el CSS que
  referencia el `index.html` vivo, no todos los `.css` del directorio.
- Las páginas de sector/solución NO se editan en los `.html` del repo: las
  generan `scripts/gen-sectors.mjs` y `gen-soluciones.mjs` (el build las pisa).
- Verifica la UI en pantalla, no con `curl`/`grep`.
