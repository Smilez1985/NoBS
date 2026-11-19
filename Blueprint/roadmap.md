# NoBS — Roadmap

Hinweis: `design.md` enthält den Gesamtbauplan.

Die Roadmap erfasst fokussiert offene und unreleased Punkte.

Erledigtes wird nach `CHANGELOG.md` verschoben.

Die vollständigen technischen Details zu einzelnen Modulen und Repositories können in den jeweiligen Quellprojekten nachgelesen werden.

---

# 1. Kern-Architektur & Basis-Bausteine (Integration)

## Projekt-Grundsätze

- [ ] SSOT etablieren (`design.md`)
- [ ] Versionierungsmodell definieren
- [ ] Audit-Modell definieren
- [ ] Internes JSON-Datenmodell definieren
- [ ] Logging-Standard definieren

---

# 2. Collector Layer

## Eventlog Collector

- [ ] System Eventlog lesen
- [ ] Application Eventlog lesen
- [ ] Setup Eventlog lesen
- [ ] Security Eventlog lesen
- [ ] Severity-Klassifizierung

---

## Reliability Collector

- [ ] Win32_ReliabilityRecords integrieren
- [ ] Historie normalisieren
- [ ] Fehler gruppieren

---

## Windows Update Collector

- [ ] WindowsUpdateClient auslesen
- [ ] Update-Historie erfassen
- [ ] Fehlercodes erfassen
- [ ] Installationsfehler erfassen

---

## CBS Collector

- [ ] CBS.log Parser
- [ ] Korruptionsindikatoren erkennen
- [ ] Reparaturhinweise extrahieren

---

## DISM Collector

- [ ] DISM Log Parser
- [ ] Komponentenstore-Zustand erfassen

---

## Hyper-V Collector

- [ ] VM Status erfassen
- [ ] VMMS Logs erfassen
- [ ] Worker Logs erfassen
- [ ] Switch-Konfiguration erfassen
- [ ] Host-Konfiguration erfassen

---

## Defender Collector

- [ ] Schutzstatus erfassen
- [ ] Bedrohungen erfassen
- [ ] Quarantäne erfassen

---

## Service Collector

- [ ] Dienststatus erfassen
- [ ] Fehlgeschlagene Starts erkennen
- [ ] Abhängigkeitsfehler erkennen

---

## Registry Collector

- [ ] Read-Only Analyse
- [ ] Snapshot erstellen
- [ ] Differenzanalyse vorbereiten

---

## WMI/CIM Collector

- [ ] Betriebssystemdaten
- [ ] Hardwaredaten
- [ ] Netzwerkdaten
- [ ] Benutzerdaten
- [ ] Prozessdaten

---

# 3. Normalizer

## Gemeinsames Faktenmodell

- [ ] Einheitliches Eventmodell
- [ ] Einheitliches Fehlerobjekt
- [ ] Einheitliche Severity-Klassen
- [ ] Zeitstempel normalisieren

---

## Datenformate

- [ ] JSON Export
- [ ] Audit JSON
- [ ] Report JSON

---

# 4. Facts Database

## Lokale Persistenz

- [ ] SQLite evaluieren
- [ ] Struktur definieren
- [ ] Faktenhistorie speichern

---

## Snapshot-System

- [ ] System-Snapshot
- [ ] Vorher/Nachher Vergleich
- [ ] Delta-Berechnung

---

# 5. Correlation Engine

## Basis-Korrelation

- [ ] Eventketten erkennen
- [ ] Fehlercluster bilden
- [ ] Zeitliche Korrelation

---

## Ursache-Folge-Modell

- [ ] Primärfehler identifizieren
- [ ] Folgefehler identifizieren
- [ ] Confidence-Modell definieren

---

## Mustererkennung

- [ ] Bekannte Windows-Update Probleme
- [ ] Hyper-V Probleme
- [ ] Dienstprobleme
- [ ] Treiberprobleme

---

# 6. Research Engine

## Externe Informationsquellen

- [ ] Microsoft Learn
- [ ] Microsoft KB Artikel
- [ ] GitHub
- [ ] Herstellerdokumentationen

