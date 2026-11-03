extends SceneTree
# Reproducible automated gameplay recording using the real gameplay/input loop.
var game: Node
func _initialize() -> void: call_deferred("run")
func run() -> void:
 game=load("res://main.tscn").instantiate()
 game.save_path="user://qa_movie.cfg"
 game.capture_mode=true
 root.add_child(game)
 game.change_course(0)
 await create_timer(1).timeout
 game.start_solo()
 var frames=0
 while game.screen=="playing" and frames<9000:
  await physics_frame
  var p=-game.boat_pos.y
  var offset=0.0
  var speed=5.5
  var nearest: Dictionary={}
  var distance=1000.0
  for h in game.course.hazards:
   var d=float(h.p)-p
   if d>-2.5 and d<13 and d<distance: distance=d;nearest=h
  if not nearest.is_empty():
   match nearest.kind:
    "bumper": offset=2.6 if nearest.offset<0 else -2.6
    "spinner":
     offset=3.8
     var a=game.sim_time*0.75+nearest.phase
     if distance>3 and distance<8 and abs(cos(a+0.4))>0.65: speed=clampf(distance-5,0,4)
     else: speed=7.0
    "gate":
     var gap=3.2+sin(game.sim_time*0.95+nearest.phase)*1.55
     if distance>2 and distance<8 and gap<4.3: speed=clampf(distance-4.5,0,3)
     else: speed=7.5
    "whirlpool": offset=3.3 if nearest.offset<0 else -3.3
    "boost": speed=7
  if p>120 and p<132: speed=9;offset=0
  var desired=Vector2(clampf((game.course.center_at(p+3)+offset-game.boat_pos.x)*2,-5,5),-speed)
  var correction=(desired-game.velocity)*3+game.velocity*0.85
  game.hud.stick=correction.normalized() if correction.length()>0.1 else Vector2(0,-1)
  game.hud.puff=correction.length()>2.8
  frames+=1
  # A concise clip includes the first checkpoint and several hazards.
  if game.elapsed>20: break
 game.hud.clear_controls()
 await create_timer(.5).timeout
 print("MOVIE_CAPTURE progress=",-game.boat_pos.y," elapsed=",game.elapsed," splashes=",game.deaths)
 game.quit_cleanly(0)
