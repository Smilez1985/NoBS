# NoBS — Roadmap

Hinweis: `design.md` enthält den Gesamtbauplan.

Die Roadmap erfasst fokussiert offene und unreleased Punkte.

Erledigtes wird nach `CHANGELOG.md` verschoben.

Die vollständigen technischen Details zu den einzelnen Modulen und Repositories können in den jeweiligen Quellprojekten nachgelesen werden.

---

# 0. Architekturentscheidungen

## Technologie-Stack

### PowerShell

Verantwortlich für:

- Eventlogs
- Registry
- Hyper-V
- Windows Update
- Services
- WMI
- CIM
- DISM
- SFC

Rolle:

- Collector
- Executor
- Verification

---
Primärsprache:
- PowerShell

Sekundärsprache:
- Python

Begründung:
Windows ist die Zielplattform.
Collector, Executor, Hyper-V, Registry und WMI sind in PowerShell nativ verfügbar.

### Python

Verantwortlich für:

- Correlation Engine
- Research Engine
- LLM Planner
- Audit Engine
- Context Management
- MCP Clients

---

### Rust

Verantwortlich für:

- MCP Server
- ACP Server
- State Management
- Packaging
- Distribution
- Config Management
- Windows Service
- Caching
- IPC Layer

---

## Architekturprinzipien

- [ ] Facts First
- [ ] Human In The Loop
- [ ] Audit First
- [ ] Offline First
- [ ] Functional Verification Over Exit Codes
- [ ] MCP First Architecture

---

## Sicherheitsmodell

### MCP Trennung

- [ ] Collector MCP
- [ ] Research MCP
- [ ] Planner MCP
- [ ] Executor MCP

### Plan Signing

- [ ] Plan Hashing
- [ ] HMAC Signing
- [ ] Session Binding
- [ ] Replay Protection
- [ ] Nonce Handling
- [ ] Expiration Validation

### Executor Security

- [ ] Executor Locking
- [ ] Signature Validation
- [ ] Nonce Validation
- [ ] Plan Validation
- [ ] Verification Enforcement

---

# 1. Kern-Architektur & Basis-Bausteine

## Projekt-Grundsätze

- [ ] SSOT etablieren
- [ ] Logging-Standard definieren
- [ ] Audit-Modell definieren
- [ ] Context-Management definieren
- [ ] Recovery-Modell definieren

---

## Datenmodell

### Facts Schema

- [ ] Event Schema
- [ ] Evidence Schema
- [ ] Source Schema
- [ ] Correlation Schema

---

### Plan Schema

- [ ] Plan Definition
- [ ] Rollback Definition
- [ ] Confidence Definition
- [ ] Verification Definition

---

### Audit Schema

- [ ] Analysis Audit
- [ ] Execution Audit
- [ ] Verification Audit

---

# 2. Datenhaltung

## SQLite

- [ ] Datenbankmodell definieren
- [ ] Migration Framework definieren

---

## Tabellen

### facts

- [ ] Fakten speichern
- [ ] Historisierung

---

### sources

- [ ] Quellen speichern

---

### correlations

- [ ] Zusammenhänge speichern

---

### plans

- [ ] Reparaturpläne speichern

---

### executions

- [ ] Ausführungen speichern

---

### audits

- [ ] Auditdaten speichern

---

### used_nonces

- [ ] Replay Protection

---

### checkpoints

- [ ] Recovery
- [ ] Fortsetzen von Agentläufen

---

# 3. Collector Layer

## Eventlog Collector

- [ ] System Log
- [ ] Application Log
- [ ] Setup Log
- [ ] Security Log

---

## Reliability Collector

- [ ] Win32_ReliabilityRecords
- [ ] Historienanalyse

---

## Windows Update Collector

- [ ] Update Status
- [ ] Fehlercodes
- [ ] Installationsfehler
- [ ] Rollbacks

---

## CBS Collector

- [ ] CBS Parser
- [ ] Korruptionsindikatoren

---

## DISM Collector

- [ ] Komponentenstore Analyse
- [ ] Reparaturstatus

---

## Service Collector

