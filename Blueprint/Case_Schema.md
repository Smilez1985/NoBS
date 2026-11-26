# NoBS Diagnostic Case & Repair Plan Schema (v0.1 Draft)

## Purpose
This YAML/JSON-compatible schema defines the normalized structure for **Facts Collection**, **Root Cause Correlation**, **End-User Explanation**, and **HITL Repair Plans** within the NoBS agent harness.

---

## 1. Schema Definition (YAML Format)

```yaml
$schema: "https://nobs.local/schemas/diagnostic-case-v0.1.json"
case_metadata:
  case_id: string                  # Unique identifier (e.g., "NOBS-APPX-001")
  title: string                    # Short descriptive title
  category: enum                   # [AppX, WindowsUpdate, Networking, SecurityPolicy, Storage, HyperV, Other]
  environment_scope: enum          # [Standalone, EnterpriseDomain, AirGapped]
  offline_solvable: boolean        # True if remediation requires zero internet access
  created_at: datetime             # ISO-8601 timestamp

symptom:
  user_report: string              # Raw symptom reported by end user
  observed_errors:                 # Raw error codes or UI messages
    - code: string                 # e.g., "0x80073D19" or "DependencyIssue"
      source: string               # e.g., "Windows Shell", "PowerShell", "EventLog"
      message: string

evidence_collection:               # Output from normalized Data Collectors
  - fact_id: string                # e.g., "FACT-01"
    collector: enum                # [AppxCollector, RegistryCollector, EventLogCollector, PolicyCollector, ServiceCollector]
    target: string                 # Registry path, log channel, cmdlet, or file path
    observed_value: string         # Actual value found on system
    expected_value: string         # Healthy baseline value
    is_anomalous: boolean          # True if this fact indicates a fault

correlation:
  root_cause_summary: string       # Technical root cause in one sentence
  confidence_score: float          # 0.00 to 1.00
  reasoning_chain:                 # Step-by-step logical deduction linking facts
    - string
  ruled_out_hypotheses:            # Checked and disproven causes (prevents false positives)
    - hypothesis: string
      disproof_fact_id: string

end_user_explanation:              # Mandatory 5-Question Plain-Language Output
  what_happened: string
  why_it_happened: string
  is_hardware_broken: boolean
  hardware_statement: string
  can_lose_data: boolean
  data_safety_statement: string
  recommended_action_summary: string

repair_plan:
  requires_elevation: boolean
  requires_reboot: boolean
  risk_level: enum                 # [Low, Medium, High]
  backup_action:
    required: boolean
    command: string
    restore_command: string
  steps:
    - step_order: integer
      description: string
      execution_context: enum      # [SYSTEM, Administrator, CurrentUser]
      command: string
      dry_run_check: string        # Command to preview impact before execution
      verification_command: string # Command to confirm step succeeded
      expected_verification: string

audit_record:                      # Populated at runtime after HITL approval
  approved_by: string
  approved_at: datetime
  execution_status: enum           # [Pending, Approved, Rejected, Succeeded, Failed, RolledBack]
  post_check_passed: boolean
```

---

## 2. Concrete Instance Example (`NOBS-APPX-001`)

