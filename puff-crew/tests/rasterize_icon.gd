extends SceneTree
func _initialize() -> void:
 var image=Image.new()
 var result=image.load_svg_from_string(FileAccess.get_file_as_string("res://assets/icon.svg"))
 if result==OK:
  image.resize(256,256,Image.INTERPOLATE_LANCZOS)
  image.save_png("res://assets/icon.png")
 quit(result)
