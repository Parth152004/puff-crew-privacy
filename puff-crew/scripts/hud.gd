class_name CrewHUD
extends Control

const INK = Color("173f4a")
const TEAL = Color("237f83")
const PAPER = Color("fff7e6")
const MUTED = Color("779294")
const LIME = Color("dcf4a4")
var game: Node
var font: Font
var font_bold: Font
var buttons: Array[Dictionary] = []
var stick := Vector2.ZERO
var puff := false
var stick_finger := -1
var puff_finger := -1
var mouse_stick := false
var mouse_puff := false
var help_open := false
var local_pause := false
var ip_input: LineEdit
var ui_scale := 1.0
var ui_offset := Vector2.ZERO
var kb_offset := 0.0
var clock := 0.0
var panel: String = ""
var preview_style: int = 0
var license_view: RichTextLabel

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 font = preload("res://assets/Outfit-Medium.ttf")
 font_bold = preload("res://assets/Outfit-Bold.ttf")
 ip_input = LineEdit.new()
 ip_input.placeholder_text = "ENTER ROOM CODE"
 ip_input.text = ""
 ip_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
 ip_input.max_length = 15
 ip_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
 ip_input.select_all_on_focus = true
 ip_input.clear_button_enabled = true
 ip_input.caret_blink = true
 ip_input.caret_blink_interval = 0.5
 ip_input.add_theme_font_override("font",font_bold)
 ip_input.add_theme_color_override("caret_color",TEAL)
 ip_input.add_theme_font_size_override("font_size",24)
 ip_input.add_theme_color_override("font_color",INK)
 ip_input.add_theme_color_override("font_placeholder_color",Color(0.35,0.52,0.54,0.8))
 var style_normal = StyleBoxFlat.new()
 style_normal.bg_color = Color(1.0,1.0,1.0,0.96)
 style_normal.border_color = Color(0.14,0.50,0.52,0.60)
 style_normal.set_border_width_all(2)
 style_normal.set_corner_radius_all(16)
 style_normal.content_margin_left = 14
 style_normal.content_margin_right = 14
 var style_focus = StyleBoxFlat.new()
 style_focus.bg_color = Color(1.0,1.0,1.0,1.0)
 style_focus.border_color = TEAL
 style_focus.set_border_width_all(3)
 style_focus.set_corner_radius_all(16)
 style_focus.content_margin_left = 14
 style_focus.content_margin_right = 14
 ip_input.add_theme_stylebox_override("normal",style_normal)
 ip_input.add_theme_stylebox_override("focus",style_focus)
 add_child(ip_input)
 ip_input.text_changed.connect(func(new_text: String):
  var upper = new_text.to_upper()
  if upper != new_text:
   var caret = ip_input.caret_column
   ip_input.text = upper
   ip_input.caret_column = caret
 )
 ip_input.text_submitted.connect(func(_v):
  ip_input.release_focus()
  DisplayServer.virtual_keyboard_hide()
  game.join_host(ip_input.text.strip_edges())
 )
 license_view=RichTextLabel.new()
 license_view.bbcode_enabled=false
 license_view.add_theme_font_override("normal_font",font)
 license_view.add_theme_color_override("default_color",INK)
 add_child(license_view)

func clear_controls() -> void:
 stick = Vector2.ZERO
 puff = false
 stick_finger = -1
 puff_finger = -1
 mouse_stick = false
 mouse_puff = false

func _process(dt: float) -> void:
 clock += dt
 var size_v = get_viewport_rect().size
 ui_scale = minf(size_v.x/1280.0,size_v.y/720.0)
 ui_offset = (size_v-Vector2(1280,720)*ui_scale)*0.5
 var target_shift = 0.0
 if ip_input.visible and ip_input.has_focus():
  var kb_h = DisplayServer.virtual_keyboard_get_height()
  if kb_h > 0:
   var kb_logical = kb_h / ui_scale
   target_shift = clampf(kb_logical - 220.0, 190.0, 260.0)
  else:
   target_shift = 195.0
 kb_offset = move_toward(kb_offset, target_shift, dt * 1000.0)
 ui_offset.y -= kb_offset * ui_scale
 ip_input.position = ui_offset+Vector2(781,306)*ui_scale
 ip_input.size = Vector2(383,62)*ui_scale
 ip_input.add_theme_font_size_override("font_size",int(23*ui_scale))
 ip_input.scale = Vector2.ONE
 ip_input.visible = game.screen == "connect" and not help_open and panel.is_empty()
 license_view.visible=panel=="licenses"
 license_view.position=ui_offset+Vector2(292,150)*ui_scale
 license_view.size=Vector2(696,420)*ui_scale
 license_view.add_theme_font_size_override("normal_font_size",int(16*ui_scale))
 queue_redraw()

