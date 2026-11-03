extends SceneTree
var checks: int = 0
var failures: int = 0
var game: Node

func check(condition: bool, label: String) -> void:
 checks+=1
 if condition: print("PASS ",label)
 else: failures+=1;push_error("FAIL "+label)

func _initialize() -> void:
 call_deferred("run")

func reset() -> void:
 game.players={1:game.new_player(true)}
 game.screen="playing"
 game.checkpoint=0;game.countdown=0;game.elapsed=0;game.deaths=0
 game.respawn();game.collision_cooldown=0

func run() -> void:
 game=load("res://main.tscn").instantiate()
 game.save_path="user://qa_state.cfg"
 root.add_child(game)
 game.set_physics_process(false)
 game.set_process(false)
 game.hud.set_process(false)
 var hazards=game.course.hazards.duplicate()
 game.course.hazards.clear()
 reset()
 game.players[1].puff=true
 for i in range(60): game.simulate(1.0/60)
 check(game.velocity.y < -5,"Thrust accelerates raft forward")
 check(-game.boat_pos.y > 7,"Thrust moves raft through course")
 check(float(game.players[1].gas)<0.76,"Holding thrust consumes gas")
 var before=game.players[1].gas
 game.players[1].puff=false
 for i in range(30): game.simulate(1.0/60)
 check(game.players[1].gas>before,"Releasing thrust restores gas")
 var momentum=game.velocity.length()
 check(momentum>0.5,"Releasing retains momentum")
 game.players[1].aim=Vector2(0,1);game.players[1].puff=true
 for i in range(20): game.simulate(1.0/60)
 check(game.velocity.y > -momentum,"Reverse thrust brakes momentum")
 reset()
 game.players={1:game.new_player(true),2:game.new_player(true)}
 game.players[1].aim=Vector2(1,0);game.players[2].aim=Vector2(-1,0)
 game.players[1].puff=true;game.players[2].puff=true
 for i in range(30): game.simulate(1.0/60)
 check(game.velocity.length()<0.01,"Opposing crew thrust cancels translation")
 reset()
 game.boat_pos=Vector2(game.course.center_at(71),-71)
 game.simulate(1.0/60)
 check(game.checkpoint==70,"Checkpoint records progress")
 game.boat_pos.x+=20
 game.simulate(1.0/60)
 check(game.deaths==1 and game.fall_time>0,"Leaving channel causes one splash")
 for i in range(70): game.simulate(1.0/60)
 check(game.fall_time==0 and abs(-game.boat_pos.y-74)<0.1,"Splash restores last checkpoint")
 check(game.velocity.length()==0,"Respawn clears velocity")
 reset()
 game.course.hazards=hazards
 var bumper=hazards[0]
 game.boat_pos=Vector2(game.course.center_at(bumper.p)+bumper.offset,-bumper.p+1)
 game.interact_hazard(bumper,1.0/60)
 check(game.velocity.length()>3,"Bumper collision applies knockback")
 var once=game.velocity
 game.interact_hazard(bumper,1.0/60)
 check(game.velocity==once,"Collision cooldown prevents repeated impulse")
 var vortex={"kind":"whirlpool","p":103.0,"offset":-0.9}
 reset()
 game.boat_pos=Vector2(game.course.center_at(103)-0.9,-103)
 game.interact_hazard(vortex,1.0/60)
 check(game.fall_time>0,"Whirlpool eye causes a splash")
 reset()
 game.course.hazards.clear()
 game.boat_pos=Vector2(game.course.center_at(122),-122)
 game.velocity=Vector2(0,-10)
 var crossed=false
 for i in range(90):
  game.simulate(1.0/60)
  if -game.boat_pos.y>129: crossed=true
 check(crossed and game.deaths==0,"A boosted raft can cross the gap")
 reset()
 game.boat_pos=Vector2(game.course.center_at(126),-126)
 for i in range(40): game.simulate(1.0/60)
 check(game.deaths==1,"Entering gap without speed fails")
 reset()
 game.boat_pos=Vector2(game.course.center_at(210.2),-210.2)
 game.simulate(1.0/60)
 check(game.screen=="results","Finish triggers results")
 check(game.bests.has(str(game.course_index)),"A completed run persists a best time")
 # Mobile controls: simultaneous pointer IDs must not steal or release each other.
 reset()
 game.hud.ui_scale=1;game.hud.ui_offset=Vector2.ZERO
 var stick_event=InputEventScreenTouch.new()
 stick_event.index=0;stick_event.position=Vector2(132,520);stick_event.pressed=true
 game.hud._input(stick_event)
 var puff_event=InputEventScreenTouch.new()
 puff_event.index=1;puff_event.position=Vector2(1130,578);puff_event.pressed=true
 game.hud._input(puff_event)
 check(game.hud.stick.y < -0.8 and game.hud.puff,"Two fingers aim and thrust together")
 stick_event.pressed=false;game.hud._input(stick_event)
 check(game.hud.stick==Vector2.ZERO and game.hud.puff,"Releasing stick preserves second finger thrust")
 puff_event.pressed=false;game.hud._input(puff_event)
 check(not game.hud.puff,"Releasing thrust pointer stops thrust")
 game.hud.clear_controls()
 check(game.hud.stick_finger==-1 and game.hud.puff_finger==-1,"Focus reset clears touch ownership")
 # All courses preserve a navigable gap and finish width.
 for index in range(3):
  game.change_course(index)
  check(game.course.width_at(85)>7 and game.course.width_at(210)>=14,"Course %d provides navigable widths"%index)
 print("SIMULATION_TESTS ",checks-failures,"/",checks," passed")
 game.leave_network()
 game.sfx.shutdown()
 await process_frame
 await process_frame
 quit(0 if failures==0 else 1)