---

## Evidenzmodell

- [ ] Quellen speichern
- [ ] Quellen bewerten
- [ ] Quellen referenzieren

---

# 7. LLM Planner

## Analyse

- [ ] Fakten korrelieren
- [ ] Ursachen bewerten
- [ ] Confidence erzeugen

---

## Planung

- [ ] Reparaturplan erstellen
- [ ] Alternativen erzeugen
- [ ] Risiken bewerten

---

## Dokumentation

- [ ] Menschliche Zusammenfassung erzeugen
- [ ] RCA-Bericht erzeugen

---

# 8. Dry Run Framework

## Planvalidierung

- [ ] Ausführbarkeit prüfen
- [ ] Abhängigkeiten prüfen
- [ ] Risiken prüfen

---

## Rollback

- [ ] Rollback erstellen
- [ ] Rollback validieren

---

# 9. Human-In-The-Loop

## Benutzerinteraktion

- [ ] Zustimmen
- [ ] Ablehnen
- [ ] Mehr Details
- [ ] Plan verbessern
- [ ] Alternative suchen

---

## Transparenz

- [ ] Evidenz anzeigen
- [ ] Quellen anzeigen
- [ ] Risiken anzeigen

---

# 10. Executor

## PowerShell

- [ ] Skriptausführung
- [ ] Rückgabewerte erfassen

---

## Windows Reparaturen

- [ ] Dienste
- [ ] Registry
- [ ] Windows Update
- [ ] DISM
- [ ] SFC
- [ ] Hyper-V

---

# 11. Audit Layer

## Änderungsprotokoll

- [ ] Aktionen protokollieren
- [ ] Ergebnisse protokollieren
- [ ] Benutzerentscheidungen protokollieren

---

## Berichte

- [ ] JSON Audit
- [ ] Markdown Audit
- [ ] RCA Report

---

# 12. MVP v0.1.0

Ziel:

NoBS kann Windows-Probleme lesen und strukturiert darstellen.

Enthalten:

- [ ] Eventlog Collector
- [ ] Reliability Collector
- [ ] Windows Update Collector
- [ ] JSON Export
- [ ] Markdown Report

Nicht enthalten:

- [ ] Reparatur
- [ ] HITL
- [ ] LLM
- [ ] Webrecherche

---

# 13. v0.2.0

Ziel:

Erste Ursachenanalyse.

Enthalten:

- [ ] Correlation Engine
- [ ] Fehlercluster
- [ ] Confidence Scoring

---

# 14. v0.3.0

Ziel:

LLM-basierte Analyse.

Enthalten:

- [ ] Lokales LLM
- [ ] RCA-Berichte
- [ ] Reparaturvorschläge

---

# 15. v0.4.0

Ziel:

Webbasierte Evidenz.

Enthalten:

- [ ] Microsoft Learn Recherche
- [ ] KB Recherche
- [ ] Quellenvalidierung

---

# 16. v0.5.0

Ziel:

Dry Run Planer.

Enthalten:

- [ ] Reparaturplan
- [ ] Risiken
- [ ] Rollback

---

# 17. v0.6.0

Ziel:

Human-In-The-Loop.

Enthalten:

- [ ] Zustimmung
- [ ] Ablehnung
- [ ] Plananpassung

---

# 18. v0.7.0

Ziel:

Kontrollierte Reparaturen.

Enthalten:

- [ ] PowerShell Executor
- [ ] Auditierung
- [ ] Ergebnisprüfung

---

# 19. v1.0.0

NoBS kann:

- Windows analysieren
- Ursachen bestimmen
- Evidenz sammeln
- Quellen recherchieren
- Reparaturpläne erzeugen
- Dry Runs durchführen
- Benutzer einbinden
- Reparaturen ausführen
- Änderungen vollständig auditieren

Status:

- [ ] Nicht begonnen

  ---

# Architekturentscheidung

Primärsprache:
- PowerShell

Sekundärsprache:
- Python

Begründung:
Windows ist die Zielplattform.
Collector, Executor, Hyper-V, Registry und WMI sind in PowerShell nativ verfügbar.

---

