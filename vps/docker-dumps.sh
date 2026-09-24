#!/usr/bin/env bash
# docker-dumps.sh — vuelca lo que vive en Docker (Odoo, n8n, Postgres) a una carpeta
# del usuario Hestia para que el backup nocturno de Hestia (v-backup-users) lo
# incluya y lo suba al destino remoto. Hestia NO conoce los contenedores: sin esto
# Odoo/n8n no tienen backup.
#
# Todo sale CIFRADO con age (clave pública en el servidor, privada fuera). Los
# dumps contienen datos de clientes, y n8n/.env contienen secretos
# (N8N_ENCRYPTION_KEY): nunca viajan en claro dentro del tar de Hestia.
#
# Config: /etc/osigc/docker-dumps.env (root:root 600) — plantilla en docker-dumps.env.example
# Uso:    sudo ./docker-dumps.sh            (cron: 02:30, antes del backup Hestia)
#         sudo ./docker-dumps.sh --check    (valida config y espacio, no vuelca)

set -uo pipefail
CONF=${DUMPS_CONF:-/etc/osigc/docker-dumps.env}
CHECK_ONLY=0; [ "${1:-}" = "--check" ] && CHECK_ONLY=1

log()  { printf '%s %s\n' "$(date '+%F %T')" "$*"; }
die()  { log "ERROR: $*"; ping_hc fail "$*"; exit 1; }
ping_hc() { # <ok|fail> [msg]
  [ -n "${HC_URL:-}" ] || return 0
  local suffix=""; [ "$1" = fail ] && suffix="/fail"
  curl -fsS -m 10 --retry 3 --data-raw "${2:-ok}" "$HC_URL$suffix" >/dev/null 2>&1 || true
}

[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root."; exit 1; }
[ -f "$CONF" ] || { echo "Falta $CONF (copia docker-dumps.env.example)."; exit 1; }
[ "$(stat -c %a "$CONF")" = 600 ] || { echo "$CONF debe tener permisos 600."; exit 1; }
# shellcheck source=/dev/null
. "$CONF"

: "${PG_CONTAINER:?}" "${PG_USER:?}" "${PG_DBS:?}" "${AGE_RECIPIENT:?}" "${OUT_DIR:?}" "${OUT_OWNER:?}"
ODOO_CONTAINER=${ODOO_CONTAINER:-}; ODOO_FILESTORE=${ODOO_FILESTORE:-/var/lib/odoo/filestore}
N8N_CONTAINER=${N8N_CONTAINER:-};   N8N_DATA=${N8N_DATA:-/home/node/.n8n}
COMPOSE_DIRS=${COMPOSE_DIRS:-};     MAX_DISK_PCT=${MAX_DISK_PCT:-85}

command -v age >/dev/null || die "falta 'age' (apt install age)"
command -v docker >/dev/null || die "falta docker"
if command -v zstd >/dev/null; then ZIP="zstd -q -T0 -10"; EXT=zst; else ZIP="gzip -6"; EXT=gz; fi
for c in "$PG_CONTAINER" $ODOO_CONTAINER $N8N_CONTAINER; do
  [ "$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)" = true ] || die "contenedor $c no está corriendo"
done

# Un solo volcado a la vez.
exec 9>/run/osigc-docker-dumps.lock
flock -n 9 || die "ya hay un volcado en curso"

# ---------- espacio: no empujar el disco hacia el BACKUP_DISK_LIMIT de Hestia ----------
PARENT=$(dirname "$OUT_DIR"); mkdir -p "$PARENT"
PCT=$(df --output=pcent "$PARENT" | tail -1 | tr -dc 0-9)
AVAIL=$(df --output=avail -B1 "$PARENT" | tail -1)
EST=0
for db in $PG_DBS; do
  s=$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d postgres -tAc "select pg_database_size('$db')" 2>/dev/null) \
    || die "no puedo leer el tamaño de la BD $db (¿existe? ¿usuario $PG_USER?)"
  EST=$((EST + s))
done
[ -n "$ODOO_CONTAINER" ] && EST=$((EST + $(docker exec "$ODOO_CONTAINER" du -sb "$ODOO_FILESTORE" 2>/dev/null | cut -f1 || echo 0)))
[ -n "$N8N_CONTAINER" ] && EST=$((EST + $(docker exec "$N8N_CONTAINER" du -sb "$N8N_DATA" 2>/dev/null | cut -f1 || echo 0)))
log "uso disco ${PCT}% · libre $((AVAIL/1048576))MB · datos a volcar (sin comprimir) ~$((EST/1048576))MB"
[ "$PCT" -lt "$MAX_DISK_PCT" ] || die "disco al ${PCT}% ≥ MAX_DISK_PCT ${MAX_DISK_PCT}%: libera espacio (cleanup-safe.sh)"
# Margen: el dump comprimido + la copia que hará Hestia en /backup esa misma noche.
[ "$AVAIL" -gt "$EST" ] || die "espacio insuficiente: libre $((AVAIL/1048576))MB < estimado $((EST/1048576))MB"
[ "$CHECK_ONLY" -eq 1 ] && { log "check OK (no se ha volcado nada)"; exit 0; }

