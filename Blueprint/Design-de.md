# NoBS (No More Bullshit)

## Was und warum

NoBS ist ein OS-naher Diagnose-, Analyse- und Remediation-Harness für Windows.

Windows sammelt bereits umfangreiche Informationen über seinen eigenen Zustand:

- Event Logs
- Reliability Monitor
- Windows Update Telemetrie
- CBS
- DISM
- WMI/CIM
- Hyper-V Diagnosedaten
- Defender Telemetrie
- Service Status
- Registry
- Performance Counter

Das Problem ist nicht der Mangel an Daten.

Das Problem ist, dass diese Daten über dutzende Quellen verteilt sind und Windows sie nur unzureichend korreliert.

Dadurch erhalten Benutzer häufig Fehlermeldungen wie:

```text
0x80070005

Something went wrong.

Windows Update failed.

Hyper-V encountered an error.
```

Dabei liegen die eigentlichen Ursachen oft bereits auf dem System vor.

NoBS sammelt diese Informationen, korreliert sie, recherchiert bei Bedarf zusätzliche Evidenz, erstellt nachvollziehbare Reparaturpläne und unterstützt Benutzer bei der Behebung von Problemen.

Das Ziel ist nicht ein weiterer Chatbot.

Das Ziel ist ein Betriebssystem-Harness, der Probleme nachvollziehbar analysiert und auf Basis von Fakten konkrete Handlungsempfehlungen erzeugt.

---

# Architekturregel (SSOT)

Wer Architekturentscheidungen, Datenflüsse, Sicherheitsmodelle oder Grundprinzipien verändert, ändert zuerst diese Datei.

Dieses Dokument ist die Single Source of Truth (SSOT).

Roadmap, Implementierung und Dokumentation richten sich nach diesem Dokument.

---

# Projektziele

## Primärziele

- Ursachen statt Symptome erkennen
- Verteilte Windows-Datenquellen zusammenführen
- Root Cause Analysis durchführen
- Evidenz sammeln
- Reparaturpläne erzeugen
- Human-In-The-Loop gewährleisten
- Vollständige Auditierbarkeit sicherstellen
- Lokal betrieben werden können

## Sekundärziele

- Support-Aufwand reduzieren
- Fehlersuche beschleunigen
- Dokumentation automatisch erzeugen
- Wiederkehrende Probleme erkennen
- Bewährte Reparaturpfade lernen

---

# Nicht-Ziele

NoBS ist kein:

- allgemeiner KI-Assistent
- Chatbot
- Sprachassistent
- Cloud-Service
- autonomes System ohne Benutzerkontrolle
- Ersatz für Administratoren

NoBS unterstützt Administratoren und Benutzer bei der Problemanalyse und Problemlösung.

---

# Technologie-Stack

NoBS verwendet bewusst mehrere Sprachen.

Jede Sprache besitzt einen klar definierten Aufgabenbereich.

## PowerShell

Windows Integration

Verantwortlich für:

- Eventlogs
- Registry
- Hyper-V
- Services
- DISM
- SFC
- WMI
- CIM
- Collector
- Executor
- Verification

---

## Python

Agentische Logik

Verantwortlich für:

- MCP Clients
- Research Engine
- Correlation Engine
- LLM Planner
- Audit Engine
- Kontextmanagement

---

## Rust

Systemnahe Infrastruktur

Verantwortlich für:

- MCP Server
- ACP Server
- State Management
- Datenhaltung
- Config Management
- Packaging
- Verteilung
- Windows Service Integration
- Caching

---

## Architekturregel

Komponenten werden nicht aufgrund persönlicher Vorlieben implementiert.

Jede Sprache besitzt einen klar definierten Verantwortungsbereich.

Doppelte Implementierungen sind zu vermeiden.

---

# Grundprinzipien

## Facts First

NoBS arbeitet ausschließlich auf nachweisbaren Fakten.

