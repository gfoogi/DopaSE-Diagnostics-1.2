# Genuine Dopamine 3.x build workspace

This builds **actual official Dopamine code**, not the DopaSE Diagnostics SwiftUI app.

**Upstream:** https://github.com/opa334/Dopamine (branch `3.x`, pinned commit `5b1d2c1c3bf54dd8e3641d29c60cd3a0c13cde88` corresponding to 3.0.13).

**Build:** `.github/workflows/build-genuine-dopamine.yml` creates an upstream Dopamine IPA with the original exploit modules, protection checks, bootstrap and app UI. The source is cloned with submodules. No new vulnerability or modifications to compatibility constraints are introduced.

**Important:** this IPA is **NOT a working jailbreak for iPhone SE 2020 / iOS 26.1 final (23B85)**. Do not install expecting this to enable jailbreak. A successful compilation is not a demonstration of exploitation, privilege elevation or kernel protection bypass on the user's device.

DopaSE Diagnostics remains a different app. These projects are separate until true compatibility on 23B85 has been independently established.

This build may fail if upstream external dependencies change. Follow the official project license, requirements and build instructions.
