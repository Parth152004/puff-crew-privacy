extends Node3D

const CourseScript = preload("res://scripts/course.gd")
const RaftScript = preload("res://scripts/raft.gd")
const HUDScript = preload("res://scripts/hud.gd")
const AudioScript = preload("res://scripts/audio.gd")
const StoreScript = preload("res://scripts/store.gd")
const PORT = 28970
const DISCOVERY_PORT = 28971
const WALK_SPEED: float = 2.4
const DECK_RADIUS: float = 0.95
var save_path: String = "user://puff_crew.cfg"
var course: RapidsCourse
var courses: Array[RapidsCourse] = []
var raft: PuffRaft
var hud: CrewHUD
var camera: Camera3D
var sfx: CrewAudio
var store: CrewStore
var sun: DirectionalLight3D
var graphics_quality: int = 1
var selected_style: int = 0
var players: Dictionary = {}
var course_index: int = 0
var screen: String = "menu"
var sound_on: bool = true
var haptics_on: bool = true
var overhead: bool = false
var networked: bool = false
var is_host: bool = false
var connecting: bool = false
var host_ip: String = ""
var room_code: String = ""
var message: String = ""
var found_hosts: Array[Dictionary] = []
var discovery_listener: PacketPeerUDP
var discovery_sender: PacketPeerUDP
var discovery_clock: float = 0.0
var network_clock: float = 0.0
var input_clock: float = 0.0
var input_sequence: int = 0
var connection_started: float = 0.0
var last_snapshot: float = 0.0
var boat_pos := Vector2(0,4)
var velocity := Vector2.ZERO
var boat_angle: float = 0.0
var spin: float = 0.0
var elapsed: float = 0.0
var sim_time: float = 0.0
var deaths: int = 0
var checkpoint: float = 0.0
var countdown: float = 0.0
var fall_time: float = 0.0
var boat_height: float = 0.38
var vertical_velocity: float = 0.0
var render_pos := Vector3.ZERO
var run_paused: bool = false
var notice: String = ""
var notice_time: float = 0.0
var collision_cooldown: float = 0.0
var boost_cooldown: float = 0.0
var puff_sound_clock: float = 0.0
var bests: Dictionary = {}
var capture_mode: bool = false
var net_test_mode: String = ""
var test_clock: float = 0.0
var test_started: bool = false
var test_seen_two: bool = false
var test_packets: int = 0
var test_max_progress: float = 0.0
var test_max_crew: int = 0
var test_seen_input: bool = false

func _ready() -> void:
 if OS.has_feature("android"): print("PUFF_READY version=",CrewRelease.VERSION," debug=",OS.is_debug_build())
 load_settings()
 make_world()
 store=StoreScript.new()
 add_child(store)
 if not store.has_outfits(): selected_style=0
 store.changed.connect(_store_changed)
 sfx = AudioScript.new()
 sfx.game = self
 add_child(sfx)
 var layer = CanvasLayer.new()
 add_child(layer)
 hud = HUDScript.new()
 hud.game = self
 layer.add_child(hud)
 players[1] = new_player(true)
 raft.set_crew([1,2,3])
 multiplayer.peer_connected.connect(_peer_connected)
 multiplayer.peer_disconnected.connect(_peer_disconnected)
 multiplayer.connected_to_server.connect(_connected)
 multiplayer.connection_failed.connect(_connection_failed)
 multiplayer.server_disconnected.connect(_server_disconnected)
 get_tree().auto_accept_quit = false
 var args = OS.get_cmdline_user_args()
 if OS.is_debug_build() and "--test-host" in args:
  net_test_mode="host"
  host_game()
 if OS.is_debug_build() and "--test-client" in args:
  net_test_mode="client"
  join_host("127.0.0.1")
 if OS.is_debug_build() and "--show-game" in args: start_solo();countdown=0
 if OS.is_debug_build() and "--android-test-host" in args:
  net_test_mode="android-host"
  host_game()
 if OS.is_debug_build() and FileAccess.file_exists("user://qa_mode.txt"):
  var qa_mode=FileAccess.get_file_as_string("user://qa_mode.txt").strip_edges()
  DirAccess.remove_absolute("user://qa_mode.txt")
  load("res://scripts/android_qa.gd").run(self,qa_mode)
 if OS.is_debug_build() and ("--capture-menu" in args or "--capture-game" in args or "--capture-outfits" in args or "--capture-privacy" in args or "--capture-settings" in args): capture_build(args)

