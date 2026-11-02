#!/usr/bin/env python3
"""Resumen de los informes DMARC agregados (rua) recibidos en dmarc@osigc.com y propuesta de política.

Uso: dmarc_resumen.py [--enviar]   (sin --enviar solo imprime; con --enviar lo manda a jmcastillo22@gmail.com)
Lee el Maildir del buzón, descomprime adjuntos .zip/.gz/.xml y agrega por IP de origen.
"""
import email, gzip, io, os, smtplib, ssl, sys, zipfile
import xml.etree.ElementTree as ET
from collections import defaultdict
from email.message import EmailMessage
from email.utils import formatdate, make_msgid

MAILDIR = "/home/user/mail/osigc.com/dmarc"
TO = "jmcastillo22@gmail.com"


def xml_blobs(msg):
    for part in msg.walk():
        name = (part.get_filename() or "").lower()
        data = part.get_payload(decode=True)
        if not data:
            continue
        try:
            if name.endswith(".zip") or data[:2] == b"PK":
                with zipfile.ZipFile(io.BytesIO(data)) as z:
                    for n in z.namelist():
                        yield z.read(n)
            elif name.endswith(".gz") or data[:2] == b"\x1f\x8b":
                yield gzip.decompress(data)
            elif name.endswith(".xml"):
                yield data
        except Exception:
            continue


reports, orgs = 0, set()
by_ip = defaultdict(lambda: {"n": 0, "pass": 0, "dkim": 0, "spf": 0})
for sub in ("cur", "new"):
    d = os.path.join(MAILDIR, sub)
    for f in os.listdir(d) if os.path.isdir(d) else []:
        with open(os.path.join(d, f), "rb") as fh:
            msg = email.message_from_binary_file(fh)
        for blob in xml_blobs(msg):
            try:
                root = ET.fromstring(blob)
            except ET.ParseError:
                continue
            reports += 1
            orgs.add(root.findtext("report_metadata/org_name") or "?")
            for rec in root.findall("record"):
                ip = rec.findtext("row/source_ip")
                n = int(rec.findtext("row/count") or 0)
                dk = rec.findtext("row/policy_evaluated/dkim") == "pass"
                sp = rec.findtext("row/policy_evaluated/spf") == "pass"
                s = by_ip[ip]
                s["n"] += n; s["dkim"] += n if dk else 0; s["spf"] += n if sp else 0
                s["pass"] += n if (dk or sp) else 0

total = sum(s["n"] for s in by_ip.values())
ok = sum(s["pass"] for s in by_ip.values())
pct = (100.0 * ok / total) if total else 0.0
own = by_ip.get("148.230.108.106", {"n": 0, "pass": 0})
own_pct = (100.0 * own["pass"] / own["n"]) if own["n"] else 0.0

lines = [f"Informes DMARC agregados recibidos en dmarc@osigc.com: {reports} (de {', '.join(sorted(orgs)) or 'ninguno'})",
         f"Mensajes evaluados: {total} · alineados DMARC (DKIM o SPF): {ok} ({pct:.1f} %)",
         f"Desde mail.osigc.com (148.230.108.106): {own['n']} · alineados {own_pct:.1f} %", "",
         "Origen (IP) · mensajes · DMARC pass · DKIM pass · SPF pass"]
for ip, s in sorted(by_ip.items(), key=lambda kv: -kv[1]["n"])[:25]:
    lines.append(f"  {ip} · {s['n']} · {s['pass']} · {s['dkim']} · {s['spf']}")

if total == 0:
    prop = "PROPUESTA: mantener p=none. No hay informes suficientes para decidir."
elif own_pct >= 98 and all(s["pass"] == s["n"] for ip, s in by_ip.items() if ip == "148.230.108.106"):
    prop = ("PROPUESTA: pasar a p=quarantine (pct=100) en _dmarc.osigc.com:\n"
            "  v=DMARC1; p=quarantine; rua=mailto:dmarc@osigc.com; ruf=mailto:dmarc@osigc.com; fo=1; adkim=s; aspf=s\n"
            "Lo que falla DMARC desde otras IPs es suplantación o reenvíos y quedaría en cuarentena. "
            "Revisa antes la tabla por si alguna IP es un servicio legítimo tuyo sin autenticar (p. ej. Brevo).")
else:
    prop = ("PROPUESTA: NO subir todavía. El correo propio no está alineado al 98 % o más; revisar las IPs con fallos "
            "antes de pasar a quarantine.")

body = "\n".join(lines) + "\n\n" + prop + "\n\nNo se ha cambiado nada en el DNS: el cambio requiere tu OK.\n"
print(body)
if "--enviar" in sys.argv:
    pw = next(l.strip().split("=", 1)[1] for l in open("/root/.hestia_mail_osigc.env") if l.startswith("info@osigc.com="))
    m = EmailMessage()
    m["From"] = "OSI Global Consulting <info@osigc.com>"; m["To"] = TO
    m["Subject"] = f"DMARC osigc.com: resumen de informes y propuesta ({pct:.0f} % alineado)"
    m["Date"] = formatdate(localtime=True); m["Message-ID"] = make_msgid(domain="osigc.com")
    m.set_content(body)
    with smtplib.SMTP_SSL("mail.osigc.com", 465, context=ssl.create_default_context()) as s:
        s.login("info@osigc.com", pw); s.send_message(m)
    print("enviado a", TO)