Fakten stammen aus:

- Event Logs
- Systemzuständen
- Telemetrie
- Konfigurationen
- Dateien
- Registry
- APIs
- Herstellerdokumentationen

Nicht belegbare Annahmen sind unzulässig.

---

## Human In The Loop

Änderungen am System erfolgen niemals ohne Benutzerfreigabe.

NoBS darf:

- analysieren
- korrelieren
- recherchieren
- planen

NoBS darf erst nach Freigabe:

- ändern
- reparieren
- konfigurieren
- entfernen
- installieren

---

## Explainability

Jede Empfehlung muss nachvollziehbar begründet werden.

Jeder Plan muss enthalten:

- Ursache
- Evidenz
- Confidence
- Risiken
- Rollback-Möglichkeit
- erwartetes Ergebnis

---

## Audit First

Jede Analyse wird protokolliert.

Jede Entscheidung wird protokolliert.

Jede Änderung wird protokolliert.

Jedes Ergebnis wird protokolliert.

Nichts geschieht ohne Nachvollziehbarkeit.

---

## Offline First

Die Kernfunktionen müssen ohne Cloud-Nutzung funktionieren.

Internetzugriff erweitert die Fähigkeiten, ersetzt sie aber nicht.

---

## Functional Verification Over Exit Codes

Eine Reparatur gilt nicht als erfolgreich, weil ein Skript erfolgreich beendet wurde.

Eine Reparatur gilt erst dann als erfolgreich, wenn das eigentliche Problem nachweislich verschwunden ist.

Beispiele:

```text
Dienst startet
≠ Problem gelöst
```

```text
Windows Update funktioniert wieder
= Problem gelöst
```

```text
VM startet erfolgreich
= Problem gelöst
```

---

# Agent Harness Architektur

## Warum NoBS ein Harness ist

Das LLM ist nicht NoBS.

Das LLM ist lediglich eine Komponente innerhalb von NoBS.

NoBS stellt die vollständige Infrastruktur bereit:

- Zustand
- Werkzeuge
- Sicherheit
- Gedächtnis
- Auditierung
- Wiederherstellung

Das LLM liefert:

- Analyse
- Korrelation
- Planung

---

## Agent Loop

Grundschema:

```text
Reason
↓
Act
↓
Observe
↓
Verify
↓
Continue / Stop
```

---

## Stop-Bedingungen

### Maximale Iterationen

```text
max_steps
```

---

### Maximales Zeitbudget

Konfigurierbar.

---

### Maximales Tokenbudget

Konfigurierbar.

---

### Erfolgreiche Verifikation

Der Agent beendet die Analyse, sobald das Problem nachweislich behoben wurde.

---

# Systemarchitektur

```text
Windows Quellen
        │
        ▼
Collector
        │
        ▼
Normalizer
        │
        ▼
Facts Database
        │
        ▼
Correlation Engine
        │
        ▼
Research Engine
        │
        ▼
LLM Planner
        │
        ▼
Dry Run
        │
        ▼
Human Approval
        │
        ▼
Executor
        │
        ▼
Verification
        │
        ▼
Audit
```

---

# MCP First Architecture

NoBS verwendet MCP als primäre Integrationsschicht.

Alle Diagnose-, Recherche-, Verifikations- und Remediation-Funktionen werden als MCP Tools bereitgestellt.

Das LLM arbeitet ausschließlich über definierte MCP Schnittstellen.

---

# Datenquellen

## Event Logs

- System
- Application
- Setup
- Security
- Custom Provider Logs

---

## Reliability Monitor

- Win32_ReliabilityRecords

---

## Windows Update

- WindowsUpdateClient
- CBS.log
- DISM.log

---

## Hyper-V

- VMMS
- Worker
- Virtual Switches
- Host Configuration

---

## Defender

- Threat Detection
- Scan Status
- Protection Status

---

## WMI / CIM

