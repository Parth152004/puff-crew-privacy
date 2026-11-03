class_name CrewStore
extends Node

signal changed

var owned: bool = true
var available: bool = true
var busy: bool = false
var price: String = "Free"
var status: String = "All expedition outfits are free for your crew!"

func _ready() -> void:
	owned = true
	status = "All expedition outfits are free for your crew!"

func buy() -> void:
	# All outfits are completely free; no purchase needed.
	owned = true
	changed.emit()

func restore() -> void:
	# All outfits are completely free; no restore needed.
	owned = true
	changed.emit()

func shutdown() -> void:
	pass

func has_outfits() -> bool:
	return true
