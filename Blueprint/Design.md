Jede schreibende Aktion benötigt eine anschließende Verifikation.

Beispiele:

```text
repair_windows_update()
 ↓
verify_windows_update()
```

---

```text
repair_hyperv_switch()
 ↓
verify_hyperv_health()
```

---

```text
restart_service()
 ↓
verify_service_status()
```

---

# Audit-Pflicht

Jeder Ausführungsvorgang erzeugt einen Audit-Eintrag.

Mindestinhalt:

```json
{
  "timestamp": "",
  "session_id": "",
  "plan_id": "",
  "plan_hash": "",
  "approved_by": "",
  "tool": "",
  "result": "",
  "verified": true
}
```

---

# Kritische Sicherheitsregel

```text
LLMs erstellen Pläne.

Menschen genehmigen Pläne.

Das HITL-Gateway signiert Pläne.

Der Executor führt ausschließlich signierte Pläne aus.

Jede Ausführung wird verifiziert.

Jede Ausführung wird auditiert.
```

Dadurch wird technisch erzwungen:

```text
Kein HITL
=
Keine Signatur
=
Keine Ausführung
```
