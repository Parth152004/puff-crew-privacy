extends SceneTree

var checks: int = 0
var failures: int = 0

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS ", label)
	else:
		failures += 1
		print("FAIL ", label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://main.tscn").instantiate()
	game.save_path = "user://qa_deck_movement.cfg"
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	game.hud.set_process(false)

	# 1. Test initial player structure has move and deck_pos
	var p1 = game.new_player(true)
	check(p1.has("deck_pos"), "new_player includes deck_pos field")
	check(p1.has("move"), "new_player includes move field")

	# 2. Test reset_deck_positions initializes multiple players on raft
	game.players = {1: game.new_player(true), 2: game.new_player(true), 3: game.new_player(true)}
	game.reset_deck_positions()
	check(game.players[1].deck_pos != game.players[2].deck_pos, "Multiplayer crew start in distinct positions on raft")
	check(game.players[1].deck_pos.length() > 0.5, "Crew members start spaced around raft ring")

	# 3. Test dynamic movement across the deck
	var start_pos: Vector2 = game.players[1].deck_pos
	game.players[1].move = Vector2(1, 0) # walk right
	for i in range(30):
		game.simulate(1.0 / 60.0)
	var new_pos: Vector2 = game.players[1].deck_pos
	check(new_pos.x > start_pos.x, "Player walked to the right across the raft plate (x moved from %s to %s)" % [snappedf(start_pos.x, 0.01), snappedf(new_pos.x, 0.01)])

	# 4. Test deck boundary clamping
	game.players[1].move = Vector2(1, 0)
	for i in range(120): # walk for 2 seconds
		game.simulate(1.0 / 60.0)
	check(game.players[1].deck_pos.length() <= 0.9501, "Player position clamped inside deck radius (dist=%s <= 0.95)" % snappedf(game.players[1].deck_pos.length(), 0.01))

	# 5. Test soft separation: two players walking into each other don't collapse to one point
	game.players[1].deck_pos = Vector2(0.1, 0)
	game.players[2].deck_pos = Vector2(0.15, 0)
	game.players[1].move = Vector2.ZERO
	game.players[2].move = Vector2.ZERO
	for i in range(10):
		game.simulate(1.0 / 60.0)
	var separation = (game.players[1].deck_pos - game.players[2].deck_pos).length()
	check(separation >= 0.40, "Capybaras separate and do not overlap on the plate (separation=%s)" % snappedf(separation, 0.01))

	# 6. Test position-based torque: player on left creates clockwise torque when puffing forward
	game.boat_angle = 0.0
	game.spin = 0.0
	game.velocity = Vector2.ZERO
	game.players = {1: game.new_player(true), 2: game.new_player(true)}
	game.players[1].deck_pos = Vector2(-0.8, 0.0) # Left side of raft
	game.players[1].aim = Vector2(0, -1) # Puff forward
	game.players[1].puff = true
	game.players[2].puff = false
	game.simulate(1.0 / 60.0)
	check(game.spin > 0.0, "Puffing from left side of raft creates positive clockwise torque (spin=%s)" % snappedf(game.spin, 0.001))

	# 7. Test network synchronization preserves deck positions
	var packed = game.pack_state()
	check(packed.has("players"), "pack_state includes players with dynamic deck_pos")
	check(packed["players"][1].has("deck_pos"), "packed state includes player deck_pos")

	# 8. Test raft visual animation uses deck positions
	game.raft.set_crew([1, 2])
	game.raft.animate(0.016, 0.0, Vector2.ZERO, game.players, 0.0)
	var node1: Node3D = game.raft.crew_nodes[0]
	check(absf(node1.position.x - game.players[1].deck_pos.x) < 0.01, "Visual capybara node placed at dynamic deck_pos.x")
	check(absf(node1.position.z - game.players[1].deck_pos.y) < 0.01, "Visual capybara node placed at dynamic deck_pos.y (in 3D Z)")

	# 9. Test puff jet points OUTSIDE away from the raft plate
	game.players[1].aim = Vector2(0, -1) # Aim forward
	game.players[1].puff = true
	game.raft.animate(0.016, 0.0, Vector2.ZERO, game.players, 0.0)
	var jet1: Node3D = game.raft.jets[0]
	check(jet1.visible == true, "Puff jet is visible when puff is active")
	check(jet1.position.z > node1.position.z, "Puff jet originates behind capybara (jet.z=%s > capybara.z=%s)" % [snappedf(jet1.position.z, 0.01), snappedf(node1.position.z, 0.01)])
	check(absf(jet1.rotation.y) < 0.01, "Puff jet rotation.y is 0, pointing bubble chain backwards OUTSIDE the plate")

	print("DYNAMIC_DECK_MOVEMENT_TESTS %d/%d passed" % [checks - failures, checks])
	quit(0 if failures == 0 else 1)