func rounded(rect: Rect2, color: Color, radius: int = 18, border: Color = Color.TRANSPARENT) -> void:
 var sb = StyleBoxFlat.new()
 sb.bg_color = color
 sb.set_corner_radius_all(radius)
 if border.a > 0:
  sb.border_color = border
  sb.set_border_width_all(2)
 draw_style_box(sb,rect)

func txt(text: String, at: Vector2, size_f: int, color: Color = INK) -> void:
 draw_string(font_bold if size_f>=28 else font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size_f,color)

func centered(text: String, rect: Rect2, size_f: int, color: Color = INK) -> void:
 var chosen = font_bold if size_f>=28 else font
 var width = chosen.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size_f).x
 txt(text,rect.position+Vector2((rect.size.x-width)*0.5,(rect.size.y+size_f*0.72)*0.5),size_f,color)

func button(action: String, text: String, rect: Rect2, primary: bool = false, enabled: bool = true) -> void:
 rounded(Rect2(rect.position+Vector2(0,4),rect.size),Color(0.06,0.2,0.23,0.12),18)
 rounded(rect,LIME if primary else Color("eceddc"),18)
 centered(text,rect,23,INK if enabled else Color("99a6a0"))
 buttons.append({"action":action,"rect":rect,"enabled":enabled})

func small_icon(action: String, text: String, pos: Vector2) -> void:
 rounded(Rect2(pos,Vector2(58,52)),Color(0.98,0.98,0.91,0.93),16)
 centered(text,Rect2(pos,Vector2(58,52)),22)
 buttons.append({"action":action,"rect":Rect2(pos,Vector2(58,52)),"enabled":true})

func badge(text: String, rect: Rect2, color: Color = TEAL) -> void:
 rounded(rect,color,12)
 centered(text,rect,15,PAPER)