func make_world() -> void:
 var world = WorldEnvironment.new()
 var env = Environment.new()
 env.background_mode = Environment.BG_SKY
 var sky = Sky.new()
 var sky_mat = ProceduralSkyMaterial.new()
 sky_mat.sky_top_color = Color("66b9cb")
 sky_mat.sky_horizon_color = Color("cae7d8")
 sky_mat.ground_horizon_color = Color("cae7d8")
 sky_mat.ground_bottom_color = Color("659fa4")
 sky_mat.sky_curve = 0.18
 sky.sky_material = sky_mat
 env.sky = sky
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("c7e6e0")
 env.ambient_light_energy = 0.35
 env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
 env.fog_enabled = true
 env.fog_light_color = Color("b8e2d6")
 env.fog_density = 0.004
 world.environment = env
 add_child(world)
 sun = DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-55,-30,0)
 sun.light_color = Color("fff0ce")
 sun.light_energy = 0.75
 sun.shadow_enabled = true
 sun.directional_shadow_max_distance = 42
 sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
 sun.shadow_bias = 0.12
 sun.shadow_normal_bias = 1.5
 add_child(sun)
 apply_graphics()
 courses.clear()
 for i in range(3):
  var c = CourseScript.new()
  add_child(c)
  c.build(i)
  var active = (i == course_index)
  c.visible = active
  c.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
  courses.append(c)
 course = courses[course_index]
 raft = RaftScript.new()
 add_child(raft)
 camera = Camera3D.new()
 camera.current = true
 camera.fov = 46
 camera.far = 150
 camera.near = 0.1
 add_child(camera)
 camera.position = Vector3(9,10,17)
 camera.look_at(Vector3(3,0,-2))
 # Soft sculptural clouds batched into a single static mesh (saves 71 draw calls)
 var cloud_st = SurfaceTool.new()
 cloud_st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(24):
  var p = Vector3(sin(i*13.3)*50,12+fmod(i*3.7,13),-i*11+10)
  for j in range(3):
   var s = SphereMesh.new()
   s.radius = 0.5
   s.height = 1.0
   s.radial_segments = 8
   s.rings = 4
   var t_mat = Transform3D(Basis().scaled(Vector3(4.6,1.6+j*0.3,2.9)), p+Vector3(j*1.7,sin(j)*0.6,0))
   cloud_st.append_from(s, 0, t_mat)
 var clouds = MeshInstance3D.new()
 clouds.mesh = cloud_st.commit()
 clouds.material_override = CrewVisuals.mat(Color("f4fbf4"), 0.9)
 clouds.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(clouds)

func new_player(ready: bool = false) -> Dictionary:
 return {"aim":Vector2(0,-1),"move":Vector2.ZERO,"deck_pos":Vector2.ZERO,"puff":false,"gas":1.0,"ready":ready,"last_input":0.0,"seq":-1,"exhausted":false}

func reset_deck_positions() -> void:
 var ids = sorted_ids()
 for i in range(ids.size()):
  var id = ids[i]
  if ids.size() == 1:
   players[id]["deck_pos"] = Vector2.ZERO
  else:
   var a = TAU * float(i) / ids.size()
   players[id]["deck_pos"] = Vector2(sin(a), cos(a)) * 0.72
  players[id]["move"] = Vector2.ZERO

func local_id() -> int:
 return multiplayer.get_unique_id() if networked else 1

func authoritative() -> bool:
 return not networked or is_host

func sorted_ids() -> Array:
 var ids = players.keys()
 ids.sort()
 return ids

func change_course(index: int) -> void:
 var new_index = clampi(index,0,2)
 if course_index == new_index and is_instance_valid(course) and course.visible: return
 course_index = new_index
 if courses.size() > course_index and is_instance_valid(courses[course_index]):
  for i in range(courses.size()):
   if is_instance_valid(courses[i]):
    var active = (i == course_index)
    courses[i].visible = active
    courses[i].process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
  course = courses[course_index]
 elif is_instance_valid(course):
  course.build(course_index)
 save_settings()

func _process(dt: float) -> void:
 notice_time = maxf(0,notice_time-dt)
 var on_menu = screen in ["menu","connect","lobby"]
 raft.local_player=local_id()
 raft.show_labels=not on_menu
 var styles={}
 for id in raft.crew_ids: styles[id]=int(players.get(id,{}).get("style",0))
 if on_menu and not networked: styles[1]=hud.preview_style if hud.panel=="wardrobe" else selected_style
 raft.set_crew(raft.crew_ids,styles)
 if on_menu:
  raft.scale = Vector3.ONE*1.7
  raft.position = Vector3(0,0.7+sin(sim_time)*0.12,1)
  var fake = {}
  var ids = raft.crew_ids
  for i in range(ids.size()): fake[ids[i]]={"aim":Vector2(sin(sim_time*0.4+i)*0.4,1).normalized(),"puff":false,"gas":1.0}
  raft.animate(dt,sin(sim_time*0.2)*0.18,Vector2.ZERO,fake,0)
  var target_pos = Vector3(10,9,15)
  camera.position = camera.position.lerp(target_pos,1-exp(-dt*3))
  camera.look_at(Vector3(3.7,0.4,-0.3))
 else:
  raft.scale = Vector3.ONE
  var goal_pos = Vector3(boat_pos.x,boat_height,boat_pos.y)
  render_pos = render_pos.lerp(goal_pos,1-exp(-dt*18)) if not authoritative() else goal_pos
  raft.position = render_pos
  raft.animate(dt,boat_angle,velocity,players,fall_time)
  var view_offset = Vector3(0,24,8) if overhead else Vector3(0,9.2,10.8)
  var camera_target = render_pos+view_offset
  camera.position = camera.position.lerp(camera_target,1-exp(-dt*4))
  camera.look_at(render_pos+Vector3(0,0,-3))
 if is_instance_valid(course) and course.visible:
  course.update_hazards(sim_time)
 if networked and is_host:
  discovery_clock+=dt
  if discovery_clock>1:
   discovery_clock=0
   advertise()
 if screen=="connect": poll_discovery()
 var now = Time.get_ticks_msec()/1000.0
 if connecting and now-connection_started>8: _connection_failed()
 if networked and not is_host and not connecting and last_snapshot>0 and now-last_snapshot>7:
  leave_game();message="Lost connection to your captain."
 if net_test_mode!="": run_network_test(dt)

