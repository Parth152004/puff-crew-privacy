# First Play release checklist

Prepared 18 October 2026. These are receiving-developer tasks, not completed account actions. The owner requested this handoff and will arrange publishing separately. Recheck live Play requirements when submission work starts.

## 1. Agree the actual release

- [ ] Play the supplied APK and inspect current code/known gaps with the owner.
- [ ] Confirm package `com.puffcrew.rapids`, title and public Ramo Labs branding; investigate name/trademark availability before finalizing the listing. Support email: jayvekaria282@gmail.com.
- [ ] Confirm free base vs paid download before first public launch. Draft recommendation: free base, all courses/joining free, optional non-consumable cosmetic bundle. Draft product ID `puff_supporter_bundle`; proposed India consumer price ₹149. No product is configured here.
- [ ] Either finish and test billing, or explicitly change the release to provide free cosmetics/remove the purchase dependency/UI/copy. Inspect debug/release differences; do not rely on `OS.is_debug_build()` to define intended release policy accidentally.
- [ ] Align in-game version, export preset and release config. Select an unused increasing versionCode after inspecting actual Play history. 1.0.0/code 2 are draft values only.

## 2. Establish local build and signing

- [ ] Follow `BUILD-ON-ANOTHER-PC.md`; reproduce debug play on the receiving PC.
- [ ] Restore owner-controlled signing material securely or deliberately establish the upload identity after Console review. Match the public certificate to the private key/registered upload certificate.
- [ ] Build a **fresh release-signed AAB** from the final source. Keep tests/debug instrumentation and secrets out of release. Capture source snapshot, toolchain, version and SHA-256.
- [ ] Validate bundle structure with the current official bundletool; use `jarsigner -verify -verbose -certs` to inspect the AAB JAR signature. Compare the signer with the chosen upload certificate. Do not try to use APK apksigner as an AAB signature validator.
- [ ] Generate APKs from that AAB for test devices, inspect merged manifests/permissions/SDKs/dependencies and native alignment. Check APK `apksigner verify --verbose --print-certs` and `zipalign -c -P 16 -v 4`. Install through Play testing as well, since Play delivers split APKs.
- [ ] Verify native ELF and APK alignment, and actual launch/play in a 16 KB page-size environment. Static alignment of the old playtest is not final-AAB/runtime proof.

## 3. Real-device and release QA

- [ ] Test exact final release on representative low/mid/high ARM64 phones, Android versions (min API 24 through current), aspect ratios/cutouts/tablets and refresh rates. Record model/OS/build/hash/results.
- [ ] Complete all three courses, checkpoint/fall/finish/retry, saves, camera, sound, haptics and all graphics settings; check full simultaneous multi-touch and menus/Back.
- [ ] Test 2, 3 and 4 physical phones on a real router, discovery/manual IP, ready/start, different outfits, host/client pause/leave, background/resume, lock/unlock, network interruption and denied/blocked networking. Document unsupported host migration/rejoin.
- [ ] Measure sustained frame times, memory, battery/heat and stability rather than relying on emulator point FPS. Repeat with purchased/free cosmetics as actually shipped.
- [ ] If billing is included: configure the permanent buy option/product/prices/countries, install from a Play test track, and use license testers to test success, cancellation, pending-to-completed, acknowledgement retry, offline cache, restart/reinstall restore, changed account, refund/revocation and price/localization. Fake-adapter tests do not satisfy this.

## 4. Privacy, assets and Console preparation

- [ ] Align in-game privacy, `release/privacy/index.html`, actual SDK handling and Data safety. Publish the final policy at a stable public HTTPS URL accessible without login; replace `privacy_policy_url: null` and add the actual URL wherever required.
- [ ] Complete audience selections honestly (owner chose 13–15/16–17/18+), IARC questionnaire/rating, ads declaration, app access, content declarations and support contact. Do not infer rating from intended age.
- [ ] Review Data safety including Play Billing if shipped, local-network exchanges, optional support email, backup/deletion behavior and any new SDK. No automatic definitive form answers are claimed in this package.
- [ ] Finalize listing copy; remove claims about unshipped purchases. Choose genuine final-build screenshots. `release/store-assets/` provides icon/feature image and screenshots for review, not proof of transaction tests. Re-capture where UI/version/payment behavior differs.
- [ ] Preserve bundled notices. Confirm original content rights and any additional asset/SDK licenses. Do not market using Fart Together's name, videos or art.
- [ ] Verify identity/contact/address/production access and any real-device verification shown in the owner's personal account. For paid content, review merchant, bank, PAN/applicable tax information and public legal-name/address disclosures with the owner. This handoff contains no tax/account readiness confirmation.

## 5. Testing tracks and eventual launch — owner/developer to execute

- [ ] Check current requirements in the actual Console. Personal accounts created after 13 November 2023 generally need **at least 12 testers continuously opted into a closed test for 14 days**, then a production-access application. The owner's account is in this group; existing production access has not been inspected. Internal testing/license-testing do not by themselves satisfy the closed-test requirement.
- [ ] Arrange genuine testing, collect issues/feedback and document fixes. Passing the duration/count is not a guarantee of production access or review approval.
- [ ] Upload only the new verified AAB to the chosen testing track when the owner resumes publishing. Review pre-launch reports, device catalog and crashes/ANRs. Re-test the actual Play-delivered app.
- [ ] Finish required listing/policy/pricing/region forms. Obtain the owner's final review of the concrete app/listing/monetization before public launch. Check paid/free model restrictions and platform fees again.
- [ ] After approval/readiness, publish with an appropriate rollout and monitor real crashes/ANRs/reviews/support. Maintain the upload-key backup, source snapshot, checksums and rollback/update plan. Never promise store acceptance or immediate revenue.

## Current official references

Checked 18 October 2026 where noted; policies may change. Existing detailed research is under `research/publishing/` and is a dated snapshot.

- [Personal-account testing](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en): current official search result reconfirmed 12 opted-in testers/14 consecutive days; direct fetch was unavailable in this session. Actual Console governs account-specific eligibility.
- [Target API requirements](https://developer.android.com/google/play/requirements/target-sdk): new standard phone/tablet apps and updates require API 36 from 31 August 2026 (reconfirmed 18 October).
- [16 KB page sizes](https://developer.android.com/guide/practices/page-sizes): check requirements and test the final native build in the appropriate environment.
- [Billing support/deprecation](https://developer.android.com/google/play/billing/deprecation-faq), [purchase security](https://developer.android.com/google/play/billing/security), [billing testing](https://developer.android.com/google/play/billing/test).
- [App signing](https://developer.android.com/studio/publish/app-signing), [bundletool](https://developer.android.com/tools/bundletool), [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469).

Do not upload the included debug APK or an old AAB as the final production build. No current AAB is included on purpose: final code/payment/privacy decisions and exact-release verification remain.