func _draw() -> void:
 if game == null: return
 buttons.clear()
 draw_set_transform(ui_offset,0,Vector2.ONE*ui_scale)
 if game.screen in ["menu","connect","lobby"]:
  draw_menu()
 elif game.screen == "playing":
  draw_game()
 elif game.screen == "results":
  draw_results()
 if help_open: draw_help()
 if not panel.is_empty(): draw_panel()
 draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func draw_menu() -> void:
 # The backdrop is the real 3D world and animated crew.
 rounded(Rect2(47,40,207,34),Color(0.08,0.3,0.33,0.85),12)
 centered("A LITTLE GAS. A LOT OF CHAOS.",Rect2(47,40,207,34),12,PAPER)
 txt("PUFF",Vector2(44,160),98,INK)
 txt("CREW",Vector2(44,247),98,INK)
 rounded(Rect2(50,271,152,37),Color("f2b887"),12)
 centered("R A P I D S",Rect2(50,271,152,37),18)
 txt("One raft. Your whole crew.",Vector2(51,644),27,INK)
 txt("Aim together. Puff together. Try not to flip.",Vector2(51,677),18,INK)
 rounded(Rect2(750,69,461,610),Color(0.09,0.29,0.31,0.12),30)
 rounded(Rect2(742,61,461,610),PAPER,30)
 match game.screen:
  "menu":
   txt("Good company.",Vector2(781,118),34)
   txt("Questionable propulsion.",Vector2(781,151),25,TEAL)
   txt("CHOOSE YOUR RIVER",Vector2(782,199),13,MUTED)
   for i in range(3):
    var r = Rect2(781+i*124,216,113,62)
    rounded(r,TEAL if game.course_index==i else Color("e8ecdc"),14)
    centered(["01  SHOALS","02  TWIST","03  MOON"][i],r,14,PAPER if game.course_index==i else INK)
    buttons.append({"action":"course_%d"%i,"rect":r,"enabled":true})
   txt(RapidsCourse.SUBTITLES[game.course_index],Vector2(782,309),17,MUTED)
   button("solo","Set sail solo  >",Rect2(781,335,383,65),true)
   button("wifi","Bring your crew  >",Rect2(781,416,383,65))
   txt("2-4 phones / same Wi-Fi / no account",Vector2(802,509),16,MUTED)
   button("help","How to play",Rect2(781,548,239,55))
   button("sound","Sound " + ("ON" if game.sound_on else "OFF"),Rect2(1033,548,131,55))
   button("wardrobe","Crew outfits",Rect2(781,612,184,45))
   button("settings","Settings & info",Rect2(979,612,185,45))
  "connect":
   txt("Better together.",Vector2(781,119),34)
   txt("Put every phone on the same Wi-Fi.",Vector2(782,156),18,TEAL)
   button("host","Host a crew",Rect2(781,187,383,65),true)
   txt("OR JOIN WITH ROOM CODE",Vector2(782,286),13,MUTED)
   var paste_rect = Rect2(1096,268,68,26)
   rounded(paste_rect,Color("e8ece0"),8)
   centered("PASTE",paste_rect,13,TEAL)
   buttons.append({"action":"paste_code","rect":paste_rect,"enabled":true})
   if ip_input.has_focus():
    var hide_rect = Rect2(1020,268,68,26)
    rounded(hide_rect,Color("e8ece0"),8)
    centered("DONE",hide_rect,13,TEAL)
    buttons.append({"action":"hide_keyboard","rect":hide_rect,"enabled":true})
   var input_box_rect = Rect2(781,306,383,62)
   rounded(Rect2(input_box_rect.position+Vector2(0,4),input_box_rect.size),Color(0.06,0.2,0.23,0.12),18)
   buttons.append({"action":"focus_input","rect":input_box_rect,"enabled":true})
   button("join","Join Room  >",Rect2(781,382,383,59),false,not game.connecting)
   if game.found_hosts.size() > 0:
    var h: Dictionary = game.found_hosts[0]
    var code_disp = str(h.get("code", game.ip_to_code(str(h.ip))))
    button("discovered","Join Room: " + code_disp,Rect2(781,456,383,54),true)
   else:
    txt("Looking for nearby rooms...",Vector2(788,482),18,MUTED)
   txt(game.message.left(42),Vector2(787,531),16,TEAL)
   button("back","<  Back",Rect2(781,563,158,50))
  "lobby":
   txt("All aboard.",Vector2(781,112),34)
   if game.is_host:
    var c = game.room_code if game.room_code != "" else game.ip_to_code(game.host_ip)
    txt("ROOM CODE: " + c,Vector2(782,148),22,TEAL)
    txt("Wi-Fi IP: " + game.host_ip + "   " + RapidsCourse.TITLES[game.course_index],Vector2(782,174),13,MUTED)
   else:
    var c = game.ip_to_code(game.host_ip)
    txt("ROOM CODE: " + c,Vector2(782,148),22,TEAL)
    txt("Connected to captain   " + RapidsCourse.TITLES[game.course_index],Vector2(782,174),13,MUTED)
   var ids = game.sorted_ids()
   for i in range(4):
    var y = 213+i*61
    rounded(Rect2(782,y,381,51),Color("edf0e3"),13)
    draw_circle(Vector2(807,y+25),13,CrewVisuals.PALETTE[i])
    if i < ids.size():
     var id = ids[i]
     txt(("Captain" if i==0 else "Crewmate %d"%(i+1))+(" (you)" if id==game.local_id() else ""),Vector2(831,y+32),19)
     txt("READY" if game.players[id].get("ready",false) else "JOINED",Vector2(1073,y+30),13,TEAL)
    else:
     txt("Waiting for a friend...",Vector2(831,y+32),18,MUTED)
   if game.is_host:
    button("start","Launch crew  >",Rect2(781,476,383,59),true,game.can_launch())
    txt("Need 2-4 players, all ready.",Vector2(783,561),16,MUTED)
   else:
    var ready = game.players.get(game.local_id(),{}).get("ready",false)
    button("ready","Ready!" if not ready else "Ready - tap to unready",Rect2(781,476,383,59),true)
    txt("Your captain launches when everyone is ready.",Vector2(783,560),15,MUTED)
   button("leave","<  Leave crew",Rect2(781,581,199,45))
 if game.message != "" and game.screen=="menu":
  rounded(Rect2(330,25,595,44),PAPER,14)
  centered(game.message,Rect2(330,25,595,44),17)