```yaml
case_metadata:
  case_id: "NOBS-APPX-001"
  title: "Snipping Tool Blocked by Corrupted UI.Xaml Framework State"
  category: "AppX"
  environment_scope: "EnterpriseDomain"
  offline_solvable: true
  created_at: "2026-11-26T10:30:00+01:00"

symptom:
  user_report: "Snipping Tool does not open when pressing Win+Shift+S or clicking the icon."
  observed_errors:
    - code: "UI_BLOCKED"
      source: "Windows Shell"
      message: "Diese App kann nicht geoeffnet werden."
    - code: "DependencyIssue"
      source: "Get-AppxPackage"
      message: "Microsoft.ScreenSketch status is DependencyIssue"
    - code: "0x80073D19"
      source: "Remove-AppxPackage"
      message: "ERROR_DEPLOYMENT_BLOCKED_BY_USER_LOG_OFF"

evidence_collection:
  - fact_id: "FACT-01"
    collector: "AppxCollector"
    target: "Get-AppxPackage | Where-Object Status -ne 'Ok'"
    observed_value: "Microsoft.UI.Xaml.2.8 (8.2511.26001.0) = Modified, NeedsRemediation"
    expected_value: "Status = Ok"
    is_anomalous: true

  - fact_id: "FACT-02"
    collector: "RegistryCollector"
    target: "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList\Microsoft.UI.Xaml.2.8_8.2511.26001.0_x64__8wekyb3d8bbwe"
    observed_value: "PackageStatus = 2 (Modified)"
    expected_value: "PackageStatus = 0"
    is_anomalous: true

  - fact_id: "FACT-03"
    collector: "PolicyCollector"
    target: "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    observed_value: "RemoveWindowsStore=1, AutoDownload=4"
    expected_value: "RequirePrivateStoreOnly=1"
    is_anomalous: true

correlation:
  root_cause_summary: "An interrupted background update flagged shared framework Microsoft.UI.Xaml.2.8 as Modified, cascading DependencyIssue to all dependent UWP apps while domain GPOs and proxy blocked self-healing."
  confidence_score: 0.96
  reasoning_chain:
    - "FACT-01 proves Snipping Tool files are intact; failure is inherited from shared framework Microsoft.UI.Xaml.2.8."
    - "FACT-02 confirms persistent PackageStatus != 0 flag in HKLM StateChange registry."
    - "Error 0x80073D19 prevents package removal because another domain user profile still references the package."
    - "FACT-03 explains why Windows could not auto-remediate the package state in the background."
  ruled_out_hypotheses:
    - hypothesis: "Missing Microsoft.VCLibs.140.00 package"
      disproof_fact_id: "Get-AppxPackage -AllUsers *VCLibs* confirmed version 14.0.33519.0 is present."

end_user_explanation:
  what_happened: "The Windows Snipping Tool and other built-in apps are temporarily blocked from starting."
  why_it_happened: "A shared Windows display component was interrupted during a background update and marked as incomplete."
  is_hardware_broken: false
  hardware_statement: "Your computer hardware is completely fine; this is purely a software configuration flag."
  can_lose_data: false
  data_safety_statement: "No personal files, screenshots, or settings will be deleted or overwritten."
  recommended_action_summary: "Reset the stuck update flag in Windows and restart the background app service (no reboot required)."

repair_plan:
  requires_elevation: true
  requires_reboot: false
  risk_level: "Low"
  backup_action:
    required: true
    command: 'reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList" "C:\Temp\PackageList_Backup.reg" /y'
    restore_command: 'reg import "C:\Temp\PackageList_Backup.reg"'
  steps:
    - step_order: 1
      description: "Reset non-zero PackageStatus flags in AppModel StateChange registry"
      execution_context: "SYSTEM"
      command: |
        Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList" |
          Where-Object { (Get-ItemProperty $_.PSPath -Name "PackageStatus" -EA SilentlyContinue).PackageStatus -ne 0 } |
          ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name "PackageStatus" -Value 0 -Force }
      dry_run_check: |
        Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList" |
          Where-Object { (Get-ItemProperty $_.PSPath -Name "PackageStatus" -EA SilentlyContinue).PackageStatus -ne 0 } |
          Select-Object PSChildName
      verification_command: |
        (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList" |
          Where-Object { (Get-ItemProperty $_.PSPath -Name "PackageStatus" -EA SilentlyContinue).PackageStatus -ne 0 }).Count
      expected_verification: "0"

    - step_order: 2
      description: "Restart AppX Deployment Service (AppXSvc) to apply state change immediately"
      execution_context: "SYSTEM"
      command: "Restart-Service -Name AppXSvc -Force"
      dry_run_check: "Get-Service -Name AppXSvc | Select-Object Name, Status"
      verification_command: "(Get-AppxPackage *Microsoft.ScreenSketch*).Status"
      expected_verification: "Ok"
```
