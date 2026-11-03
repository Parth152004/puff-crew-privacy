extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://main.tscn").instantiate()
	game.save_path = "user://qa_switch_test.cfg"
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	game.hud.set_process(false)

	var initial_nodes = game.get_child_count()
	print("Initial game child count: ", initial_nodes)
	print("Pre-built courses count: ", game.courses.size())

	for target in [1, 2, 0, 1, 2, 0]:
		var t0 = Time.get_ticks_usec()
		game.change_course(target)
		var elapsed_us = Time.get_ticks_usec() - t0
		print("Switched to Course ", target, " in ", elapsed_us, " microseconds (", snappedf(elapsed_us / 1000.0, 0.01), " ms)")
		assert(game.course == game.courses[target], "Active course pointer must match target")
		assert(game.course.visible == true, "Active course must be visible")
		for i in range(game.courses.size()):
			if i != target:
				assert(game.courses[i].visible == false, "Inactive course %d must be hidden" % i)

	print("Final game child count: ", game.get_child_count())
	assert(game.get_child_count() == initial_nodes, "No node leak after multiple course switches!")
	print("ALL COURSE SWITCH TESTS PASSED INSTANTANEOUSLY!")
	quit(0)
