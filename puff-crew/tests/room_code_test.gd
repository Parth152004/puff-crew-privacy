extends SceneTree

var checks: int = 0
var failures: int = 0
var game: Node

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
	var game_script = load("res://scripts/game.gd")

	# 1. Roundtrip test for standard local/hotspot IP ranges
	var test_ips = [
		"127.0.0.1",
		"192.168.1.1",
		"192.168.43.1",
		"192.168.0.105",
		"192.168.29.112",
		"172.20.10.2",
		"172.16.0.1",
		"10.0.0.1",
		"10.105.251.2",
		"8.8.8.8"
	]
	for ip in test_ips:
		var code = game_script.ip_to_code(ip)
		var decoded = game_script.code_to_ip(code)
		check(decoded == ip, "Roundtrip %s -> %s -> %s" % [ip, code, decoded])

	# 2. Case insensitivity and whitespace tolerance
	check(game_script.code_to_ip("4cs3") == "192.168.43.1", "Lowercase 4cs3 decodes to 192.168.43.1")
	check(game_script.code_to_ip("  4CS3  ") == "192.168.43.1", "Padded code decodes to 192.168.43.1")
	check(game_script.code_to_ip("local") == "127.0.0.1", "Lowercase local decodes to 127.0.0.1")

	# 3. Direct IP passthrough
	check(game_script.code_to_ip("192.168.1.25") == "192.168.1.25", "Direct IP is preserved")

	# 4. Invalid code handling
	check(game_script.code_to_ip("???") == "", "Invalid symbols return empty string")
	check(game_script.code_to_ip("") == "", "Empty string returns empty string")

	# 5. Game instance integration
	game = load("res://main.tscn").instantiate()
	game.save_path = "user://qa_code_state.cfg"
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	game.hud.set_process(false)

	# Test host assigns room code
	game.host_game()
	check(game.room_code != "", "Host assigns room code: " + game.room_code)
	check(game.room_code == game_script.ip_to_code(game.host_ip), "Host room code matches host IP encoding")

	# Test joining invalid code sets message
	game.leave_game()
	game.join_host("INVALID!@#")
	check("not found" in game.message.to_lower(), "Invalid code shows friendly error message: " + game.message)

	# Test discovered host resolution
	var host_entry: Dictionary = {"ip": "192.168.99.88", "code": "CREW1", "last": Time.get_ticks_msec()}
	game.found_hosts.append(host_entry)
	game.join_host("CREW1")
	check(game.host_ip == "192.168.99.88", "Discovered room code 'CREW1' resolves to host IP")
	game.leave_network()

	print("ROOM_CODE_TESTS %d/%d passed" % [checks - failures, checks])
	quit(0 if failures == 0 else 1)
