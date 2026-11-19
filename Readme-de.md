# NoBS

> **No More Bullshit Windows Diagnostics and Remediation.**

Windows weiß bereits, was nicht stimmt.

Es hat die Logs.
Es hat die Telemetrie.
Es hat die Event Traces.
Es hat die Absturzberichte.
Es hat den Update-Verlauf.

Dennoch erhalten Benutzer immer noch:

```text
0x80070005

Etwas ist schiefgelaufen.

Bei Hyper-V ist ein Fehler aufgetreten.

Fehler bei Windows Update.
```

NoBS existiert, um Windows-Bullshit in menschliche Sprache zu übersetzen.

---

## Das Problem

Moderne Windows-Systeme sammeln bereits enorme Mengen an Diagnoseinformationen:

- Event Logs
- Reliability Monitor (Zuverlässigkeitsüberwachung)
- Windows Update Telemetrie
- CBS-Logs
- DISM-Logs
- WMI / CIM
- Hyper-V-Diagnosedaten
- Defender-Telemetrie
- Dienststatus (Service Status)
- Leistungsindikatoren (Performance Counters)
- Registry-Zustand

Das Problem ist nicht der Mangel an Informationen.

Das Problem ist, dass diese Informationen:

- über Dutzende Orte verstreut sind
- schwer zu korrelieren sind
- schwer zu verstehen sind
- schwer in Maßnahmen umzusetzen sind

Von Benutzern wird erwartet, dass sie zu Systemadministratoren werden, nur um zu verstehen, warum ein Update fehlgeschlagen ist.

Das ist inakzeptabel.

---

## Das Ziel

NoBS macht aus:

```text
0x80070005
```

das hier:

```text
Windows Update kann nicht auf erforderliche Dateien zugreifen.

Evidenz:
- Event ID 20
- "Access Denied"-Einträge in der CBS.log
- Fehlgeschlagene Update-Transaktion

Wahrscheinliche Ursache:
Beschädigte Berechtigungen im Update-Subsystem.

Konfidenz:
87 %

Vorgeschlagene Reparatur:
Update-Berechtigungen zurücksetzen und Update-Cache neu aufbauen.

Risiko:
Niedrig
```

---

## Was NoBS ist

NoBS ist ein OS-nativer Troubleshooting-Harness für Windows.

Es:

1. Sammelt Systemfakten.
2. Korreliert Informationen über mehrere Quellen hinweg.
3. Ermittelt wahrscheinliche Grundursachen (Root Causes).
4. Recherchiert verfügbare Lösungen.
5. Erstellt einen Reparaturplan.
6. Präsentiert einem Menschen die Evidenz.
7. Führt genehmigte Korrekturen aus.
8. Auditiert jede Änderung.

---

## Was NoBS NICHT ist

NoBS ist kein:

- Chatbot
- virtueller Assistent
- Cloud-Dienst
- weiterer „KI-Copilot“
- Ersatz für Administratoren

NoBS ist eine Diagnose- und Remediation-Plattform.

Fakten zuerst.
Logisches Schließen als Zweites.
Ausführung zuletzt.

---
# Zielgruppe

## Primäre Zielgruppe

NoBS richtet sich primär an Endanwender.

Gemeint sind Menschen, die ihren Computer benutzen und nicht administrieren wollen (z. B. Eltern, Großeltern, Schüler, Rentner, Kleinunternehmer, Handwerker, Lehrer, Pfleger).

Diese Nutzer:

- können keine Logfiles lesen
- kennen keine Eventlogs
- können keine Registry bearbeiten
- nutzen keine PowerShell
- können Fehlercodes nicht interpretieren
- wissen nicht, welche Systemdaten relevant sind

NoBS soll keine Administratoren ausbilden.

NoBS soll Computerprobleme verständlich erklären und sicher lösbar machen.

---

## Sekundäre Zielgruppe

- Helpdesk
- First Level Support
- IT-Administratoren
- Power User

Diese Zielgruppen profitieren von:

- Zeitersparnis
- strukturierten RCA-Berichten
- lückenloser Auditierung
- reproduzierbarer Automatisierung

Sie sind jedoch ausdrücklich nicht die primäre Zielgruppe.

---

# Nutzerprinzip

NoBS erklärt Computerprobleme in der Sprache von Menschen.

Der Computer muss sich dem Menschen verständlich machen – nicht umgekehrt.

Jede Ausgabe für Endanwender beantwortet zwingend fünf Kernfragen:

