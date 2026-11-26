# NoBS – Fallbeispiel-Sammlung (Real-World Reference Cases)

Diese Sammlung dokumentiert reale Windows-Diagnose- und Behebungsszenarien aus produktiven Unternehmens- und Behördenumgebungen. Jedes Fallbeispiel folgt der **NoBS-Architektur** (*Fakten zuerst → Korrelation → Beweis → Sicherer Behebungsplan → Audit*).

---

## Fall 01: `NOBS-APPX-001` – System-Apps (Snipping Tool) starten nach Update-Abbruch nicht mehr

### 1. Ausgangslage & Kontext
* **Symptom:** Mehrere integrierte Windows-11-Anwendungen (Snipping Tool, Rechner, Terminal, Kamera, Microsoft Store) öffnen sich nicht mehr.
* **Benutzer-Fehlermeldung:** *„Diese App kann nicht geöffnet werden.“* (ohne Fehlercode, ohne Protokollhinweis).
* **Umgebung:** Windows 11 Enterprise/Pro in einer Active-Directory-Domäne mit restriktiver Web-Proxy-Filterung, deaktiviertem öffentlichen Microsoft Store (`RemoveWindowsStore = 1`) und Mehrbenutzer-Anmeldungen.

---

### 2. Endanwender-Ansicht (Die 5 Kernfragen)

1. **Was ist passiert?**
   Das Snipping Tool und einige weitere eingebaute Windows-Programme können derzeit nicht gestartet werden, weil ein gemeinsamer Systembaustein nach einem unterbrochenen Update als beschädigt markiert wurde.
2. **Warum ist es passiert?**
   Während einer Hintergrundaktualisierung wurde der Vorgang unterbrochen (z. B. durch einen Neustart oder eine Proxy-Blockade). Windows hat daraufhin den gemeinsamen Benutzeroberflächen-Baustein (`Microsoft.UI.Xaml.2.8`) gesperrt, und wegen der Unternehmensrichtlinien konnte Windows die Reparaturdatei nicht selbstständig aus dem Internet nachladen.
3. **Ist mein Computer kaputt?**
   Nein. Es liegt kein Hardwaredefekt vor – es handelt sich lediglich um einen feststeckenden Software-Status in der Windows-App-Verwaltung.
4. **Kann ich dabei Daten verlieren?**
   Nein. Deine persönlichen Dateien, Dokumente und Einstellungen sind vollständig sicher und werden bei der Behebung nicht verändert.
5. **Was kann dagegen getan werden?**
   Der fehlerhafte Sperrstatus in der Windows-Registrierung wird auf `0` zurückgesetzt und der App-Bereitstellungsdienst neu gestartet. Zusätzlich wird die Gruppenrichtlinie so angepasst, dass Windows Systembausteine künftig wieder sauber verwalten kann.

---

### 3. Technische Beweiskette (Facts First)

| Quelle | Rohbefund / Evidenz | Bedeutung |
| :--- | :--- | :--- |
| **`Get-AppxPackage`** | `Microsoft.ScreenSketch` → `Status: DependencyIssue` | Nicht das Snipping Tool selbst ist defekt, sondern eine seiner Abhängigkeiten. |
| **`AppxManifest.xml`** | Benötigt `Microsoft.VCLibs.140.00`, `Microsoft.UI.Xaml.2.8`, `Microsoft.WindowsAppRuntime.2` | Abgleich der exakten Mindestversionen gegen den lokalen Bestand. |
| **`Get-AppxPackage` (Frameworks)** | `Microsoft.UI.Xaml.2.8` (`8.2511.26001.0`) → `Status: Modified, NeedsRemediation` | **Hauptursache:** Zentrales UI-Framework ist als beschädigt/verändert markiert; alle abhängigen Apps fallen im Domino-Effekt aus. |
| **`Remove-AppxPackage -AllUsers`** | Fehler `0x80073D19` (`ERROR_DEPLOYMENT_BLOCKED_BY_USER_LOG_OFF`) | Das beschädigte Paket lässt sich nicht entfernen, weil es noch im Profil eines abgemeldeten/getrennten Domänenbenutzers registriert ist. |
| **Registry (`StateChange\PackageList`)** | `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList\Microsoft.UI.Xaml.2.8_...` → `PackageStatus != 0` | Persistentes Status-Flag, das die Ausführung der Laufzeitbibliothek blockiert. |
| **Registry (`Policies\WindowsStore`)** | `RemoveWindowsStore = 1`, `AutoDownload = 4`, `RequirePrivateStoreOnly = 1` | Altlasten aus Group Policy Preferences (`Element entfernen = Nein`) blockieren den Store-Dienst und verhindern Hintergrund-Selbstheilungen. |

