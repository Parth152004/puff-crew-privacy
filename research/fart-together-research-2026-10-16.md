# Fart Together — research report

Research date: 16 October 2026. Scope: the GamesMrkt Steam game, with a separate note on similarly named Roblox experiences. This is desk research, not a hands-on review or a code audit. Sources include current Steam listings and public APIs, developer statements, player reviews, community discussions, and selected secondary reporting. Features advertised for an unreleased game are promises, not verified shipped behavior.

**Principal finding.** Fart Together has a clear cooperative hook and encouraging early demo reception. Its commercial prospects remain uncertain: a free-demo audience does not establish willingness to pay, sustained retention, or the quality and quantity of the eventual full release.

**1. Identity and availability**

| Item | Finding |
|---|---|
| Developer and publisher | GamesMrkt |
| Full game | Steam app 5117550; unreleased, listed as coming soon |
| Demo | Steam app 5208630; free, released 8 October 2026 |
| Confirmed native platform | Windows PC |
| Current main premise | Two to four players jointly propel a raft through obstacles |
| Competitive capacity advertised | Up to eight players |
| Full-game price | Not published in the checked Steam listing; no INR price returned |

The [current full-game listing](https://store.steampowered.com/app/5117550/Fart_Together/) advertises online and shared/split-screen co-op and PvP, Remote Play Together, achievements, cloud saves, and leaderboards. Its [public metadata](https://store.steampowered.com/api/appdetails?appids=5117550&cc=in&l=english) marks Windows support and full controller support. These are full-game listing claims.

The [demo listing](https://store.steampowered.com/app/5208630/Fart_Together_Demo/) advertises online co-op and Steam Cloud. Do not assume the demo includes local play, eight-player competition, or the full game's controller support.

**2. How it plays**

Players are hippos on one raft. The group must coordinate propulsion direction, timing, and stamina to negotiate a course. The developer estimates a demo run at approximately 15–55 minutes, depending on coordination; this is not a guaranteed completion time or the full game's total length. See the [developer's demo introduction](https://www.reddit.com/r/playmygame/comments/1x1qam0/fart_together_our_free_24_player_coop_demo_is/).

The advertised challenges include tight routes, turns, moving hazards, and keeping the raft balanced. A mistimed input can compromise the entire group. The developer frames the physics as deliberately playful rather than a realistic boating simulation. [Official game description](https://store.steampowered.com/app/5117550/Fart_Together/).

As a design interpretation, the loop is: inspect the next obstacle, agree on a maneuver, combine inputs, observe the outcome, and revise the plan. The interaction is interesting because each player has partial influence over a common result. The group can understand the objective immediately while taking time to develop reliable control.

A successful cooperative maneuver provides evidence that the team is learning. Failure supplies an event people can discuss: someone acted too soon, two inputs conflicted, or the team overcorrected. That makes communication part of play rather than a separate social layer.

**3. Controls, multiplayer, and practical limitations**

A [community answer](https://steamcommunity.com/app/5117550/discussions/0/569300204759681687/) reports successful three-player support, consistent with the advertised range. It is a player answer, not a developer statement.

Another [player report](https://steamcommunity.com/app/5117550/discussions/0/569300204759702507/) describes failed Steam invitations and room-code joins. This supports the existence of invite/code flows and a reported joining problem; it does not establish the frequency, cause, or current fix status.

A [discussion about playing without friends](https://steamcommunity.com/app/5117550/discussions/0/569300204759580810/) suggests friction for people arriving alone. Public matchmaking, bot teammates, and satisfactory solo play were not established by the inspected current material. Older cached descriptions mentioned one-to-four-player solo play; the current description emphasizes two to four.

Exact default keyboard mappings, complete remapping options, mixed local/online parties, reconnect behavior, host migration, dedicated servers, and built-in voice chat remain unverified. For planning a session, assemble a group first and test that everyone can join before committing to a longer run.

**4. Demo reception and observed complaints**

The inspected Steam page showed **93% positive from 130 reviews**. A direct [Steam review API snapshot](https://store.steampowered.com/appreviews/5208630?json=1&language=all&filter=all&num_per_page=100&purchase_type=all) returned **125 positive and 11 negative, 136 total**, or approximately **91.9% positive**, also categorized Very Positive. Cached views and endpoint timing/filtering differ; these figures should not be combined into one supposedly exact live count.

I inspected the 100 records returned by the all-language review query and a separately requested negative subset. This was a convenience sample, not random sampling, and I did not statistically code or count themes. Many reviews are brief jokes, so a positive vote is more informative than taking every sentence literally.

Repeated positive themes were laughter with friends, satisfaction from coordination, and enthusiasm for the sound and physical comedy. Specific complaints included awkward camera angles, repetitive music, a checkpoint issue, difficulty/frustration, and a browser survey after exiting that reportedly leaves Steam showing the game as stopping. These are player reports, not reproduced defects. The join failure above provides a separate connection complaint.

Review IDs supporting the more specific observations include 237737444 (camera/music), 237510087 (checkpoint), 237811730 (survey/exit), 237768759 (sound/challenge), and 237806699 (group enjoyment), retrievable through the review endpoint. The saved JSON records the reviewed sample IDs without storing user identifiers or full review text.

The evidence supports an enjoyable early social experience for many reviewers. It cannot establish long-term replay value, network reliability across regions, or full-release quality.

**5. Audience, positioning, and discoverability — analysis**

The best audience hypothesis is a small existing friend group that enjoys coordination, physical comedy, and recoverable frustration. Creators who play with friends are another plausible audience because coordination mistakes produce understandable moments for spectators. These are interpretations of the concept and feedback, not measured audience segments.

The premise is easy to communicate in one sentence. A spectator can recognize the common vehicle and understand that the team is responsible for its movement. This reduces explanation time and gives short clips a useful structure: intention, conflicting actions, visible failure, and reaction.

The corresponding product risk is that the joke can become familiar before the movement system develops enough depth. Lasting interest would depend on fair control, varied situations, useful feedback, and a reason to improve after the first successful run. Cosmetic variety alone would not demonstrate those qualities.

Coordination difficulty and input ambiguity should be evaluated separately. Players can enjoy a demanding maneuver when they understand why it failed. A camera that conceals an obstacle, unclear propulsion feedback, or an unreliable connection can make an equally difficult failure feel arbitrary.

**6. Early traction and commercial evidence**

GamesMrkt publicly reported **1,000 Steam wishlists in five days** before the demo. The [announcement listing](https://steamcommunity.com/app/5117550/eventcomments/) dates the milestone to September; the claim also appears in the [studio's own posts](https://ec.linkedin.com/company/gamesmrkt). It is a historical, self-reported milestone, not the current wishlist total.

The [SteamDB demo chart snapshot](https://steamdb.info/app/5208630/charts/) displayed a peak of **2,279 concurrent players on 15 October 2026**, with approximately 1,549 playing in that captured view. These are third-party snapshot figures and can change. Concurrent players are not cumulative unique players, copies sold, or revenue.

There is a plausible early discovery signal, but no reliable paid-demand conclusion. I found no verified sales, revenue, acquisition cost, wishlist conversion, retention cohort, or total development budget. It would be misleading to infer any of those from demo reviews or concurrency.

**7. Release plans and monetization**

The developer said it planned to release shortly after October's Steam Next Fest in its [demo announcement](https://www.reddit.com/r/IndieGaming/comments/1x1qflk/we_made_a_coop_game_where_hippos_steer_a_raft_by/). The current authoritative store status remains coming soon. A third-party [catalogue lists 30 October and Early Access](https://everygame.gg/game/fart-together/trailers-and-media); I found no primary confirmation, so neither should be treated as established.

The [official app metadata](https://store.steampowered.com/api/appdetails?appids=5117550&cc=in&l=english) marks the full game as not free, but supplies no price. That suggests an intended paid product, not a final commercial commitment. The demo is free. DLC, microtransactions, cosmetic purchase pricing, subscriptions, and a battle pass were not verified. A casual yes in a user forum is insufficient confirmation of a DLC plan.

Older cached descriptions mention Free Mode, Time Trial, Team Races, cosmetic rewards, and customizable controls. Some current metadata supports competitive play and leaderboards, but the named mode list and cosmetic progression were absent from the current main description inspected. Keep these as historical advertised details requiring reconfirmation.

**8. PC requirements and accessibility**

| Component | Minimum | Recommended |
|---|---|---|
| OS | Windows 10, 64-bit | Windows 10/11, 64-bit |
| CPU | Intel i5-8400 / AMD Ryzen 3 1200 | Intel i5-10400 / AMD Ryzen 5 3600 |
| RAM | 8 GB | 16 GB |
| GPU | GTX 1050 Ti / Radeon RX 560 | GTX 1660 / Radeon RX 590 |
| Storage | 4 GB | 4 GB |
| Other | DirectX 11; broadband for online play | DirectX 11; broadband for online play |

These are published targets, not benchmarks. They match Steam and the [15 October VZone report](https://vzone.gg/noticia/fart-together-como-baixar-jogar/). No measured frame rates or performance on integrated graphics were verified.

Steam lists 17 interface languages, including English, Brazilian Portuguese, Arabic, and Persian. Hindi is not listed. Accessibility declarations include keyboard-only input, camera comfort, and separate volume controls. These are publisher declarations, not an independent accessibility evaluation. Steam Deck compatibility was shown as unknown for the demo; native macOS/Linux support was not listed. [Demo listing](https://store.steampowered.com/app/5208630/Fart_Together_Demo/).

No verified standalone console or mobile release was found. A similarly named Roblox experience or generic mobile catalogue entry does not establish a port of the GamesMrkt game.

**9. Developer background and technical evidence**

The [GamesMrkt website](https://www.gamesmrkt.com/) says the studio was founded in Mersin, Türkiye, in 2018 and has released more than 15 games reaching over 50 million players. Those are studio-wide self-reported figures, not Fart Together statistics. Its listed portfolio includes Skillful Finger and My Arcade Center.

The studio says the game's first version took two months to develop; that is not the same as total production time. Its public [company profile and hiring material](https://ae.linkedin.com/company/gamesmrkt) mention Unity, C#, and multiplayer frameworks, but do not prove which exact engine version or networking framework Fart Together uses. A third-party catalogue labels it Unity 6; I could not independently establish that from game-specific primary evidence.

For an engineering study, a useful conceptual model is that combined player forces determine raft movement and off-center forces can induce rotation. That is a generic rigid-body interpretation, not a reconstruction of the actual implementation. Physics constants, network authority, synchronization frequency, prediction, reconciliation, transport, backend provider, and anti-cheat remain unknown.

**10. Comparable games**

The factual descriptions below come from each game's official store page. The comparison and lessons are my analysis; none establishes influence or affiliation.

| Reference | Relevant mechanic | What to compare with Fart Together |
|---|---|---|
| [Chained Together](https://store.steampowered.com/app/2567870/Chained_Together/) | One-to-four-player climbing with physically linked players | Shared consequences, recovery after mistakes, and the balance between tension and repetition |
| [Heave Ho](https://store.steampowered.com/app/905340/heave_ho/?l=english) | Up to four players grab and swing through physical challenges; couch play and Remote Play | Readability of physical comedy, clear cause and effect, and quick cooperative problem-solving |
| [Bread & Fred](https://store.steampowered.com/app/1607680/_Bread__Fred/?l=english) | Two penguins coordinate jumps and swings while climbing | Timing communication, teaching precision, and how much lost progress a group tolerates |

Fart Together's central distinction within this comparison is that players jointly operate one vehicle. A design review should ask whether each player's contribution is visible and meaningful, whether the team can recover from small errors, and whether the required coordination changes enough across obstacles.

**11. Name confusion: Roblox**

A separate account presents a Roblox game called Fart Together as a solo-developed project. Its [15 October post](https://www.reddit.com/r/robloxgamedev/comments/1x6bzc8/made_a_coop_game_where_4_hippos_move_a_raft_only/) describes one-to-four hippos, lobbies, and environmental hazards. A [16 October post](https://www.reddit.com/r/robloxgamedev/comments/1x70zu2/my_coop_raft_game_felt_empty_for_solo_players_so/) discusses solo races and bot rivals.

These are self-reported development posts. I found no verified relationship to GamesMrkt, no confirmed shared release identity, and no basis to merge their mechanics, controls, monetization, or player counts. The similarity does not by itself establish affiliation, authorization, or copying. This report's main findings concern the Steam title.

**12. Strengths, risks, and practical recommendations — analysis**

| Area | Assessment |
|---|---|
| Strongest hook | A common goal and vehicle make cooperation immediately understandable |
| Best supported strength | Early reviewers repeatedly describe enjoyable group sessions |
| Main product uncertainty | Whether control depth and course variety sustain interest after the joke is familiar |
| Immediate friction | Forming a group, joining reliably, and seeing obstacles clearly |
| Commercial uncertainty | Unknown full-game price, content volume, launch date, and paid conversion |
| Growth opportunity | Clear clips of cooperative attempts, recoveries, and dramatic mistakes |

For a player, the sensible next step is the free demo with two or three friends. Use it to evaluate camera comfort, connection reliability, tolerance for retries, and whether the group enjoys negotiating movement. Buying the eventual game should depend on its price, final content, and launch feedback.

For someone studying the design, prioritize five questions: can a first-time group understand each input's effect; can they diagnose a failure; can they restart without excessive waiting; do different obstacles demand different strategies; and does success produce a desire to improve? These tests are more useful than copying the surface joke.

For product evaluation, measure invitation-to-join completion, time to first successful maneuver, failure/retry rates by section, session abandonment after repeated failures, return sessions, and how those measures differ between two-, three-, and four-player groups. These are proposed measurements, not data available for this game.

**13. Remaining unknowns and research boundary**

Public research cannot currently resolve the final course count, complete mode roster, full-game playtime, save/checkpoint rules, exact controls, public matchmaking, mixed local/online play, voice chat, reconnect/host migration, server regions, verified hardware performance, engine/network implementation, final monetization, or current total wishlists. Formal age ratings were not established; a family-friendly store tag is not a rating.

I did not install the demo, join its Discord, contact the developer, purchase anything, or reproduce reported defects. The official trailer was located at [GamesMrkt's YouTube video](https://www.youtube.com/watch?v=N6aVfoC7Dss), but playback could not be inspected in this research run; no frame-by-frame visual conclusions are claimed.

The saved [source snapshot](fart-together-source-snapshot-2026-10-16.json) preserves selected public Steam metadata, review totals, and reviewed record IDs. This report distinguishes current listings, historical promises, player anecdotes, secondary measurements, and original analysis so later decisions can be updated without treating speculation as fact.
