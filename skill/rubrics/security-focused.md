---
name: security-focused
description: For teams where security posture drives technical decisions. Weights blind spots and threat awareness heavily.
---

## Dimensions

### Evidence specificity
Weight: 15%
1-3: Vague or absent. No references to threat models, CVEs, or security audits.
4-6: General awareness. "This is more secure." References OWASP or general best practices without specifics.
7-10: Cites specific threat vectors, past incidents, CVE references, or audit findings. "This mitigates SSRF via allowlist because our last pentest flagged open redirects."

### Assumption count
Weight: 15%
1-3: Assumes trust boundaries that don't exist. Unstated assumptions about input validation, auth state, or network security.
4-6: Some trust boundaries acknowledged. Missing assumptions about edge cases like token expiry, race conditions, or privilege escalation paths.
7-10: Trust boundaries explicitly mapped. Developer states what they're assuming about auth state, input sources, and network topology.

### Blind spot severity
Weight: 40%
1-3: Missed critical security failure modes — auth bypass, injection vectors, unencrypted sensitive data, privilege escalation.
4-6: Missed moderate security concerns — overly broad permissions, missing rate limiting, insufficient logging for audit trails.
7-10: Security failure modes addressed. Threat model considered. Known risks documented with mitigations or explicit acceptance.

### Threat model awareness
Weight: 15%
1-3: No consideration of who the adversary is or what they'd target. Decision made in a vacuum.
4-6: Partial threat awareness. Considers some attack vectors but not the full attack surface for this change.
7-10: Clear threat model. Knows who would attack this, how, and what the impact would be. Decision accounts for realistic threat actors.

### Confidence calibration
Weight: 15%
1-3: "This is secure" with no evidence. Overconfidence on security claims is especially dangerous.
4-6: Mostly calibrated but claims security properties without verification. "I think this prevents XSS."
7-10: Security claims backed by testing, code review, or documented properties of the approach. Acknowledges what hasn't been verified.

## Role calibration

- **Executive/CTO decisions**: Threat model awareness is paramount. Are they making security-sensitive vendor/architecture choices with an accurate threat model? Evidence should reference compliance requirements, not just engineering intuition.
- **Senior/Staff engineer decisions**: Blind spot severity is the primary signal. They should catch auth bypass, injection, and data exposure risks without prompting. Assumption count around trust boundaries matters.
- **Mid-level engineer decisions**: Focus on whether they're applying security patterns correctly and asking the right questions when unsure. Reward flagging concerns to senior engineers over attempting solo security decisions.
- **Junior engineer decisions**: Confidence calibration is critical. A junior saying "I'm not sure if this is secure" scores higher than one saying "this is fine." Reward appropriate escalation and explicit uncertainty.

## Security-specific flags

- `auth-bypass(high)` — Decision could allow unauthorized access
- `input-validation(med)` — Untrusted input not validated or sanitized
- `data-exposure(high)` — Sensitive data visible in logs, URLs, or error messages
- `privilege-escalation(high)` — User could gain elevated permissions
- `missing-audit-trail(med)` — Security-relevant action not logged
- `crypto-misuse(high)` — Rolling custom crypto, weak algorithms, or hardcoded keys
- `trust-boundary-crossed(med)` — Assumption about trusted input source may be wrong
- `rate-limit-absent(low)` — Endpoint exposed without rate limiting
