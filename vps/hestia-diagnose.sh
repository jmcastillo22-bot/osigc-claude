#!/usr/bin/env bash
# hestia-diagnose.sh — diagnóstico SOLO LECTURA del VPS (HestiaCP + Docker).
# No escribe, no borra, no reinicia nada. Seguro en producción.
# Uso: sudo ./hestia-diagnose.sh 2>&1 | tee /root/diag-$(date +%F).txt
#
# Cubre las causas raíz de "Hestia no actualiza / no hace backup":
#   disco lleno (BACKUP_DISK_LIMIT), /backup sin rotación, restos tmp.* de
#   backups abortados, clave GPG del repo caducada, SO no soportado, dpkg a
#   medias, nginx editado a mano (lo pisa el upgrade) y cadenas DOCKER en iptables.

set -uo pipefail
export PATH="/usr/local/hestia/bin:$PATH"
HCONF=/usr/local/hestia/conf/hestia.conf

hdr()  { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
ok()   { printf '  \033[32m✔\033[0m %s\n' "$1"; }
run()  { printf '\033[2m$ %s\033[0m\n' "$*"; "$@" 2>&1 | sed 's/^/    /'; }
has()  { command -v "$1" >/dev/null 2>&1; }

[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root (sudo)."; exit 1; }
[ -f "$HCONF" ] || { echo "No encuentro $HCONF — ¿es un servidor Hestia?"; exit 1; }
hconf() { grep -E "^$1=" "$HCONF" | head -1 | cut -d"'" -f2; }

# ---------- 1. Sistema y versión Hestia ----------
hdr "Sistema y versión Hestia"
run v-list-sys-info
run grep -E '^(PRETTY_NAME|VERSION_ID)' /etc/os-release
dpkg -l | awk '/^ii +hestia/ {print "    "$2" "$3}'
run apt-cache policy hestia
run v-list-sys-hestia-updates
run v-list-sys-hestia-autoupdate

# ---------- 2. Salud de apt/dpkg ----------
hdr "apt / dpkg"
AUDIT=$(dpkg --audit 2>&1)
[ -z "$AUDIT" ] && ok "dpkg --audit limpio" || { warn "dpkg con paquetes a medias:"; printf '%s\n' "$AUDIT" | sed 's/^/    /'; }
for k in /usr/share/keyrings/hestia-keyring.gpg /etc/apt/trusted.gpg.d/hestia*.gpg; do
  [ -f "$k" ] || continue
  echo "  clave: $k"
  gpg --show-keys --with-colons "$k" 2>/dev/null | awk -F: '/^pub/ {
    exp = ($7 == "" ? "sin caducidad" : strftime("%F", $7));
    print "    pub " $5 " caduca: " exp }'
done
ls -l --time-style=+%F /var/lib/apt/lists/*hestia* 2>/dev/null | awk '{print "    lista apt: "$6" "$7}' \
  || warn "no hay listas apt de Hestia descargadas"
apt list --upgradable 2>/dev/null | grep -c upgradable | xargs -I{} echo "    paquetes actualizables: {}"

# ---------- 3. Disco ----------
hdr "Disco"
run df -h / /boot /backup
run df -i /
LIMIT=$(hconf BACKUP_DISK_LIMIT); LIMIT=${LIMIT:-95}
BK=$(hconf BACKUP); BK=${BK:-/backup}
USE=$(df --output=pcent "$BK" 2>/dev/null | tail -1 | tr -dc 0-9)
if [ -n "$USE" ] && [ "$USE" -ge "$LIMIT" ]; then
  warn "uso de $BK = ${USE}% ≥ BACKUP_DISK_LIMIT ${LIMIT}% → Hestia ABORTA los backups"
else ok "uso de $BK = ${USE:-?}% (límite backups ${LIMIT}%)"; fi
echo "  Top directorios en / (mismo FS):"
du -xh --max-depth=2 / 2>/dev/null | sort -h | tail -20 | sed 's/^/    /'
echo "  Ficheros > 500M:"
find / -xdev -type f -size +500M -printf '    %s\t%p\n' 2>/dev/null | sort -n | tail -15 \
  | awk -F'\t' '{printf "    %6.1fG  %s\n", $1/1073741824, $2}'
du -sh /home/*/tmp /var/log/nginx/domains /var/log/apache2/domains /usr/local/hestia/log \
       /var/cache/apt /root/.cache/* /root/.npm /home/*/.cache/* 2>/dev/null | sort -h | sed 's/^/    /'
has journalctl && run journalctl --disk-usage

# ---------- 4. Backups Hestia ----------
hdr "Backups Hestia"
grep -E '^(BACKUP|UPGRADE|DISK_QUOTA)' "$HCONF" | sed 's/^/    /'
for t in sftp ftp b2 rclone; do
  out=$(v-list-backup-host "$t" 2>/dev/null | grep -v '^$')
  [ -n "$out" ] && { echo "  host remoto ($t):"; printf '%s\n' "$out" | sed 's/^/    /'; }
done
case ",$(hconf BACKUP_SYSTEM)," in
  *,sftp,*|*,ftp,*|*,b2,*|*,rclone,*) ok "hay destino remoto configurado" ;;
  *) warn "BACKUP_SYSTEM='$(hconf BACKUP_SYSTEM)': SIN copia fuera del servidor" ;;
esac
echo "  Contenido de $BK:"
ls -la --time-style=+%F "$BK" 2>/dev/null | tail -n +2 | sed 's/^/    /'
du -sh "$BK"/* 2>/dev/null | sort -h | sed 's/^/    /'
TMPS=$(find "$BK" -maxdepth 1 -name 'tmp.*' -type d 2>/dev/null)
[ -n "$TMPS" ] && { warn "restos de backups abortados:"; du -sh $TMPS | sed 's/^/    /'; }
pgrep -af 'v-backup' >/dev/null && warn "hay un v-backup EN CURSO ahora mismo"
for u in $(v-list-users plain 2>/dev/null | cut -f1); do
  echo "  usuario $u — backups registrados:"
  v-list-user-backups "$u" 2>/dev/null | tail -6 | sed 's/^/    /'
  pk=$(v-list-user "$u" shell 2>/dev/null | awk '/^PACKAGE:/ {print $2}')
  [ -n "$pk" ] && v-list-user-package "$pk" shell 2>/dev/null | grep -E '^BACKUPS' | sed "s/^/    paquete $pk: /"
done
for f in /usr/local/hestia/log/backup.log /usr/local/hestia/log/system.log; do
  [ -f "$f" ] && { echo "  últimas líneas de $f:"; tail -25 "$f" | sed 's/^/    /'; }
done
echo "  Cron del admin (backup/update):"
v-list-cron-jobs admin plain 2>/dev/null | grep -E 'backup|update' | sed 's/^/    /'

# ---------- 5. Docker (fuera de Hestia: sus backups NO lo cubren) ----------
hdr "Docker"
if has docker; then
  run docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
  run docker system df
  echo "  Logs json de contenedores (sin rotación = crecen sin límite):"
  du -sh /var/lib/docker/containers/*/*-json.log 2>/dev/null | sort -h | tail -5 | sed 's/^/    /'
  [ -f /etc/docker/daemon.json ] && run cat /etc/docker/daemon.json || warn "sin /etc/docker/daemon.json (sin rotación de logs)"
  echo "  Volúmenes montados (lo que hay que respaldar aparte):"
  docker ps -q | xargs -r docker inspect --format '{{.Name}}{{range .Mounts}} | {{.Source}} -> {{.Destination}}{{end}}' | sed 's/^/    /'
else warn "docker no instalado"; fi

# ---------- 6. Riesgos de upgrade Hestia ----------
hdr "Riesgos de upgrade: nginx editado a mano"
# Un proxy_pass a un puerto local en un fichero NO *_custom lo regenera Hestia
# en upgrade / v-rebuild-web-domains → Odoo/n8n se caen si no viene de plantilla.
for f in /home/*/conf/web/*/nginx*.conf /home/*/conf/web/*/*.nginx*.conf; do
  [ -f "$f" ] || continue
  case "$f" in *_custom*) continue ;; esac
  if grep -Eq 'proxy_pass +https?://(127\.0\.0\.1|localhost|172\.[0-9.]+):(8069|8072|5678|[0-9]{4,5})' "$f"; then
    dom=$(basename "$(dirname "$f")"); usr=$(echo "$f" | cut -d/ -f3)
    tpl=$(v-list-web-domain "$usr" "$dom" shell 2>/dev/null | awk '/^PROXY:/ {print $2}')
    warn "$f → proxy a puerto local (plantilla proxy: ${tpl:-?}). Verifica que la plantilla lo genera."
  fi
done
ls /usr/local/hestia/data/templates/web/nginx/ 2>/dev/null | sed 's/^/    plantilla: /'
find /home/*/conf/web -name '*_custom*' 2>/dev/null | sed 's/^/    include custom: /'

hdr "Firewall Hestia ↔ Docker"
run v-list-sys-firewall
N=$(iptables -S 2>/dev/null | grep -c DOCKER)
echo "    reglas iptables DOCKER: $N (0 con contenedores corriendo = red de Docker rota)"

hdr "FIN (nada se ha modificado)"
