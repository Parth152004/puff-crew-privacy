class_name RapidsCourse
extends Node3D

const V = preload("res://scripts/visuals.gd")
const TITLES = ["SUNLIT SHOALS", "MANGO TWIST", "MOONSTONE RUN"]
const SUBTITLES = ["Find your flow", "Mind the moving parts", "A little less room for error"]
var course_index: int = 0
var length_m: float = 210.0
var hazards: Array[Dictionary] = []
var water_mat: ShaderMaterial
var checkpoint_nodes: Array[Node3D] = []
var stage_time: float = 0.0

func center_at(p: float) -> float:
 return sin(p*0.033)*4.0 + sin(p*0.068)*1.5*(course_index+1)*0.5

func width_at(p: float) -> float:
 var base = 11.5 - course_index*0.65
 if p < 15: return 13.5
 if p > 200: return 14.0
 if p > 78 and p < 90: return 8.5-course_index*0.35
 return base

func is_gap(p: float) -> bool:
 return p > 125.0 and p < 128.3

func build(index: int) -> void:
 course_index = index
 for n in get_children():
  remove_child(n)
  n.queue_free()
 hazards.clear()
 checkpoint_nodes.clear()
 var surface = SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var sand = Color("edc99b")
 for n in range(-12,225):
  var p = float(n)
  if is_gap(p+0.5): continue
  var c0 = center_at(p)
  var c1 = center_at(p+1)
  var w0 = width_at(p)*0.5
  var w1 = width_at(p+1)*0.5
  var vertices = [Vector3(c0-w0,0,-p),Vector3(c1-w1,0,-p-1),Vector3(c1+w1,0,-p-1),Vector3(c0+w0,0,-p)]
  for j in [0,1,2,0,2,3]:
   surface.set_normal(Vector3.UP)
   surface.set_uv(Vector2(0.0 if j in [0,1] else 1.0,p if j in [0,3] else p+1.0))
   surface.add_vertex(vertices[j])
  for side in [-1,1]:
   var a = Vector3(c0+side*(w0+0.12),-0.13,-p)
   var b = Vector3(c1+side*(w1+0.12),-0.13,-p-1)
   var curb = V.box(self,(a+b)*0.5,Vector3(0.27,0.36,a.distance_to(b)+0.025),sand)
   curb.rotation.y = atan2(b.x-a.x,b.z-a.z)
 var water = MeshInstance3D.new()
 water.mesh = surface.commit()
 water_mat = ShaderMaterial.new()
 water_mat.shader = preload("res://shaders/water.gdshader")
 if index == 1:
  water_mat.set_shader_parameter("deep_color",Color("197c94"))
  water_mat.set_shader_parameter("shallow_color",Color("6cddd0"))
 elif index == 2:
  water_mat.set_shader_parameter("deep_color",Color("4b67a6"))
  water_mat.set_shader_parameter("shallow_color",Color("8ba9de"))
 water.material_override = water_mat
 add_child(water)
 # Sunken underside: channels float above the ocean, with open edges.
 for n in range(-10,221,5):
  if n >= 125 and n <= 128: continue
  var p = float(n)
  var base = V.box(self,Vector3(center_at(p),-0.45,-p),Vector3(width_at(p)+0.4,0.55,5.08),Color("d9b888"))
  base.rotation.y = -atan((center_at(p+1)-center_at(p-1))*0.5)
  for side in [-1,1]:
   if n%15 != 0: continue
   var island = Vector3(center_at(p)+side*(14.0+sin(n)*2),-0.15,-p-2)
   V.island(self,island,n+side,index)
   V.palm(self,island+Vector3(side,0.6,0),n+side*8)
   V.garden(self,island+Vector3(-side*1.2,0.55,1.4),n+side)
   for k in range(2):
    var rock = V.lowpoly_sphere(self,island+Vector3(sin(n+k)*2.2,0.6,cos(n+k)*2.2),Vector3(0.9,0.7+k*0.2,0.9),Color("b5c2b1"))
    rock.rotation.y = k
 # Ocean under the elevated course, with a fogged horizon.
 var ocean = V.box(self,Vector3(0,-8,-95),Vector3(220,0.12,450),Color("62b7bd"))
 ocean.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for p in [0.0,70.0,140.0,210.0]:
  make_arch(p,"FINISH" if p == 210 else ("READY, CREW?" if p == 0 else "CHECKPOINT"))
 add_hazard("bumper",24,-2.2)
 add_hazard("bumper",32,2.2)
 add_hazard("spinner",48,0)
 add_hazard("gate",61,0)
 add_hazard("bumper",83,1.3)
 add_hazard("whirlpool",103,-0.9)
 add_hazard("boost",119,0)
 add_hazard("spinner",153,0)
 add_hazard("gate",176,0)
 add_hazard("bumper",190,-2)
 if index > 0:
  add_hazard("bumper",39,2.2)
  add_hazard("whirlpool",92,1.8)
 if index > 1:
  add_hazard("spinner",197,0)
 for p in range(7,208,9):
  if is_gap(p): continue
  var x = center_at(p)
  for side in [-1,1]:
   # Small buoys visually mark the safe channel without covering its surface.
   V.lowpoly_sphere(self,Vector3(x+side*(width_at(p)*0.5+0.6),0.28,-p),Vector3(0.4,0.55,0.4),Color("ffb17a"))

 merge_static_geometry()