func draw_game() -> void:
 rounded(Rect2(27,25,250,69),PAPER,18)
 txt(RapidsCourse.TITLES[game.course_index],Vector2(46,54),17)
 txt("SOLO EXPEDITION" if not game.networked else "%d / 4 CREW"%game.players.size(),Vector2(47,78),12,TEAL)
 rounded(Rect2(363,25,550,52),Color(0.08,0.25,0.29,0.88),18)
 var progress = clampf(-game.boat_pos.y/game.course.length_m,0,1)
 rounded(Rect2(383,45,417,9),Color("496f72"),4)
 if progress > 0.005: rounded(Rect2(383,45,417*progress,9),LIME,4)
 for j in range(4): draw_circle(Vector2(383+j*139,49.5),5,LIME if progress>=j/3.0 else Color("77928c"))
 txt("%d%%"%int(progress*100),Vector2(823,59),18,PAPER)
 small_icon("camera","VIEW",Vector2(1068,25))
 small_icon("pause","II",Vector2(1138,25))
 txt(game.format_time(game.elapsed),Vector2(45,129),26,PAPER)
 txt("%d SPLASHES"%game.deaths,Vector2(47,154),13,Color("e7f4e9"))
 # Large controls remain outside the forward sightline.
 var joy = Vector2(132,578)
 draw_circle(joy,85,Color(0.06,0.26,0.30,0.28))
 draw_arc(joy,85,0,TAU,64,Color(0.92,0.98,0.92,0.60),2.0,true)
 draw_circle(joy,63,Color(0.93,0.98,0.91,0.12))
 for a in [0,PI/2,PI,PI*1.5]:
  var dir = Vector2(cos(a),sin(a))
  draw_line(joy+dir*60,joy+dir*69,Color(1,1,1,0.65),3,true)
 draw_circle(joy+stick*57,31,Color("e3f5d3"))
 draw_circle(joy+stick*57-Vector2(5,6),14,Color(1,1,1,0.3))
 txt("AIM",Vector2(114,691),14,PAPER)
 var p: Dictionary = game.players.get(game.local_id(),{})
 var gas: float = p.get("gas",1.0)
 var c = Vector2(1130,578)
 draw_circle(c+Vector2(0,5),86,Color(0.07,0.23,0.27,0.22))
 draw_circle(c,84,LIME if gas>0.03 else Color("ccd5bb"))
 draw_arc(c,76,-PI/2,-PI/2+TAU*gas,64,TEAL,5,true)
 centered("PUFF!",Rect2(c-Vector2(74,39),Vector2(148,64)),28)
 txt("HOLD",c+Vector2(-19,40),12,TEAL)
 rounded(Rect2(474,642,331,41),Color(0.08,0.25,0.29,0.82),15)
 txt("GAS",Vector2(493,668),12,PAPER)
 rounded(Rect2(535,657,247,10),Color("557878"),5)
 if gas > 0.01: rounded(Rect2(535,657,247*gas,10),LIME,5)
 var prompt = "Lift off to refill" if gas<0.20 else "Aim with your left thumb. Hold PUFF to move."
 centered(prompt,Rect2(300,688,680,24),14,PAPER)
 if game.countdown > 0:
  draw_circle(Vector2(640,302),69,Color(0.08,0.28,0.31,0.85))
  centered(str(int(ceil(game.countdown))),Rect2(575,237,130,130),64,PAPER)
  centered("CREW, GET READY",Rect2(450,385,380,40),20,PAPER)
 if game.notice_time > 0:
  rounded(Rect2(390,103,500,53),PAPER,18)
  centered(game.notice,Rect2(390,103,500,53),21)
 if game.fall_time > 0:
  centered("SPLASH!",Rect2(410,280,460,90),55,PAPER)
  centered("Back to your last checkpoint",Rect2(410,367,460,40),20,PAPER)
 if local_pause or game.run_paused:
  draw_rect(Rect2(0,0,1280,720),Color(0.035,0.14,0.18,0.65))
  rounded(Rect2(417,143,446,421),PAPER,27)
  centered("Taking a breather.",Rect2(437,172,406,60),30)
  centered("Crew paused" if game.run_paused else "Your crew is still sailing",Rect2(437,238,406,35),17,TEAL)
  button("resume","Back to the river",Rect2(457,293,366,63),true)
  button("retry","Retry checkpoint",Rect2(457,371,366,59),false,game.authoritative())
  button("quit","Leave expedition",Rect2(457,448,366,59))
  button("settings","Display & sound",Rect2(457,519,366,35))