- Hardware
- Betriebssystem
- Netzwerk
- Dienste
- Benutzer
- Prozesse

---

## Registry

Während der Analyse ausschließlich lesender Zugriff.

Schreibender Zugriff nur innerhalb freigegebener Reparaturpläne.

---

## Performance Daten

- CPU
- RAM
- Storage
- Netzwerk
- Prozesse
- Dienste

---

# Collector

Verantwortlichkeiten:

- Sammeln
- Extrahieren
- Klassifizieren
- Strukturieren

Der Collector interpretiert niemals Daten.

Collector-Ausgaben sind reine Fakten.

---

# Normalizer

Alle Quellen werden in ein gemeinsames Datenmodell überführt.

Beispiel:

```json
{
  "id": "uuid",
  "timestamp": "",
  "collector": "",
  "source": "",
  "severity": "",
  "event_id": "",
  "message": "",
  "host": "",
  "tags": []
}
```

---

# Facts Database

Die Facts Database enthält ausschließlich Fakten.

Sie enthält:

- Messwerte
- Ereignisse
- Zustände
- Konfigurationen
- Ergebnisse

Sie enthält keine Vermutungen.

Sie enthält keine KI-generierten Annahmen.

---

# Context Management

## Aktiver Kontext

Der Prompt enthält nur relevante Informationen.

---

## Persistentes Gedächtnis

Speicherorte:

- SQLite
- Auditdatenbank
- Runbooks
- Faktenhistorie

---

## Kontext-Kompaktierung

Gespeichert werden:

- Evidenz
- Entscheidungen
- Ergebnisse

Nicht komplette Rohlogs.

---

# Correlation Engine

Die Correlation Engine sucht Zusammenhänge zwischen Fakten.

Sie erzeugt Evidenzketten.

Sie führt keine Reparaturen aus.

---

# Evidenzmodell

## Level 1

Einzelner Messwert

---

## Level 2

Einzelner Logeintrag

---

## Level 3

Mehrere unabhängige Quellen bestätigen denselben Sachverhalt.

---

## Level 4

Funktionale Verifikation.

---

# Research Engine

Bevorzugte Quellen:

- Microsoft Learn
- Microsoft KB Artikel
- Herstellerdokumentationen
- Offizielle GitHub-Projekte

Alle Quellen müssen dokumentiert werden.

---

# Rolle des LLM

Das LLM ist kein Wahrheitslieferant.

Das LLM ist:

- Analyst
- Korrelator
- Planer
- Dokumentationsgenerator

Das LLM erhält ausschließlich strukturierte Fakten.

Das LLM darf:

- Fakten auswerten
- recherchieren
- Reparaturpläne erzeugen

Das LLM soll nicht raten.

---

# MCP Sicherheitsmodell

## MCP Klassen

### Klasse A – Read Only

Beispiele:

```text
get_recent_errors()
get_windows_update_status()
get_hyperv_status()
```

---

### Klasse B – Research

Beispiele:

```text
search_ms_learn()
search_kb_articles()
search_github()
```

---

### Klasse C – Planning

Beispiele:

```text
build_repair_plan()
estimate_risk()
generate_rollback()
```

---

### Klasse D – Execution

Beispiele:

```text
repair_windows_update()
modify_registry()
restart_service()
```

---

# Physische MCP Trennung

Read-only und Execute werden in separaten Prozessen betrieben.

## Collector MCP

Read Only.

---

## Research MCP

Recherche.

---

## Planner MCP

Analyse.

---

## Executor MCP

Write Access.

Akzeptiert ausschließlich signierte Pläne.

---

# Kryptografische Freigabe-Architektur

## Grundprinzip

LLMs erzeugen Pläne.

Menschen genehmigen Pläne.

Der HITL Gateway signiert Pläne.

Der Executor führt ausschließlich signierte Pläne aus.

---

# Signed Plan Format

