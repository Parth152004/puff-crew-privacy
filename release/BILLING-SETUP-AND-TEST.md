# DRAFT: Supporter Outfit Bundle — Play setup and verification

The current 0.2.0 playtest excludes native billing and unlocks all outfits. This document describes future release work. No current AAB is supplied in the handoff. See `../handoff/KNOWN-GAPS.md` before exporting the release preset.

Package: `com.puffcrew.rapids`. Product ID: **puff_supporter_bundle**. Title: **Supporter Outfit Bundle**. One-time, permanent, non-consumable purchase; configure a **buy/permanent** purchase option (not rental). Suggested India consumer price for testing: **₹149**, with deliberate regional prices. This is a proposal, not validated conversion data.

Description: Mariner, Sun Seeker and Stargazer hats with matching scarves. Cosmetic only. All courses and crew joining stay free. No currency, subscription, power upgrade or future-content promise.

The Godot first-party plugin 3.3.0 integrates Billing Library 9.1.0. Prices and eligible offer information are read from Google Play. Until the product is active/available, the purchase button stays unavailable; a hardcoded price or simulated purchase is never shown as real. No purchase token is sent to LAN peers or logged by our scripts.

## Owner's Console work

1. Confirm the app/package identity and app-signing configuration. Build a fresh AAB from the finalized current source and confirm the chosen upload certificate; preserve the private upload-key backup separately. The included public certificate alone cannot sign the game.
2. Finish merchant/bank/PAN and applicable tax setup. Review the public legal-name/address disclosure for a monetized personal account.
3. Create and activate the one-time product above, its permanent buy option, country availability and prices.
4. Upload the AAB to the internal/closed test track. Add license testers and actual closed-track testers as required; those are separate settings.
5. Install through the opted-in Google Play test link under the tester's own account. An ADB sideload is not evidence that real billing works.

## Test matrix — real Play testing remains outstanding

- Confirm price/currency come from the store and the bundle contents are accurate.
- Use Google's license-test payment methods, avoiding unintended real charges.
- Complete a test purchase: content stays locked until completion and acknowledgement, then unlocks.
- Cancel the checkout: no unlock and no blocked game.
- Use a pending payment: no early unlock; completion later restores/unlocks correctly.
- Interrupt network/focus during checkout and acknowledgement; retry Restore purchases.
- Relaunch, reinstall and restore with the same Play account.
- Change to a non-owning account; a successful query without the purchase removes cached access.
- Refund/revoke a test purchase; verify access updates after a successful store query.
- Verify owned offline access, while a fresh install cannot fabricate an entitlement.
- Preview locked outfits without equipping them. Equip owned outfits; verify the appearance on another phone.
- Confirm purchases never alter forces, stamina, levels or other players' controls.

Automated state-machine checks cover pending/cancel/restore/revocation and acknowledgement behavior with a fake billing adapter. They are **not live transaction tests**.

## Security and operational boundary

This first integration uses Google Play's native client and local access caching; it does not implement a Ramo Labs backend or independent server-side signature/token verification. Google recommends secure-backend verification for stronger fraud resistance. Local entitlement data and a modified client can be tampered with. The current product is low-value cosmetic content, and LAN peers validate only bounded visual choices, not a remote account's payment. Do not describe it as fraud-proof.

On an online successful ownership query, missing/refunded/suspended entitlement is removed. Offline cached access is preserved. Unacknowledged completed purchases are retried; pending purchases are never acknowledged or granted. Play-managed refunds and account changes can only update an offline client once it reconnects and queries the store.

Sources: [Godot IAP](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_in_app_purchases.html), [plugin 3.3.0](https://github.com/godot-sdk-integrations/godot-google-play-billing/releases/tag/3.3.0), [Google purchase security](https://developer.android.com/google/play/billing/security).
