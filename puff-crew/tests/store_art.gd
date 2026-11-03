extends SceneTree
class FeatureTitle extends Control:
 var font=preload("res://assets/Outfit-Bold.ttf")
 func _draw():
  var card=StyleBoxFlat.new()
  card.bg_color=Color("fff7e6")
  card.set_corner_radius_all(26)
  draw_style_box(card,Rect2(30,30,390,440))
  draw_string(font,Vector2(61,85),"RAMO LABS",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("237f83"))
  draw_string(font,Vector2(55,196),"PUFF",HORIZONTAL_ALIGNMENT_LEFT,-1,101,Color("173f4a"))
  draw_string(font,Vector2(55,290),"CREW",HORIZONTAL_ALIGNMENT_LEFT,-1,96,Color("173f4a"))
  draw_string(font,Vector2(64,335),"R A P I D S",HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("237f83"))
  draw_string(font,Vector2(63,396),"One raft. Your whole crew.",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("173f4a"))
  draw_string(font,Vector2(63,433),"Solo + same-Wi-Fi co-op",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("237f83"))
func _initialize(): call_deferred("run")
func run():
 root.content_scale_size=Vector2i(1024,500)
 var game=load("res://main.tscn").instantiate()
 game.capture_mode=true
 root.add_child(game)
 game.hud.hide()
 for i in range(12):await process_frame
 game.set_process(false)
 game.camera.position=Vector3(8,8,13)
 game.camera.look_at(Vector3(-4,0.8,-0.1))
 var layer=CanvasLayer.new();root.add_child(layer)
 layer.add_child(FeatureTitle.new())
 await RenderingServer.frame_post_draw
 var output=OS.get_environment("PUFF_FEATURE_PATH")
 root.get_texture().get_image().save_png(output)
 var icon=Image.new()
 var svg=FileAccess.get_file_as_string("res://assets/icon.svg").replace('rx="112"','rx="0"')
 icon.load_svg_from_string(svg)
 icon.save_png(output.get_base_dir()+"/icon-512.png")
 game.quit_cleanly(0)
