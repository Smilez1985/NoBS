# Design Document: macret (Mask Secrets)

**Module ID:** `NOBS-MOD-MACRET`  
**Status:** Draft / Blueprint v0.1  
**Component Type:** Pre-Processing Security & Privacy Gate (Offline-First)  
**Target Ecosystem:** NoBS (No More Bullshit Windows Diagnostics and Remediation) & Standalone CLI/PowerShell

---

## 1. Executive Summary

**macret** (*Mask Secrets*) is a deterministic, local, offline-first sanitization and pseudonymization engine designed for IT administrators, helpdesk engineers, and end users. 

Before diagnostic logs, PowerShell outputs, registry exports, or normalized NoBS fact files (`Case_Schema`) leave a local machine—whether for sharing in support tickets, community forums, GitHub issues, or external LLM analysis—**macret** intercepts and masks sensitive infrastructure reconnaissance data (AD domains, OUs, hostnames, usernames, SIDs, IP addresses, internal URLs, and credentials) while preserving full diagnostic and structural context.

---

## 2. The Problem Statement

Diagnostic data in Windows environments is inherently rich in internal reconnaissance metadata:
1. **Structural Leakage:** Combining an internal Active Directory FQDN, Organizational Unit (OU) hierarchy, and workstation naming conventions reveals organizational structure, physical locations, OS rollout states, and administrative tiering.
2. **Identity Exposure:** Event logs, `whoami` outputs, and file paths (`C:\Users\...`) expose real user names, dedicated admin accounts, and Security Identifiers (SIDs).
3. **Network Topology:** Proxy addresses, internal shares (`\\server\share`), WSUS/SCCM endpoints, and RFC 1918 IP addresses map out internal infrastructure.
4. **The "Naive Redaction" Trap:** Simple search-and-replace with `[REDACTED]` destroys diagnostic correlation. If two log entries refer to different servers or different users, replacing both with `[REDACTED]` makes it impossible to tell whether an issue is caused by a single machine or cross-account mismatch.

---

## 3. Core Design Principles

### 3.1 Offline-First & Zero-Trust Execution
- **100% Local Processing:** `macret` never transmits raw data to any cloud service. All detection, parsing, and replacement happen locally in memory.
- **Zero External Dependencies:** Designed to run natively on standard Windows 10/11 systems using built-in PowerShell (5.1 / 7+) without requiring third-party runtimes or internet access.

### 3.2 Deterministic & Referential Pseudonymization (Mapping Consistency)
Instead of destructive redaction, `macret` uses **session-scoped deterministic aliases**:
- `corp.internal.local` $ightarrow$ `DOMAIN-01.local`
- `CLIENT-PC-042` $ightarrow$ `HOST-01`
- `SERVER-DC-01` $ightarrow$ `HOST-02`
- `j.doe` $ightarrow$ `USER-01`
- `doe_admin` $ightarrow$ `USER-02`

**Why this matters:** An external analyst or LLM can still see that `USER-01` differs from `USER-02` (crucial for diagnosing Over-the-Shoulder UAC or AppX user-context bugs) without ever learning their real identities.

### 3.3 Reversible Local Vault (Ephemeral Session Map)
- During a sanitization run, `macret` keeps an in-memory (or optionally encrypted, user-scoped DPAPI) mapping table (`macret-map.json`).
- When an external tool or LLM returns a remediation script containing `HOST-01` or `DOMAIN-01.local`, `macret --unmask` can locally re-hydrate the real values for execution by the administrator.
- **Self-Destruct / Ephemeral Default:** By default, the mapping table lives only in memory or is purged upon session close to prevent leftover secret stores on disk.

### 3.4 Defense-in-Depth Detection Layers
`macret` combines three detection strategies rather than relying solely on regex:
1. **Dynamic Environment Introspection (Auto-Discovery):** Before scanning text, `macret` queries the local OS for its actual hostname (`$env:COMPUTERNAME`), domain (`$env:USERDNSDOMAIN`), NetBIOS name, current username (`$env:USERNAME`), local user profiles (`C:\Users\*`), and local IP/DNS configuration, adding them as high-priority exact matches.
2. **Structured Pattern & Regex Rules:** Catches RFC 1918 IPs, IPv6 addresses, MAC addresses, Windows SIDs (`S-1-5-21-...`), LDAP Distinguished Names (`OU=...,DC=...`), UNC paths (`\\...`), JWTs, API keys, and connection strings.
3. **Custom Dictionary / Allowlist & Denylist:** Allows organizations to define custom prefixes (e.g., `SRV-*`, `WKS-*`, `DEPT-*`) or protect known benign Windows terms (e.g., `NT AUTHORITY\SYSTEM`, `Microsoft.UI.Xaml`, `127.0.0.1`) from false-positive masking.

---

## 4. Architecture & Data Flow

```text
  Raw Input (Clipboard / Log File / Pipe / NoBS Facts JSON)
                            │
                            ▼
             ┌──────────────────────────────┐
             │  1. Environment Introspector │  ◄── Queries local Hostname, Domain,
             │     (Auto-Seed Dictionary)   │      Usernames, SIDs, Local IPs
             └──────────────┬───────────────┘
                            │
                            ▼
             ┌──────────────────────────────┐
             │  2. Allowlist Filter         │  ◄── Protects Windows built-ins
             │     (False-Positive Guard)   │      (SYSTEM, TrustedInstaller, etc.)
             └──────────────┬───────────────┘
                            │
                            ▼
             ┌──────────────────────────────┐
             │  3. Multi-Pass Tokenizer     │  ◄── Longest-match-first replacement
             │     & Regex Engine           │      (DNs -> FQDNs -> Hosts -> IPs)
             └──────────────┬───────────────┘
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
┌───────────────────────────┐ ┌───────────────────────────┐
│  Sanitized Output         │ │  Local Ephemeral Map      │
│  (Safe for Sharing / LLM) │ │  (In-Memory / DPAPI)      │
└───────────────────────────┘ └───────────────────────────┘
```

