# VPS (HestiaCP + Docker): limpieza, updates y backups

Servidor `148.230.108.106`: **HestiaCP** gestiona webs (beta.osigc.cloud, osigc.com),
su nginx/PHP, mail, DNS y el backup nocturno `v-backup-users`. **Fuera de Hestia**,
Docker ejecuta `odoo19`, `postgres16` y `n8n` (`/opt/*`): Hestia **no** los respalda.

| Script | Qué hace | Riesgo |
|---|---|---|
| `hestia-diagnose.sh` | Diagnóstico solo lectura: disco, backups, versión, clave GPG, nginx editado a mano, iptables DOCKER | Ninguno |
| `cleanup-safe.sh` | Libera disco. **Dry-run por defecto**; `--apply --snapshot-ok` ejecuta | Bajo |
| `docker-dumps.sh` | Vuelca Postgres + filestore Odoo + datos n8n + config del stack, **cifrado con age**, a `/home/user/private/docker-dumps` para que lo recoja Hestia | Bajo (solo lectura sobre contenedores) |

Copia al VPS: `scp -r vps root@148.230.108.106:/root/osigc-vps` (o `git pull` del repo).

## 0. Diagnóstico

```bash
sudo /root/osigc-vps/hestia-diagnose.sh 2>&1 | tee /root/diag-$(date +%F).txt
```

| Señal en el informe | Causa raíz | Fase |
|---|---|---|
| `uso ≥ BACKUP_DISK_LIMIT` | Hestia aborta backups por disco lleno | 2 |
| `restos de backups abortados` (`/backup/tmp.*`) | Backups a medias que ocupan espacio | 2 |
| `SIN copia fuera del servidor` | `BACKUP_SYSTEM=local`: el backup muere con el VPS | 4 |
| clave `caduca:` en el pasado / `EXPKEYSIG` | `apt` rechaza el repo Hestia → no actualiza | 3 |
| `dpkg con paquetes a medias` | Upgrade anterior interrumpido (típico: disco lleno) | 3 |
| `proxy a puerto local` en fichero no `_custom` | El upgrade regenera el vhost → **se cae Odoo/n8n** | 3 (antes de actualizar) |
| `reglas iptables DOCKER: 0` | Firewall Hestia borró las cadenas de Docker | 3 |

## 1. Red de seguridad (obligatoria antes de borrar o actualizar)

1. **Snapshot del VPS** en hPanel (Hostinger). Único rollback que cubre Hestia + Docker.
2. Dump de BDs **fuera del servidor**, en streaming (no necesita disco local):
   ```bash
   docker exec postgres16 pg_dump -U odoo -Fc <bd> | ssh <destino> "cat > bestia-pre/<bd>.dump"
   ```
3. Copia de configuración: `tar czf - /usr/local/hestia/conf /home/user/conf /etc/nginx | ssh <destino> "cat > bestia-pre/conf.tgz"`.

## 2. Limpieza

```bash
sudo ./cleanup-safe.sh                                  # revisar dry-run
sudo ./cleanup-safe.sh --apply --snapshot-ok            # apt, journald, docker build/images, cachés, /backup/tmp.*
sudo ./cleanup-safe.sh --apply --snapshot-ok --prune-backups   # + rota /backup/*.tar (solo si hay destino remoto)
```

Rotación de logs de Docker (reinicia dockerd → **corta Odoo/n8n**; hacerlo en la ventana de la fase 3):
```json
// /etc/docker/daemon.json
{ "log-driver": "json-file", "log-opts": { "max-size": "50m", "max-file": "3" } }
```
Solo aplica a contenedores **recreados** (`docker compose up -d --force-recreate <svc>`).

Además en Hestia: bajar `BACKUPS` del paquete a 1–2 (`v-change-package` o panel) y
excluir pesos muertos con `v-update-user-backup-exclusions` (`node_modules`,
`beta.osigc.cloud/app/dist`, cachés).

**Validación:** `df -h /` < 70 % (lejos del 95 % en el que Hestia aborta backups).

## 3. Updates de Hestia (ventana de mantenimiento)

1. **Antes**: todo vhost con `proxy_pass` a Odoo/n8n hecho a mano → pasarlo a plantilla
   propia (sobrevive a upgrades) y aplicarla:
   ```bash
   cp /usr/local/hestia/data/templates/web/nginx/default.tpl  .../nginx/osigc-odoo.tpl
   cp /usr/local/hestia/data/templates/web/nginx/default.stpl .../nginx/osigc-odoo.stpl
   # editar proxy_pass / websockets / timeouts en ambos
   v-change-web-domain-proxy-tpl user erp.osigc.<tld> osigc-odoo
   ```
   Alternativa mínima: mover las directivas a `/home/user/conf/web/<dominio>/nginx.ssl.conf_custom`.