func draw_results() -> void:
 draw_rect(Rect2(0,0,1280,720),Color(0.035,0.17,0.20,0.36))
 for j in range(28):
  var x=fmod(j*173.7+sin(clock+j)*28.0,1280.0)
  var y=fmod(clock*(27.0+j%5*9.0)+j*87.0,790.0)-35.0
  var color=[LIME,Color("f7bd66"),Color("f2a8c2"),Color("7cd4cf")][j%4]
  var direction=Vector2(cos(clock*2.0+j),sin(clock*2.0+j))*5.0
  draw_line(Vector2(x,y)-direction,Vector2(x,y)+direction,color,4.0,true)
 rounded(Rect2(387,75,506,570),PAPER,30)
 badge("EXPEDITION COMPLETE",Rect2(496,108,288,34))
 centered("What a crew.",Rect2(420,160,440,70),45)
 centered(RapidsCourse.TITLES[game.course_index],Rect2(420,239,440,30),16,TEAL)
 var stars = 3 if game.deaths<=2 else (2 if game.deaths<=6 else 1)
 for i in range(3):
  draw_circle(Vector2(570+i*70,313),24,Color("f7bd66") if i<stars else Color("e1e4d4"))
  centered("*",Rect2(546+i*70,290,48,48),34,PAPER)
 centered(game.format_time(game.elapsed),Rect2(420,356,440,70),46)
 centered("%d splashes / Best %s"%[game.deaths,game.best_text()],Rect2(420,431,440,33),18,TEAL)
 button("again","One more run  >",Rect2(437,493,406,62),true,game.authoritative())
 button("quit","Back to shore",Rect2(437,571,406,47))

func draw_help() -> void:
 draw_rect(Rect2(0,0,1280,720),Color(0.035,0.14,0.18,0.65))
 rounded(Rect2(310,89,660,541),PAPER,28)
 txt("A tiny guide to a big splash.",Vector2(352,147),32)
 var lines = ["1   Drag the left stick to aim your capybara.","2   Hold PUFF with your right thumb to push.","3   Release PUFF to refill your gas.","4   Drift matters. Aim backwards to brake.","5   Time the gates; avoid the whirlpool eye.","6   Hit the gold boost arrows for the jump.","7   In co-op, everyone moves the same raft."]
 for i in range(lines.size()): txt(lines[i],Vector2(355,208+i*43),21)
 txt("Tip: aim backwards and puff to slow the raft." if OS.has_feature("android") else "Desktop: WASD / arrows to aim, SPACE to puff, ESC to pause.",Vector2(353,535),16,TEAL)
 button("close_help","Got it. Let's float.",Rect2(353,560,574,48),true)

func logical(p: Vector2) -> Vector2:
 return (p-ui_offset)/ui_scale

func _input(event: InputEvent) -> void:
 if game == null: return
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode == KEY_ESCAPE:
   if not panel.is_empty(): close_panel()
   elif help_open: help_open=false
   elif game.screen=="playing": activate("pause" if not local_pause else "resume")
   elif game.screen=="connect": activate("back")
  if event.keycode == KEY_ENTER and game.screen=="menu": activate("solo")
 var point := Vector2.ZERO
 var down := false
 var up := false
 var finger := -2
 if event is InputEventScreenTouch:
  point=logical(event.position);down=event.pressed;up=not event.pressed;finger=event.index
 elif event is InputEventScreenDrag:
  point=logical(event.position);finger=event.index
  if finger==stick_finger: stick=((point-Vector2(132,578))/65.0).limit_length()
  return
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  point=logical(event.position);down=event.pressed;up=not event.pressed;finger=-3
 elif event is InputEventMouseMotion:
  if mouse_stick: stick=((logical(event.position)-Vector2(132,578))/65.0).limit_length()
  return
 else: return
 if up:
  if finger==stick_finger or (finger==-3 and mouse_stick): stick=Vector2.ZERO;stick_finger=-1;mouse_stick=false
  if finger==puff_finger or (finger==-3 and mouse_puff): puff=false;puff_finger=-1;mouse_puff=false
  return
 if not down: return
 if game.screen=="playing" and not local_pause and not game.run_paused and not help_open and panel.is_empty():
  if point.distance_to(Vector2(132,578))<110:
   stick_finger=finger;mouse_stick=finger==-3;stick=((point-Vector2(132,578))/65.0).limit_length();return
  if point.distance_to(Vector2(1130,578))<105:
   puff_finger=finger;mouse_puff=finger==-3;puff=true;return
 for i in range(buttons.size()-1,-1,-1):
  var b: Dictionary=buttons[i]
  if help_open and b.action!="close_help": continue
  if not panel.is_empty() and not str(b.action).begins_with("modal_"): continue
  if b.enabled and b.rect.has_point(point):
   activate(b.action)
   get_viewport().set_input_as_handled()
   return
 if game.screen == "connect" and ip_input.has_focus():
  ip_input.release_focus()
  DisplayServer.virtual_keyboard_hide()