1. **Was ist passiert?** (Verständliche Beschreibung statt Fehlercode)
2. **Warum ist es passiert?** (Ursache ohne Fachchinesisch)
3. **Ist mein Computer kaputt?** (Einordnung von Hardware- vs. Softwareproblem)
4. **Kann ich etwas verlieren?** (Klare Aussage zur Datensicherheit / Backup-Status)
5. **Was kann dagegen getan werden?** (Konkreter, sicherer Lösungsvorschlag)

Technische Details (Event-IDs, Log-Pfade, Registry-Keys, Befehle) bleiben vollständig erhalten, werden aber für Endanwender hinter einer Detail-Ansicht gekapselt.

---

## Designprinzipien

### Facts First (Fakten zuerst)

NoBS startet niemals mit Annahmen.

Es startet mit messbaren Systemfakten.

### Human In The Loop

Keine Reparatur wird ohne Genehmigung ausgeführt.

### Explain Everything (Alles erklären)

Jede Empfehlung muss enthalten:

- Evidenz
- Begründung
- Konfidenzwert
- Rollback-Informationen
- Risikobewertung

### Offline First

Das System muss auch ohne Internetzugang nützlich bleiben.

### Audit First

Jede Aktion wird aufgezeichnet.

Nichts geschieht im Stillen.

### No Magic (Keine Magie)

NoBS muss immer beantworten können:

```text
Warum denkst du das?

Warum schlägst du das vor?

Welche Evidenz stützt diese Schlussfolgerung?
```

---

# Architektur

```text
Windows
│
├─ Event Logs
├─ Reliability Monitor
├─ Windows Update
├─ CBS
├─ DISM
├─ WMI/CIM
├─ Hyper-V
├─ Defender
└─ Systemzustand
             │
             ▼
      Data Collectors
             │
             ▼
       Normalisierung
             │
             ▼
       Facts Database
             │
             ▼
      Correlation Engine
             │
             ▼
         Web-Recherche
             │
             ▼
             LLM
             │
             ▼
     Repair Plan Generator
             │
             ▼
      Dry-Run-Validierung
             │
             ▼
           HITL
             │
             ▼
         Ausführung
             │
             ▼
            Audit
```

---

## Beispiel-Workflow

Benutzer sagt:

```text
Windows Update ist kaputt.
```

NoBS:

```text
✓ Update-Telemetrie sammeln

✓ Update-Logs analysieren

✓ CBS-Integrität prüfen

✓ DISM-Zustand prüfen

✓ Zugehörige Event-IDs prüfen

✓ Ergebnisse korrelieren

✓ Dokumentierte Lösungen recherchieren

✓ Reparaturplan erstellen
```

Ergebnis:

```text
Problem:
Windows-Update-Fehler

Ursache:
Beschädigter Komponentenspeicher (Component Store)

Konfidenz:
91 %

Evidenz:
- CBS-Beschädigung erkannt
- Event ID 20
- Fehlgeschlagene Pakettransaktion

Empfohlene Maßnahmen:
1. DISM RestoreHealth
2. SFC Scan
3. Windows Update erneut testen

Risiko:
Niedrig

Rollback:
Nicht erforderlich

Ausführen?
[Y]a (Yes)
[N]ein (No)
[Details]
[Plan verbessern]
```

---

# Warum dieses Projekt existiert

Betriebssysteme sollten Benutzern helfen, Probleme zu lösen.

Stattdessen zeigen die meisten Systeme rohe Fehlercodes an und zwingen Benutzer dazu, Foren, Blogs, Reddit-Threads und zufällige YouTube-Videos zu durchsuchen.

NoBS zielt darauf ab, diese Lücke zu schließen.

Die Zukunft ist nicht:

```text
Mehr KI.
```

Die Zukunft ist:

```text
Besseres Verständnis vorhandener Systemdaten.
```

---

# Aktueller Status

```text
Status: Planung / Pre-Alpha
```

Es ist noch nichts veröffentlicht.

Die Blaupause kommt zuerst.

Siehe:

```text
Blueprint/
├─ design.md
├─ roadmap.md
└─ changelog.md
```

---

# Philosophie

Hört auf, Benutzern das hier zu zeigen:

```text
0x80070005
```

Fangt an, ihnen das hier zu sagen:

```text
Was passiert ist.
Warum es passiert ist.
Wie man es behebt.
Wie riskant die Reparatur ist.
```

**No More Bullshit.**
