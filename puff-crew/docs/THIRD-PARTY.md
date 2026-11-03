# Third-party components

- **Godot Engine 4.7.2** — MIT-licensed game engine. Android binaries include the Godot runtime and its third-party components. Full notices are included in `assets/GODOT-LICENSE.txt` and `assets/GODOT-THIRD-PARTY.txt`, exported with the game. Sources: https://godotengine.org/license/ and https://github.com/godotengine/godot/blob/4.7.2-stable/COPYRIGHT.txt .
- **Outfit** — Copyright 2021 The Outfit Project Authors. SIL Open Font License 1.1, full text in `assets/FONT-LICENSE.txt`. Static weights were instantiated from the included variable font with fontTools. Source: https://github.com/google/fonts/tree/main/ofl/outfit .
- **fontTools** — optional development tool for regenerating static fonts, not a runtime dependency. The distributed game loads the included font files.
- **GodotGooglePlayBilling 3.3.0** — MIT-licensed first-party plugin, staged for future publishing work. Its native SDK/dependencies are excluded from the current debug playtest, which provides all outfits without purchases. Local export-plugin change: debug exports return no Android libraries/dependencies. Full license: `addons/GodotGooglePlayBilling/LICENSE`. Source: https://github.com/godot-sdk-integrations/godot-google-play-billing/releases/tag/3.3.0 . Downloaded archive SHA-256: `20d75623d6f337f08d8283c83098b73678d5f575e39247af5a8eb80588b18568`.

Character/environment geometry, UI, icon SVG, shader, generated audio and game source were created for this project. No gameplay video, extracted commercial character model or soundtrack is included in the game.