func activate(action: String) -> void:
 game.sfx.play_cue("tap")
 if action.begins_with("course_"):
  game.change_course(int(action.right(1)));return
 match action:
  "focus_input":
   ip_input.grab_focus()
   DisplayServer.virtual_keyboard_show(ip_input.text,Rect2(ip_input.global_position,ip_input.size))
  "hide_keyboard":
   ip_input.release_focus()
   DisplayServer.virtual_keyboard_hide()
  "paste_code":
   var clip = DisplayServer.clipboard_get().strip_edges().to_upper()
   if not clip.is_empty():
    ip_input.text = clip
    ip_input.caret_column = clip.length()
  "solo":
   ip_input.release_focus()
   DisplayServer.virtual_keyboard_hide()
   clear_controls();game.start_solo()
  "wifi": game.message="";game.screen="connect";game.begin_discovery()
  "host":
   ip_input.release_focus()
   DisplayServer.virtual_keyboard_hide()
   game.host_game()
  "join":
   ip_input.release_focus()
   DisplayServer.virtual_keyboard_hide()
   game.join_host(ip_input.text.strip_edges())
  "discovered":
   ip_input.release_focus()
   DisplayServer.virtual_keyboard_hide()
   game.join_host(str(game.found_hosts[0].ip))
  "start": game.start_run()
  "ready": game.toggle_ready()
  "leave","quit":
   ip_input.release_focus()
   DisplayServer.virtual_keyboard_hide()
   clear_controls();local_pause=false;game.leave_game()
  "back":
   ip_input.release_focus()
   DisplayServer.virtual_keyboard_hide()
   game.leave_game();game.message=""
  "help": help_open=true
  "close_help": help_open=false
  "sound": game.sound_on=not game.sound_on;game.save_settings()
  "settings": panel="settings";clear_controls()
  "wardrobe": panel="wardrobe";preview_style=game.selected_style;clear_controls()
  "modal_close": close_panel()
  "modal_privacy": panel="privacy"
  "modal_credits": panel="credits"
  "modal_licenses":
   panel="licenses"
   if license_view.text.is_empty():
    for path in ["res://assets/GODOT-LICENSE.txt","res://assets/GODOT-THIRD-PARTY.txt","res://assets/FONT-LICENSE.txt","res://addons/GodotGooglePlayBilling/LICENSE"]:
     license_view.text+=FileAccess.get_file_as_string(path)+"\n\n"
  "modal_settings": panel="settings"
  "modal_support": OS.shell_open("mailto:"+CrewRelease.SUPPORT_EMAIL+"?subject=Puff%20Crew%20support")
  "modal_quality":
   game.graphics_quality=(game.graphics_quality+1)%3;game.apply_graphics();game.save_settings()
  "modal_sound": game.sound_on=not game.sound_on;game.save_settings()
  "modal_haptics": game.haptics_on=not game.haptics_on;game.save_settings()
  "modal_buy": game.store.buy()
  "modal_restore": game.store.restore()
  "modal_equip":
   game.select_style(preview_style)
   close_panel()
  "camera": game.overhead=not game.overhead;game.save_settings()
  "pause":
   clear_controls();local_pause=true
   if game.authoritative(): game.run_paused=true
  "resume":
   local_pause=false
   if game.authoritative(): game.run_paused=false
  "retry":
   local_pause=false;game.run_paused=false;game.respawn();game.deaths+=1
  "again": local_pause=false;game.start_run()
 if action.begins_with("modal_style_"):
  preview_style=int(action.trim_prefix("modal_style_"))
  game.raft.set_crew(game.raft.crew_ids,{1:preview_style})

func close_panel() -> void:
 panel=""
 preview_style=game.selected_style

