# Publishing and revenue options for Puff Crew: Rapids

Researched **17 October 2026**, for an India-based developer who already has a Google Play developer account. This report uses official platform documentation and the actual local project. Platform facts are linked beside the relevant claims. Recommendations, candidate prices and financial scenarios are our analysis, not platform promises or revenue forecasts. Account-specific production access, merchant setup and store approval have not been inspected.

## Recommended direction

**Launch on Google Play first, with a free playable base and a small number of permanent purchases. Keep joining a crew free.** Start with an optional cosmetic/supporter bundle; add a paid expansion when there is substantially more course content. A captain-owned expansion that guests can play during that captain's session is worth testing. That is a proposed game entitlement design, not a platform feature or permission already obtained.

The reason is specific to this game: four people must install it before a group can play. Four upfront payments add friction. Free joining lets an enthusiastic player recruit friends; cosmetics and optional courses can earn revenue after the group enjoys the game. LAN hosting also avoids a recurring hosted-game-server bill in the current design.

Two alternatives remain useful. **A paid download is the simplest monetization implementation**, since it avoids an in-game billing SDK. **A pay-what-you-want itch.io release is the quickest independent route to a public download and voluntary support**, subject to seller/payment setup. Neither creates an audience automatically.

I would postpone forced ads, subscriptions and paid user acquisition. The present three compact courses need physical-device and human retention testing before we can estimate their commercial value.

## What can be published from the current build?

The local build is version 0.1.0, an approximately 28 MB **debug-signed ARM64 APK**, minimum Android API 24, target API 36. It has solo play, three short courses and a 2–4-player LAN lobby. There is no billing, advertising, account, analytics or entitlement system. Test evidence covers 25 behavior checks, all courses, four desktop processes, and two Android emulators; physical phones remain untested. See the project's `docs/QA.md` and `builds/build-report.json`.

The current APK is suitable for controlled playtesting. **It is not the file to upload as a new public Google Play release.** Godot's publishing documentation requires an Android App Bundle for a new Play app and non-debug signing. We must configure the Gradle/AAB export and your release/upload-key workflow. [Godot Android publishing instructions](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).

