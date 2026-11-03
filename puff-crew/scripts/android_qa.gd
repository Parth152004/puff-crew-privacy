extends RefCounted
# Debug-only app instrumentation. Triggered by a file in the app's private sandbox.
# It exercises the same InputEventScreenTouch path as a real two-finger gesture.
static func touch(game: Node,index: int,pos: Vector2,pressed: bool) -> void:
 var event=InputEventScreenTouch.new()
 event.index=index
 event.position=game.hud.ui_offset+pos*game.hud.ui_scale
 event.pressed=pressed
 game.get_viewport().push_input(event,true)

static func tap(game: Node,pos: Vector2) -> void:
 touch(game,5,pos,true)
 await game.get_tree().process_frame
 touch(game,5,pos,false)
 await RenderingServer.frame_post_draw

static func capture(game: Node,name: String) -> void:
 await RenderingServer.frame_post_draw
 game.get_viewport().get_texture().get_image().save_png("user://qa-"+name+".png")

static func run(game: Node,mode: String) -> void:
 game.capture_mode=true
 await game.get_tree().create_timer(1.0).timeout
 await capture(game,"menu")
 if mode=="solo":
  await tap(game,Vector2(973,367))
  game.countdown=0
  await game.get_tree().create_timer(0.4).timeout
  var before=game.boat_pos
  touch(game,0,Vector2(132,519),true)
  touch(game,1,Vector2(1130,578),true)
  await game.get_tree().create_timer(2.0).timeout
  var passed=game.boat_pos.y < before.y-3 and game.players[1].gas<0.7
  await capture(game,"gameplay")
  touch(game,0,Vector2(132,519),false)
  touch(game,1,Vector2(1130,578),false)
  await game.get_tree().create_timer(0.5).timeout
  passed=passed and not game.hud.puff and game.hud.stick==Vector2.ZERO
  var distance=before.y-game.boat_pos.y
  var gas=game.players[1].gas
  var game_fps=Engine.get_frames_per_second()
  var game_draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
  var old_view=game.overhead
  await tap(game,Vector2(1097,51))
  passed=passed and game.overhead!=old_view
  await tap(game,Vector2(1097,51))
  await tap(game,Vector2(1167,51))
  var paused_elapsed=game.elapsed
  await game.get_tree().create_timer(0.2).timeout
  passed=passed and game.run_paused and game.elapsed==paused_elapsed
  await tap(game,Vector2(640,325))
  passed=passed and not game.run_paused
  await tap(game,Vector2(1167,51))
  await tap(game,Vector2(640,400))
  passed=passed and game.deaths==1 and not game.run_paused
  await tap(game,Vector2(1167,51))
  await tap(game,Vector2(640,476))
  passed=passed and game.screen=="menu" and not game.networked
  await tap(game,Vector2(973,448))
  game.hud.ip_input.text="192.0.2.1"
  await tap(game,Vector2(973,411))
  await tap(game,Vector2(860,588))
  passed=passed and game.screen=="menu" and not game.networked and not game.connecting
  await tap(game,Vector2(1072,634))
  passed=passed and game.hud.panel=="settings"
  var quality=game.graphics_quality
  await tap(game,Vector2(808,215))
  passed=passed and game.graphics_quality==(quality+1)%3
  await tap(game,Vector2(808,215))
  await tap(game,Vector2(808,215))
  await tap(game,Vector2(640,351))
  passed=passed and game.hud.panel=="privacy"
  await capture(game,"privacy")
  await tap(game,Vector2(640,624))
  await tap(game,Vector2(640,425))
  passed=passed and game.hud.panel=="credits"
  await tap(game,Vector2(640,532))
  passed=passed and game.hud.panel=="licenses" and game.hud.license_view.text.length()>10000
  await tap(game,Vector2(640,624))
  await tap(game,Vector2(640,624))
  await tap(game,Vector2(640,624))
  await tap(game,Vector2(873,634))
  await tap(game,Vector2(1072,295))
  passed=passed and game.hud.panel=="wardrobe" and game.hud.preview_style==3 and game.raft.crew_styles.get(1)==3
  await capture(game,"wardrobe")
  await tap(game,Vector2(973,517))
  passed=passed and game.hud.panel.is_empty() and game.selected_style==3
  await tap(game,Vector2(973,367))
  await game.get_tree().create_timer(0.3).timeout
  passed=passed and game.players[1].get("style")==3 and game.raft.crew_styles.get(1)==3
  await capture(game,"outfit-gameplay")
  await tap(game,Vector2(1167,51))
  await tap(game,Vector2(640,476))
  var result={"pass":passed,"mode":mode,"distance":distance,"gas":gas,"fps":game_fps,"draw_calls":game_draw_calls,"resolution":str(game.get_viewport().get_visible_rect().size),"ui_checks":"solo, view, pause, resume, retry, leave, cancel pending connection, graphics, privacy, credits, licenses, outfit preview/equip in solo"}
  FileAccess.open("user://qa-result.json",FileAccess.WRITE).store_string(JSON.stringify(result))
  print("ANDROID_QA ",JSON.stringify(result))
  game.run_paused=true
 elif mode=="client":
  await tap(game,Vector2(873,634))
  await tap(game,Vector2(1072,215))
  await tap(game,Vector2(973,517))
  var target="10.0.2.2"
  if FileAccess.file_exists("user://qa_target.txt"):
   target=FileAccess.get_file_as_string("user://qa_target.txt").strip_edges()
   DirAccess.remove_absolute("user://qa_target.txt")
  var discovered=false
  await tap(game,Vector2(973,448))
  if target!="10.0.2.2":
   var search_time=0.0
   while game.found_hosts.is_empty() and search_time<5.0:
    await game.get_tree().create_timer(0.2).timeout
    search_time+=0.2
   discovered=not game.found_hosts.is_empty()
   if discovered: target=str(game.found_hosts[0].ip)
  if discovered:
   await tap(game,Vector2(973,483))
  else:
   game.hud.ip_input.text=target
   await tap(game,Vector2(973,411))
  var wait=0.0
  while game.screen!="playing" and wait<12:
   await game.get_tree().create_timer(0.4).timeout
   wait+=0.4
   if game.screen=="lobby" and game.players.has(game.local_id()) and not game.players[game.local_id()].ready: await tap(game,Vector2(973,505))
  if game.screen=="playing":
   while game.countdown>0: await game.get_tree().create_timer(0.1).timeout
   touch(game,0,Vector2(132,519),true)
   touch(game,1,Vector2(1130,578),true)
   await game.get_tree().create_timer(3.0).timeout
  await capture(game,"coop")
  var outfit_ok=int(game.players.get(game.local_id(),{}).get("style",0))==1
  if target!="10.0.2.2": outfit_ok=outfit_ok and int(game.players.get(1,{}).get("style",0))==2
  var result={"pass":game.players.size()==2 and game.test_packets>10 and game.screen=="playing" and outfit_ok,"mode":mode,"target":target,"discovered":discovered,"outfit_sync":outfit_ok,"crew":game.players.size(),"packets":game.test_packets,"progress":-game.boat_pos.y,"fps":Engine.get_frames_per_second()}
  FileAccess.open("user://qa-result.json",FileAccess.WRITE).store_string(JSON.stringify(result))
  print("ANDROID_QA ",JSON.stringify(result))
  touch(game,0,Vector2(132,519),false)
  touch(game,1,Vector2(1130,578),false)

 elif mode=="host":
  await tap(game,Vector2(873,634))
  await tap(game,Vector2(873,295))
  await tap(game,Vector2(973,517))
  await tap(game,Vector2(973,448))
  await tap(game,Vector2(973,219))
  FileAccess.open("user://qa-host-ready.json",FileAccess.WRITE).store_string(JSON.stringify({"ready":game.is_host,"ip":game.local_ip()}))
  var waited=0.0
  while not game.can_launch() and waited<25:
   await game.get_tree().create_timer(0.2).timeout
   waited+=0.2
  if game.can_launch():
   await tap(game,Vector2(973,505))
   while game.countdown>0: await game.get_tree().create_timer(0.1).timeout
   touch(game,0,Vector2(132,519),true)
   touch(game,1,Vector2(1130,578),true)
   await game.get_tree().create_timer(3.0).timeout
  await capture(game,"host-coop")
  var seen_input=false
  var outfit_ok=int(game.players.get(1,{}).get("style",0))==2
  for id in game.players:
   if id!=1 and int(game.players[id].get("seq",-1))>10: seen_input=true
   if id!=1: outfit_ok=outfit_ok and int(game.players[id].get("style",0))==1
  var result={"pass":game.is_host and game.players.size()==2 and seen_input and -game.boat_pos.y>10 and outfit_ok,"mode":mode,"crew":game.players.size(),"outfit_sync":outfit_ok,"remote_input":seen_input,"progress":-game.boat_pos.y,"fps":Engine.get_frames_per_second()}
  FileAccess.open("user://qa-result.json",FileAccess.WRITE).store_string(JSON.stringify(result))
  print("ANDROID_QA ",JSON.stringify(result))
  touch(game,0,Vector2(132,519),false)
  touch(game,1,Vector2(1130,578),false)