```json
{
  "plan_id": "uuid",
  "nonce": "uuid",
  "hash": "sha256",
  "approved_by": "local_user",
  "approved_at": "TT-MM-JJJJ_HH-MM-SS",
  "expires_at": "TT-MM-JJJJ_HH-MM-SS",
  "signature": "..."
}
```

---

# Replay Protection

## Ablaufzeit

Standard:

```text
5 Minuten
```

---

## Nonce

Jeder Plan erhält eine eindeutige Nonce.

Nach Ausführung:

```text
consumed
```

---

## Executor Prüfungen

Pflicht:

- Signatur gültig
- Hash gültig
- Nicht abgelaufen
- Nonce vorhanden
- Nonce nicht verbraucht

---

# Executor Locking

## Standardzustand

```text
LOCKED
```

---

## Entsperrung

Nur über den HITL Gateway.

---

## Automatische Sperre

Nach:

- Erfolg
- Fehler
- Timeout

wird automatisch wieder gesperrt.

---

# LLM Isolation

Verboten:

```text
LLM
↓
Executor
```

Erlaubt:

```text
LLM
↓
Plan
↓
HITL
↓
Signatur
↓
Executor
```

---

# Reparaturpläne

Jeder Plan muss enthalten:

- Ursache
- Evidenz
- Quellen
- Schritte
- Risiko
- Rollback
- Confidence

---

# Dry Run

Vor jeder Ausführung wird ein Dry Run erzeugt.

Der Nutzer muss nachvollziehen können:

- Was passiert?
- Warum?
- Mit welchen Risiken?

---

# Verification Engine

Nach jeder Änderung erfolgt eine erneute Analyse.

Ziel:

Prüfen ob das Problem verschwunden ist.

Nicht ob der Befehl erfolgreich war.

---

# Verification Failure Handling

## verified = true

Problem behoben.

Audit abschließen.

---

## verified = false

Dem Nutzer werden angeboten:

```text
[ Rollback durchführen ]

[ Alternativen suchen ]

[ Plan verbessern ]

[ Manuell eingreifen ]
```

---

# Rollback Policy

Jeder Plan benötigt vor Ausführung:

- Rollbackstrategie
- Risikobewertung
- Verifikationsmethode

---

## Rollback Modi

```json
{
  "rollback_mode": "none|manual|automatic"
}
```

---

## Kritische Regel

NoBS führt niemals einen nicht-validierten Rollback automatisch aus.

---

# Checkpoints

Typische Checkpoints:

- Analyse abgeschlossen
- Recherche abgeschlossen
- Plan erstellt
- Plan genehmigt
- Reparatur ausgeführt
- Verifikation abgeschlossen

---

# Recovery

Agentläufe müssen jederzeit wiederaufnehmbar sein.

---

# Learning Engine

Erfolgreiche Reparaturen können in Runbooks überführt werden.

Ablauf:

```text
Problem
↓
Analyse
↓
Reparatur
↓
Verifikation
↓
Audit
↓
Runbook
```

---

# Audit

Jede Analyse und jede Änderung wird dokumentiert.

Beispiel:

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

# Sicherheitsmodell

NoBS startet standardmäßig im:

```text
Read Only Mode
```

Schreibende Aktionen benötigen:

- Plan
- HITL
- Signatur
- Audit
- Verifikation

---

# Langfristige Vision

NoBS stellt die fehlende Schicht zwischen:

- Rohdaten
- Ursachenanalyse
- Reparatur
- Verifikation

bereit.

Das Ziel ist, aus:

```text
0x80070005
```

ein:

```text
Was ist passiert?
Warum ist es passiert?
Welche Beweise gibt es?
Wie behebe ich es?
Wie riskant ist die Reparatur?
Kann die Reparatur rückgängig gemacht werden?
Hat die Reparatur funktioniert?
```

zu machen.

---

# Leitsatz

