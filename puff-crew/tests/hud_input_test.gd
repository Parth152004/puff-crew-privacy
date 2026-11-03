extends SceneTree

func _init() -> void:
	print("--- TESTING HUD INPUT, KEYBOARD PAN & TOUCHBOX ---")
	var game = load("res://scripts/game.gd").new()
	root.add_child(game)
	await process_frame
	
	var hud = game.hud
	assert(hud != null, "HUD must exist")
	assert(hud.ip_input != null, "ip_input LineEdit must exist")
	
	# Set screen to connect
	game.screen = "connect"
	hud._process(0.016)
	
	var initial_pos_y = hud.ip_input.position.y
	print("Initial ip_input position Y: ", initial_pos_y)
	
	# Tap to focus input
	hud.activate("focus_input")
	assert(hud.ip_input.has_focus(), "ip_input must be focused")
	print("PASS ip_input is focused")
	
	# Process multiple frames to let kb_offset slide up
	for i in range(20):
		hud._process(0.016)
		
	var shifted_pos_y = hud.ip_input.position.y
	print("Shifted ip_input position Y: ", shifted_pos_y, " (kb_offset=", hud.kb_offset, ")")
	assert(hud.kb_offset >= 180.0, "kb_offset must be >= 180 when focused")
	assert(shifted_pos_y < initial_pos_y - 150.0, "Input box must pan significantly upward when keyboard is open")
	print("PASS ip_input panned upward by ", initial_pos_y - shifted_pos_y, " pixels")
	
	# Test Done button is present when focused
	hud._draw()
	var found_done = false
	for b in hud.buttons:
		if b.action == "hide_keyboard":
			found_done = true
			break
	assert(found_done, "DONE button must be present when focused")
	print("PASS DONE button is present when focused")
	
	# Test hiding keyboard
	hud.activate("hide_keyboard")
	assert(not hud.ip_input.has_focus(), "ip_input focus must be released")
	print("PASS hide_keyboard released focus")
	
	# Process frames to let it slide back down
	for i in range(25):
		hud._process(0.016)
		
	print("Returned ip_input position Y: ", hud.ip_input.position.y, " (kb_offset=", hud.kb_offset, ")")
	assert(hud.kb_offset < 10.0, "kb_offset must return to ~0 when unfocused")
	print("PASS ip_input smoothly returned to original position")
	
	# Test auto uppercase
	hud.ip_input.text = "4cs3"
	hud.ip_input.text_changed.emit("4cs3")
	assert(hud.ip_input.text == "4CS3", "ip_input must convert text to uppercase")
	print("PASS text automatically converts to uppercase: ", hud.ip_input.text)
	
	# Test text_submitted releases focus
	hud.ip_input.grab_focus()
	hud.ip_input.text_submitted.emit("4CS3")
	assert(not hud.ip_input.has_focus(), "text_submitted must release focus")
	print("PASS text_submitted releases focus")
	
	print("ALL HUD KEYBOARD & INPUT TESTS PASSED 8/8!")
	quit(0)
