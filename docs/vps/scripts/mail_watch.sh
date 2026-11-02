#!/bin/bash
# Vigilancia del correo de osigc.com y del VPS. Mide en el host y, si hay alerta, la entrega
# al flujo n8n «OSIGC · Alertas correo y VPS» (email a alertas-vps@ + WhatsApp con plantilla).
#
# Uso: mail_watch.sh --quick   (cron cada 15 min: cola exim, disco, puertos 25/993 desde fuera, certificado)
#      mail_watch.sh --daily   (cron 08:00 CET: listas negras, PTR directo/inverso, backup de las 03:30)
#      MAIL_WATCH_FORCE=1 mail_watch.sh --quick   (fuerza una alerta de prueba)
# Secretos: token del webhook en /root/.mail_watch.env (600); destino WhatsApp ALERTA_WA_TO en
# /etc/osigc-credentials/kd_reply_poller.env (600). Nada se imprime en el log.
set -u
MODE="${1:---quick}"
IP=148.230.108.106
HOST=mail.osigc.com
LOG=/opt/osigc/logs/mail_watch.log
STAMPS=/var/lib/osigc-alerts
WEBHOOK=http://127.0.0.1:5678/webhook/mail-watch-alert
mkdir -p "$STAMPS" "$(dirname "$LOG")"

_get() { grep -m1 "^$1=" "$2" 2>/dev/null | cut -d= -f2- | tr -d '"'"'"; }
TOKEN=$(_get MAIL_WATCH_TOKEN /root/.mail_watch.env)
WA_TO=$(_get ALERTA_WA_TO /etc/osigc-credentials/kd_reply_poller.env)

fails=()
add() { fails+=("$1"); }

# Comprobación de un puerto TCP desde fuera del VPS (check-host.net, 3 nodos; OK si alguno conecta)
port_from_outside() {
  local port=$1 req id res
  req=$(curl -s -m 15 -H "Accept: application/json" "https://check-host.net/check-tcp?host=$HOST:$port&max_nodes=3") || return 2
  id=$(echo "$req" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("request_id",""))' 2>/dev/null)
  [ -z "$id" ] && return 2
  sleep 12
  res=$(curl -s -m 15 -H "Accept: application/json" "https://check-host.net/check-result/$id") || return 2
  echo "$res" | python3 -c '
import json,sys
d=json.load(sys.stdin); ok=0; seen=0
for node,v in d.items():
    if not v: continue
    seen+=1
    if isinstance(v,list) and v and isinstance(v[0],dict) and "time" in v[0]: ok+=1
sys.exit(0 if ok>0 else (2 if seen==0 else 1))' ; return $?
}

if [ "$MODE" = "--quick" ]; then
  q=$(exim -bpc 2>/dev/null || echo 999)
  [ "$q" -gt 50 ] && add "Cola de Exim con $q mensajes (umbral 50)"
  free_pct=$(df -P /home | awk 'NR==2{gsub("%","",$5); print 100-$5}')
  [ "$free_pct" -lt 15 ] && add "Espacio libre en /home: ${free_pct}% (umbral 15%)"
  for p in 25 993; do
    port_from_outside $p; rc=$?
    [ $rc -eq 1 ] && add "Puerto $p de $HOST no responde desde fuera (check-host.net)"
    [ $rc -eq 2 ] && echo "$(date '+%F %T') aviso: check-host.net sin resultado para el puerto $p" >> "$LOG"
  done
  end=$(echo | openssl s_client -connect $HOST:993 -servername $HOST 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
  if [ -n "$end" ]; then
    days=$(( ( $(date -d "$end" +%s) - $(date +%s) ) / 86400 ))
    [ "$days" -lt 14 ] && add "Certificado de $HOST caduca en $days días"
  else
    add "No se pudo leer el certificado de $HOST:993"
  fi
elif [ "$MODE" = "--daily" ]; then
  rev=$(echo $IP | awk -F. '{print $4"."$3"."$2"."$1}')
  for z in zen.spamhaus.org b.barracudacentral.org bl.spamcop.net dnsbl.sorbs.net; do
    a=$(dig +short "$rev.$z" A | head -1)
    case "$a" in
      "") ;;                                   # no listada
      127.255.255.*) echo "$(date '+%F %T') aviso: $z rechaza la consulta desde este resolver ($a)" >> "$LOG" ;;
      127.*) add "IP $IP listada en $z ($a)" ;;
    esac
  done
  ptr=$(dig +short -x $IP @8.8.8.8 | sed 's/\.$//')
  [ "$ptr" != "$HOST" ] && add "PTR de $IP = '$ptr' (esperado $HOST)"
  fwd=$(dig +short $HOST A @8.8.8.8 | head -1)
  [ "$fwd" != "$IP" ] && add "$HOST resuelve a '$fwd' (esperado $IP)"
  last=$(tail -1 /opt/osigc/logs/backup_mail.log 2>/dev/null)
  if ! echo "$last" | grep -q "^$(date +%F) .* OK: "; then
    add "Backup del correo de hoy no OK: ${last:-sin log}"
  fi
else
  echo "uso: $0 --quick|--daily" >&2; exit 64
fi

[ "${MAIL_WATCH_FORCE:-0}" = 1 ] && add "PRUEBA forzada del sistema de alertas ($MODE)"

if [ ${#fails[@]} -eq 0 ]; then
  echo "$(date '+%F %T') $MODE OK" >> "$LOG"; exit 0
fi

# Antirrepetición: el mismo conjunto de fallos no se reenvía en 6 h (salvo prueba forzada)
key=$(printf '%s\n' "${fails[@]}" | sed 's/[0-9]\+/N/g' | md5sum | cut -c1-12)
stamp="$STAMPS/mail_watch_$key"
if [ "${MAIL_WATCH_FORCE:-0}" != 1 ] && [ -n "$(find "$stamp" -mmin -360 2>/dev/null)" ]; then
  echo "$(date '+%F %T') $MODE ALERTA repetida (silenciada): ${fails[*]}" >> "$LOG"; exit 1
fi

summary=$(printf '%s; ' "${fails[@]}" | sed 's/; $//' | tr -s ' ')
text="Vigilancia de mail.osigc.com / VPS $IP ($MODE, $(date '+%d/%m/%Y %H:%M %Z'))

$(printf -- '- %s\n' "${fails[@]}")

Log: $LOG"
sev=$([ "${MAIL_WATCH_FORCE:-0}" = 1 ] && echo PRUEBA || echo ALERTA)
payload=$(SEV="$sev" TITLE="Correo osigc.com: ${#fails[@]} incidencia(s)" SUMMARY="$summary" TEXT="$text" WA_TO="$WA_TO" \
  python3 -c 'import json,os; print(json.dumps({k.lower(): os.environ[k] for k in ("SEV","TITLE","SUMMARY","TEXT","WA_TO")}).replace("\"sev\"","\"severity\""))')
code=$(printf 'header = "X-Mail-Watch-Token: %s"\n' "$TOKEN" | curl -s -o /dev/null -w '%{http_code}' -m 30 --config - \
  -H 'Content-Type: application/json' -X POST --data "$payload" "$WEBHOOK")
echo "$(date '+%F %T') $MODE ALERTA enviada (webhook $code): ${fails[*]}" >> "$LOG"
[ "$code" = 200 ] && touch "$stamp"
exit 1
