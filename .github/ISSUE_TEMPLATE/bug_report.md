---
name: Bug Report
about: Report a bug or issue with the demo
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

A clear and concise description of what the bug is.

## Steps to Reproduce

1. Configure environment with '...'
2. Run command '...'
3. Observe error '...'

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Environment

**Operating System:**
- [ ] Linux (distribution and version: ___)
- [ ] macOS (version: ___)
- [ ] Windows (version: ___)

**dstack Version:**
```bash
# Output of: dstack version
```

**Cloud Provider:**
- [ ] RunPod
- [ ] VastAI
- [ ] Other: ___

**GPU Type:** (e.g., A40, RTX4090, L40)

**dstack Server:**
- [ ] Local (dstack server)
- [ ] Remote (hosted)

## Configuration

**Relevant sections from your `.env` file** (remove sensitive information):
```bash
SERVICE_NAME=mistral-7b
GPU=A40:1
SPOT_POLICY=on-demand
# ... other relevant settings
```

**Service configuration** (if relevant):
```yaml
# Paste relevant sections from your rendered service.yaml
```

## Logs and Error Messages

<details>
<summary>dstack logs</summary>

```
# Output of: dstack logs mistral-7b --project mistral-7b
```

</details>

<details>
<summary>Error messages</summary>

```
# Paste any error messages here
```

</details>

## Additional Context

Any other context, screenshots, or information that might help diagnose the issue.

## Possible Solution

If you have ideas about what might be causing the issue or how to fix it, please share them here.

## Checklist

- [ ] I have searched existing issues to avoid duplicates
- [ ] I have included all relevant logs and error messages
- [ ] I have removed sensitive information (API keys, tokens) from logs
- [ ] I have tested with the latest version of dstack
- [ ] I have verified my environment configuration matches the README