func _physics_process(dt: float) -> void:
 sim_time += dt
 collision_cooldown = maxf(0,collision_cooldown-dt)
 boost_cooldown = maxf(0,boost_cooldown-dt)
 if screen=="playing":
  read_local_input(dt)
  if authoritative() and not run_paused:
   simulate(dt)
  if networked and is_host:
   network_clock += dt
   if network_clock >= 0.05:
    network_clock=0
    broadcast_state()
 elif screen in ["lobby","results"] and networked and is_host:
  network_clock += dt
  if network_clock>=0.15:
   network_clock=0
   broadcast_state()

func read_local_input(dt: float) -> void:
 var id = local_id()
 if not players.has(id): return
 var aim: Vector2 = hud.stick
 var keyboard = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
 if keyboard.length_squared()>0: aim=keyboard.normalized()
 var has_stick_input = hud.stick.length() > 0.1 or keyboard.length_squared() > 0
 if not has_stick_input:
  aim = players[id].aim
 var thrust = hud.puff or Input.is_physical_key_pressed(KEY_SPACE)
 if hud.local_pause or run_paused: thrust=false
 if net_test_mode!="": aim=Vector2(0,-1);thrust=true;has_stick_input=true
 var move_dir = Vector2.ZERO
 if has_stick_input:
  move_dir = Vector2(aim.x * cos(boat_angle) - aim.y * sin(boat_angle), aim.x * sin(boat_angle) + aim.y * cos(boat_angle)).limit_length()
 if authoritative():
  players[id].aim=aim.limit_length()
  players[id].puff=thrust
  players[id].move=move_dir
  players[id].last_input=sim_time
 else:
  players[id].aim=aim.limit_length()
  players[id].puff=thrust
  players[id].move=move_dir
  var cur_dpos: Vector2 = players[id].get("deck_pos", Vector2.ZERO)
  var speed_scale = 0.65 if thrust else 1.0
  players[id]["deck_pos"] = (cur_dpos + move_dir * WALK_SPEED * speed_scale * dt).limit_length(DECK_RADIUS)
  input_clock+=dt
  if input_clock>=0.033:
   input_clock=0
   input_sequence+=1
   submit_input.rpc_id(1,aim,move_dir,thrust,input_sequence)
 # A quiet synthesized puff reinforces the active player's input.
 puff_sound_clock+=dt
 if thrust and float(players[id].gas)>0.05 and puff_sound_clock>0.27 and countdown<=0:
  puff_sound_clock=0
  sfx.play_cue("puff")