func make_arch(p: float, text: String) -> void:
 var root = Node3D.new()
 root.position = Vector3(center_at(p),0,-p)
 add_child(root)
 checkpoint_nodes.append(root)
 var w = width_at(p)*0.5
 for side in [-1,1]:
  V.cylinder(root,Vector3(side*(w+0.5),2.5,0),0.14,5,Color("e9bd78"))
  V.sphere(root,Vector3(side*(w+0.5),5.05,0),Vector3(0.4,0.4,0.4),Color("fff0c0"))
 V.rod(root,Vector3(-w-0.5,4.8,0),Vector3(w+0.5,4.8,0),0.12,Color("e9bd78"))
 V.box(root,Vector3(0,4.5,0),Vector3(5.4,1.1,0.16),Color("1e6c72"))
 var label = Label3D.new()
 label.text = text
 label.font_size = 54
 label.pixel_size = 0.012
 label.position = Vector3(0,4.5,0.11)
 label.modulate = Color("fff1cc")
 label.outline_size = 0
 root.add_child(label)
 for i in range(9):
  var flag = V.cylinder(root,Vector3((i-4)*1.1,4.35,0),0.26,0.65,Color("faab83") if i%2==0 else Color("a7dfbe"),3,0)
  flag.rotation.z = PI

func add_hazard(kind: String, p: float, offset: float) -> void:
 var root = Node3D.new()
 root.position = Vector3(center_at(p)+offset,0,-p)
 add_child(root)
 var h: Dictionary = {"kind":kind,"p":p,"offset":offset,"node":root,"phase":p*0.39}
 match kind:
  "bumper":
   V.cylinder(root,Vector3(0,0.35,0),0.93,0.7,Color("ffe4a9"))
   V.sphere(root,Vector3(0,0.9,0),Vector3(1.85,1.2,1.85),Color("f18d7e"))
   V.cylinder(root,Vector3(0,1.43,0),0.3,0.14,Color("ffe4a9"))
  "spinner":
   V.cylinder(root,Vector3(0,0.45,0),0.5,0.9,Color("ffe4a9"))
   var arm = Node3D.new()
   root.add_child(arm)
   V.box(arm,Vector3(0,0.65,0),Vector3(7.0,0.35,0.45),Color("e59570"))
   for side in [-1,1]:
    V.sphere(arm,Vector3(side*3.5,0.65,0),Vector3(1.05,1.05,1.05),Color("ee7b79"))
    for j in range(6):
     var a = TAU*j/6
     var spike = V.cylinder(arm,Vector3(side*3.5+cos(a)*0.53,0.7,sin(a)*0.53),0.15,0.38,Color("fff1c6"),6,0)
     spike.quaternion = Quaternion(Vector3.UP,Vector3(cos(a),0,sin(a)))
   h["arm"] = arm
  "gate":
   var left = V.box(root,Vector3.ZERO,Vector3(3.2,1.6,0.85),Color("bd9bc6"))
   var right = V.box(root,Vector3.ZERO,Vector3(3.2,1.6,0.85),Color("bd9bc6"))
   for node in [left,right]:
    V.box(node,Vector3(0,0,0.44),Vector3(0.25,1.6,0.025),Color("ffe4ba"))
   h["left"] = left
   h["right"] = right
  "whirlpool":
   V.cylinder(root,Vector3(0,0.032,0),2.25,0.018,Color("1c8194"),48)
   var spiral=SurfaceTool.new()
   spiral.begin(Mesh.PRIMITIVE_TRIANGLES)
   for arm in range(3):
    for j in range(48):
     var vertices=[]
     for step in [j,j+1]:
      var u=step/48.0
      var radius=0.37+u*1.92
      var angle=u*TAU*0.70+arm*TAU/3.0
      var v=Vector3(cos(angle),0,sin(angle))
      vertices.append(v*(radius-0.055)+Vector3(0,0.067,0))
      vertices.append(v*(radius+0.055)+Vector3(0,0.067,0))
     for k in [0,2,1,1,2,3]:
      spiral.set_normal(Vector3.UP)
      spiral.add_vertex(vertices[k])
   var foam=V.mesh(root,spiral.commit(),Vector3.ZERO,Color("d4f5dc"))
   foam.material_override=foam.material_override.duplicate()
   foam.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED
   foam.material_override.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
   foam.material_override.albedo_color=Color("dffbe9")
   foam.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
   V.cylinder(root,Vector3(0,0.08,0),0.55,0.025,Color("174b64"))
  "boost":
   for j in range(3):
    for side in [-1,1]:
     var b = V.box(root,Vector3(side*0.42,0.06,j*0.75),Vector3(1.0,0.08,0.23),Color("ffda87"))
     b.rotation.y = side*0.55
 hazards.append(h)