```text
Stop guessing.
Collect evidence.

Stop reading logs.
Understand problems.

Stop showing error codes.
Explain causes.

No More Bullshit.
```
**Regeln für Agenten:**

• Regel R1 (Harte Isolation / sohelper- & tor-Prinzip): Passt 1:1 zu deinem Executor MCP (Design.md). Statt freier PowerShell-Befehle sollte der Executor ausschließlich eine strikte Positivliste signierter Reparatur-Operationen akzeptieren, und die Research Engine läuft gekapselt über ein zentrales Gateway.

• Regel R2 (Stiller Erfolg verboten + Gegenprobe): Das ergänzt deine Verification Engine um ein entscheidendes Qualitätsmerkmal: Gegenproben (Negative Testing). Jede verify_*()-Funktion sollte im Testbetrieb gegen einen absichtlich kaputten Zustand geprüft werden – schlägt sie dort nicht fehl, gilt die Prüfung als wertlos.

• Regel R3 (Nur SHA-256-signierte Pakete, kein freies Nachladen): Eine extrem wichtige Ergänzung für deine Research & Execution Engine: Wenn eine Reparatur ein Tool, ein Update-Paket oder einen Treiber benötigt, darf NoBS niemals selbstständig Binaries aus dem Netz laden, sondern nur gegen einen lokalen, SHA-256-verifizierten Katalog prüfen (oder einen benannten Befund melden).

• Regel R4 (Keine Klartext-Passwörter / Einmal-Tokens): Sobald NoBS in Enterprise- oder Helpdesk-Szenarien (Sekundärzielgruppe) über WinRM/SSH läuft, greift das exakt zu deinem Nonce- und Session-Binding-Modell: keine gespeicherten Credentials, nur kurzlebige, hostgebundene Einmal-Tokens.

• Regel R5 (Abgestufte Freigaben): Hilft enorm bei der UX für Endanwender und Helpdesk: Nicht-destruktive Standard-Reparaturen (Caches leeren, Dienste neu starten) können in einen niedrigschwelligen Bestätigungs-Flow, während tiefgreifende Eingriffe (Registry-Änderungen, Firewall-Regeln, Datenlöschung) ein hartes Genehmigungs-Gate erzwingen.

• Regel R6 (Lernen nur aus grün geprüften Lösungen + SKILL.md-Promotion): Das ist der perfekte Bauplan für deine Learning Engine aus der Design.md! Nur verifizierte Lösungen (verified: true) wandern ins rag4ll-Runbook-Gedächtnis – und ab N ≥ 10 verifizierten Treffern erzeugt NoBS automatisch einen deterministischen SKILL.md-Entwurf, der nach Review als festes MCP-Tool promoviert wird.

---


• Manifest-gesteuerte Aktualisierung (.lcf-installed-files): Ein erneuter Lauf aktualisiert nur die vom Repository gelieferten Dateien und räumt exakt veraltete Dateien aus früheren Versionen weg – ohne jemals bestehende Nutzerdaten, eigene Targets, Caches oder Konfigurationen anzufassen.
• Echter --dry-run-Modus: Der Installer erkennt das komplette System und zeigt genau an, welche Pakete, Quellen und Änderungen er durchführen würde, ohne auch nur ein Byte anzufassen.
• Kryptografische Verifikation vor Vertrauen: Fremde Schlüssel (wie Docker GPG) werden in einem isolierten temporären Keyring gegen fest verdrahtete Fingerprints geprüft, bevor das System ihnen vertraut – und im Fehlerfall nimmt docker_rpm_undo jede angefangene Änderung rückstandsfrei zurück.
• Klartext-Diagnose statt kryptischer Fehler: Selbst wenn eine HTTPS-Verbindung scheitert, prüft das Skript zuerst, ob schlicht die Systemuhr (klassischer Dual-Boot-Windows-Bug!) verstellt ist, und erklärt die Behebung in klaren Sätzen.