func simulate(dt: float) -> void:
 if countdown>0:
  countdown=maxf(0,countdown-dt)
  return
 elapsed+=dt
 if fall_time>0:
  fall_time+=dt
  boat_height-=dt*fall_time*8
  if fall_time>1.05: respawn()
  return
 var force = Vector2.ZERO
 var torque = 0.0
 var ids = sorted_ids()
 for i in range(ids.size()):
  var id = ids[i]
  var p: Dictionary = players[id]
  var walk: Vector2 = p.get("move", Vector2.ZERO)
  if walk.length_squared() > 0.01:
   var cur_dpos: Vector2 = p.get("deck_pos", Vector2.ZERO)
   var speed_scale = 0.65 if p.get("puff", false) else 1.0
   p["deck_pos"] = (cur_dpos + walk * WALK_SPEED * speed_scale * dt).limit_length(DECK_RADIUS)
   players[id] = p
 if ids.size() > 1:
  for i in range(ids.size()):
   for j in range(i+1, ids.size()):
    var id_a = ids[i]
    var id_b = ids[j]
    var pos_a: Vector2 = players[id_a].get("deck_pos", Vector2.ZERO)
    var pos_b: Vector2 = players[id_b].get("deck_pos", Vector2.ZERO)
    var diff = pos_a - pos_b
    var dist = diff.length()
    var min_gap = 0.44
    if dist < min_gap and dist > 0.001:
     var push = diff.normalized() * (min_gap - dist) * 0.5
     players[id_a]["deck_pos"] = (pos_a + push).limit_length(DECK_RADIUS)
     players[id_b]["deck_pos"] = (pos_b - push).limit_length(DECK_RADIUS)
 for i in range(ids.size()):
  var id = ids[i]
  var p: Dictionary = players[id]
  if networked and id!=1 and sim_time-float(p.last_input)>0.4: p.puff=false; p.move=Vector2.ZERO
  if p.get("exhausted",false) and (not p.puff or float(p.gas)>0.3): p.exhausted=false
  var firing: bool = p.puff and float(p.gas)>0.015 and not p.get("exhausted",false)
  if firing:
   p.gas=maxf(0,float(p.gas)-dt*0.26)
   var aim: Vector2=p.aim
   force+=aim*10.5/ids.size()
   if ids.size()>1:
    var dpos: Vector2 = p.get("deck_pos", Vector2(sin(TAU*i/ids.size()), cos(TAU*i/ids.size()))*0.7)
    var world_lever = Vector2(dpos.x*cos(boat_angle)+dpos.y*sin(boat_angle), -dpos.x*sin(boat_angle)+dpos.y*cos(boat_angle))
    torque+=(world_lever.x*aim.y-world_lever.y*aim.x)*1.4/ids.size()
   if float(p.gas)<=0.015: p.exhausted=true
  else:
   p.gas=minf(1,float(p.gas)+dt*(0.17 if p.puff else 0.42))
  players[id]=p
 velocity+=force*dt
 velocity*=exp(-dt*0.85)
 velocity=velocity.limit_length(12.0)
 spin=lerpf(spin,torque,dt*2)
 boat_angle+=spin*dt
 boat_pos+=velocity*dt
 boat_pos.y=minf(boat_pos.y,7)
 var progress=-boat_pos.y
 var edge=absf(boat_pos.x-course.center_at(progress))
 if edge>course.width_at(progress)*0.5+0.1:
  splash("Over the edge!")
  return
 if boat_height>0.38 or vertical_velocity!=0:
  vertical_velocity-=dt*9
  boat_height+=vertical_velocity*dt
  if not course.is_gap(progress) and boat_height<0.38: boat_height=0.38;vertical_velocity=0
 if course.is_gap(progress) and boat_height<0.12:
  splash("Mind the gap!");return
 if course.is_gap(progress) and vertical_velocity==0:
  vertical_velocity=-0.4
 if progress>122.2 and progress<125 and velocity.y < -4.8 and vertical_velocity==0:
  vertical_velocity=4.8
 for h in course.hazards:
  if absf(progress-float(h.p))>7: continue
  interact_hazard(h,dt)
  if fall_time>0: return
 if progress>70 and checkpoint<70:
  checkpoint=70;checkpoint_reached()
 if progress>140 and checkpoint<140:
  checkpoint=140;checkpoint_reached()
 if progress>=course.length_m:
  screen="results"
  velocity=Vector2.ZERO
  record_best()
  sfx.play_cue("finish")
  show_notice("You made it, crew!")

func interact_hazard(h: Dictionary, dt: float) -> void:
 var pos = Vector2(course.center_at(h.p)+h.offset,-h.p)
 var delta = boat_pos-pos
 match h.kind:
  "bumper":
   if delta.length()<2.15: impact(delta.normalized(),3.9)
  "spinner":
   var a = sim_time*(0.75+course_index*0.18)+h.phase
   var arm = Vector2(cos(a),-sin(a))*3.5
   var closest = Geometry2D.get_closest_point_to_segment(boat_pos,pos-arm,pos+arm)
   var diff = boat_pos-closest
   if diff.length()<1.43: impact(diff.normalized(),5.1)
  "gate":
   var gap = 3.2+sin(sim_time*(0.95+course_index*0.15)+h.phase)*1.55
   if absf(delta.y)<1.7 and absf(delta.x)>gap*0.5-1.2:
    impact(Vector2(signf(delta.x)*-0.18,signf(delta.y)),4.6)
  "whirlpool":
   var dist = delta.length()
   if dist<4.0:
    var strength = (1-dist/4)*3.8
    velocity+=(-delta.normalized()*strength+Vector2(-delta.y,delta.x).normalized()*strength*0.5)*dt
    if dist<0.72: splash("Caught in the whirlpool!")
  "boost":
   if absf(delta.x)<2.0 and absf(delta.y)<1.5 and boost_cooldown<=0:
    velocity.y=minf(velocity.y,-10.2)
    boost_cooldown=5
    show_notice("Whoosh! Keep your line for the jump.")

func impact(normal: Vector2, strength: float) -> void:
 if collision_cooldown>0: return
 if normal.length()<0.2: normal=Vector2(1,0)
 collision_cooldown=0.65
 velocity=normal*strength
 boat_pos+=normal*0.38
 spin+=strength*0.15
 sfx.play_cue("tap")
 if OS.has_feature("android") and haptics_on: Input.vibrate_handheld(35)

func splash(reason: String) -> void:
 if fall_time>0: return
 fall_time=0.01
 deaths+=1
 show_notice(reason)
 sfx.play_cue("splash")
 if OS.has_feature("android") and haptics_on: Input.vibrate_handheld(70)

