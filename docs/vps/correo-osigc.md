# Correo de osigc.com en el VPS (mail.osigc.com)

Migrado de Zoho Mail al VPS el 02/11/2026. Zoho (Mail Lite, vence 15/11/2026) queda sin uso.
Este documento no contiene secretos: solo rutas de los ficheros (600) que los guardan.

## Arquitectura

| Pieza | Detalle |
|---|---|
| Servidor | VPS Hostinger `srv1139644` · IPv4 `148.230.108.106` · Ubuntu 24.04 · HestiaCP (usuario Hestia `user`) |
| MTA | Exim 4.97 (plantilla `/etc/exim4/exim4.conf.template`, generada por `update-exim4.conf`) |
| IMAP | Dovecot 2.3.21 · Maildir en `/home/user/mail/osigc.com/<buzón>/` · separador `/` |
| Antispam | SpamAssassin (`spamd`, `ANTISPAM_SYSTEM=spamassassin`); ClamAV apagado |
| Webmail | Roundcube en `https://webmail.osigc.com` |
| TLS | Let's Encrypt `mail.` + `webmail.osigc.com` (renovación diaria de Hestia 05:34); `mta-sts.osigc.com`; `autoconfig.` + `autodiscover.osigc.com` |
| HELO | `helo_data = mail.osigc.com` fijo en `remote_smtp` y `remote_forwarded_smtp` |
| IPv6 | Exim con `disable_ipv6 = true`: todo sale por IPv4 |
| Límite de envío | info@ 60/h; resto 200/h (`/etc/exim4/domains/osigc.com/limits`) |

Hostnames: `mail.osigc.com` (IMAP/SMTP), `webmail.osigc.com`, `mta-sts.osigc.com`, `autoconfig.osigc.com` (alias `autodiscover.osigc.com`).

## DNS (Squarespace Domains → Google Cloud DNS `ns-cloud-d1..d4.googledomains.com`)

| Registro | Valor |
|---|---|
| `MX @` | `10 mail.osigc.com` |
| `A mail` / `webmail` / `mta-sts` | `148.230.108.106` |
| `TXT @` (SPF) | `v=spf1 ip4:148.230.108.106 include:spf.brevo.com -all` |
| `TXT mail._domainkey` | DKIM RSA 2048 del VPS (`/etc/exim4/domains/osigc.com/dkim.pem`) |
| `TXT _dmarc` | `v=DMARC1; p=none; rua=mailto:dmarc@osigc.com; ruf=mailto:dmarc@osigc.com; fo=1; adkim=s; aspf=s` |
| `TXT _smtp._tls` | `v=TLSRPTv1; rua=mailto:tlsrpt@osigc.com` |
| `TXT _mta-sts` | `v=STSv1; id=20261102` (política en `https://mta-sts.osigc.com/.well-known/mta-sts.txt`, `mode: testing`) |
| PTR (hPanel) | `148.230.108.106 → mail.osigc.com` (guardado 02/11 13:33 CET) |

Pendiente de publicar: `A autoconfig`/`autodiscover`, SRV `_imaps._tcp`, `_submission._tcp`, `_submissions._tcp`, `_autodiscover._tcp`.
Squarespace pide un código por email (jmcastillo1401@gmail.com) en cada sesión de edición: abrir el formulario una sola vez por código.
`include:brevo.com` era incorrecto (autoriza Google y Zendesk); el bueno es `include:spf.brevo.com`.

## Buzones y alias

| Buzón | Alias | Uso |
|---|---|---|
| info@osigc.com | alertas-vps@, admin@, support@, citadirecta@ | buzón principal, formulario web, Odoo, Cal.com, n8n |
| jmcastillo@osigc.com | — | personal |
| dmarc@osigc.com | — | informes DMARC (rua/ruf) |
| tlsrpt@osigc.com | — | informes TLS-RPT |

Contraseñas: `/root/.hestia_mail_osigc.env` (600). Cambio: Hestia → Mail → osigc.com o `v-change-mail-account-password`.
Configuración de clientes: IMAP `mail.osigc.com:993` SSL · SMTP `mail.osigc.com:465` SSL (o 587 STARTTLS) · usuario = dirección completa.
Autoconfig (Thunderbird/Apple): `/mail/config-v1.1.xml`; Autodiscover (Outlook, POST): `/autodiscover/autodiscover.xml` → `autodiscover.php`
en `/home/user/web/autoconfig.osigc.com/public_html/`.

## Quién envía y por dónde

