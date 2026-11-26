<#
.SYNOPSIS
    NoBS Data Collector Prototype: Collects normalized AppX, Registry, Policy, and EventLog facts.
.DESCRIPTION
    Implements the "Facts First" & "Offline First" principles of the NoBS blueprint.
    Collects read-only system telemetry related to AppX / UWP application failures (e.g. Snipping Tool)
    and outputs a schema-compliant JSON structure ready for the NoBS Correlation Engine.
.PARAMETER TargetPackageFilter
    Wildcard filter for the affected UWP package (default: "*Microsoft.ScreenSketch*").
.PARAMETER OutputPath
    Optional path to write the normalized JSON output file.
.EXAMPLE
    .\Collect-AppXFacts.ps1 -OutputPath "C:\Temp\nobs_facts.json"
#>

[CmdletBinding()]
param (
    [string]$TargetPackageFilter = "*Microsoft.ScreenSketch*",
    [string]$OutputPath = ""
)

$ErrorActionPreference = "SilentlyContinue"
$collectionTimestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Verbose "Starting NoBS read-only fact collection on $env:COMPUTERNAME..."

# Helper function to create standardized evidence items matching Case_Schema.md
function New-NoBSEvidence {
    param (
        [string]$Id,
        [string]$Collector,
        [string]$Source,
        [string]$Key,
        $ObservedValue,
        $ExpectedValue,
        [bool]$IsAnomaly
    )
    return [ordered]@{
        id             = $Id
        collector      = $Collector
        source         = $Source
        key            = $Key
        observed_value = $ObservedValue
        expected_value = $ExpectedValue
        is_anomaly     = $IsAnomaly
    }
}

$evidenceList = @()
$evCounter = 1

# -------------------------------------------------------------------------
# 1. AppxCollector: Target package & broken framework dependencies
# -------------------------------------------------------------------------
$targetApps = Get-AppxPackage -AllUsers $TargetPackageFilter
if ($targetApps) {
    foreach ($app in $targetApps) {
        $isBroken = ($app.Status -ne "Ok")
        $evidenceList += New-NoBSEvidence `
            -Id ("EV-{0:D3}" -f $evCounter++) `
            -Collector "AppxCollector" `
            -Source "Get-AppxPackage -AllUsers" `
            -Key "$($app.Name) ($($app.Version)) [Status]" `
            -ObservedValue ([string]$app.Status) `
            -ExpectedValue "Ok" `
            -IsAnomaly $isBroken
    }
} else {
    $evidenceList += New-NoBSEvidence `
        -Id ("EV-{0:D3}" -f $evCounter++) `
        -Collector "AppxCollector" `
        -Source "Get-AppxPackage -AllUsers" `
        -Key "$TargetPackageFilter [Presence]" `
        -ObservedValue "NotFound" `
        -ExpectedValue "Installed" `
        -IsAnomaly $true
}

# Check all non-Ok packages system-wide (e.g., UI.Xaml, VCLibs, WindowsAppRuntime)
$brokenAllUsers = Get-AppxPackage -AllUsers | Where-Object { $_.Status -ne "Ok" -and $_.Name -notlike $TargetPackageFilter }
foreach ($pkg in $brokenAllUsers) {
    $evidenceList += New-NoBSEvidence `
        -Id ("EV-{0:D3}" -f $evCounter++) `
        -Collector "AppxCollector" `
        -Source "Get-AppxPackage -AllUsers (System-Wide)" `
        -Key "$($pkg.Name) ($($pkg.Version)) [Status]" `
        -ObservedValue ([string]$pkg.Status) `
        -ExpectedValue "Ok" `
        -IsAnomaly $true
}

# -------------------------------------------------------------------------
# 2. RegistryCollector: AppModel StateChange PackageList flags
# -------------------------------------------------------------------------
$pkgListPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList"
if (Test-Path $pkgListPath) {
    $stateEntries = Get-ChildItem -Path $pkgListPath
    foreach ($entry in $stateEntries) {
        $statusProp = Get-ItemProperty -Path $entry.PSPath -Name "PackageStatus" -ErrorAction SilentlyContinue
        if ($null -ne $statusProp -and $statusProp.PackageStatus -ne 0) {
            $evidenceList += New-NoBSEvidence `
                -Id ("EV-{0:D3}" -f $evCounter++) `
                -Collector "RegistryCollector" `
                -Source "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList" `
                -Key "$($entry.PSChildName)\PackageStatus" `
                -ObservedValue ([int]$statusProp.PackageStatus) `
                -ExpectedValue 0 `
                -IsAnomaly $true
        }
    }
}