- [ ] Status erfassen
- [ ] Fehlerhafte Dienste

---

## Registry Collector

- [ ] Read Only Analyse
- [ ] Snapshot Support

---

## WMI/CIM Collector

- [ ] Hardware
- [ ] Betriebssystem
- [ ] Netzwerk
- [ ] Benutzer
- [ ] Prozesse

---

## Hyper-V Collector

- [ ] VMs
- [ ] VMMS
- [ ] Worker
- [ ] Switches
- [ ] Host

---

## Defender Collector

- [ ] Bedrohungen
- [ ] Schutzstatus
- [ ] Quarantäne

---

# 4. Normalizer

## Gemeinsames Faktenmodell

- [ ] Eventlog → Fact
- [ ] Reliability → Fact
- [ ] Update → Fact
- [ ] Hyper-V → Fact

---

## Datenformate

- [ ] JSON Export
- [ ] Report JSON
- [ ] Audit JSON

---

# 5. Correlation Engine

## Evidence Graph

- [ ] Fakten verknüpfen
- [ ] Beweisketten bilden

---

## Root Cause Analyse

- [ ] Primärfehler erkennen
- [ ] Folgefehler erkennen
- [ ] Confidence berechnen

---

## Mustererkennung

- [ ] Windows Update
- [ ] Hyper-V
- [ ] Dienste
- [ ] Treiber
- [ ] Defender

---

# 6. Research Engine

## Lokale Wissensbasis

- [ ] Known Issues
- [ ] Known Fixes
- [ ] Verified Runbooks

---

## Externe Recherche

- [ ] Microsoft Learn
- [ ] Microsoft KB
- [ ] Herstellerdokumentation
- [ ] GitHub

---

## Quellbewertung

- [ ] Quellen speichern
- [ ] Quellen gewichten
- [ ] Quellen referenzieren

---

# 7. MCP Infrastruktur

## Rust MCP Core

- [ ] MCP Server Grundgerüst
- [ ] Tool Registry
- [ ] Capability Modell

---

## Collector MCP

- [ ] get_recent_errors()
- [ ] get_windows_update_status()
- [ ] get_reliability_summary()

---

## Research MCP

- [ ] search_ms_docs()
- [ ] search_kb_articles()
- [ ] search_github()

---

## Planning MCP

- [ ] build_repair_plan()
- [ ] build_rollback_plan()
- [ ] estimate_risk()

---

## Verification MCP

- [ ] verify_windows_update()
- [ ] verify_service_health()
- [ ] verify_hyperv_health()

---

## Executor MCP

- [ ] repair_windows_update()
- [ ] restart_service()
- [ ] modify_registry()
- [ ] repair_component_store()

---

# 8. ACP Infrastruktur

## ACP Core

- [ ] ACP Server Grundgerüst
- [ ] Agent Discovery
- [ ] Capability Exchange

---

## Spätere Agenten

- [ ] Research Agent
- [ ] Audit Agent
- [ ] Hyper-V Agent
- [ ] Update Agent

---

# 9. LLM Planner

## Analyse

- [ ] Evidenz auswerten
- [ ] Ursachen bestimmen
- [ ] Confidence erzeugen

---

## Planung

- [ ] Reparaturplan erzeugen
- [ ] Alternativen erzeugen
- [ ] Risiken bewerten

---

## Dokumentation

- [ ] RCA Bericht
- [ ] Management Summary
- [ ] Technischer Bericht

---

# 10. Dry Run System

## Dry Run

- [ ] Aktionen simulieren
- [ ] Auswirkungen darstellen

---

## Rollback

- [ ] Rollback erzeugen
- [ ] Rollback validieren

---

# 11. Human In The Loop

## Benutzerentscheidungen

- [ ] Zustimmen
- [ ] Ablehnen
- [ ] Plan verbessern
- [ ] Alternative suchen
- [ ] Details anzeigen

---

## Approval Gateway

- [ ] Signierung
- [ ] Session Binding
- [ ] Timeout Handling

---

# 12. Executor

## PowerShell Executor

- [ ] PowerShell Ausführung
- [ ] Ergebnis erfassen

