#!/bin/bash
# Backup diario cifrado de los buzones de Hestia fuera del VPS.
# Destino parametrizable: MAIL_BK_DEST (por defecto el remote cifrado mailcrypt:, sobre onedrive:).
# Para pasar a Backblaze B2: crear un remote crypt sobre b2: y exportar MAIL_BK_DEST=<remote>:
# Copia a carpeta fechada (rclone copy, nunca sync) y retención MAIL_BK_DAYS días.
set -o pipefail
umask 077

DEST="${MAIL_BK_DEST:-mailcrypt:}"
DAYS="${MAIL_BK_DAYS:-30}"
STAMP="$(date +%Y-%m-%d)"
WORK="/root/backups/mail-tmp"
LOG="/opt/osigc/logs/backup_mail.log"
FILE="$WORK/mail-$STAMP.tar.zst"

log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

mkdir -p "$WORK" "$(dirname "$LOG")"

# Buzones (Maildir) + configuración de dominios de correo de Hestia de todos los usuarios
tar --zstd -cf "$FILE" /home/*/mail /home/*/conf/mail 2>>"$LOG"
rc=$?
if [ $rc -gt 1 ] || ! zstd -tq "$FILE"; then
  log "FAIL: tar rc=$rc o zstd corrupto"; rm -f "$FILE"; exit 2
fi
size=$(stat -c%s "$FILE")

if ! rclone copy "$FILE" "$DEST$STAMP/" --log-file "$LOG" --log-level NOTICE; then
  log "FAIL: rclone copy a $DEST$STAMP/"; exit 3
fi

# Verificación: el fichero remoto existe y tiene el mismo tamaño
rsize=$(rclone size "$DEST$STAMP/" --json 2>/dev/null | grep -o '"bytes":[0-9]*' | cut -d: -f2)
if [ "$rsize" != "$size" ]; then
  log "FAIL: tamaño remoto $rsize != local $size"; exit 4
fi
rm -f "$FILE"

# Retención: solo borra copias fechadas más antiguas que DAYS
rclone delete "$DEST" --min-age "${DAYS}d" --log-file "$LOG" --log-level NOTICE
rclone rmdirs "$DEST" --leave-root --log-file "$LOG" --log-level NOTICE

log "OK: $STAMP $size bytes -> $DEST$STAMP/"
