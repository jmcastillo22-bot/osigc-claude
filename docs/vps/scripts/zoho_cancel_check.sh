#!/bin/bash
# Comprueba si el correo de osigc.com ya no depende de Zoho y avisa por email al owner.
# Uso: zoho_cancel_check.sh [--dry-run]   (cron 13-15/11; --dry-run solo imprime)
# Marca manual tras importar la 2ª exportación de Zoho: touch /root/.zoho_second_import_done
set -u
TO="jmcastillo22@gmail.com"
FROM="OSI Global Consulting <info@osigc.com>"
SENT_FLAG=/var/lib/osigc-alerts/zoho_cancel_ok_sent
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1

ok=(); pend=()
check() { if eval "$2" >/dev/null 2>&1; then ok+=("$1"); else pend+=("$1"); fi; }

NS=ns-cloud-d1.googledomains.com
check "MX de osigc.com = solo mail.osigc.com" \
  '[ "$(dig +short osigc.com MX @$NS | awk "{print \$2}" | sort -u)" = "mail.osigc.com." ]'
check "SPF sin Zoho y con -all" \
  'dig +short osigc.com TXT @$NS | grep spf1 | grep -v zohomail | grep -q -- "-all"'
# El PTR no depende de Zoho (afecta a la reputación de salida): se vigila aparte, no bloquea la cancelación.
check "DMARC publicado con rua a dmarc@osigc.com" \
  'dig +short _dmarc.osigc.com TXT @$NS | grep -q "rua=mailto:dmarc@osigc.com"'
check "Backup cifrado del correo OK en las últimas 26 h" \
  '[ -n "$(find /opt/osigc/logs/backup_mail.log -mmin -1560)" ] && tail -1 /opt/osigc/logs/backup_mail.log | grep -q " OK: "'
check "Odoo sin servidores Zoho (SMTP ni IMAP)" \
  '[ "$(docker exec postgres16 psql -U odoo -d osigcodoo -At -c "select (select count(*) from ir_mail_server where active and smtp_host ilike '"'"'%zoho%'"'"') + (select count(*) from fetchmail_server where active and server ilike '"'"'%zoho%'"'"')")" = 0 ]'
check "Cal.com sin SMTP de Zoho" \
  '! grep -qi "zoho" /opt/calcom/docker-compose.yml'
check "n8n sin credenciales Zoho en flujos activos" \
  '[ "$(sudo -u postgres psql -d n8n_prod -At -c "select count(*) from credentials_entity where name ilike '"'"'%zoho%'"'"'")" = 0 ]'
check "2ª exportación de Zoho importada (13/11)" \
  '[ -f /root/.zoho_second_import_done ]'

if [ ${#pend[@]} -eq 0 ]; then
  subj="Correo osigc.com: YA puedes cancelar Zoho"
  intro="Todo el correo de osigc.com funciona en mail.osigc.com y nada depende ya de Zoho. Puedes cancelar la suscripción de Zoho Mail (vence el 15/11) desde mailadmin.zoho.eu > Subscription."
else
  subj="Correo osigc.com: AÚN NO canceles Zoho (${#pend[@]} pendientes)"
  intro="Todavía hay pendientes antes de cancelar Zoho Mail (vence el 15/11):"
fi
body="$intro

Pendiente:
$(for p in "${pend[@]}"; do echo "  - $p"; done)

Comprobado OK:
$(for o in "${ok[@]}"; do echo "  - $o"; done)

Comprobación automática del VPS ($(date '+%d/%m/%Y %H:%M %Z'))."

if [ $DRY = 1 ]; then echo "Subject: $subj"; echo; echo "$body"; exit 0; fi
# El aviso «ya puedes cancelar» se manda una sola vez
if [ ${#pend[@]} -eq 0 ] && [ -f "$SENT_FLAG" ]; then exit 0; fi
printf 'From: %s\nTo: %s\nSubject: %s\nContent-Type: text/plain; charset=UTF-8\n\n%s\n' "$FROM" "$TO" "$subj" "$body" \
  | /usr/sbin/sendmail -f info@osigc.com "$TO"
[ ${#pend[@]} -eq 0 ] && { mkdir -p "$(dirname "$SENT_FLAG")"; date > "$SENT_FLAG"; }
exit 0
