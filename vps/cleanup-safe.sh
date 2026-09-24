#!/usr/bin/env bash
# cleanup-safe.sh — libera disco en el VPS (HestiaCP + Docker) sin tocar datos vivos.
#
# Por defecto es DRY-RUN: solo muestra qué haría y cuánto ocupa.
#   sudo ./cleanup-safe.sh                       # dry-run
#   sudo ./cleanup-safe.sh --apply --snapshot-ok # ejecuta (exige snapshot hecho)
#   ... --prune-backups                          # además rota /backup/*.tar (ver abajo)
#
# NUNCA hace: docker system prune --volumes, docker volume rm, tocar contenedores
# en marcha, borrar backups sin destino remoto configurado, ni borrar assets de beta
# (solo los lista: los chunks de Vite se referencian desde JS y un fallo rompe la web).
#
# Variables opcionales: KEEP_LOCAL=2 (tars locales por usuario), JOURNAL_MAX=500M.

set -uo pipefail
export PATH="/usr/local/hestia/bin:$PATH"
HCONF=/usr/local/hestia/conf/hestia.conf
KEEP_LOCAL=${KEEP_LOCAL:-2}
JOURNAL_MAX=${JOURNAL_MAX:-500M}
BETA_DOCROOT=${BETA_DOCROOT:-/home/user/web/beta.osigc.cloud/public_html}

APPLY=0; SNAP=0; PRUNE_BK=0
for a in "$@"; do case "$a" in
  --apply) APPLY=1 ;; --snapshot-ok) SNAP=1 ;; --prune-backups) PRUNE_BK=1 ;;
  -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
  *) echo "opción desconocida: $a"; exit 2 ;;
esac; done