• Einstiegspunkt install.ps1 (und install.sh für eine spätere Linux-Variante): Auf Windows ist PowerShell auf jedem Rechner ab Werk vorinstalliert. Ein install.ps1-Skript als Einstiegspunkt braucht keinerlei Vorab-Kompilierung, lässt sich von Admins und Power-Usern vor der Ausführung im Klartext prüfen und kann selbstständig prüfen, ob die kompilierte Rust-Core-Binary schon vorliegt, diese SHA-256-verifiziert herunterladen oder direkt mit cargo bauen.
• Kein Rust-Zwang für den Installer selbst: Wenn install.ps1 (analog zu deiner install.sh) die System-Checks, die eingebettete Python-Umgebung, das Manifest (nobs-installed-manifest.json), --dry-run, --offline und das Aufräumen übernimmt, sparst du dir für den Installer den kompletten Cross-Compile- und GUI-Overhead in Rust – und bleibst trotzdem zu 100 % bei deinen Regeln (R3: SHA-256-Prüfung, Idempotenz, Manifest-Tracking).
• Saubere Brücke zu Rust: Rust kümmert sich dann erst um die eigentliche Laufzeit-Infrastruktur (MCP-Server, Windows-Service, State Management), während install.ps1 / uninstall.ps1 das Lebenszyklus-Management des Pakets steuern



---

ungeordneet:

Die Kombination aus Tray-Icon und On-Demand-Fenster mit automatischem Desktop-Screenshot + Texterkennung (OCR) ist eine geniale Idee – und genau der fehlende Baustein für echte Endanwender.

Warum der „Screenshot-Trigger“ der ultimative Einstieg ist

• Kein Abtippen von Hex-Codes mehr: Oma oder ein Mitarbeiter im Büro muss keinen Fehlercode wie 0x80070003 mehr abschreiben oder erklären, was gerade passiert ist. Die Fehlermeldung poppt auf → Klick aufs NoBS-Tray-Icon („Was ist das?“) → NoBS macht sofort einen Screenshot, bevor das Fenster weggeklickt wird.
• Lokales Windows-OCR ab Werk: Windows 10 und 11 bringen mit der nativen Windows.Media.Ocr-API (direkt aus PowerShell oder Rust ansprechbar!) bereits eine extrem schnelle, 100 % lokale Texterkennung mit – ganz ohne Cloud und ohne zusätzliche KI-Bibliotheken.
• Der „Scharfschützen-Effekt“ für die Collectors: Sobald OCR aus dem Screenshot den Text, den Fenstertitel, den Prozessnamen (Get-Process des aktiven Fensters!) und die Uhrzeit extrahiert hat, müssen die Collectors nicht mehr blind das ganze System durchwühlen. Sie suchen gezielt im Zeitfenster ± 60 Sekunden um diesen einen Prozess und Fehlercode herum.

Die ideale Benutzerführung (Beides vereint)

Am besten funktioniert genau das Zusammenspiel beider Varianten:
• Schlafendes Tray-Icon (Null Ressourcenverbrauch): Verbraucht im Leerlauf praktisch nichts. Ein Klick (oder Rechtsklick → „Bildschirm prüfen“) friert den aktuellen Bildschirm ein, liest den Text und das aktive Fenster aus und startet gezielt die Analyse.
• On-Demand-Hauptfenster: Wenn die Meldung schon weg ist (z. B. nach einem Neustart oder Bluescreen), öffnet man NoBS ganz normal, tippt in zwei Worten ein („Windows Update hängt“ oder „Drucker geht nicht“) oder zieht einen gespeicherten Screenshot rein – und der Harness durchsucht die letzten Stunden der Logs.
Das fügt sich nahtlos in deine Facts First- und Offline First-Architektur ein, weil auch der Screenshot + OCR nichts weiter ist als ein weiterer Collector (Fenstertitel + Prozess-ID + OCR-Text + Zeitstempel).
