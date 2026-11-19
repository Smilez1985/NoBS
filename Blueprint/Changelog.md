# Changelog

Siehe https://keepachangelog.com/de/1.1.0/

Ausnahme:
Wir haben im Changelog keine "Unreleased"-Sparte.
Offene und geplante Arbeiten gehören nach `roadmap.md`.

Jeder Changelog-Eintrag benötigt:

- Versionsnummer
- Timestamp
- Fertigstellung
- Teststatus
- Commit-Status

Einträge werden ausschließlich für vollständig abgeschlossene Arbeiten erstellt.

"Fertig" bedeutet:

- implementiert
- verdrahtet
- getestet
- dokumentiert
- commitbereit

Zeitformat:

```text
TT-MM-JJJJ_HH-MM-SS
```

Beispiel:

```text
19-11-2026_10-00-00
```

---

## [0.0.1] - 19-11-2026_10-00-00

### Added

- Projekt erstellt
- Repository erstellt
- Blaupause-Struktur definiert
- `design.md` angelegt
- `roadmap.md` angelegt
- `CHANGELOG.md` angelegt
- SSOT-Prinzip eingeführt
- Versionierungsrichtlinien definiert
- Auditierungsrichtlinien definiert

### Tested

- Dokumentationsstruktur geprüft

### Notes

- Initiales Projektgerüst
- Keine Implementierung enthalten

---

## Änderungsrichtlinien

### Added

Neue Funktionen.

Beispiele:

```text
EventLog Collector
Hyper-V Collector
Audit Engine
LLM Planner
```

---

### Changed

Verhalten bestehender Funktionen wurde verändert.

Beispiele:

```text
JSON Schema erweitert
Korrelation verbessert
Audit Format geändert
```

---

### Fixed

Fehlerkorrekturen.

Beispiele:

```text
Eventlog Parsing Fehler behoben
Hyper-V Erkennung korrigiert
Falsch-positive Erkennung reduziert
```

---

### Removed

Entfernte Funktionen.

Beispiele:

```text
Veraltete Schnittstelle entfernt
Legacy Collector entfernt
```

---

### Security

Sicherheitsrelevante Änderungen.

Beispiele:

```text
Dry Run Pflicht eingeführt
PowerShell Sandbox erweitert
Web-Recherche eingeschränkt
```

---

# Beispiel zukünftiger Einträge

## [0.1.0] - 21-11-2026_14-30-00

### Added

- Eventlog Collector
- Reliability Collector
- Windows Update Collector
- Gemeinsames JSON-Datenmodell
- Erster Markdown-Report

### Tested

- Windows 11 24H2
- Hyper-V Host
- Virtuelle Maschine

### Notes

- Erste lauffähige Datensammlung
- Noch keine Ursachenanalyse
- Noch keine Reparaturfunktionen

---

## [0.2.0] - 24-11-2026_18-45-00

### Added

- Correlation Engine
- Ereignisketten-Erkennung
- Fehlercluster-Erkennung
- Confidence Scoring

### Tested

- Windows Update Fehler
- Dienstfehler
- Hyper-V Fehler

### Notes

- Erste Root-Cause-Analysen verfügbar

---

## [0.3.0] - 01-12-2026_20-15-00

### Added

- LLM Planner
- RCA-Berichte
- Reparaturvorschläge

### Changed

- Correlation Engine erweitert

### Tested

- Lokales LLM
- Offline Betrieb

### Notes

- Erste KI-gestützte Ursachenanalyse

---

## [1.0.0] - TBD

### Added

- Vollständiger Collector Stack
- Correlation Engine
- Research Engine
- LLM Planner
- Dry Run Framework
- Human-In-The-Loop Workflow
- Executor
- Audit Engine

### Tested

- End-to-End Workflow

### Notes

- Erste produktionsreife Version von NoBS
- No More Bullshit Windows Diagnostics and Remediation
