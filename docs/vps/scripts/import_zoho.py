#!/usr/bin/env python3
"""Importa una exportación ZIP de Zoho (.eml por carpeta) a un buzón Maildir de Hestia/Dovecot.

Uso: import_zoho.py <zip> <buzon@dominio> [--dry-run]

- Carpeta Zoho "Inbox" -> INBOX; "Inbox/X" -> INBOX/X; resto igual (separador "/").
- Escribe en <maildir>/cur con flag \\Seen (y \\Draft en Drafts), mtime = cabecera Date.
- Idempotente: salta solo copias byte-idénticas (md5) ya presentes en la carpeta destino;
  Zoho guarda versiones distintas con el mismo Message-ID y hay que conservarlas.
- Al final: doveadm force-resync y recuento por carpeta (origen vs destino).
"""
import email.utils, hashlib, os, pwd, grp, re, socket, subprocess, sys, time, zipfile
from collections import Counter

ZIP, USER = sys.argv[1], sys.argv[2]
DRY = "--dry-run" in sys.argv
local, domain = USER.split("@")
BASE = f"/home/user/mail/{domain}/{local}"
UID, GID = pwd.getpwnam("user").pw_uid, grp.getgrnam("mail").gr_gid
HOST = socket.gethostname()
MID_RE = re.compile(rb"^message-id:\s*(<[^>\r\n]+>)", re.I | re.M)


def mailbox_name(folder):
    parts = folder.split("/")
    if parts[0].lower() == "inbox":
        parts[0] = "INBOX"
    return "/".join(parts)


def maildir_path(mbox):
    return BASE if mbox == "INBOX" else os.path.join(BASE, "." + mbox.replace("/", "."))


def header_block(data):
    end = data.find(b"\r\n\r\n")
    if end < 0:
        end = data.find(b"\n\n")
    return data[: end if end >= 0 else 8192]


def message_id(data):
    m = MID_RE.search(header_block(data))
    return m.group(1).strip().lower() if m else None


def msg_time(data):
    m = re.search(rb"^date:\s*(.+)$", header_block(data), re.I | re.M)
    if m:
        try:
            return email.utils.parsedate_to_datetime(m.group(1).decode("latin-1").strip()).timestamp()
        except Exception:
            pass
    return time.time()


def existing_ids(path):
    """md5 del contenido de cada mensaje ya presente en la carpeta."""
    ids = set()
    for sub in ("cur", "new"):
        d = os.path.join(path, sub)
        if not os.path.isdir(d):
            continue
        for f in os.listdir(d):
            try:
                with open(os.path.join(d, f), "rb") as fh:
                    ids.add(hashlib.md5(fh.read()).hexdigest())
            except OSError:
                pass
    return ids


def ensure_mailbox(mbox):
    if mbox == "INBOX" or DRY:
        return
    if not os.path.isdir(maildir_path(mbox)):
        subprocess.run(["doveadm", "mailbox", "create", "-s", "-u", USER, mbox], check=True)


z = zipfile.ZipFile(ZIP)
entries = [n for n in z.namelist() if not n.endswith("/") and "/" in n]
src = Counter(mailbox_name(n.rsplit("/", 1)[0]) for n in entries)
added, skipped, seq = Counter(), Counter(), 0
cache = {}

for name in entries:
    mbox = mailbox_name(name.rsplit("/", 1)[0])
    path = maildir_path(mbox)
    if mbox not in cache:
        ensure_mailbox(mbox)
        cache[mbox] = existing_ids(path)
    data = z.read(name)
    mid = hashlib.md5(data).hexdigest()
    if mid in cache[mbox]:
        skipped[mbox] += 1
        continue
    if DRY:
        added[mbox] += 1
        continue
    ts = msg_time(data)
    seq += 1
    flags = "DS" if mbox.lower() == "drafts" else "S"
    fname = f"{int(ts)}.M{seq}P{os.getpid()}.{HOST},S={len(data)}:2,{flags}"
    tmp = os.path.join(path, "tmp", fname)
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    with open(tmp, "wb") as fh:
        fh.write(data)
    os.chown(tmp, UID, GID)
    os.chmod(tmp, 0o660)
    os.utime(tmp, (ts, ts))
    os.rename(tmp, os.path.join(path, "cur", fname))
    cache[mbox].add(mid)
    added[mbox] += 1

if not DRY:
    for p, dirs, files in os.walk(BASE):
        for d in dirs:
            try:
                os.chown(os.path.join(p, d), UID, GID)
            except OSError:
                pass
    subprocess.run(["doveadm", "force-resync", "-u", USER, "*"], check=True)

print(f"{USER} ({'SIMULACIÓN' if DRY else 'IMPORTADO'})")
print(f"{'carpeta':<22}{'origen':>8}{'añadidos':>10}{'saltados':>10}{'destino':>9}")
for mbox in sorted(src):
    dest = "-"
    if not DRY:
        r = subprocess.run(["doveadm", "-f", "flow", "mailbox", "status", "-u", USER, "messages", mbox],
                           capture_output=True, text=True)
        dest = r.stdout.strip().split("=")[-1] if r.returncode == 0 else "?"
    print(f"{mbox:<22}{src[mbox]:>8}{added[mbox]:>10}{skipped[mbox]:>10}{dest:>9}")
print(f"{'TOTAL':<22}{sum(src.values()):>8}{sum(added.values()):>10}{sum(skipped.values()):>10}")
