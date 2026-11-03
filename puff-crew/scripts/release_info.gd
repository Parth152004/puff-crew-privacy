class_name CrewRelease
extends RefCounted

const VERSION = "1.0.0"
const PUBLISHER = "Ramo Labs"
const SUPPORT_EMAIL = "jayvekaria282@gmail.com"
const PRODUCT_ID = ""
const OUTFITS = ["CLASSIC", "MARINER", "SUN SEEKER", "STARGAZER"]

static func privacy_lines() -> Array[String]:
	return [
		"Ramo Labs / Puff Crew: Rapids / Version 1.0.0",
		"No game account, ads, analytics or location tracking.",
		"Settings, outfits, best times and game progress stay on this device.",
		"Nearby discovery shares your local IP and crew/course availability.",
		"Crew connections exchange controls, outfits and shared game state.",
		"These connections go to your crew, not to a Ramo Labs server.",
		"This game is 100% free with no in-app purchases or subscriptions.",
		"All expedition outfits are completely free for all players.",
		"No card, bank details or personal financial data are collected.",
		"Support email is optional. We use messages only to help you.",
		"Clear app storage to erase local data.",
		"You can request deletion of support messages by email.",
		"Privacy/support: " + SUPPORT_EMAIL
	]