[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root (sudo)."; exit 1; }
if [ "$APPLY" -eq 1 ] && [ "$SNAP" -eq 0 ]; then
  echo "--apply exige --snapshot-ok: haz antes el snapshot del VPS en hPanel y un pg_dump fuera del servidor."
  exit 1
fi

hdr()  { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
has()  { command -v "$1" >/dev/null 2>&1; }
# do_ <descripción> <comando...>: en dry-run solo lo imprime.
do_() {
  local d="$1"; shift
  if [ "$APPLY" -eq 1 ]; then printf '  → %s\n' "$d"; "$@" 2>&1 | sed 's/^/    /'
  else printf '  [dry-run] %s: %s\n' "$d" "$*"; fi
}
hconf() { grep -E "^$1=" "$HCONF" 2>/dev/null | head -1 | cut -d"'" -f2; }
BK=$(hconf BACKUP); BK=${BK:-/backup}

BEFORE=$(df --output=avail -B1M / | tail -1)
hdr "Estado inicial"; df -h / /boot "$BK" 2>/dev/null | sed 's/^/  /'
[ "$APPLY" -eq 1 ] && echo "  MODO: APPLY" || echo "  MODO: DRY-RUN (nada se modifica)"

# ---------- 1. apt ----------
hdr "apt: caché y kernels antiguos"
du -sh /var/cache/apt 2>/dev/null | sed 's/^/  caché: /'
echo "  kernel en uso: $(uname -r) (autoremove nunca lo quita)"
apt-get -s autoremove --purge 2>/dev/null | awk '/^Purg|^Remv/ {print "    se quitaría: "$2}'
do_ "apt clean" apt-get clean
do_ "apt autoremove --purge" apt-get -y autoremove --purge

# ---------- 2. journald ----------
hdr "journald (límite $JOURNAL_MAX)"
has journalctl && journalctl --disk-usage 2>/dev/null | sed 's/^/  /'
do_ "vaciar journal hasta $JOURNAL_MAX" journalctl --vacuum-size="$JOURNAL_MAX"
if ! grep -Eq '^SystemMaxUse=' /etc/systemd/journald.conf 2>/dev/null; then
  do_ "fijar SystemMaxUse=$JOURNAL_MAX (persistente)" \
    sh -c "mkdir -p /etc/systemd/journald.conf.d && printf '[Journal]\nSystemMaxUse=%s\n' '$JOURNAL_MAX' > /etc/systemd/journald.conf.d/osigc-size.conf && systemctl restart systemd-journald"
fi

# ---------- 3. Docker (sin volúmenes, sin contenedores) ----------
hdr "Docker: build cache e imágenes sin contenedor"
if has docker; then
  docker system df 2>/dev/null | sed 's/^/  /'
  echo "  imágenes colgantes:"; docker images -f dangling=true --format '    {{.ID}} {{.Size}}' 2>/dev/null
  do_ "docker builder prune" docker builder prune -af
  # image prune -a solo quita imágenes sin NINGÚN contenedor (ni parado) asociado.
  do_ "docker image prune -a" docker image prune -af
  echo "  logs json > 100M (se ven aquí; la rotación va en daemon.json, ver README):"
  find /var/lib/docker/containers -name '*-json.log' -size +100M -exec du -sh {} + 2>/dev/null | sed 's/^/    /'
else warn "docker no instalado"; fi

# ---------- 4. Cachés de herramientas ----------
hdr "Cachés (Playwright retirado, npm)"
for d in /root/.cache/ms-playwright /home/*/.cache/ms-playwright; do
  [ -d "$d" ] || continue
  du -sh "$d" | sed 's/^/  /'
  do_ "borrar $d" rm -r -- "$d"
done
for d in /root/.npm/_cacache /home/*/.npm/_cacache; do
  [ -d "$d" ] || continue
  du -sh "$d" | sed 's/^/  /'
  do_ "borrar caché npm $d" rm -r -- "$d"
done

# ---------- 5. Restos de backups Hestia abortados ----------
hdr "Hestia: $BK/tmp.* de backups abortados"
if pgrep -f 'v-backup' >/dev/null; then
  warn "hay un v-backup en curso: NO se tocan tmp.* (re-ejecuta cuando termine)"
else
  while IFS= read -r d; do
    du -sh "$d" | sed 's/^/  /'
    do_ "borrar $d" rm -r -- "$d"
  done < <(find "$BK" -maxdepth 1 -type d -name 'tmp.*' -mmin +120 2>/dev/null)
fi

# ---------- 6. Rotación de tars locales ----------
hdr "Hestia: tars locales en $BK (conservar $KEEP_LOCAL por usuario)"
REMOTE=0
case ",$(hconf BACKUP_SYSTEM)," in *,sftp,*|*,ftp,*|*,b2,*|*,rclone,*) REMOTE=1 ;; esac
for u in $(v-list-users plain 2>/dev/null | cut -f1); do
  mapfile -t tars < <(ls -1t "$BK/$u".*.tar 2>/dev/null)
  [ "${#tars[@]}" -gt "$KEEP_LOCAL" ] || continue
  for t in "${tars[@]:$KEEP_LOCAL}"; do
    du -sh "$t" | sed 's/^/  sobrante: /'
    if [ "$PRUNE_BK" -eq 1 ] && [ "$REMOTE" -eq 1 ]; then
      do_ "borrar backup $(basename "$t")" v-delete-user-backup "$u" "$(basename "$t")"
    fi
  done
done
[ "$PRUNE_BK" -eq 1 ] && [ "$REMOTE" -eq 0 ] && \
  warn "BACKUP_SYSTEM sin destino remoto: NO se borran tars locales (serían la única copia)"
[ "$PRUNE_BK" -eq 0 ] && echo "  (solo listado; añade --prune-backups para rotarlos)"

# ---------- 7. Assets huérfanos de beta (solo informe) ----------
hdr "beta.osigc.cloud: assets no referenciados (solo informe)"
if [ -d "$BETA_DOCROOT/assets" ]; then
  # Cierre transitivo: html vivos → assets que citan → assets que citan esos (chunks Vite).
  declare -A live=()
  queue=$(find "$BETA_DOCROOT" -name '*.html' -not -path '*/assets/*')
  while [ -n "$queue" ]; do
    next=""
    for n in $(grep -ohE '[A-Za-z0-9_.-]+\.(js|css|woff2?|png|jpe?g|webp|svg|avif)' $queue 2>/dev/null | sort -u); do
      [ -f "$BETA_DOCROOT/assets/$n" ] && [ -z "${live[$n]:-}" ] || continue
      live[$n]=1; next="$next $BETA_DOCROOT/assets/$n"
    done
    queue="$next"
  done
  orphans=0; bytes=0
  for f in "$BETA_DOCROOT"/assets/*; do
    n=$(basename "$f"); [ -n "${live[$n]:-}" ] && continue
    orphans=$((orphans+1)); bytes=$((bytes+$(stat -c %s "$f")))
    [ "$orphans" -le 30 ] && echo "    huérfano: $n"
  done
  echo "  vivos: ${#live[@]} · huérfanos: $orphans ($((bytes/1048576)) MB)"
  echo "  No se borran aquí (máx. 30 listados): bórralos a mano tras verificar la web en pantalla."
else echo "  $BETA_DOCROOT/assets no existe (ajusta BETA_DOCROOT)"; fi

# ---------- Resumen ----------
hdr "Resultado"
df -h / /boot "$BK" 2>/dev/null | sed 's/^/  /'
AFTER=$(df --output=avail -B1M / | tail -1)
[ "$APPLY" -eq 1 ] && echo "  liberado en /: $((AFTER-BEFORE)) MB" || echo "  dry-run: nada modificado."