---

### 4. Ursachen-Korrelation
* **Konfidenz:** `98 %`
* **Zusammenfassung:** Ein unterbrochenes Update hat `Microsoft.UI.Xaml.2.8` in den Zustand `Modified, NeedsRemediation` versetzt. Eine automatische Selbstheilung scheiterte an der Kombination aus Web-Proxy, deaktiviertem Store-Dienst (`RemoveWindowsStore = 1` / `AutoDownload = 4`) und der Mehrbenutzer-Sperre (`0x80073D19`).

---

### 5. Behebungs- & Präventionsplan (Offline-First & HITL)

* **Risikobewertung:** Niedrig (kein Neustart erzwungen, keine Benutzerdaten betroffen).
* **Rollback-Plan:** Vorheriger Export des Registry-Zweigs `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList` als `.reg`-Backup.

#### Schritt A: Akute Behebung (Offline-Reparatur auf dem Client)
1. Fehlerhafte `PackageStatus`-Flags unter `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList` auf `0` zurücksetzen.
2. Dienst `AppXSvc` neu starten, damit die Statusänderung ohne Systemneustart wirksam wird.
3. Bei Bedarf Framework-Pakete und `Microsoft.ScreenSketch` im Kontext des angemeldeten Benutzers neu registrieren (`Add-AppxPackage -DisableDevelopmentMode -Register`).

#### Schritt B: Dauerhafte Prävention (GPO-Bereinigung)
1. Klebende GPP-Registry-Altlasten (`RemoveWindowsStore`, `AutoDownload`, `DisableOSUpgrade`) aktiv über Group Policy Preferences (*Aktion: Löschen*) entfernen.
2. Ausschließlich **`RequirePrivateStoreOnly = 1`** (*Nur privaten Store im Microsoft Store anzeigen = Aktiviert*) setzen, damit der öffentliche App-Katalog für Benutzer gesperrt bleibt, während Windows System-Frameworks im Hintergrund wieder regulär pflegen darf.

---

## Fall 02: `NOBS-WINGET-002` – Inkonsistenter `winget`-Status & Berechtigungsisolation in der Domäne

### 1. Ausgangslage & Kontext
* **Symptom:** Der Windows-Paket-Manager (`winget`) meldet auf einem Teil der Domänenrechner *„Windows-Paket-Manager ist deaktiviert“* (`35` von `89` geprüften Clients), während er auf anderen Rechnern aktiv ist. In Remote-Admin-Sitzungen (`Enter-PSSession` / `SYSTEM`) wird `winget` zudem nicht als Befehl erkannt oder schlägt mit *„Zugriff verweigert“* bzw. UAC-Fehlern fehl.
* **Umgebung:** Active Directory mit separaten Admin-Konten (Over-the-Shoulder-UAC), Endpoint-Detection-and-Response (EDR) und historisch gewachsenem OS-Deployment.

---

### 2. Endanwender-Ansicht (Die 5 Kernfragen)

1. **Was ist passiert?**
   Der Windows-Paket-Manager (`winget`) war auf einem Teil der Arbeitsplatzrechner durch eine alte Sicherheitseinstellung abgeschaltet und konnte in administrativen Remote-Sitzungen nicht direkt aufgerufen werden.
2. **Warum ist es passiert?**
   Bei früheren Windows-Installationen wurde einmalig ein Sperrwert in die Registrierung geschrieben, der jedoch in keiner aktuellen Gruppenrichtlinie mehr verwaltet wird. Zusätzlich ist `winget` als benutzerbezogenes App-Paket umgesetzt, weshalb separate Admin-Konten keinen automatischen Zugriff auf den Befehlsalias haben.