func update_hazards(t: float) -> void:
 stage_time = t
 for h in hazards:
  var root: Node3D = h.node
  var speed = 0.75+course_index*0.18
  match h.kind:
   "spinner": h.arm.rotation.y = t*speed + h.phase
   "gate":
    var gap = 3.2+sin(t*(0.95+course_index*0.15)+h.phase)*1.55
    h.left.position = Vector3(-gap*0.5-1.6,0.65,0)
    h.right.position = Vector3(gap*0.5+1.6,0.65,0)
    h["gap"] = gap
   "whirlpool": root.rotation.y = t*1.3
   "bumper": root.scale.y = 1.0+sin(t*2+h.phase)*0.03

# Batch static scenery by material to avoid hundreds of mobile draw calls.
func merge_static_geometry() -> void:
 var excluded: Array[Node] = []
 for h in hazards: excluded.append(h.node)
 var groups: Dictionary = {}
 collect_static(self,Transform3D.IDENTITY,excluded,groups)
 for key in groups:
  var group: Dictionary=groups[key]
  var st=SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for item in group.items:
   var instance: MeshInstance3D=item.node
   for surface_i in range(instance.mesh.get_surface_count()):
    st.append_from(instance.mesh,surface_i,item.transform)
   var p_node = instance.get_parent()
   if p_node != null:
    p_node.remove_child(instance)
    instance.queue_free()
    if p_node != self and p_node.get_child_count() == 0:
     var grand = p_node.get_parent()
     if grand != null: grand.remove_child(p_node)
     p_node.queue_free()
  var combined=MeshInstance3D.new()
  combined.mesh=st.commit()
  combined.material_override=group.material
  combined.cast_shadow=group.cast_shadow
  add_child(combined)

func collect_static(node: Node, transform: Transform3D, excluded: Array[Node], groups: Dictionary) -> void:
 for child in node.get_children():
  if child.is_queued_for_deletion() or child in excluded: continue
  if not child is Node3D: continue
  var next_transform: Transform3D=transform*child.transform
  if child is MeshInstance3D and child.material_override is StandardMaterial3D:
   # Local chunks can be culled independently; 70m chunks optimize draw calls and build time.
   var key=str(child.material_override.get_instance_id())+":"+str(int(floor(next_transform.origin.z/70.0)))+":"+str(child.cast_shadow)
   if not groups.has(key): groups[key]={"material":child.material_override,"cast_shadow":child.cast_shadow,"items":[]}
   groups[key].items.append({"node":child,"transform":next_transform})
  collect_static(child,next_transform,excluded,groups)