func draw_panel() -> void:
 draw_rect(Rect2(0,0,1280,720),Color(0.035,0.14,0.18,0.10 if panel=="wardrobe" else 0.76))
 if panel!="wardrobe": rounded(Rect2(250,45,780,630),PAPER,28)
 if panel=="settings":
  txt("Make yourself at home.",Vector2(291,111),33)
  txt("Puff Crew: Rapids  "+CrewRelease.VERSION+"  /  "+CrewRelease.PUBLISHER,Vector2(292,146),18,TEAL)
  button("modal_sound","Sound "+("ON" if game.sound_on else "OFF"),Rect2(291,184,318,62))
  button("modal_quality","Graphics: "+["Performance","Balanced","High"][game.graphics_quality],Rect2(628,184,361,62))
  button("modal_haptics","Haptics "+("ON" if game.haptics_on else "OFF"),Rect2(291,260,318,45))
  txt("Performance reduces shadows",Vector2(628,280),16,MUTED)
  txt("to help slower phones.",Vector2(628,300),16,MUTED)
  button("modal_privacy","Privacy policy",Rect2(291,322,698,58))
  button("modal_credits","Credits & licenses",Rect2(291,397,698,58))
  button("modal_support","Email support",Rect2(291,472,698,58))
  centered(CrewRelease.SUPPORT_EMAIL,Rect2(291,542,698,35),18,TEAL)
  button("modal_close","Back to the river",Rect2(291,600,698,48),true)
 elif panel=="privacy":
  txt("Your crew. Your privacy.",Vector2(291,105),31)
  var lines=CrewRelease.privacy_lines()
  for i in range(lines.size()): txt(lines[i],Vector2(292,151+i*35),17,INK if i>0 else TEAL)
  button("modal_settings","< Settings",Rect2(291,600,698,48),true)
 elif panel=="credits":
  txt("Made for good company.",Vector2(291,105),31)
  var lines=["Publisher: Ramo Labs","Original game, characters, scenery and generated audio.","Built with Godot Engine 4.7.2 (MIT license).","Outfit font / The Outfit Project Authors (SIL OFL 1.1).","Google Play Billing plugin 3.3.0 (MIT).","No affiliation with Fart Together or GamesMrkt.","Thank you for sailing with us."]
  for i in range(lines.size()): txt(lines[i],Vector2(292,164+i*43),19)
  button("modal_licenses","Read bundled licenses",Rect2(291,505,698,55))
  button("modal_settings","< Settings",Rect2(291,600,698,48),true)
 elif panel=="licenses":
  txt("Open-source notices",Vector2(291,105),31)
  button("modal_credits","< Credits",Rect2(291,600,698,48),true)
 elif panel=="wardrobe":
  rounded(Rect2(742,61,461,610),PAPER,30)
  txt("Dress for adventure.",Vector2(781,116),30)
  txt("The expedition outfit collection",Vector2(782,151),18,TEAL)
  for i in range(4):
   var r=Rect2(781+(i%2)*198,182+(i/2)*80,185,66)
   rounded(r,TEAL if preview_style==i else Color("e8ecdc"),16)
   centered(CrewRelease.OUTFITS[i],Rect2(r.position+Vector2(0,7),Vector2(185,29)),16,PAPER if preview_style==i else INK)
   centered("AVAILABLE" if game.store.has_outfits() or i==0 else "BUNDLE",Rect2(r.position+Vector2(0,35),Vector2(185,24)),11,PAPER if preview_style==i else TEAL)
   buttons.append({"action":"modal_style_%d"%i,"rect":r,"enabled":true})
  txt("Three hats and matching scarves. Cosmetic only.",Vector2(782,367),16)
  txt("All rivers and crew joining stay free.",Vector2(782,397),17,TEAL)
  txt("Choose your look and take it downriver.",Vector2(782,424),16,MUTED)
  var status=game.store.status
  if status.length()>48:
   var split_at=status.rfind(" ",48)
   txt(status.left(split_at),Vector2(782,455),14,TEAL)
   txt(status.substr(split_at+1).left(53),Vector2(782,474),14,TEAL)
  else: txt(status,Vector2(782,465),14,TEAL)
  var can_equip=true
  button("modal_equip","Wear "+CrewRelease.OUTFITS[preview_style],Rect2(781,493,383,48),true,can_equip)
  button("modal_close","< Back",Rect2(1033,613,131,40))
