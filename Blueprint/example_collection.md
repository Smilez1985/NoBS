# NoBS – Real-World Case Collection (`Example_Collection.md`)

> **Purpose:** Reference scenarios from real enterprise and public-sector Windows environments demonstrating how **NoBS** transforms opaque Windows error states into evidence-based root cause analysis, safe offline-first remediation, and auditable outcomes.

---

## Case 01: Built-in UWP Apps Fail to Launch (`DependencyIssue` / `Modified, NeedsRemediation`)

### 1. User Symptom
- **UI Message:** *"This app can't open"* (*„Diese App kann nicht geöffnet werden“*) when launching **Snipping Tool** (`Win + Shift + S`), Calculator, Terminal, or Microsoft Store.
- **Environment:** Domain-joined Windows 11 Enterprise client behind a restrictive corporate web proxy, with Microsoft Store and App Installer restricted by Group Policy (`RemoveWindowsStore = 1`, `AutoDownload = 4`).

---

### 2. Plain-Language End-User Output (NoBS 5-Question Principle)

1. **What happened?**
   Built-in Windows apps such as the Snipping Tool cannot start because a shared Windows user-interface component (`Microsoft.UI.Xaml.2.8`) is marked as incomplete in the system registry.
2. **Why did it happen?**
   A background update of a shared Windows component was interrupted, leaving an internal error flag (`Modified / NeedsRemediation`). Because company network rules block direct downloads from the Microsoft Store, Windows could not automatically download a fresh copy to heal itself.
3. **Is my computer broken?**
   No. This is purely a software configuration and update-state issue. Your hardware and operating system core are healthy.
4. **Can I lose any data?**
   No. Resetting the internal app status flag and restarting the Windows app deployment service (`AppXSvc`) does not touch personal files, settings, or documents.
5. **What can be done about it?**
   Reset the stuck `PackageStatus` flag for the affected runtime package in the Windows Registry to `0` and restart the `AppXSvc` service. Optionally, update Group Policy from hard-blocking the Store (`RemoveWindowsStore = 1`) to `RequirePrivateStoreOnly = 1` so Windows can maintain system components cleanly in the future.

---

### 3. Evidence & Correlation (Technical Details)

#### Collected System Facts
* **AppX Package State (`Get-AppxPackage`):**
  * `Microsoft.ScreenSketch` (`11.2609.15.0`) → `Status: DependencyIssue`
  * `Microsoft.WindowsCalculator`, `Microsoft.WindowsTerminal`, `Microsoft.SecHealthUI` → `Status: DependencyIssue`
  * `Microsoft.UI.Xaml.2.8` (`8.2511.26001.0`) → `Status: Modified, NeedsRemediation`
  * `Microsoft.UI.Xaml.2.8` (`8.2501.31001.0`) → `Status: Ok`
* **Package Removal Attempt (`Remove-AppxPackage -AllUsers`):**
  * Failed with **`0x80073D19`** (`ERROR_DEPLOYMENT_BLOCKED_BY_USER_LOG_OFF`) because the package is still staged/registered in profiles of other logged-off domain users on the shared workstation.
* **Registry State (`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList`):**
  * Key `Microsoft.UI.Xaml.2.8_8.2511.26001.0_x64__8wekyb3d8bbwe` has `PackageStatus != 0` (corresponds to `0x80073CFC` / `Modified`).
* **Policy State (`HKLM\SOFTWARE\Policies\Microsoft\WindowsStore`):**
  * `RemoveWindowsStore = 1` and `AutoDownload = 4` (persisted via Group Policy Preferences without *"Remove this item when it is no longer applied"*).

#### Correlation Logic
1. `Microsoft.ScreenSketch` is not broken itself; its manifest depends on `Microsoft.UI.Xaml.2.8 (>= 8.2501.31001.0)`.
2. Windows prefers the highest installed framework version (`8.2511.26001.0`), which is flagged `Modified, NeedsRemediation`.
3. Multi-user profile locks (`0x80073D19`) prevent uninstalling the newer version, and corporate proxy/GPO rules (`RemoveWindowsStore = 1`) block online self-remediation.
4. Clearing `PackageStatus` in `StateChange\PackageList` and restarting `AppXSvc` resolves the block **100% offline** without requiring a reboot or internet access.