# ---------- volcado en staging (mismo FS → swap atómico) ----------
STAGE=$(mktemp -d "$PARENT/.docker-dumps.XXXXXX") || die "no puedo crear staging"
chmod 700 "$STAGE"
trap 'rm -rf -- "$STAGE"' EXIT
enc() { age -r "$AGE_RECIPIENT" -o "$1"; }   # stdin → fichero cifrado
STAMP=$(date +%F_%H%M)

for db in $PG_DBS; do
  plain="$STAGE/$db.dump"
  docker exec "$PG_CONTAINER" pg_dump -U "$PG_USER" -Fc "$db" > "$plain" || die "pg_dump $db falló"
  # Validar ANTES de cifrar: un dump que pg_restore no lista no sirve.
  n=$(docker exec -i "$PG_CONTAINER" pg_restore --list < "$plain" 2>/dev/null | grep -vc '^;') \
    || die "pg_restore --list no puede leer el dump de $db"
  [ "$n" -gt 0 ] || die "dump de $db vacío"
  enc "$STAGE/$db.dump.age" < "$plain" || die "cifrado de $db falló"
  rm -f -- "$plain"
  log "BD $db: $n objetos, $(du -h "$STAGE/$db.dump.age" | cut -f1) cifrado"
done

if [ -n "$ODOO_CONTAINER" ]; then
  docker exec "$ODOO_CONTAINER" tar -C "$ODOO_FILESTORE" -cf - . | $ZIP | enc "$STAGE/odoo-filestore.tar.$EXT.age" \
    || die "tar del filestore de Odoo falló"
  log "filestore Odoo: $(du -h "$STAGE/odoo-filestore.tar.$EXT.age" | cut -f1)"
fi

if [ -n "$N8N_CONTAINER" ]; then
  # Incluye config con encryptionKey: sin ella las credenciales de n8n no se recuperan.
  docker exec "$N8N_CONTAINER" tar -C "$N8N_DATA" -cf - . | $ZIP | enc "$STAGE/n8n-data.tar.$EXT.age" \
    || die "tar de datos n8n falló"
  log "datos n8n: $(du -h "$STAGE/n8n-data.tar.$EXT.age" | cut -f1)"
fi

if [ -n "$COMPOSE_DIRS" ]; then
  # Solo definición del stack (compose, .env, configs); sin datos ni node_modules.
  # shellcheck disable=SC2086
  tar -cf - --exclude='*/node_modules' --exclude='*/data' --exclude='*/filestore' \
      --exclude='*.dump' --exclude='*/.git' $COMPOSE_DIRS 2>/dev/null | $ZIP | enc "$STAGE/stack-config.tar.$EXT.age" \
    || die "tar de COMPOSE_DIRS falló"
  log "config del stack: $(du -h "$STAGE/stack-config.tar.$EXT.age" | cut -f1)"
fi

# Manifiesto en claro (sin secretos): qué hay, hashes y versiones para restaurar.
{
  echo "fecha: $STAMP"; echo "host: $(hostname -f 2>/dev/null || hostname)"
  echo "age_recipient: $AGE_RECIPIENT"
  echo "imágenes:"
  for c in "$PG_CONTAINER" $ODOO_CONTAINER $N8N_CONTAINER; do
    echo "  $c: $(docker inspect -f '{{.Config.Image}} {{.Image}}' "$c")"
  done
  echo "sha256:"; (cd "$STAGE" && sha256sum -- *.age | sed 's/^/  /')
} > "$STAGE/MANIFEST.txt"

# ---------- swap atómico: siempre queda un único juego completo ----------
chown -R "$OUT_OWNER:$OUT_OWNER" "$STAGE"
if [ -d "$OUT_DIR" ]; then mv -- "$OUT_DIR" "$OUT_DIR.old.$$"; fi
mv -- "$STAGE" "$OUT_DIR" || { [ -d "$OUT_DIR.old.$$" ] && mv -- "$OUT_DIR.old.$$" "$OUT_DIR"; die "swap falló"; }
trap - EXIT
rm -rf -- "$OUT_DIR.old.$$"
TOTAL=$(du -sh "$OUT_DIR" | cut -f1)
log "OK → $OUT_DIR ($TOTAL). Lo recoge v-backup-users en el siguiente backup Hestia."
ping_hc ok "docker-dumps OK $STAMP $TOTAL"