func checkpoint_reached() -> void:
 show_notice("Checkpoint! A fresh start, just ahead.")
 sfx.play_cue("checkpoint")
 for id in players: players[id].gas=1.0;players[id].exhausted=false

func respawn() -> void:
 boat_pos=Vector2(course.center_at(checkpoint+4),-checkpoint-4)
 velocity=Vector2.ZERO
 spin=0
 boat_angle=0
 boat_height=0.38
 vertical_velocity=0
 fall_time=0
 collision_cooldown=1.2
 reset_deck_positions()
 for id in players: players[id].gas=1.0;players[id].exhausted=false
 render_pos=Vector3(boat_pos.x,boat_height,boat_pos.y)

func start_solo() -> void:
 leave_network()
 players={1:new_player(true)}
 players[1]["style"]=selected_style if store.has_outfits() else 0
 start_run()

func start_run() -> void:
 if networked and not is_host: return
 checkpoint=0;elapsed=0;deaths=0;run_paused=false;countdown=3.0
 screen="playing"
 hud.local_pause=false
 hud.clear_controls()
 respawn()
 raft.set_crew(sorted_ids())
 camera.position=Vector3(boat_pos.x,13,boat_pos.y+16)
 if networked:
  multiplayer.multiplayer_peer.refuse_new_connections=true
  broadcast_state()

func show_notice(text: String) -> void:
 notice=text;notice_time=3.0

func format_time(seconds: float) -> String:
 return "%02d:%02d.%01d"%[int(seconds)/60,int(seconds)%60,int(seconds*10)%10]

func best_text() -> String:
 return format_time(float(bests[str(course_index)])) if bests.has(str(course_index)) else "--:--"

func record_best() -> void:
 var key = str(course_index)
 if not bests.has(key) or elapsed<float(bests[key]): bests[key]=elapsed
 save_settings()

func load_settings() -> void:
 var cfg = ConfigFile.new()
 if cfg.load(save_path)==OK:
  sound_on=cfg.get_value("options","sound",true)
  haptics_on=cfg.get_value("options","haptics",true)
  overhead=cfg.get_value("options","overhead",false)
  course_index=clampi(int(cfg.get_value("options","course",0)),0,2)
  bests=cfg.get_value("records","bests",{})
  graphics_quality=clampi(int(cfg.get_value("options","graphics",1)),0,2)
  selected_style=clampi(int(cfg.get_value("options","outfit",0)),0,3)

func save_settings() -> void:
 var cfg = ConfigFile.new()
 cfg.set_value("options","sound",sound_on)
 cfg.set_value("options","haptics",haptics_on)
 cfg.set_value("options","overhead",overhead)
 cfg.set_value("options","course",course_index)
 cfg.set_value("records","bests",bests)
 cfg.set_value("options","graphics",graphics_quality)
 cfg.set_value("options","outfit",selected_style)
 cfg.save(save_path)

func apply_graphics() -> void:
 var vp = get_viewport()
 if vp != null:
  vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
 match graphics_quality:
  0: # Performance (Super smooth on budget mobile phones)
   if is_instance_valid(sun): sun.shadow_enabled = false
   if vp != null:
    vp.msaa_3d = Viewport.MSAA_DISABLED
    vp.scaling_3d_scale = 0.75
  1: # Balanced (Default - smooth 60 FPS, optimized shadows, crisp UI)
   if is_instance_valid(sun):
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 36
   if vp != null:
    vp.msaa_3d = Viewport.MSAA_DISABLED
    vp.scaling_3d_scale = 0.85
  2: # High (High-end phones - 2X MSAA and native 3D buffer)
   if is_instance_valid(sun):
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 42
   if vp != null:
    vp.msaa_3d = Viewport.MSAA_2X
    vp.scaling_3d_scale = 1.0

func _store_changed() -> void:
 if not store.has_outfits() and selected_style>0: select_style(0)

func select_style(value: int) -> void:
 value=clampi(value,0,3)
 if value>0 and not store.has_outfits(): return
 selected_style=value
 if players.has(local_id()): players[local_id()]["style"]=value
 if networked and not is_host: outfit_request.rpc_id(1,value)
 elif networked: broadcast_roster()
 save_settings()

# Only the host integrates physics. Clients submit their own bounded input.
func host_game() -> void:
 leave_network()
 var peer = ENetMultiplayerPeer.new()
 var err = peer.create_server(PORT,3)
 if err!=OK: message="Port busy. Close the other crew and try again.";return
 multiplayer.multiplayer_peer=peer
 networked=true;is_host=true;screen="lobby"
 players={1:new_player(true)}
 players[1]["style"]=selected_style if store.has_outfits() else 0
 host_ip=local_ip()
 room_code=ip_to_code(host_ip)
 raft.set_crew([1])
 discovery_sender=PacketPeerUDP.new()
 discovery_sender.set_broadcast_enabled(true)
 discovery_sender.set_dest_address("255.255.255.255",DISCOVERY_PORT)
 message=""