# -------------------------------------------------------------------------
# 3. PolicyCollector: Windows Store & AppInstaller Policy Flags
# -------------------------------------------------------------------------
$storePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
if (Test-Path $storePolicyPath) {
    $storeProps = Get-ItemProperty -Path $storePolicyPath
    foreach ($valName in @("RemoveWindowsStore", "AutoDownload", "RequirePrivateStoreOnly", "DisableStoreApps")) {
        if ($null -ne $storeProps.$valName) {
            $expected = if ($valName -eq "RequirePrivateStoreOnly") { 1 } else { 0 }
            $isAnomaly = ($valName -in @("RemoveWindowsStore", "DisableStoreApps") -and $storeProps.$valName -eq 1) -or
                         ($valName -eq "AutoDownload" -and $storeProps.$valName -eq 4)
            $evidenceList += New-NoBSEvidence `
                -Id ("EV-{0:D3}" -f $evCounter++) `
                -Collector "PolicyCollector" `
                -Source "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" `
                -Key $valName `
                -ObservedValue ([int]$storeProps.$valName) `
                -ExpectedValue $expected `
                -IsAnomaly $isAnomaly
        }
    }
}

$appInstallerPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"
if (Test-Path $appInstallerPolicyPath) {
    $aiProps = Get-ItemProperty -Path $appInstallerPolicyPath
    if ($null -ne $aiProps.EnableAppInstaller) {
        $evidenceList += New-NoBSEvidence `
            -Id ("EV-{0:D3}" -f $evCounter++) `
            -Collector "PolicyCollector" `
            -Source "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" `
            -Key "EnableAppInstaller" `
            -ObservedValue ([int]$aiProps.EnableAppInstaller) `
            -ExpectedValue 1 `
            -IsAnomaly ($aiProps.EnableAppInstaller -eq 0)
    }
}

# -------------------------------------------------------------------------
# 4. EventLogCollector: Recent AppXDeploymentServer Errors / Warnings
# -------------------------------------------------------------------------
$appxEvents = Get-WinEvent -LogName "Microsoft-Windows-AppXDeploymentServer/Operational" -MaxEvents 40 -ErrorAction SilentlyContinue |
    Where-Object { $_.Level -le 3 -or $_.Message -match "0x80073|DependencyIssue|Modified|NeedsRemediation" } |
    Select-Object -First 5

foreach ($evt in $appxEvents) {
    $shortMsg = ($evt.Message -replace "\r?\n", " ").Trim()
    if ($shortMsg.Length -gt 220) {
        $shortMsg = $shortMsg.Substring(0, 220) + "..."
    }
    $evidenceList += New-NoBSEvidence `
        -Id ("EV-{0:D3}" -f $evCounter++) `
        -Collector "EventLogCollector" `
        -Source "Microsoft-Windows-AppXDeploymentServer/Operational" `
        -Key "EventID $($evt.Id) ($($evt.TimeCreated.ToString('s')))" `
        -ObservedValue $shortMsg `
        -ExpectedValue "NoDeploymentErrors" `
        -IsAnomaly $true
}

# -------------------------------------------------------------------------
# 5. ServiceCollector: AppXSvc state
# -------------------------------------------------------------------------
$appxSvc = Get-Service -Name "AppXSvc" -ErrorAction SilentlyContinue
if ($appxSvc) {
    $evidenceList += New-NoBSEvidence `
        -Id ("EV-{0:D3}" -f $evCounter++) `
        -Collector "ServiceCollector" `
        -Source "Get-Service" `
        -Key "AppXSvc.StartType" `
        -ObservedValue ([string]$appxSvc.StartType) `
        -ExpectedValue "Manual" `
        -IsAnomaly ($appxSvc.StartType -eq "Disabled")
}

# -------------------------------------------------------------------------
# Assemble Normalized Facts Payload
# -------------------------------------------------------------------------
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$anomaliesCount = ($evidenceList | Where-Object { $_.is_anomaly -eq $true }).Count

$payload = [ordered]@{
    schema_version = "0.1-draft"
    collector_name = "Collect-AppXFacts.ps1"
    collected_at   = $collectionTimestamp
    environment    = [ordered]@{
        hostname    = $env:COMPUTERNAME
        os_caption  = $osInfo.Caption
        os_build    = "$($osInfo.Version) ($($osInfo.BuildNumber))"
        domain      = $env:USERDNSDOMAIN
        is_domain   = [bool](Get-CimInstance Win32_ComputerSystem).PartOfDomain
        exec_user   = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    }
    summary        = [ordered]@{
        total_facts_collected = $evidenceList.Count
        anomalies_detected    = $anomaliesCount
    }
    evidence_items = $evidenceList
}

$jsonOutput = $payload | ConvertTo-Json -Depth 5

if ($OutputPath -ne "") {
    $parentDir = Split-Path -Path $OutputPath -Parent
    if ($parentDir -and -not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
    }
    Set-Content -Path $OutputPath -Value $jsonOutput -Encoding UTF8
    Write-Host "Normalized NoBS facts written to: $OutputPath ($anomaliesCount anomalies detected)" -ForegroundColor Green
} else {
    Write-Output $jsonOutput
}