### Ordering Priority (Longest-Match-First)
To prevent partial replacement collisions (e.g., masking a hostname inside an FQDN before the FQDN itself is recognized), `macret` processes entities in strict hierarchical order:
1. **Credentials & Tokens** (Passwords, Bearer tokens, Base64 secrets, registry keys with secrets)
2. **LDAP Distinguished Names** (`CN=...,OU=...,DC=...`)
3. **UNC Paths & Internal URLs** (`\\server\share\path`, `https://intranet.corp.local/...`)
4. **FQDNs & AD Domains** (`host.sub.domain.tld`, `domain.local`)
5. **Security Identifiers (SIDs) & GUIDs** (`S-1-5-21-...`)
6. **Hostnames & Usernames** (Auto-discovered + naming convention patterns)
7. **Network Identifiers** (IPv4, IPv6, MAC addresses)

---

## 5. Masking Taxonomy & Output Standard

| Entity Category | Raw Example | Masked Alias | Notes |
| :--- | :--- | :--- | :--- |
| **AD Domain (FQDN)** | `corp.example.gov` | `DOMAIN-01.local` | Preserves domain boundary awareness |
| **NetBIOS Domain** | `CORP` | `DOMAIN-01` | Linked to `DOMAIN-01.local` |
| **Organizational Unit** | `OU=Finance,OU=Berlin,DC=corp...` | `OU=ORG-01,OU=LOC-01,DC=DOMAIN-01,DC=local` | Preserves OU nesting depth |
| **Workstation / Server** | `WKS-BER-0142` | `HOST-01` | Distinct counter per unique host |
| **User Account** | `j.smith` / `smith_adm` | `USER-01` / `USER-02` | Distinguishes standard vs. admin accounts |
| **Windows SID** | `S-1-5-21-3874358491-...-7358` | `SID-USER-01` | Correlated with `USER-01` if resolvable |
| **Private IPv4** | `10.42.18.105` | `10.0.0.1` | Mapped into RFC 5737 / `10.0.0.x` test range |
| **UNC Share** | `\\fs01.corp.example.gov\scripts$` | `\\HOST-02\SHARE-01` | Preserves path structure |
| **Secret / Key** | `Password=SuperSecret123!` | `Password=[SECRET-REDACTED-01]` | Irreversible by default |

---

## 6. Integration into NoBS & CLI Usage

### 6.1 Integration in the NoBS Pipeline
Within the **NoBS** architecture, `macret` acts as the mandatory security boundary between **Data Collectors / Normalization** and any **External Web Research / LLM Reasoning** module:

```text
Data Collectors ──► Normalization ──► [ macret Gate ] ──► LLM / External Share
                                            │
                                            ▼
                                  Audit Log Entry:
                            "14 entities masked (3 hosts,
                             1 domain, 2 users, 8 IPs)"
```

### 6.2 Planned CLI & PowerShell Interface
- **Clipboard Sanitization (Daily Admin Workflow):**
  ```powershell
  Get-Clipboard | Invoke-Macret | Set-Clipboard
  ```
- **Pipeline / File Sanitization with Summary Report:**
  ```powershell
  Get-Content .\error_log.txt | Invoke-Macret -Report
  ```
- **Re-Hydrating a Remediation Script Locally:**
  ```powershell
  Get-Content .\suggested_fix.ps1 | Invoke-Macret -Unmask -MapFile .\session.map
  ```
- **Strict Paranoid Mode (Irreversible + Custom Org Prefixes):**
  ```powershell
  Invoke-Macret -Path .\facts.json -Paranoid -CustomPrefixes "WKS-","SRV-","DEPT-"
  ```

---

## 7. Security & Threat Model Considerations

1. **False Negatives on Custom Naming Conventions:** Regex alone cannot know that `ZEUS01` is an internal server name if it is not the local host. Mitigated via **Auto-Discovery** (querying active AD/DNS cache and local profiles) plus configurable organization prefix lists.
2. **Over-Masking / Breaking Technical Logs:** Blindly masking words like `System`, `Admin`, `Default`, or version strings (`8.2511.26001.0` looking like an IP) destroys log readability. Mitigated via strict **Allowlists** and context-aware IP validation (ensuring version numbers are not treated as IPv4 addresses).
3. **Map File Leakage:** A persistent mapping file on disk is itself a high-value reconnaissance artifact. Mitigated by keeping maps **in-memory by default** and encrypting disk exports with Windows **DPAPI** (`ProtectedData`) tied to the current user account.

---

## 8. Roadmap for `macret`

- **Phase 1 (MVP - PowerShell Module `Macret.psm1`):**
  - Auto-discovery of local host, domain, users, SIDs, and local IPs.
  - Deterministic masking for FQDNs, OUs, SIDs, IPs, UNC paths, and `C:\Users\<name>` paths.
  - Clipboard-to-Clipboard one-liner (`macret -clip`).
- **Phase 2 (NoBS Integration & Schema Support):**
  - Native JSON-aware parsing for NoBS `Case_Schema` files (masking values without corrupting JSON keys).
  - Audit trail integration recording entity counts masked per run.
- **Phase 3 (Reversible DPAPI Vault & Custom Rulesets):**
  - Optional encrypted session map for `Unmask` workflows.
  - Organization config file (`macret.config.json`) for custom hostname prefixes and allowlists.