const CODE_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"

static func ip_to_code(ip_str: String) -> String:
 var parts = ip_str.split(".")
 if parts.size() != 4:
  return ip_str
 var b0 = int(parts[0])
 var b1 = int(parts[1])
 var b2 = int(parts[2])
 var b3 = int(parts[3])
 if b0 == 127 and b1 == 0 and b2 == 0 and b3 == 1:
  return "LOCAL"
 if b0 == 192 and b1 == 168:
  var val = (1 << 16) | (b2 << 8) | b3
  var s = ""
  for _i in range(4):
   s = CODE_ALPHABET[val % 32] + s
   val /= 32
  return s
 if b0 == 172 and b1 >= 16 and b1 <= 31:
  var val = ((b1 - 16) << 16) | (b2 << 8) | b3
  var s = ""
  for _i in range(4):
   s = CODE_ALPHABET[val % 32] + s
   val /= 32
  return "H" + s
 if b0 == 10:
  var val = (b1 << 16) | (b2 << 8) | b3
  var s = ""
  for _i in range(5):
   s = CODE_ALPHABET[val % 32] + s
   val /= 32
  return "T" + s
 var val = (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
 var s = ""
 for _i in range(7):
  s = CODE_ALPHABET[val % 32] + s
  val /= 32
 return "X" + s

static func code_to_ip(raw: String) -> String:
 var code = raw.strip_edges().to_upper()
 if code == "LOCAL":
  return "127.0.0.1"
 if "." in code:
  return code if code.is_valid_ip_address() else ""
 if code.length() == 4:
  var val = 0
  for i in range(4):
   var idx = CODE_ALPHABET.find(code[i])
   if idx == -1: return ""
   val = val * 32 + idx
  if (val >> 16) == 1:
   return "192.168.%d.%d" % [(val >> 8) & 0xFF, val & 0xFF]
 elif code.length() == 5 and code.begins_with("H"):
  var val = 0
  for i in range(1, 5):
   var idx = CODE_ALPHABET.find(code[i])
   if idx == -1: return ""
   val = val * 32 + idx
  return "172.%d.%d.%d" % [16 + ((val >> 16) & 0x0F), (val >> 8) & 0xFF, val & 0xFF]
 elif code.length() == 6 and code.begins_with("T"):
  var val = 0
  for i in range(1, 6):
   var idx = CODE_ALPHABET.find(code[i])
   if idx == -1: return ""
   val = val * 32 + idx
  return "10.%d.%d.%d" % [(val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF]
 elif code.length() == 8 and code.begins_with("X"):
  var val = 0
  for i in range(1, 8):
   var idx = CODE_ALPHABET.find(code[i])
   if idx == -1: return ""
   val = val * 32 + idx
  return "%d.%d.%d.%d" % [(val >> 24) & 0xFF, (val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF]
 return ""

func local_ip() -> String:
 # Prefer the Wi-Fi interface when a device also has ethernet/cellular addresses.
 for interface in IP.get_local_interfaces():
  var label=str(interface.get("name","")).to_lower()
  if "wlan" in label or "wifi" in label or label=="en0":
   for address in interface.get("addresses",[]):
    if ":" not in address and not address.begins_with("127.") and not address.begins_with("169.254."): return address
 var candidates: Array[String] = []
 for address in IP.get_local_addresses():
  if ":" not in address and not address.begins_with("127.") and not address.begins_with("169.254."):
   candidates.append(address)
 for prefix in ["192.168.","10.","172."]:
  for address in candidates:
   if address.begins_with(prefix): return address
 return candidates[0] if not candidates.is_empty() else "127.0.0.1"

func begin_discovery() -> void:
 if discovery_listener!=null: discovery_listener.close()
 discovery_listener=PacketPeerUDP.new()
 discovery_listener.bind(DISCOVERY_PORT)
 found_hosts.clear()

func advertise() -> void:
 if discovery_sender==null or screen!="lobby": return
 discovery_sender.put_packet(JSON.stringify({"game":"puff-crew-v1","port":PORT,"count":players.size(),"course":course_index,"code":room_code}).to_utf8_buffer())

func poll_discovery() -> void:
 if discovery_listener==null: return
 while discovery_listener.get_available_packet_count()>0:
  var bytes=discovery_listener.get_packet()
  var ip=discovery_listener.get_packet_ip()
  if bytes.size()>512: continue
  var data=JSON.parse_string(bytes.get_string_from_utf8())
  if data is Dictionary and data.get("game","")=="puff-crew-v1":
   var code = str(data.get("code", ip_to_code(ip)))
   var exists=false
   for h in found_hosts:
    if h.ip==ip:
     h["last"]=Time.get_ticks_msec()
     h["code"]=code
     exists=true
   if not exists:
    found_hosts.append({"ip":ip,"code":code,"last":Time.get_ticks_msec()})
 for i in range(found_hosts.size()-1,-1,-1):
  if Time.get_ticks_msec()-int(found_hosts[i].last)>4000: found_hosts.remove_at(i)

func join_host(target: String) -> void:
 if connecting: return
 var query = target.strip_edges().to_upper()
 if query.is_empty():
  message="Enter a room code or IP."
  return
 var resolved_ip = ""
 for h in found_hosts:
  if str(h.get("code","")).to_upper()==query or str(h.get("ip",""))==query:
   resolved_ip = str(h.ip)
   break
 if resolved_ip.is_empty():
  if query.is_valid_ip_address() and not (":" in query):
   resolved_ip = query
  else:
   resolved_ip = code_to_ip(query)
 if resolved_ip.is_empty() or not resolved_ip.is_valid_ip_address() or (":" in resolved_ip):
  message="Room '%s' not found. Check code & Wi-Fi." % query
  return
 leave_network()
 var peer=ENetMultiplayerPeer.new()
 var err=peer.create_client(resolved_ip,PORT)
 if err!=OK: message="Could not connect. Check the room code.";return
 multiplayer.multiplayer_peer=peer
 networked=true;is_host=false;connecting=true
 host_ip=resolved_ip
 message="Joining room %s..." % query
 connection_started=Time.get_ticks_msec()/1000.0

func _connected() -> void:
 if not networked or is_host: return
 connecting=false;screen="lobby";message=""
 last_snapshot=Time.get_ticks_msec()/1000.0
 outfit_request.rpc_id(1,selected_style if store.has_outfits() else 0)

func _connection_failed() -> void:
 if not networked or is_host: return
 leave_network();screen="connect";message="No crew found. Check the IP and same Wi-Fi."

func _server_disconnected() -> void:
 if not networked: return
 leave_game();message="Your captain left. Host a new crew to sail again."

func _peer_connected(id: int) -> void:
 if not is_host: return
 if screen!="lobby" or players.size()>=4:
  multiplayer.multiplayer_peer.disconnect_peer(id);return
 players[id]=new_player(net_test_mode=="host")
 reset_deck_positions()
 raft.set_crew(sorted_ids())
 broadcast_roster()

func _peer_disconnected(id: int) -> void:
 if is_host:
  players.erase(id)
  raft.set_crew(sorted_ids())
  show_notice("A crewmate left. You can keep sailing.")
  if networked: broadcast_roster()

@rpc("authority","call_remote","reliable")
func roster_sync(roster: Dictionary, index: int) -> void:
 if is_host: return
 players=roster
 if course_index!=index: change_course(index)
 raft.set_crew(sorted_ids())

func toggle_ready() -> void:
 if is_host or not networked: return
 var value = not players.get(local_id(),{}).get("ready",false)
 ready_request.rpc_id(1,value)

@rpc("any_peer","call_remote","reliable")
func ready_request(value: bool) -> void:
 if not is_host or screen!="lobby": return
 var sender=multiplayer.get_remote_sender_id()
 if not players.has(sender): return
 players[sender].ready=value
 broadcast_roster()

@rpc("any_peer","call_remote","reliable")
func outfit_request(value: int) -> void:
 if not is_host or screen!="lobby": return
 var sender=multiplayer.get_remote_sender_id()
 if not players.has(sender): return
 # Only a bounded visual choice crosses the LAN; never a purchase token.
 players[sender]["style"]=clampi(value,0,3)
 broadcast_roster()

func can_launch() -> bool:
 if players.size()<2 or players.size()>4: return false
 for id in players:
  if not players[id].get("ready",false): return false
 return true

@rpc("any_peer","call_remote","unreliable_ordered",1)
func submit_input(aim: Vector2, move_dir: Vector2, thrust: bool, sequence: int) -> void:
 if not is_host or screen!="playing": return
 var sender=multiplayer.get_remote_sender_id()
 if not players.has(sender) or not aim.is_finite(): return
 if sequence<=int(players[sender].seq): return
 if aim.length()<0.1: aim=players[sender].aim
 players[sender].aim=aim.limit_length()
 players[sender].move=move_dir.limit_length() if move_dir.is_finite() else Vector2.ZERO
 players[sender].puff=thrust
 players[sender].last_input=sim_time
 players[sender].seq=sequence

func pack_state() -> Dictionary:
 return {"pos":boat_pos,"vel":velocity,"angle":boat_angle,"height":boat_height,"elapsed":elapsed,"time":sim_time,"deaths":deaths,"checkpoint":checkpoint,"countdown":countdown,"fall":fall_time,"paused":run_paused,"screen":screen,"course":course_index,"players":players,"notice":notice if notice_time>0 else ""}

@rpc("authority","call_remote","unreliable_ordered",2)
func state_sync(s: Dictionary) -> void:
 if is_host: return
 test_packets+=1
 last_snapshot=Time.get_ticks_msec()/1000.0
 var old_screen=screen
 var old_cp=checkpoint
 var old_fall=fall_time
 if course_index!=int(s.course): change_course(int(s.course))
 boat_pos=s.pos;velocity=s.vel;boat_angle=s.angle;boat_height=s.height;elapsed=s.elapsed;sim_time=s.time
 deaths=s.deaths;checkpoint=s.checkpoint;countdown=s.countdown;fall_time=s.fall;run_paused=s.paused
 screen=s.screen;players=s.players
 raft.set_crew(sorted_ids())
 if old_screen!=screen:
  hud.clear_controls();hud.local_pause=false
  if screen=="playing": render_pos=Vector3(boat_pos.x,boat_height,boat_pos.y)
  if screen=="results": record_best();sfx.play_cue("finish")
 if checkpoint>old_cp: sfx.play_cue("checkpoint")
 if fall_time>0 and old_fall<=0: sfx.play_cue("splash")
 if str(s.notice)!="" and str(s.notice)!=notice: show_notice(s.notice)

func leave_network() -> void:
 networked=false;is_host=false;connecting=false
 room_code=""
 if multiplayer.multiplayer_peer!=null:
  multiplayer.multiplayer_peer.close()
  multiplayer.multiplayer_peer=null
 if discovery_sender!=null: discovery_sender.close();discovery_sender=null
 if discovery_listener!=null: discovery_listener.close();discovery_listener=null
 last_snapshot=0

func leave_game() -> void:
 leave_network()
 screen="menu";run_paused=false;fall_time=0;elapsed=0
 players={1:new_player(true)}
 raft.set_crew([1,2,3])
 hud.local_pause=false;hud.clear_controls()

func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT and not capture_mode and net_test_mode=="":
  if is_instance_valid(hud): hud.clear_controls()
  if screen=="playing" and authoritative(): run_paused=true
 if what==NOTIFICATION_WM_CLOSE_REQUEST:
  quit_cleanly(0)
 if what==NOTIFICATION_WM_GO_BACK_REQUEST and is_instance_valid(hud):
  if not hud.panel.is_empty(): hud.close_panel()
  elif hud.help_open: hud.help_open=false
  elif screen=="playing": hud.activate("pause")
  elif screen=="menu": quit_cleanly(0)
  else: leave_game()

func run_network_test(dt: float) -> void:
 test_clock+=dt
 test_max_progress=maxf(test_max_progress,-boat_pos.y)
 test_max_crew=maxi(test_max_crew,players.size())
 if players.size()>=2: test_seen_two=true
 for id in players:
  if id!=1 and int(players[id].get("seq",-1))>5: test_seen_input=true
 if net_test_mode in ["host","android-host"] and can_launch() and test_clock>1.8 and not test_started:
  test_started=true;start_run();countdown=0
 if test_clock>(35 if net_test_mode=="android-host" else (10 if net_test_mode=="host" else 8)):
  var passed = test_seen_two and test_max_progress>8
  if net_test_mode in ["host","android-host"]: passed=passed and test_seen_input
  if net_test_mode=="client": passed=passed and test_packets>20
  print("NETWORK_TEST ",net_test_mode," ","PASS" if passed else "FAIL"," max_crew=",test_max_crew," max_progress=",test_max_progress," packets=",test_packets," remote_input=",test_seen_input)
  net_test_mode=""
  quit_cleanly(0 if passed else 1)

func capture_build(args: PackedStringArray) -> void:
 capture_mode=true
 change_course(0)
 if "--capture-outfits" in args:
  hud.panel="wardrobe";hud.preview_style=3
 if "--capture-privacy" in args: hud.panel="privacy"
 if "--capture-settings" in args: hud.panel="settings"
 if "--capture-game" in args:
  start_solo()
  countdown=0
  boat_pos=Vector2(course.center_at(38),-38)
  players={1:new_player(true),2:new_player(true),3:new_player(true)}
  raft.set_crew(sorted_ids())
  camera.position=Vector3(boat_pos.x,9.2,boat_pos.y+10.8)
 for i in range(12): await get_tree().process_frame
 var output=OS.get_environment("PUFF_CAPTURE_PATH")
 if output!="":
  get_viewport().get_texture().get_image().save_png(output)
  print("CAPTURE_SAVED ",output)
 quit_cleanly(0)

func connected_targets() -> Array:
 var targets: Array=[]
 if not networked or not is_host: return targets
 var peer: ENetMultiplayerPeer=multiplayer.multiplayer_peer
 for id in multiplayer.get_peers():
  if not players.has(id): continue
  var packet_peer=peer.get_peer(id)
  if packet_peer!=null and packet_peer.get_state()==ENetPacketPeer.STATE_CONNECTED and packet_peer.get_channels()>2:
   targets.append(id)
 return targets

func broadcast_state() -> void:
 var state=pack_state()
 for id in connected_targets(): state_sync.rpc_id(id,state)

func broadcast_roster() -> void:
 for id in connected_targets(): roster_sync.rpc_id(id,players,course_index)

func quit_cleanly(code: int) -> void:
 leave_network()
 store.shutdown()
 sfx.shutdown()
 await get_tree().process_frame
 await get_tree().process_frame
 get_tree().quit(code)
