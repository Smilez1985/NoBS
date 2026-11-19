# NoBS

> **No More Bullshit Windows Diagnostics and Remediation.**

Windows already knows what's wrong.

It has the logs.
It has the telemetry.
It has the event traces.
It has the crash reports.
It has the update history.

Yet users still get:

```text
0x80070005

Something went wrong.

Hyper-V encountered an error.

Windows Update failed.
```

NoBS exists to translate Windows bullshit into human language.

---

## The Problem

Modern Windows systems already collect enormous amounts of diagnostic information:

- Event Logs
- Reliability Monitor
- Windows Update telemetry
- CBS logs
- DISM logs
- WMI / CIM
- Hyper-V diagnostics
- Defender telemetry
- Service status
- Performance counters
- Registry state

The problem is not missing information.

The problem is that the information is:

- scattered across dozens of locations
- difficult to correlate
- difficult to understand
- difficult to act upon

Users are expected to become system administrators just to understand why an update failed.

That is unacceptable.

---

## The Goal

NoBS turns:

```text
0x80070005
```

into:

```text
Windows Update cannot access required files.

Evidence:
- Event ID 20
- Access Denied entries in CBS.log
- Failed update transaction

Likely Cause:
Corrupted permissions in the update subsystem.

Confidence:
87%

Suggested Repair:
Reset update permissions and rebuild update cache.

Risk:
Low
```

---

## What NoBS Is

NoBS is an OS-native troubleshooting harness for Windows.

It:

1. Collects system facts.
2. Correlates information across multiple sources.
3. Determines likely root causes.
4. Researches available solutions.
5. Builds a repair plan.
6. Presents evidence to a human.
7. Executes approved fixes.
8. Audits every change.

---

## What NoBS Is NOT

NoBS is not:

- a chatbot
- a virtual assistant
- a cloud service
- another "AI copilot"
- a replacement for administrators

NoBS is a diagnostic and remediation platform.

Facts first.
Reasoning second.
Execution last.

---
# Target Audience

## Primary Target Audience

NoBS is primarily designed for everyday end users.

This means people who want to use their computer, not administer it (e.g., parents, grandparents, students, retirees, small business owners, tradespeople, teachers, caregivers).

These users:

- cannot read log files
- do not know what event logs are
- cannot edit the Windows Registry
- do not use PowerShell
- cannot interpret error codes
- do not know which system data is relevant

NoBS is not meant to train system administrators.

NoBS is meant to explain computer problems in plain language and make them safely solvable.

---

## Secondary Target Audience

- Helpdesk
- First-Level Support
- IT Administrators
- Power Users

These groups benefit from:

- time savings
- structured RCA reports
- complete auditing
- reproducible automation

However, they are explicitly not the primary target audience.

---

# User Principle

NoBS explains computer problems in human language.

The computer must make itself understandable to the human — not the other way around.

Every output for end users must answer five core questions:

1. **What happened?** (Plain-language explanation instead of an error code)
2. **Why did it happen?** (Root cause without technical jargon)
3. **Is my computer broken?** (Clear distinction between hardware and software issues)
4. **Can I lose any data?** (Transparent statement on data safety and backup status)
5. **What can be done about it?** (Concrete, safe remediation proposal)

Technical details (Event IDs, log paths, registry keys, commands) remain fully preserved for transparency and auditing, but are encapsulated behind a details view for end users.

---

## Design Principles

### Facts First

NoBS never starts with assumptions.

It starts with measurable system facts.

### Human In The Loop

No repair is executed without approval.

### Explain Everything

Every recommendation must contain:

- evidence
- reasoning
- confidence score
- rollback information
- risk assessment

### Offline First

The system must remain useful without internet access.

### Audit First

Every action is recorded.

Nothing happens silently.

### No Magic

NoBS must always be able to answer:

```text
Why do you think this?

Why are you suggesting this?

What evidence supports the conclusion?
```

---

# Architecture

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
└─ System State
             │
             ▼
      Data Collectors
             │
             ▼
       Normalization
             │
             ▼
       Facts Database
             │
             ▼
      Correlation Engine
             │
             ▼
         Web Research
             │
             ▼
             LLM
             │
             ▼
     Repair Plan Generator
             │
             ▼
      Dry Run Validation
             │
             ▼
           HITL
             │
             ▼
         Execution
             │
             ▼
            Audit
```

---

## Example Workflow

User says:

```text
Windows Update is broken.
```

NoBS:

```text
✓ Collect update telemetry

✓ Analyze update logs

✓ Check CBS integrity

✓ Check DISM health

✓ Check related Event IDs

✓ Correlate findings

✓ Research documented fixes

✓ Build repair plan
```

Result:

```text
Problem:
Windows Update failure

Cause:
Corrupted component store

Confidence:
91%

Evidence:
- CBS corruption detected
- Event ID 20
- Failed package transaction

Recommended Actions:
1. DISM RestoreHealth
2. SFC Scan
3. Retest Windows Update

Risk:
Low

Rollback:
Not required

Execute?
[Y]es
[N]o
[Details]
[Improve Plan]
```

---

# Why This Project Exists

Operating systems should help users solve problems.

Instead, most systems expose raw error codes and force users to search forums, blogs, Reddit threads and random YouTube videos.

NoBS aims to close that gap.

The future is not:

```text
More AI.
```

The future is:

```text
Better understanding of existing system data.
```

---

# Current Status

```text
Status: Planning / Pre-Alpha
```

Nothing is released.

The blueprint comes first.

See:

```text
Blueprint/
├─ design.md
├─ roadmap.md
└─ changelog.md
```

---

# Philosophy

Stop showing users:

```text
0x80070005
```

Start telling them:

```text
What happened.
Why it happened.
How to fix it.
How risky the fix is.
```

**No More Bullshit.**