---

### 4. Repair Plan & Governance (HITL + Audit)

```yaml
case_id: NOBS-APPX-001
confidence: 0.96
risk_level: Low
offline_capable: true
reboot_required: false
rollback_supported: true
```

#### Step 1: Backup & Reset Registry Flag (System Scope)
* **Backup:** Export `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList` to `%SystemDrive%\Temp\PackageList_Backup_<timestamp>.reg`.
* **Action:** Set `PackageStatus = 0` on all subkeys under `PackageList` where `PackageStatus != 0`.
* **Service Refresh:** Restart `AppXSvc` (`Restart-Service -Name AppXSvc -Force`).

#### Step 2: Preventive Domain Policy Hygiene (Optional / Admin Governance)
* Replace legacy `RemoveWindowsStore = 1` and `AutoDownload = 4` GP-Preference entries with explicit **Delete** actions.
* Enforce `RequirePrivateStoreOnly = 1` (Administrative Templates → Windows Components → Store) so end users remain blocked from public Store apps while Windows retains permission to service built-in frameworks.

#### Verification Criteria
* `Get-AppxPackage -AllUsers *Microsoft.UI.Xaml.2.8*` returns `Status: Ok`.
* `Get-AppxPackage *Microsoft.ScreenSketch*` returns `Status: Ok`.
* Snipping Tool (`ms-screenclip:`) launches without error.

---

## Case 02: Inconsistent `winget` Availability Across Domain Clients (`EnableAppInstaller`)

### 1. User Symptom
- **CLI Output:** *"Windows Package Manager is disabled"* or `winget` missing from `PATH` on a subset of domain workstations, while working on identical sibling machines.
- **GPO Confusion:** `gpresult /h` shows **0 matches** for `EnableAppInstaller` or `DesktopAppInstaller`, yet `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppInstaller\EnableAppInstaller` is set to `0x0` and `reg.exe add` fails with `Access Denied` even in an elevated Command Prompt.

---

### 2. Evidence & Correlation (Technical Details)

#### Collected System Facts
* **Policy Registry (`HKLM\SOFTWARE\Policies\Microsoft\Windows\AppInstaller`):**
  * `EnableWindowsPackageManager = 0x1`
  * `EnableAppInstaller = 0x0` (overrides `EnableWindowsPackageManager` and disables the entire CLI/installer)
* **GPO & SCCM Baseline Check:**
  * `gpresult` and `SYSVOL` (`Registry.pol` / `Registry.xml`) contain **no** active policy setting `EnableAppInstaller`.
  * SCCM DCM (`root\ccm\dcm:SMS_DesiredConfiguration`) shows no active compliance baseline enforcing the key.
  * Fleet query across 89 online clients in the same OU reveals configuration drift: `48` set to `1`, `7` not configured (active), and `35` stuck at `0` (legacy OSD task sequence hardening artifact).
* **Execution Context & EDR Behavior:**
  * Direct invocation of `reg.exe` is blocked by endpoint protection rules, whereas PowerShell `Set-ItemProperty` succeeds.
  * Under separate admin credentials (`Over-the-Shoulder UAC` / WinRM), `winget` is not in `$env:PATH` because App Execution Aliases reside in per-user `%LOCALAPPDATA%\Microsoft\WindowsApps`.

---

### 3. Repair Plan & Governance

```yaml
case_id: NOBS-WINGET-002
confidence: 0.94
risk_level: Low
offline_capable: true
reboot_required: false
rollback_supported: true
```

#### Action
1. **Normalize Fleet State:** Set `EnableAppInstaller = 1` via PowerShell (`Set-ItemProperty`) across affected clients or enforce via Group Policy Preferences (*Update*).
2. **Admin Session Invocation:** Register `Microsoft.DesktopAppInstaller` for the admin context or invoke `winget.exe` directly from its package installation path when running in WinRM / `SYSTEM` sessions.
3. **Scope Awareness:** Separate `--scope user` upgrades (run in standard user session) from `--scope machine` upgrades (run in elevated/SYSTEM session) to avoid UAC elevation deadlocks (`Exitcode: 1` / `6710886`).