2. `dpkg --configure -a` si el diagnóstico lo marcó.
3. Clave del repo caducada: reinstalarla **según la doc oficial de Hestia** (no de memoria), `apt update` sin errores.
4. Solo Hestia: `apt install --only-upgrade hestia hestia-nginx hestia-php`.
5. Validar:
   ```bash
   v-list-sys-services
   for d in erp.osigc... crm.osigc... beta.osigc.cloud osigc.com; do curl -sS -o /dev/null -w "%{http_code} $d\n" https://$d; done
   iptables -S | grep -c DOCKER     # 0 → systemctl restart docker (corta prod; pide OK)
   ```
6. Actualizaciones automáticas: `unattended-upgrades` solo seguridad para el SO; auto-update
   de Hestia (`v-add-cron-hestia-autoupdate apt`) **solo cuando** el paso 1 esté hecho.

Impactos: reiniciar odoo19 corta sesiones SSO; n8n pierde ejecuciones en curso;
osigc.com comparte servidor. Postgres: solo minor 16.x (a 17 = dump/restore, proyecto aparte).

## 4. Backups: un único circuito

```
02:30  docker-dumps.sh   → /home/user/private/docker-dumps/*.age  (+ MANIFEST.txt)
03:00  v-backup-users    → /backup/user.<fecha>.tar  → destino remoto (sftp/b2/rclone)
```

Instalación:
```bash
apt install -y age zstd
# en tu Mac (NO en el VPS): age-keygen -o ~/.osigc/bestia-backup.key  → copia la línea "public key"
install -d -m 700 /etc/osigc
install -m 600 docker-dumps.env.example /etc/osigc/docker-dumps.env   # editar: BDs, AGE_RECIPIENT...
install -m 700 docker-dumps.sh /usr/local/sbin/osigc-docker-dumps
osigc-docker-dumps --check                  # valida config y espacio sin volcar
osigc-docker-dumps                          # primer volcado real
echo '30 2 * * * root /usr/local/sbin/osigc-docker-dumps >> /var/log/osigc-docker-dumps.log 2>&1' > /etc/cron.d/osigc-docker-dumps

# Destino remoto de Hestia (credenciales solo en el comando, nunca en el repo):
v-add-backup-host sftp <host> <usuario> '<password>' /bestia 22     # o b2 / rclone
grep BACKUP_SYSTEM /usr/local/hestia/conf/hestia.conf               # debe incluir el remoto
v-backup-user user                                                   # prueba manual
tar -tf /backup/user.*.tar | grep -m3 docker-dumps                   # confirmar que lo incluye
```

Si `tar -tf` no muestra `docker-dumps`, la carpeta no entra en el backup del usuario:
cambia `OUT_DIR` a una ruta que sí entre o sube los `.age` con `rclone copy` al final del script.

Espacio: cada noche el volcado vive dos veces en local (carpeta + tar en `/backup`).
El script aborta si el disco supera `MAX_DISK_PCT` (85 %) o no cabe el estimado.

Monitorización: `HC_URL` de healthchecks.io en el `.env` (avisa si no hay ping en 26 h)
y `tail /usr/local/hestia/log/backup.log`.

## 5. Restauración (probar una vez al mes)

```bash
# en una máquina con la clave privada
age -d -i ~/.osigc/bestia-backup.key odoo.dump.age > odoo.dump
docker run -d --name pg-restore-test -e POSTGRES_PASSWORD=x postgres:16
docker exec -i pg-restore-test createdb -U postgres restore_test
docker exec -i pg-restore-test pg_restore -U postgres -d restore_test --no-owner < odoo.dump
docker exec pg-restore-test psql -U postgres -d restore_test -c "select count(*) from res_partner; select count(*) from account_move;"
age -d -i ~/.osigc/bestia-backup.key odoo-filestore.tar.zst.age | zstd -d | tar -t | head
docker rm -f pg-restore-test
```
Web/mail/DNS de Hestia: `v-restore-user` sobre un usuario de prueba.

## KPIs

| KPI | Objetivo |
|---|---|
| `/` usado | < 70 % |
| Tars locales en `/backup` | ≤ 2 por usuario |
| Último backup remoto correcto | < 26 h |
| `v-list-sys-hestia-updates` | al día |
| Dominios respondiendo tras upgrade | 100 % |
| Restore test mensual | OK, RTO medido |