3. **Ist mein Computer kaputt?**
   Nein. Es handelt sich um eine reine Konfigurationsabweichung zwischen älteren und neueren Rechnerinstallationen.
4. **Kann ich dabei Daten verlieren?**
   Nein. Es werden keine Benutzerdaten verändert.
5. **Was kann dagegen getan werden?**
   Der veraltete Sperrwert wird auf allen betroffenen Rechnern per PowerShell einheitlich freigeschaltet, und administrative Skripte sprechen die `winget.exe` über ihren direkten Paketpfad an.

---

### 3. Technische Beweiskette (Facts First)

| Quelle | Rohbefund / Evidenz | Bedeutung |
| :--- | :--- | :--- |
| **Registry (`Policies\AppInstaller`)** | `EnableAppInstaller = 0x0` (trotz `EnableWindowsPackageManager = 0x1`) | `EnableAppInstaller = 0` überstimmt die Paket-Manager-Freigabe und sperrt `winget` komplett. |
| **`gpresult` & SYSVOL-Scan** | `0` Treffer in `Registry.pol` / `Registry.xml` und `0` Treffer in SCCM Baselines | Keine aktive GPO oder Baseline setzt den Wert – es ist eine Altlast aus früheren OSD-Tasksequenzen. |
| **Zugriffstest (`reg.exe` vs. PowerShell)** | `reg add` → `Zugriff verweigert` (trotz `Administratoren: FullControl`); `Set-ItemProperty` → Erfolgreich | EDR-/Endpoint-Schutz blockiert direkte Schreibzugriffe über `reg.exe` auf `Policies`-Schlüssel, erlaubt aber PowerShell/`SYSTEM`. |
| **Remote-Sitzung (`conrad_admin` / `SYSTEM`)** | `winget` nicht erkannt; Direktaufruf aus `WindowsApps` → `Zugriff verweigert` vor `Add-AppxPackage -Register` | App-Execution-Aliases (`%LocalAppData%\Microsoft\WindowsApps`) existieren nur für registrierte Benutzerkonten und nicht in WinRM-/`SYSTEM`-Sitzungen. |
| **Installation (`winget upgrade`)** | `Exitcode: 1` / `6710886` (*„Es wird ein Prompt erwartet“*) bei Over-the-Shoulder-UAC | Geschachtelte UAC-Dialoge und Benutzerprofil-Isolation verhindern Installationen zwischen Standard-User-Desktop und separatem Admin-Token. |

---

### 4. Ursachen-Korrelation
* **Konfidenz:** `96 %`
* **Zusammenfassung:** Zwei unabhängige Ebenen überlagern sich: (1) Eine nicht mehr per GPO verwaltete OSD-Altlast (`EnableAppInstaller = 0`) auf 39 % der Clients und (2) die AppContainer-/Profil-Architektur von `DesktopAppInstaller`, die in Remote- und getrennten Admin-Sitzungen eine explizite Paketregistrierung sowie die Trennung zwischen `--scope user` und `--scope machine` erfordert.

---

### 5. Behebungsplan & Audit-Ergebnis

1. **Bestandsaufnahme & Bereinigung per WinRM (`Invoke-Command`):**
   * Abfrage aller aktiven Clients einer OU (`LastLogonDate` < 14 Tage, kurzes 5-Sekunden-WinRM-Timeout).
   * Alle `35` betroffenen Rechner von `EnableAppInstaller = 0` auf `1` vereinheitlicht (`89/89` erreichbare Clients danach einheitlich aktiv).
2. **Standardisierung für Remote-Admin-Skripte:**
   * Sicherstellen der Paketregistrierung (`Add-AppxPackage -DisableDevelopmentMode -Register`) oder Ausführung im `SYSTEM`-Kontext (z. B. über SCCM Client Center *Run PS*).
   * Strikte Trennung zwischen Benutzer-Updates (`--scope user` im Kontext des angemeldeten Benutzers) und System-Updates (`--scope machine` als `SYSTEM`).
