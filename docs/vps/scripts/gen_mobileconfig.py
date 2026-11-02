#!/usr/bin/env python3
"""Genera un perfil Apple .mobileconfig (sin contraseñas) con cuentas IMAP de osigc.com.

Uso: gen_mobileconfig.py <salida.mobileconfig> <buzón> [<buzón> ...]
iOS/macOS piden la contraseña de cada cuenta al instalar el perfil.
"""
import plistlib, sys, uuid

out, accounts = sys.argv[1], sys.argv[2:]
HOST = "mail.osigc.com"
payloads = []
for addr in accounts:
    payloads.append({
        "PayloadType": "com.apple.mail.managed",
        "PayloadVersion": 1,
        "PayloadIdentifier": f"com.osigc.mail.{addr.split('@')[0]}",
        "PayloadUUID": str(uuid.uuid4()).upper(),
        "PayloadDisplayName": f"Correo {addr}",
        "EmailAccountDescription": addr,
        "EmailAccountName": "OSI Global Consulting",
        "EmailAccountType": "EmailTypeIMAP",
        "EmailAddress": addr,
        "IncomingMailServerAuthentication": "EmailAuthPassword",
        "IncomingMailServerHostName": HOST,
        "IncomingMailServerPortNumber": 993,
        "IncomingMailServerUseSSL": True,
        "IncomingMailServerUsername": addr,
        "OutgoingMailServerAuthentication": "EmailAuthPassword",
        "OutgoingMailServerHostName": HOST,
        "OutgoingMailServerPortNumber": 465,
        "OutgoingMailServerUseSSL": True,
        "OutgoingMailServerUsername": addr,
        "OutgoingPasswordSameAsIncomingPassword": True,
        "PreventMove": False,
        "PreventAppSheet": False,
        "SMIMEEnabled": False,
        "allowMailDrop": True,
    })

profile = {
    "PayloadType": "Configuration",
    "PayloadVersion": 1,
    "PayloadIdentifier": "com.osigc.mail.profile",
    "PayloadUUID": str(uuid.uuid4()).upper(),
    "PayloadDisplayName": "Correo OSI Global Consulting (osigc.com)",
    "PayloadDescription": "Configura las cuentas de correo de osigc.com en mail.osigc.com (IMAP 993 SSL, SMTP 465 SSL).",
    "PayloadOrganization": "OSI Global Consulting",
    "PayloadRemovalDisallowed": False,
    "PayloadContent": payloads,
}
with open(out, "wb") as fh:
    plistlib.dump(profile, fh)
print(f"{out}: {len(payloads)} cuentas")
