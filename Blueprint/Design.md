- DISM
- SFC
- Hyper-V Cmdlets
- Registry
- Windows APIs

---

# Audit

Jede Analyse und jede Änderung wird dokumentiert.

Mindestinformationen:

```json
{
  "timestamp": "",
  "problem": "",
  "evidence": [],
  "confidence": 0,
  "plan": [],
  "approved": true,
  "result": ""
}
```

---

# Sicherheitsmodell

NoBS arbeitet standardmäßig im Analysemodus.

Standardzustand:

```text
Read Only
```

Schreibende Aktionen müssen explizit freigegeben werden.

---

# Langfristige Vision

Windows sammelt bereits nahezu alle Informationen, die für eine automatisierte Problemanalyse erforderlich sind.

NoBS soll die fehlende Schicht zwischen:

- Rohdaten
- Ursachenanalyse
- Reparatur

bereitstellen.

Das Ziel ist, aus:

```text
0x80070005
```

ein

```text
Was ist passiert?
Warum ist es passiert?
Wie behebe ich es?
Wie riskant ist die Reparatur?
```

zu machen.

NoBS steht für:

No More Bullshit.
