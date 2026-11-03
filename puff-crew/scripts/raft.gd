class_name PuffRaft
extends Node3D
const V = preload("res://scripts/visuals.gd")
var deck: Node3D
var crew_nodes: Array[Node3D] = []
var jets: Array[Node3D] = []
var wake: Array[MeshInstance3D] = []
var crew_ids: Array = []
var crew_styles: Dictionary = {}
var deck_style: int = -1
var t: float = 0.0
var local_player: int = 1
var show_labels: bool = false

func _ready() -> void:
 deck = Node3D.new()
 add_child(deck)
 var hull=V.cylinder(deck,Vector3(0,0,0),1.5,0.36,Color("f1bd76"),24)
 hull.material_override=hull.material_override.duplicate()
 hull.material_override.disable_receive_shadows=true
 V.cylinder(deck,Vector3(0,0.22,0),1.27,0.13,Color("fff1c9"),24)
 for j in range(-3,4):
  V.box(deck,Vector3(0,0.298,j*0.32),Vector3(2.2-abs(j)*0.15,0.025,0.023),Color("dfbf8a"))
 var ring = TorusMesh.new()
 ring.inner_radius = 1.27
 ring.outer_radius = 1.65
 ring.rings = 24
 ring.ring_segments = 8
 var rim=V.mesh(deck,ring,Vector3(0,0.25,0),Color("ef9a70"),Vector3(1,0.7,1))
 rim.material_override=rim.material_override.duplicate()
 rim.material_override.disable_receive_shadows=true
 for j in range(8):
  var a = j*TAU/8
  var wrap = V.box(deck,Vector3(cos(a)*1.45,0.3,sin(a)*1.45),Vector3(0.3,0.3,0.39),Color("fff0c6"))
  wrap.rotation.y = -a
 for j in range(3):
  var tor = TorusMesh.new()
  tor.inner_radius = 1.5+j*0.14
  tor.outer_radius = 1.54+j*0.14
  tor.rings = 24
  tor.ring_segments = 4
  var m = V.mesh(self,tor,Vector3(0,-0.3,0),Color("c4f5e8"),Vector3(1,0.03,1))
  m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  wake.append(m)
 set_crew([1])

func set_crew(ids: Array, styles: Dictionary = {}) -> void:
 if ids == crew_ids and styles==crew_styles: return
 crew_ids = ids.duplicate()
 crew_styles=styles.duplicate()
 for n in crew_nodes: n.queue_free()
 for n in jets: n.queue_free()
 crew_nodes.clear()
 jets.clear()
 for i in range(ids.size()):
  var c = V.capybara(deck,i,int(styles.get(ids[i],0)))
  c.scale = Vector3.ONE*0.83
  var label=Label3D.new()
  label.name="YouLabel"
  label.text="YOU"
  label.font=preload("res://assets/Outfit-Bold.ttf")
  label.font_size=38
  label.outline_size=6
  label.pixel_size=0.011
  label.position=Vector3(0,1.75,0)
  label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
  label.modulate=Color("fff7de")
  label.outline_modulate=Color("173f4a")
  c.add_child(label)
  crew_nodes.append(c)
  var jet = Node3D.new()
  add_child(jet)
  for j in range(4):
   var bubble = V.lowpoly_sphere(jet,Vector3(0,0,j*0.28),Vector3.ONE*(0.17+j*0.07),Color("d8ed9e"))
   bubble.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  jets.append(jet)

func seat(i: int) -> Vector3:
 if crew_ids.size() == 1: return Vector3.ZERO
 var a = TAU*i/crew_ids.size()
 return Vector3(sin(a)*0.78,0,cos(a)*0.78)

func animate(dt: float, angle: float, velocity: Vector2, players: Dictionary, falling: float) -> void:
 t += dt
 deck.rotation = Vector3(sin(t*3.1)*0.025+velocity.y*0.006,angle,sin(t*2.6)*0.025-velocity.x*0.014)
 if falling > 0:
  deck.rotation.x += falling*2.5
  deck.rotation.z += falling
 for i in range(crew_ids.size()):
  var id = crew_ids[i]
  var p: Dictionary = players.get(id,{})
  var aim: Vector2 = p.get("aim",Vector2(0,-1))
  var puff: bool = p.get("puff",false) and p.get("gas",1.0)>0.04
  var c: Node3D = crew_nodes[i]
  c.get_node("YouLabel").visible=show_labels and id==local_player
  var def_seat = seat(i)
  var dpos: Vector2 = p.get("deck_pos", Vector2(def_seat.x, def_seat.z))
  var is_walking = (p.get("move", Vector2.ZERO) as Vector2).length_squared() > 0.05
  var waddle = sin(t*18.0)*0.06 if is_walking else 0.0
  c.position = Vector3(dpos.x, 0.32+sin(t*4+i)*0.025, dpos.y)
  c.rotation.y = lerp_angle(c.rotation.y,atan2(-aim.x,-aim.y)-angle,0.22)
  c.rotation.z = lerp_angle(c.rotation.z, waddle, 0.3)
  c.scale.y = 0.83+(sin(t*28)*0.035 if puff else 0.0)
  V.animate_capybara(c,t,puff,float(i))
  var jet: Node3D = jets[i]
  jet.visible = puff and falling <= 0
  var world_seat = Vector3(dpos.x, 0, dpos.y).rotated(Vector3.UP, angle)
  var aim_norm = aim.normalized() if aim.length_squared() > 0.01 else Vector2(0, -1)
  # Position puff jet at capybara's rear and project outward into the water outside the plate
  jet.position = world_seat + Vector3(-aim_norm.x*0.45, 0.35, -aim_norm.y*0.45)
  jet.rotation.y = atan2(-aim_norm.x, -aim_norm.y)
  jet.scale = Vector3.ONE*(0.85+sin(t*30)*0.18)
 for j in range(wake.size()):
  var phase = fmod(t*0.7+j*0.25,1.0)
  wake[j].scale = Vector3(1+phase*0.7,0.03,1+phase*0.7)
  wake[j].position.y = -0.3-j*0.002
  wake[j].visible = falling <= 0
