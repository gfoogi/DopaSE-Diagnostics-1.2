# iPhone SE 2020 — iOS 26.1 (23B85) kernel research

Research snapshot: **2026-11-12**. Target: **iPhone12,8 / A13 / 26.1 / 23B85**.

## Verified findings

1. Dopamine branch `3.x` does **not** list 23B85 as compatible. Its `momentarius/Info.plist` lists 26.0–26.0.1 and beta builds 23B5044l, 23B5059e, 23B5064e.
2. Apple's iOS 26.1 release fixes kernel vulnerabilities including CVE-2025-43510 and CVE-2025-43520. Those older primitives must **not** be assumed available on 23B85.
3. An external research repository ("clipwire", dated August 2026) proposes two other memory-management bug hypotheses for iOS 26.1 and claims A13 offsets. Its primary documented device is iPhone 11 (iPhone12,1), not SE 2020 (iPhone12,8).
4. Its readme explicitly describes a **work-in-progress development harness, not an end-to-end jailbreak**. Its sample deployment presumes an already-jailbroken device. A working, safe path for an unmodified SE 2020 is **not established**.
5. No independently validated kernel read/write primitive, elevation of privileges, compatible protection bypass, or successful Dopamine bootstrap on SE 2020 / 23B85 has been demonstrated by this project.

## Research milestones and exit conditions

| Milestone | Evidence necessary | State |
| --- | --- | --- |
| 1. Target identification | Exact model/build/kernel version | DONE: model and build known; kernel version to be captured on device |
| 2. Official compatibility baseline | Upstream Dopamine metadata | DONE: no final 26.1 support |
| 3. Candidate provenance | License, reproducible test report, independent reproduction | OPEN |
| 4. Device-specific verification | No assumption that iPhone 11 offsets work on SE 2020 | OPEN |
| 5. Controlled assessment | Dedicated test phone, reversible non-invasive checks, detailed failure logs | OPEN |
| 6. Privilege-capability validation | Reproducible independently reviewed evidence, no guessed addresses | OPEN |
| 7. Platform protections | Verified iOS 26.1 device-specific compatibility | OPEN |
| 8. Dopamine integration | Source review, bootstrap tests and recovery plan | OPEN |
| 9. Release gate | Source audit, signed build, repeatable tests, explicit risk acceptance | BLOCKED until 3–8 |

## Implementation boundaries

- Keep user-facing compatibility at **unsupported**, not "supported", until validated upstream or by reproducible independent tests.
- Never enable speculative kernel-memory operations merely by adding `23B85` to a version list.
- Keep the existing DopaSE Diagnostics app separate from any research components.
- Do not test unverified kernel exploits on the primary phone or one with irreplaceable data.
- Do not download or execute unexplained compiled binaries from third-party repositories.
- No kernel exploit, credential patch or bypass implementation is part of this research record.

## Primary sources

- Dopamine: https://github.com/opa334/Dopamine
- Dopamine `3.x` metadata: https://github.com/opa334/Dopamine/blob/3.x/Application/Dopamine/Exploits/momentarius/Info.plist
- Apple iOS 26.1 security bulletin: https://support.apple.com/en-us/125632
- Google Threat Intelligence on patch levels and DarkSword: https://cloud.google.com/blog/topics/threat-intelligence/darksword-ios-exploit-chain

## Conclusion

**Status: CANDIDATE_RESEARCH_ONLY**. Existence of an experimental harness does not imply this build is jailbreakable. The app should continue reporting `23B85` as unsupported until actual end-to-end validation.