The existing target API 36 meets the published new-app target requirement effective 31 August 2026. [Android target API requirements](https://developer.android.com/google/play/requirements/target-sdk).

Android's 16 KB requirement also matters because Godot includes native libraries. A fresh read-only audit of this exact APK passed `zipalign -c -P 16 -v 4`; both ARM64 libraries have 16,384-byte alignment for every load segment. That is useful static evidence, **not a 16 KB runtime-device test or proof that a future SDK-integrated AAB passes**. Recheck the final release, including plugins. Evidence: `builds/release-readiness-zipalign.log` and `builds/release-readiness-elf.json`. [Android 16 KB guidance](https://developer.android.com/guide/practices/page-sizes).

## The revenue models

These cover the principal direct and indirect commercial routes. They are alternatives to select and combine carefully, not a list of features to implement together.

| Model | What the customer or partner pays for | Fit for this game | Main work or tradeoff |
|---|---|---|---|
| Paid download | One purchase per store account to install | Reasonable simple alternative | No billing UI needed, but every friend faces a purchase decision; the short content must justify the price |
| Free demo + permanent full unlock | More courses/modes after trying the base | Strong after content expansion | Billing, restore, entitlements and a clear free/paid boundary |
| Cosmetic bundles | Scarves, raft themes, hats, trails or celebrations | Strong first purchase | Add visible customization, sync it over LAN and keep performance equal |
| Supporter edition | A voluntary paid bundle with a badge/cosmetic extras | Good early option | Clear description of what is delivered; do not promise unspecified future content |
| Paid course packs/DLC | A fixed set of additional obstacle runs | Strong medium-term option | Design and playtest enough distinct courses to provide value |
| Captain/party pass | The owner can host additional courses for their crew | Promising experiment | Define session-only guest access, verify the host's entitlement and explain who can host afterwards |
| Rewarded ads | Advertiser pays when players voluntarily view an ad | Conditional | SDK/consent/review; use optional cosmetic rewards outside active sailing |
| Interstitial ads + remove-ads purchase | Ads between completed runs; one purchase removes them | Weaker than optional rewards | Frequency caps, lifecycle handling, purchase restore; interruption can lose the whole group |
| Banner/native ads | Advertising space in menus | Low priority | Limited screen space and modest inventory; never obscure touch controls |
| Consumable currency/boosts/retries | Repeated purchases of spendable items | Poor fit initially | Economy, fraud, refunds and fairness; a stronger puff or paid recovery changes shared outcomes |
| Subscription | Regular content or a meaningful ongoing service | Poor fit today | A three-course LAN game does not yet offer recurring value; requires reliable content cadence |
| Season/battle pass | A finite progression track and cosmetic rewards | Later only | Considerable content, progression, support and event work |
| Pay-what-you-want/tips | Voluntary support for the download or creator | Good small-audience route | Traffic, payment availability and billing rules if surfaced inside the Play app |
| Publisher deal | Advance, development support, marketing and/or revenue share | Worth exploring after real playtests | Selective; advances may be recouped before royalties; negotiate control and rights |
| Subscription-catalog license | Inclusion in a service such as Play Pass | Later opportunity | Selective admission and contract-specific compensation; no guaranteed payout |
| Web-portal revenue/license | Browser ad share, purchases or a flat license | Useful second product | Browser port, SDK and performance work; LAN networking needs adaptation |
| Sponsorship/branded edition | A company funds a themed course, event or campaign | Plausible B2B route | Sell and deliver a custom project; rights, brand approval and commercial-content disclosures |
| Venue/event license | Organizers license an installation or party experience | Niche but compatible with LAN | Event tooling, device setup, support and commercial terms |
| White-label/source/template license | Other studios buy a reusable framework or reskin | Separate developer-facing business | Documentation, license terms, updates/support; may create direct competitors |
| Full game/IP sale | Buyer acquires specified code, assets and rights | Possible exit | One-off proceeds; negotiate ownership, liabilities and any retained rights |
| Crowdfunding/memberships | Fans fund development or regular creator updates | Only with an audience | Fulfillment and ongoing commitments; funding is not evidence of game-market demand |
| Merchandise/content business | Physical goods, devlog/channel income, tutorials | Later, indirect | Requires fans or an education audience; manufacturing/platform costs and time |
| Incubator/grant/investment | Funding or capital for development | Optional parallel route | Competitive selection and eligibility; capital/recoupable funding is not ordinary sales revenue |

For Play-distributed digital unlocks, cosmetics and ad removal, the default is Google Play Billing unless an applicable permitted alternative program applies. Ordinary commercial supporter purchases are not automatically exempt charitable donations. [Google Play Payments policy](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en).

### A small initial product catalog

These are **candidate Indian consumer prices to test**, not validated willingness-to-pay estimates. Configure regional prices separately.

| Candidate product | Test price | Proposed contents |
|---|---:|---|
| Base game | Free | Current three courses, solo and joining/hosting their LAN sessions |
| Explorer cosmetic/supporter bundle | ₹99–₹149 | Several original scarves/raft styles, badge and a celebration; no power advantage |
| New river expansion | ₹149–₹299 | A clearly specified set of genuinely new, longer courses; build these before selling |
| Captain expansion edition | ₹199–₹399 | Alternative packaging of the expansion with proposed session guest access; test whether groups prefer this |
| Premium paid app alternative | ₹149–₹299 | Choose this instead of the free-base strategy if simple billing-free distribution is the priority and playtests support value |

Do not ship all these SKUs together. Begin with one clear purchase. If there are no forced ads, do not sell a misleading “remove ads” product. State whether a bundle covers only today's contents or named future additions; avoid a perpetual promise that limits later pricing.

There is a consequential Play pricing rule: after an app has been offered free, the same package cannot be converted to a paid download; a paid app can become free. A free app can still sell IAP. Decide the base model before the public free release. [Play app pricing](https://support.google.com/googleplay/android-developer/answer/6334373).

## Publishing channels, ranked

| Channel | Cost/economics verified in public sources | Practical recommendation |
|---|---|---|
| **Google Play** | You already have the developer account. For eligible enrolled developers in remaining markets such as India, the 15% tier applies to the first US$1M annual earnings, then 30%; fees differ for some overseas buyers under 2026 regional rules | First commercial channel; best use of your existing account and straightforward Android discovery/install/update flow |
| **itch.io** | Seller chooses the platform revenue share from 0–100%; payment processing and tax/payment setup still apply. Paid and pay-what-you-want downloads supported | Good for a clearly labeled playtest/indie release, supporter sales and direct community links; mobile users must sideload the APK |
| **Samsung Galaxy Store** | No signup/annual publishing fee; developer normally receives 80% of net sales for paid games and standard IAP using Samsung Checkout, subject to deductions | Useful second Android store; confirm commercial seller approval and implement the appropriate billing flavor |
| **Indus Appstore** | Promotes choice of external in-app payment gateway and zero commission on those payments. Current terms permit notified fees; the 2024 free-listing promotion is not proof of free listing in 2026 | Worth evaluating for India after Play; confirm current dashboard fees, eligible monetization and payment settlement before committing |
| **Epic Games Store mobile** | Store advertises 100% of the first US$1M net revenue per product/year from Epic-processed payments, then 88/12. Mobile access is described through its Early Adopter program | Investigate onboarding eligibility; do not assume general PC self-publishing access automatically grants mobile publishing |
| **TapTap** | Official developer docs support approved developer accounts and APK distribution; monetization/territory terms require checking | Additional discovery/community channel; review the agreement's release/removal obligations before accepting |
| **Huawei AppGallery** | Distribution and paid cooperation routes exist; game-specific commercial terms and territories vary | Target only after confirming device compatibility, account eligibility and applicable billing terms; do not reuse old promotional splits |
| **Your own website/direct APK** | No app-store commission on your own direct transactions, but hosting, gateway, fraud, tax and update support remain | Useful for testers or a known community. Public sales need trust, distribution/update design and verification planning |
| **Gumroad** | Public pricing states 10% + US$0.50 on direct/profile sales and 30% on Discover sales; payout method depends on country | Better suited to higher-priced source/template packs than very cheap APKs because of the fixed fee |
| **CrazyGames** | Web distribution; Basic Launch does not monetize. Full Launch requires its SDK and enables the revenue-sharing opportunity | Later browser demo/solo product, subject to selection and performance |
| **Poki** | Curated web deals: preferred web-exclusive arrangement; published docs describe 50/50 for Poki-acquired users and 100% developer share for direct users; non-exclusive flat-license possibilities | Consider only after assessing web exclusivity. Its default exclusive term is five years; Steam/mobile rights are outside web exclusivity |
| **Steam/PC** | Steam Direct is US$100 per product, recoupable after US$1,000 adjusted gross revenue; onboarding includes a 30-day fee-to-release wait | A later PC edition could be a separate revenue stream. It needs PC-quality controls/content and an honest LAN-only listing unless internet multiplayer is added |
| **Apple App Store** | US$99/year membership; eligible enrolled Small Business developers can qualify for 15% commission under standard terms | Later iOS port; requires Apple signing, purchase integration and device testing, not uploading the Android APK |
| **Fire tablets/TV** | Amazon still supports Fire devices, but discontinued the general Android-phone Appstore on 20 August 2025 | Only an intentional Fire-device adaptation; not an alternative general Android-phone launch |
| **Consoles** | Platform approval and a porting path are required; Godot uses approved third-party/middleware options or developer-built ports | Long-term opportunity after proven demand, not the next release step |

Sources: [Play fees](https://support.google.com/googleplay/android-developer/answer/112622?hl=en), [itch.io payments](https://itch.io/docs/creators/payments), [itch.io pricing](https://itch.io/docs/creators/pricing), [Samsung FAQ](https://developer.samsung.com/galaxy-store/faq.html), [Indus announcement](https://www.indusappstore.com/press/phonepe-unveils-indus-appstore-a-game-changer-in-indias-digital-journey/), [Indus current terms](https://www.indusappstore.com/developer-tnc/), [Epic distribution](https://store.epicgames.com/distribution), [Epic mobile onboarding caveat](https://store.epicgames.com/distribution/web-shops), [TapTap release guide](https://developer.taptap.io/docs/store/store-creategame/), [TapTap agreement](https://developer.taptap.io/docs/store/store-devagreement/), [Huawei distribution](https://developer.huawei.com/consumer/en/appgallery), [Gumroad pricing](https://gumroad.com/pricing), [CrazyGames launch/ads](https://docs.crazygames.com/requirements/ads/), [Poki deal types](https://developers.poki.com/guide/revenue-deal-types), [Poki revenue details](https://developers.poki.com/guide/working-with-poki), [Steam fee](https://partner.steamgames.com/doc/gettingstarted/appfee), [Steam onboarding](https://partner.steamgames.com/steamdirect), [Apple program](https://developer.apple.com/programs/), [Apple Small Business](https://developer.apple.com/app-store/small-business-program/), [Amazon discontinuation](https://developer.amazon.com/apps-and-games/blogs/2025/02/upcoming-changes-to-amazon-appstore-for-android-devices-and-coins-program), [Godot consoles](https://godotengine.org/consoles/).

### Direct distribution is still a managed release

Google's updated Android verification rollout began on 30 September 2026 for participating stores in Brazil, Indonesia, Singapore and Thailand on certified Android 7+ devices, with broader expansion planned for 2027. Play Console is a verification path for developers who distribute on and outside Play. This is **not an assertion that direct APKs are currently blocked in India**. Account and package registration should be checked before broad international sideload distribution. [Android verification and rollout](https://developer.android.com/developer-verification).

Keep store variants and update ownership deliberate. A Play-signed installation and a directly distributed APK with a different signing certificate do not form a seamless update path. Your existing debug APK should not become the long-term public distribution identity. Where billing differs by store, separate configurations/package IDs can reduce accidental cross-store updates. Samsung specifically recommends different package names when using Samsung IAP across stores. [Samsung FAQ](https://developer.samsung.com/galaxy-store/faq.html).

### Web is a port, not another upload of this APK

Godot can export this GDScript/Compatibility-renderer project to the browser, but WebAssembly/WebGL 2 support, memory, loading, audio startup and portal SDK integration must be tested. More significantly, browsers do not provide the low-level sockets used by this game's ENet and UDP discovery. A browser version needs solo mode initially, or redesigned networking using supported browser transports and likely signaling/relay infrastructure. Do not sell the web port as equivalent same-Wi-Fi co-op without that work. [Godot web export and networking limits](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).

## Advertising: useful only when it fits the session

**Recommended experiment:** optional rewarded videos on a results/customization screen for a temporary cosmetic preview or cosmetic progress. Reward completion must not affect raft physics or split the group. No internet/ad fill should leave the core game fully playable.

**Avoid:** ads during steering, ads after every splash, one client being held at a checkpoint by a video, mandatory ad viewing before a friend can join, or gameplay advantages tied to purchases. In the present code, host focus loss pauses the simulation; an ad/payment overlay can affect focus. We must explicitly test the whole crew's pause/ready/resume behavior around SDK overlays, cancellation, loading failure and backgrounding.

AdMob requires a supported-store listing and app readiness review. New Play-listed apps also need app-ads.txt verification before full ad serving. A standalone APK link is not, by itself, an immediate approved AdMob business. [AdMob readiness](https://support.google.com/admob/answer/10564477?hl=en), [app-ads.txt verification](https://support.google.com/admob/answer/14538460?hl=en).

Ad SDK data practices change the privacy disclosures. For relevant European traffic, Google's personalized-ad requirements include a certified CMP integrated with the IAB TCF; UMP is Google's implementation option. Consent denial, privacy-option reopening and ads-unavailable behavior need testing. [Google consent requirements](https://support.google.com/admob/answer/13554116?hl=en), [Android UMP](https://developers.google.com/admob/android/privacy).

The cartoon presentation makes audience definition a real product decision. Select ages honestly; an age rating and intended target audience are separate. If children are included, additional SDK, advertising and data rules apply, including certified SDK requirements and restrictions on personalized advertising. Do not simply label it adult-only to avoid those obligations. [Play Families policy](https://support.google.com/googleplay/android-developer/answer/9893335?hl=en).

AdMob is one implementation option. Mediation with additional ad networks can be evaluated after real traffic exists; adding more SDKs now increases integration and disclosure work without establishing demand. No ad network can guarantee this game's eCPM, fill rate or earnings.

## Publisher, licensing and funding routes

**Mobile publishing:** Voodoo accepts games through its publishing routes. This is a lead to assess, not evidence of acceptance or a standard commercial offer. Our LAN party design may fit differently from its performance-driven mobile catalog. Prepare a polished playable build, a short honest trailer, actual retention/session evidence, a development budget and a clear rights statement. [Voodoo publishing](https://voodoo.io/publishing).

**Premium/PC publishing:** Team17 has an official pitch route. A larger PC/console party-game edition would be a more relevant pitch than treating today's short Android prototype as a finished premium product. [Team17 pitch](https://www.team17.com/pitch-your-game).

**Catalog licensing:** Play Pass invites developers to express interest. Apple Arcade is another curated catalog route after an Apple-platform plan. Selection and economics are contract-specific; neither should be entered into a revenue forecast without an offer. [Play Pass](https://google.play/business/programs/googleplaypass/), [Apple Arcade](https://developer.apple.com/apple-arcade/).

**India incubation:** KRAFTON India Gaming Incubator describes mentorship and support for Indian developers/studios. Check the current cohort, entity/team requirements, funding structure and selection terms; an old FAQ's application date is not evidence of a currently open window. [KIGI](https://krafton.in/kigi).

**Crowdfunding and memberships:** itch.io supports early access and project goals; Patreon supports memberships/digital sales, with a standard 10% platform fee for new creator pages plus applicable processing/taxes. These need an audience and deliverables. Kickstarter currently lists 25 eligible creator countries and India is not on that list; an India-only residence/entity is not sufficient to launch there. Do not use a fictitious foreign address. [itch.io options](https://itch.io/docs/general/about), [Patreon fees](https://support.patreon.com/hc/en-gb/articles/36426991446797-A-standard-platform-fee-for-new-creators-effective-after-4-August-2025), [Kickstarter eligibility](https://help.kickstarter.com/en-us/articles/16236782-when-will-kickstarter-be-available-in-other-countries).

**B2B licensing:** propose a branded team challenge for events, cafes, resorts or company gatherings, priced as development/license/support work. This is our commercial hypothesis, not evidence of interested buyers. A one-off project can earn money without mass downloads, but sales, support and contracts become the business.

Before accepting a publisher, portal or acquisition deal, have its agreement reviewed for: IP ownership, platforms/territories, exclusivity duration, definition of net receipts, recoupable marketing costs and caps, milestone cancellation, minimum commitments, reporting/audit, update obligations, source handover, termination/reversion and rights to sequels. A headline revenue split alone is insufficient.

## Economics: illustrations, not forecasts

There is no reliable earnings forecast yet. We do not have real installs, human retention, purchase conversion, refund rates, measured ad impressions or acquisition cost. These scenarios show what to measure.

### Permanent purchase

For a **tax-exclusive calculation basis** of ₹149 per purchase and an assumed 15% store fee:

| Scenario | Purchases | Sales basis | After assumed store fee |
|---|---:|---:|---:|
| 10,000 free installs; 1% buy | 100 | ₹14,900 | ₹12,665 |
| 10,000 free installs; 3% buy | 300 | ₹44,700 | ₹37,995 |
| 10,000 free installs; 5% buy | 500 | ₹74,500 | ₹63,325 |
| 1,000 paid downloads | 1,000 | ₹149,000 | ₹126,650 |

The paid-download row requires 1,000 paying customers; it does not assume the same conversion as free installs. The ₹149 calculation basis is **not** the bank proceeds from a ₹149 tax-inclusive Indian store price. These amounts exclude indirect taxes, taxes on fees, withholding cash-flow effects, refunds, development, support and marketing. The actual fee depends on program and buyer region.

At 3% conversion, this example yields ₹3.80 per free install before those further deductions. Buying installs at ₹10 each would lose money on this purchase alone: 10,000 installs cost ₹100,000 versus ₹37,995 after the modeled store fee. A low-cost install campaign is not profitable just because it is cheap relative to another campaign.

### Advertising

`Monthly ad revenue ≈ average DAU × served impressions per DAU/day × 30 × realized publisher eCPM / 1,000`.

| Average daily active users | Actually served ads per user/day | Assumed eCPM | Illustrative month |
|---:|---:|---:|---:|
| 1,000 | 1 | US$2 | US$60 |
| 1,000 | 1 | US$5 | US$150 |
| 1,000 | 2 | US$5 | US$300 |
| 10,000 | 1 | US$5 | US$1,500 |

The eCPMs are chosen sensitivity inputs, not observed India benchmarks or network quotes. Use actual served impressions, not ad requests; multiply by consent/availability/fill effects if starting from opportunities. DAU is not downloads. Local Wi-Fi need not have internet, and many users may never opt into a reward. Do not apply the Play IAP fee mechanically to publisher ad earnings; model the ad network's actual payout terms and deductions separately.

Measure first-time tutorial completion, time to solo success, lobby discovery/join success, percentage reaching a two-person session, repeated crew sessions, day-1/day-7 return, crash/ANR rates, purchase conversion and refunds. For this social game, repeat crew formation is as useful as individual retention. Begin with consent-appropriate minimal measurement; do not silently add tracking to a previously tracking-free build.

## India-specific money and payment decisions

1. **Check your merchant/payments setup.** A developer account does not prove that bank verification, commercial agreements, tax identity or payouts are configured. Confirm PAN, legal/entity details and applicable GSTIN requirements. Google's India guidance leaves India-based developers responsible for determining their GST obligations and taxes on service fees; Google may deduct applicable income withholding and GST TCS. Do not treat gross receipts as spendable profit. Have an Indian CA classify the actual arrangement, including international receipts. [Google India tax guidance](https://support.google.com/product-documentation/answer/15152449), [India verification/GST guidance](https://support.google.com/paymentscenter/answer/7421525?hl=en-IN).
2. **Enroll/check the appropriate fee program.** Do not assume the 15% tier is automatically enabled. It requires enrollment and associated-account disclosures. The current fee table has changed in several overseas regions; selling from India does not make every buyer's transaction an India transaction. [15% enrollment](https://support.google.com/googleplay/android-developer/answer/10632485), [current regional fees](https://support.google.com/googleplay/android-developer/answer/112622?hl=en).
3. **Do not add a normal UPI/Razorpay checkout to the Play app as an assumed fee bypass.** India permits qualifying alternative billing alongside Play under a formal program. Its fee reduction is four percentage points, not elimination: a 15% applicable fee becomes 11%, before gateway/operating costs. Reporting and program requirements still apply. It is likely unnecessary complexity at our initial scale. [India alternative billing](https://support.google.com/googleplay/android-developer/answer/13306652).
4. **Separate sales channels and products clearly.** A source-template sale or physical merchandise business is different from an in-app course unlock. A website does not automatically make steering Play users to external digital purchases compliant; evaluate the program for the user's region and channel. [Payments policy](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en).
5. **Keep this an entertainment game.** Entry-fee cash contests, wagering and cash-out tokens are not a sensible monetization extension. India's current Play country requirements prohibit apps considered online money games under the applicable law. This report does not assess a money-gaming business. [Play country requirements](https://support.google.com/googleplay/android-developer/answer/6223646).

## Concrete path to public release

| Stage | Work and exit condition |
|---|---|
| 1. Confirm account status | Check personal/organization type, creation date, production access, verification and merchant setup. No need for a second account solely for this game |
| 2. Fix the product/price promise | Choose free + one permanent purchase or paid download; confirm title/package identity, target audience and what LAN-only means in the listing |
| 3. Validate the actual phones | Test solo plus 2, 3 and 4 physical phones on at least a normal router and an isolation/restricted-network case; cover Samsung/other GPU vendors, weak devices, focus loss, reconnect expectations, touch, heat and battery |
| 4. Prepare a production build | Gradle release AAB, safe upload-key custody/Play App Signing plan, versioning, remove test-only code from release, final ABI/16 KB/target API checks, symbol/debug artifact handling and install/update tests |
| 5. Add only the chosen monetization | For IAP: product catalog, localized store-returned prices, pending/canceled/failed states, verified grants, acknowledgement, purchase restore and offline entitlement rules. Test refunds and reinstall |
| 6. Prepare the listing and policies | Real screenshots/trailer, icon/feature art, honest short/long description, support contact, privacy policy URL and in-app link/text, Data safety, ads declaration, intended ages, IARC content rating and reviewer access instructions for LAN testing |
| 7. Internal → closed test | Use Play-distributed builds to test purchases and real installation. Resolve store pre-launch reports and observe real gameplay; keep LAN testing separate from store-account eligibility |
| 8. Production access/review | If required, complete the personal-account closed test and apply for production; approval and further review are not guaranteed by hitting a timer |
| 9. Controlled public launch | Select countries deliberately, check purchases/support, monitor vitals and reviews, and expand after evidence supports it. Do not spend heavily on acquisition before retention and net value are measured |

New personal accounts created after 13 November 2023 need at least 12 testers continuously opted into a closed test for 14 days before applying for production access. Your existing account may already be eligible; its age/type and the game's production-access state must be checked. An account's mere existence does not settle the requirement. [Testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465).

Every app needs accurate privacy/Data safety disclosures, including third-party SDK behavior; a no-account/no-ads app is not exempt from the privacy-policy requirement. We currently lack an in-game privacy/about page and published policy. Describe local best-time storage and LAN peer exchange accurately rather than blindly selecting “no data” because there is no cloud backend. [User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en), [review preparation](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en).

Godot supplies an Android Play Billing plugin, so an engine change is not required to sell purchases. Verify the plugin's actual Billing Library version and compatibility before implementation: version 7's ordinary submission deadline was 31 August 2026, while version 8's is 31 August 2027. Test a supported integration rather than relying on an old tutorial. Secure-backend verification is Google's recommended stronger purchase-processing design; the current game has no backend. Its need/cost should be chosen deliberately, while keeping already-owned LAN gameplay usable offline. [Godot IAP](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_in_app_purchases.html), [billing version deadlines](https://developer.android.com/google/play/billing/deprecation-faq), [purchase security](https://developer.android.com/google/play/billing/security).

## Rights and discoverability

Godot's MIT license permits commercial distribution without an engine royalty, while requiring applicable notices; it does not force our game source to be public. The engine/font notices are already included in the project. This does not establish clearance for the game's name or every possible similarity. [Godot license](https://godotengine.org/license/).

Market **Puff Crew** under its own identity. Do not use Fart Together's name/logo, extracted art, footage or implied affiliation as the store branding. Perform title/trademark searches before spending on a brand, retain the asset/source provenance, and review any third-party or AI-tool terms relevant to materials added later. A distinct title and original assets help but are not a legal clearance opinion. [Play intellectual property](https://support.google.com/googleplay/android-developer/answer/9888072), [impersonation](https://support.google.com/googleplay/android-developer/answer/9888374).

Commercially, lead with the actual hook: friends steering one raft from separate phones on the same Wi-Fi. Use short real clips showing conflicting thrust, a team recovery and a successful obstacle. Test the installation/join instructions with people who did not build the game. Hindi/Gujarati and other languages can be tested as audience-specific store/tutorial improvements. Creators, campus groups and local game gatherings are potential acquisition experiments, not guaranteed distribution. In the current version, do not advertise internet matchmaking or remote co-op.

## Decision to make next

**Preferred:** Google Play free base + one ₹99–₹149 cosmetic/supporter bundle, after release preparation and real-phone tests; develop and validate an expansion before adding course purchases. Consider itch.io for community downloads/support and Samsung/Indus as later channels.

**If minimum monetization engineering is the priority:** choose a paid Play download, validate that the content justifies its price, and complete the same release/signing/privacy/device work. No ad or IAP SDK is needed for that option.

**If avoiding consumer-scale marketing is the priority:** prepare a publisher pitch or try a small paid branded/event commission. Those require sales/negotiation and can change ownership and creative control.

This research changes no live listing, account, payment setup or game monetization. No server or emulator was started for the research.
