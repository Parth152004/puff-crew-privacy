# Known gaps and release decisions

**This handoff is complete as a development package. Public-release work remains.**

## Release behavior differs from the included playtest

The APK is 0.2.0/code 2, debug-signed. `CrewStore.has_outfits()` grants outfits in debug, checkout is hidden, and the export plugin omits native billing libraries/dependencies for debug. In release, the staged GodotGooglePlayBilling integration becomes active and cosmetic access is gated. No real product, price, license test, purchase, restore or refund has been tested through Play.

Decide either to release all cosmetics free (change the release code, dependencies and copy accordingly) or finish the proposed non-consumable bundle. Do not simply export the release preset assuming the debug outfit behavior carries across. Review `scripts/store.gd`, `scripts/hud.gd`, `scripts/release_info.gd`, `addons/GodotGooglePlayBilling/export_plugin.gd` and `release/BILLING-SETUP-AND-TEST.md`.

Entitlement state is cached locally and refreshed through Google's client. There is no independent secure verification backend; a modified client/local cache can be tampered with. The 16 purchase-state tests use a fake adapter and establish no live store readiness. Do not advertise future products or fraud resistance that have not been delivered.

## Versions, privacy and store copy

- In-game version and debug preset: **0.2.0**. Google Play preset and draft release config: **1.0.0**, code **2**. Align deliberately; do not assume code 2 is unused in the real Console. The local release helper now catches identity mismatches.
- In-game privacy text describes the no-purchase playtest. Draft HTML/listing describe optional future purchases. Align them to the actual release, host a real public HTTPS privacy URL, and complete Data safety from the shipped SDK/data behavior. No URL is currently configured.
- No IARC rating, Console audience form, ads declaration, merchant/tax readiness or production access has been completed/inspected here. 13+ is the owner's intended audience, not an assigned content rating.
- The store assets are editable originals and genuine renderer screenshots. Screen selection must match the final paid/free UI and chosen release. No independent trademark clearance/name availability search is claimed. Do not use the reference game's name, artwork or identity as your store branding.

## Test scope

25 behavior checks, all three automated course runs, four desktop ENet processes, Android solo touch/UI and two Android emulators sharing virtual Wi-Fi passed. Emulators sampled around 50–60 FPS, not a physical-device performance guarantee. There are shader-cache fallback/recompilation warnings in emulator logs; no observed script crash in the checked paths.

Final APK SHA-256: `3bae7d8db2cb97fe3caa78ab41a3eab79e25eb0e1263b74cab26a59e299e1151`.

Android UI/pair QA used SHA-256: `5978e39297d7784ea16838a4efeb29fd60d2350894d0447377759433a026d663`.

After Android QA, only whirlpool foam material visibility was changed (two-sided/unshaded), the video inspected and the APK rebuilt/signature/CRC checked. That final visual-only adjustment was not rerun on Android. Repeat exact-final-build tests instead of presenting these as final release certification.

Physical phones, real haptics, router/hotspot compatibility, low/mid/high hardware, Android versions, 16 KB runtime environment, thermal/battery endurance and 3–4 actual phones remain untested. A public-release AAB must be freshly built, validated and installed through Play testing. Older preparatory AABs are excluded from this package.

## Product limits

- Three compact procedural courses; no large campaign or content service.
- ARM64 Android API 24+ with GLES 3 only. No 32-bit ARM or x86 customer build.
- Same-network ENet co-op only. UDP 28970 for play, UDP 28971 for discovery. Router isolation/broadcast filtering may prevent discovery/connectivity; manual IPv4 entry exists.
- The captain owns the simulation. No host migration, internet matchmaking, mid-run rejoining or reconnection recovery. Test backgrounding, calls, lock/unlock, network loss and departing host/client before launch.
- Local settings/best times; no cloud save, account system, analytics, ads or backend.
- Current English UI; no localization/accessibility certification. Touch sizing, contrast, cutouts, wide/tablet screens and haptic preferences need real-device review.