---

## Unterstützte Reparaturen

- [ ] Dienste
- [ ] Registry
- [ ] Hyper-V
- [ ] DISM
- [ ] SFC
- [ ] Windows Update

---

# 13. Verification Engine

## Verifikation

- [ ] Problem erneut prüfen
- [ ] Funktionstest durchführen
- [ ] Erfolg nachweisen

---

## Failure Handling

- [ ] Verification Failure
- [ ] Rollback Vorschlagen
- [ ] Plan verbessern

---

# 14. Recovery & Checkpoints

## Checkpoints

- [ ] Analyse abgeschlossen
- [ ] Recherche abgeschlossen
- [ ] Plan erstellt
- [ ] Plan freigegeben
- [ ] Reparatur durchgeführt
- [ ] Verifiziert

---

## Recovery

- [ ] Lauf fortsetzen
- [ ] Zustand wiederherstellen

---

# 15. Audit Layer

## Auditierung

- [ ] Toolaufrufe
- [ ] Benutzerentscheidungen
- [ ] Reparaturen
- [ ] Verifikationen

---

## Berichte

- [ ] JSON Audit
- [ ] Markdown Audit
- [ ] RCA Report

---

# 16. Learning Engine

## Runbook Learning

- [ ] Erfolgreiche Reparaturen erkennen
- [ ] Reparaturen bewerten
- [ ] Runbooks erzeugen

---

## Skill Promotion

- [ ] Wiederholte Lösungen erkennen
- [ ] MCP Tool Kandidaten erzeugen

---

# MVP v0.1.0

Ziel:

NoBS kann Systemdaten sammeln, normalisieren und als Bericht ausgeben.

Enthalten:

- [ ] Eventlog Collector
- [ ] Reliability Collector
- [ ] Windows Update Collector
- [ ] JSON Normalizer
- [ ] SQLite Facts Tabelle
- [ ] Markdown Report
- [ ] JSON Report

Nicht enthalten:

- [ ] LLM
- [ ] MCP
- [ ] ACP
- [ ] Reparaturen
- [ ] HITL

---

# v0.2.0

Ziel:

Persistente Faktenhaltung.

Enthalten:

- [ ] SQLite Schema
- [ ] Fact History
- [ ] Snapshot System

---

# v0.3.0

Ziel:

Rust Core Infrastruktur.

Enthalten:

- [ ] Rust Core
- [ ] Config Management
- [ ] Logging
- [ ] State Management

---

# v0.4.0

Ziel:

MCP Read-Only Infrastruktur.

Enthalten:

- [ ] MCP Core
- [ ] Collector MCP
- [ ] Research MCP

---

# v0.5.0

Ziel:

Root Cause Analysis.

Enthalten:

- [ ] Correlation Engine
- [ ] Evidence Graph
- [ ] Confidence Modell

---

# v0.6.0

Ziel:

LLM Planner.

Enthalten:

- [ ] Ursachenanalyse
- [ ] Reparaturplanung
- [ ] RCA Berichte

---

# v0.7.0

Ziel:

Research Engine.

Enthalten:

- [ ] Microsoft Learn
- [ ] KB Recherche
- [ ] GitHub Recherche

---

# v0.8.0

Ziel:

Kryptografische Sicherheit.

Enthalten:

- [ ] Plan Signing
- [ ] Replay Protection
- [ ] Nonce System
- [ ] Executor Locking

---

# v0.9.0

Ziel:

Executor.

Enthalten:

- [ ] PowerShell Executor
- [ ] Registry Reparaturen
- [ ] Service Reparaturen
- [ ] Windows Update Reparaturen

---

# v1.0.0

Ziel:

Vollständiger End-to-End Workflow.

Enthalten:

- [ ] Facts Collection
- [ ] Correlation Engine
- [ ] Research Engine
- [ ] LLM Planner
- [ ] MCP Infrastruktur
- [ ] HITL
- [ ] Plan Signing
- [ ] Executor
- [ ] Verification
- [ ] Audit
- [ ] Recovery

Status:

- [ ] Nicht begonnen

---