| Emisor | Servidor | Remitente |
|---|---|---|
| Odoo `osigcodoo` (ir_mail_server 2) | mail.osigc.com:465 info@ | info@osigc.com |
| Odoo fetchmail (CommOS) | IMAP mail.osigc.com:993 info@ | — |
| Cal.com (`/opt/calcom/docker-compose.yml` + `.env`) | mail.osigc.com:465 info@ | info@osigc.com |
| n8n credencial «SMTP mail.osigc.com info@osigc.com» | 3 flujos: formulario web, CVH informe, WA Transport | info@osigc.com |
| n8n credencial «IMAP mail.osigc.com info@osigc.com» | flujos inactivos de ingesta | — |
| Brevo (Odoo server 1, n8n «Brevo SMTP») | smtp-relay.brevo.com | info@osigc.es (osigc.com sin autenticar en Brevo) |
| Campañas masivas | NUNCA por mail.osigc.com | — |

## Scripts (`/opt/osigc/scripts/`)

| Script | Función | Programación |
|---|---|---|
| `backup_mail.sh` | tar.zst de `/home/*/mail` + `/home/*/conf/mail`, `rclone copy` a `mailcrypt:<fecha>/`, verifica tamaño, retención 30 días | cron 03:30 UTC |
| `mail_watch.sh --quick` | cola Exim >50, `/home` <15 % libre, puertos 25/993 desde fuera (check-host.net), certificado <14 días | cron cada 15 min |
| `mail_watch.sh --daily` | Spamhaus/Barracuda/SpamCop/SORBS, PTR directo e inverso, backup del día | cron 07:00 UTC (08:00 CET) |
| `import_zoho.py <zip> <buzón> [--dry-run]` | importa exportaciones .eml de Zoho a Maildir (fecha original, \Seen, dedupe por md5) | manual |
| `zoho_cancel_check.sh [--dry-run]` | comprueba que nada depende de Zoho y avisa por email | cron 13–15/11/2026 (ya avisó 02/11) |
| `recordatorio_zoho_20261113.sh` | recordatorio de revisar Zoho | 13/11/2026 07:00 UTC |
| `dmarc_resumen.py [--enviar]` | resumen de informes DMARC y propuesta de p=quarantine | 23/11/2026 07:00 UTC |

## Alertas

`mail_watch.sh` → webhook n8n `POST /webhook/mail-watch-alert` (cabecera `X-Mail-Watch-Token`, token en `/root/.mail_watch.env`)
→ flujo «OSIGC · Alertas correo y VPS (webhook → email + WhatsApp)» (id `osigcMailAlert0001`):
email a alertas-vps@osigc.com y WhatsApp con la plantilla aprobada `osigc_notificacion_servicio` (es_ES, Meta Cloud API,
número +34 624 54 63 70, destino `ALERTA_WA_TO` en `/etc/osigc-credentials/kd_reply_poller.env`).
Antirrepetición 6 h por conjunto de fallos (`/var/lib/osigc-alerts/`). Prueba: `MAIL_WATCH_FORCE=1 /opt/osigc/scripts/mail_watch.sh --quick`.
Log: `/opt/osigc/logs/mail_watch.log`.

## Backups

- Remoto `mailcrypt:` = `rclone crypt` sobre `onedrive:Backups/vps-mail-crypt` (nombres cifrados).
- Claves: `/root/.mail_backup_crypt.env` (600) y copia en `onedrive:Backups/vps-mail-keys/` (autorizado por el owner 02/11).
- Cambiar a Backblaze B2: crear remote crypt sobre `b2:` y exportar `MAIL_BK_DEST=<remote>:` en el cron.
- Copias puntuales: `/root/backups/mail-pre-*.tar.zst`, exportaciones Zoho en `/root/backups/zoho-export-20261102/`.

## Restauración de un buzón

```bash
T=$(mktemp -d /root/backups/restore.XXXX)
rclone lsf mailcrypt:                                  # fechas disponibles
rclone copy mailcrypt:AAAA-MM-DD/ "$T/"
tar --zstd -xf "$T"/mail-AAAA-MM-DD.tar.zst -C "$T"
# revisar y copiar el buzón (ej. info) sin pisar lo nuevo:
rsync -a --ignore-existing "$T/home/user/mail/osigc.com/info/" /home/user/mail/osigc.com/info/
chown -R user:mail /home/user/mail/osigc.com/info
doveadm force-resync -u info@osigc.com '*'
rm -rf "$T"
```
Restauración probada el 02/11/2026 con datos reales: 588 + 1662 mensajes, 0 diferencias.

## Historial

- 02/11/2026: corte de Zoho al VPS (MX ~14:15 CET), importación completa y 2.ª exportación; mail-tester 10/10;
  Gmail SPF/DKIM/DMARC PASS. PTR de Hostinger inconsistente entre nodos rdns (pendiente de ticket).
- Sin MX secundario (decisión del owner 02/11: se confía en los reintentos del remitente, 4–5 días, y en las alertas cada 15 min).
- Pendiente: DMARC a quarantine (~23/11), autenticar osigc.com en Brevo si se usa para masivo.
