extends SceneTree
var game: Node
func _initialize() -> void: call_deferred("run")
func run() -> void:
 game=load("res://main.tscn").instantiate()
 game.save_path="user://qa_courses.cfg"
 root.add_child(game)
 game.set_process(false);game.set_physics_process(false);game.hud.set_process(false)
 game.sound_on=false
 var failed=false
 for course_index in range(3):
  game.change_course(course_index)
  game.start_solo();game.countdown=0
  var tick=0
  while tick<24000 and game.screen=="playing":
   var p=-game.boat_pos.y
   var offset=0.0
   var speed=5.5
   var nearest: Dictionary={}
   var distance=1000.0
   for h in game.course.hazards:
    var d=float(h.p)-p
    if d>-2.5 and d<13 and d<distance:
     distance=d;nearest=h
   if not nearest.is_empty():
    match nearest.kind:
     "bumper": offset=2.6 if nearest.offset<0 else -2.6
     "spinner":
      offset=3.8
      var a=game.sim_time*(0.75+course_index*0.18)+nearest.phase
      if distance>3 and distance<8 and abs(cos(a+0.4))>0.65: speed=clampf(distance-5,0,4)
      else: speed=7.0
     "gate":
      offset=0
      var gap=3.2+sin(game.sim_time*(0.95+course_index*0.15)+nearest.phase)*1.55
      if distance>2 and distance<8 and gap<4.3: speed=clampf(distance-4.5,0,3)
      else: speed=7.5
     "whirlpool": offset=3.3 if nearest.offset<0 else -3.3
     "boost": speed=7
   if p>120 and p<132: speed=9.0;offset=0
   var target_x=game.course.center_at(p+3)+offset
   var desired=Vector2(clampf((target_x-game.boat_pos.x)*2,-5,5),-speed)
   var correction=(desired-game.velocity)*3+game.velocity*0.85
   game.players[1].aim=correction.normalized() if correction.length()>0.1 else Vector2(0,-1)
   game.players[1].puff=correction.length()>2.8
   game.sim_time+=1.0/60
   game.collision_cooldown=maxf(0,game.collision_cooldown-1.0/60)
   game.boost_cooldown=maxf(0,game.boost_cooldown-1.0/60)
   game.simulate(1.0/60)
   tick+=1
  var passed=game.screen=="results"
  print("COURSE_RUN ",course_index," PASS" if passed else " FAIL"," seconds=",snappedf(game.elapsed,.1)," splashes=",game.deaths," progress=",-game.boat_pos.y)
  failed=failed or not passed
 await process_frame
 await process_frame
 game.sfx.shutdown()
 await process_frame
 await process_frame
 quit(1 if failed else 0)
