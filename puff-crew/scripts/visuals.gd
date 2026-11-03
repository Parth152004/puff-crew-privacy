class_name CrewVisuals
extends RefCounted

const PALETTE = [Color("db9b64"), Color("69c5b3"), Color("d99ac5"), Color("9d9ad9")]
static var materials: Dictionary = {}

static func mat(color: Color, roughness: float = 0.75) -> StandardMaterial3D:
	var key = str(color) + str(roughness)
	if materials.has(key): return materials[key]
	var m = StandardMaterial3D.new()
	m.albedo_color = color.srgb_to_linear()
	m.roughness = roughness
	m.metallic_specular = 0.35
	materials[key] = m
	return m

static func mesh(parent: Node3D, shape: Mesh, pos: Vector3, color: Color, scale_v: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var o = MeshInstance3D.new()
	o.mesh = shape
	o.material_override = mat(color)
	o.position = pos
	o.scale = scale_v
	parent.add_child(o)
	return o

static func sphere(parent: Node3D, pos: Vector3, size: Vector3, color: Color, rad: int = 14, rings: int = 7) -> MeshInstance3D:
	var s = SphereMesh.new()
	s.radius = 0.5
	s.height = 1.0
	s.radial_segments = rad
	s.rings = rings
	return mesh(parent, s, pos, color, size)

static func lowpoly_sphere(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	return sphere(parent, pos, size, color, 8, 4)

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var b = BoxMesh.new()
	b.size = size
	return mesh(parent, b, pos, color)

static func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, sides: int = 14, top: float = -1.0) -> MeshInstance3D:
	var c = CylinderMesh.new()
	c.top_radius = radius if top < 0 else top
	c.bottom_radius = radius
	c.height = height
	c.radial_segments = sides
	return mesh(parent, c, pos, color)

static func rod(parent: Node3D, a: Vector3, b: Vector3, radius: float, color: Color, sides: int = 6) -> MeshInstance3D:
	var o = cylinder(parent, (a+b)*0.5, radius, a.distance_to(b), color, sides)
	var up = (b-a).normalized()
	o.quaternion = Quaternion(Vector3.UP, up)
	return o

static func capybara(parent: Node3D, color_index: int, outfit: int = 0) -> Node3D:
	var root = Node3D.new()
	parent.add_child(root)
	var col: Color = PALETTE[color_index % 4]
	sphere(root, Vector3(0,0.45,0.06), Vector3(0.72,0.82,0.9), col)
	sphere(root, Vector3(0,0.99,-0.16), Vector3(0.78,0.68,0.77), col.lightened(0.07))
	sphere(root, Vector3(0,0.88,-0.5), Vector3(0.69,0.4,0.42), col.lightened(0.27))
	var eyes: Array[Node3D]=[]
	var arms: Array[Node3D]=[]
	for side in [-1,1]:
		sphere(root, Vector3(side*0.28,1.29,-0.02), Vector3(0.22,0.24,0.16), col.darkened(0.08), 10, 5)
		sphere(root, Vector3(side*0.28,1.30,-0.10), Vector3(0.11,0.13,0.045), col.lightened(0.3), 8, 4)
		var eye = Node3D.new()
		eye.position = Vector3(side*0.25,1.09,-0.48)
		root.add_child(eye)
		sphere(eye, Vector3.ZERO, Vector3(0.14,0.17,0.065), Color("fffbeb"), 10, 5)
		sphere(eye, Vector3(0,-0.01,-0.035), Vector3(0.077,0.1,0.04), Color("253d43"), 8, 4)
		sphere(eye, Vector3(-side*0.01,0.015,-0.055), Vector3(0.023,0.03,0.012), Color.WHITE, 6, 3)
		eyes.append(eye)
		sphere(root, Vector3(side*0.13,0.96,-0.693), Vector3(0.065,0.04,0.022), col.darkened(0.5), 6, 3)
		var arm = sphere(root, Vector3(side*0.37,0.55,-0.12), Vector3(0.24,0.48,0.27), col.darkened(0.03), 10, 5)
		arms.append(arm)
		sphere(root, Vector3(side*0.22,0.13,-0.18), Vector3(0.29,0.22,0.43), col.darkened(0.1), 10, 5)
	sphere(root, Vector3(0,0.8,-0.692), Vector3(0.17,0.023,0.02), col.darkened(0.5), 6, 3)
	var scarf_color = [Color("fff0bc"),Color("ee796b"),Color("64bbcf"),Color("dcafef")][clampi(outfit,0,3)]
	var scarf = cylinder(root,Vector3(0,0.73,-0.05),0.35,0.13,scarf_color,16)
	scarf.scale.z = 0.9
	var tail = box(root,Vector3(0.18,0.62,-0.39),Vector3(0.13,0.28,0.04),scarf_color)
	if outfit == 1:
		cylinder(root,Vector3(0,1.36,-0.13),0.38,0.12,Color("fff6dd"),16)
		cylinder(root,Vector3(0,1.47,-0.13),0.29,0.17,Color("284b66"),16,0.25)
		sphere(root,Vector3(0,1.46,-0.39),Vector3(0.13,0.12,0.05),Color("f4cc72"),8,4)
	elif outfit == 2:
		cylinder(root,Vector3(0,1.36,-0.13),0.47,0.07,Color("e7b16d"),16)
		cylinder(root,Vector3(0,1.47,-0.10),0.29,0.20,Color("ffe1a0"),14,0.24)
		cylinder(root,Vector3(0,1.40,-0.10),0.30,0.07,Color("64bbcf"),16)
	elif outfit == 3:
		cylinder(root,Vector3(0,1.36,-0.10),0.44,0.07,Color("6262a8"),16)
		cylinder(root,Vector3(0,1.68,-0.10),0.30,0.64,Color("8481c8"),12,0.015)
		for j in range(3): sphere(root,Vector3((j-1)*0.10,1.52+j*0.11,-0.31+j*0.05),Vector3.ONE*0.07,Color("ffe7a0"),6,3)
	root.set_meta("eyes",eyes)
	root.set_meta("arms",arms)
	root.set_meta("scarf_tail",tail)
	return root

static func animate_capybara(root: Node3D, t: float, puff: bool, phase: float) -> void:
	var blink = fmod(t+phase*1.7, 4.8)
	for eye in root.get_meta("eyes",[]): eye.scale.y = 0.12 if blink>4.62 else 1.0
	var arms = root.get_meta("arms",[])
	for i in range(arms.size()):
		arms[i].rotation.x = sin(t*(14.0 if puff else 2.0)+phase)*0.12-(0.28 if puff else 0.0)
	var tail: Node3D = root.get_meta("scarf_tail")
	tail.rotation.x = sin(t*4.0+phase)*0.11+(0.15 if puff else 0.0)

static func palm(parent: Node3D, pos: Vector3, seed_n: int) -> void:
	var trunk = Node3D.new()
	parent.add_child(trunk)
	trunk.position = pos
	var h = 3.4 + fmod(seed_n*0.37, 1.6)
	var lean = sin(seed_n*2.2)*0.55
	for i in range(3):
		var a = Vector3(lean*i/3.0, h*i/3.0, 0)
		var b = Vector3(lean*(i+1)/3.0, h*(i+1)/3.0, 0)
		rod(trunk, a, b, 0.15-i*0.018, Color("b77a4f"), 6)
	for i in range(5):
		var angle = i*TAU/5.0 + seed_n
		var direction = Vector3(cos(angle), 0, sin(angle))
		var cross_dir = Vector3(-sin(angle), 0, cos(angle))
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for segment in range(3):
			var t0 = segment/3.0
			var t1 = (segment+1)/3.0
			var a = Vector3(lean, h+0.2, 0) + direction*t0*2.8 + Vector3(0, -t0*t0*0.8, 0)
			var b = Vector3(lean, h+0.2, 0) + direction*t1*2.8 + Vector3(0, -t1*t1*0.8, 0)
			var w0 = sin(t0*PI)*0.42 + 0.02
			var w1 = sin(t1*PI)*0.42 + 0.02
			var verts = [a-cross_dir*w0, b-cross_dir*w1, b+cross_dir*w1, a+cross_dir*w0]
			for k in [0,1,2, 0,2,3]: st.add_vertex(verts[k])
		st.generate_normals()
		var leaf_mat = mat(Color("2fa874").lightened((i%3)*0.06)).duplicate()
		leaf_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		var leaf = MeshInstance3D.new()
		leaf.mesh = st.commit()
		leaf.material_override = leaf_mat
		trunk.add_child(leaf)
	lowpoly_sphere(trunk, Vector3(lean, h-0.15, 0), Vector3(0.55, 0.35, 0.55), Color("7a5638"))

static func garden(parent: Node3D, pos: Vector3, seed_n: int) -> void:
	var green = Color("3fa86a")
	for i in range(3):
		var offset = Vector3(sin(seed_n+i*2.1)*0.9, 0, cos(seed_n+i*2.1)*0.9)
		lowpoly_sphere(parent, pos+offset+Vector3(0,0.22,0), Vector3(0.75,0.55,0.75), green.lightened((i%2)*0.07))
	for i in range(2):
		var base = pos + Vector3(sin(seed_n+i*1.8)*1.1, 0.35, cos(seed_n+i*1.8)*1.1)
		rod(parent, base, base+Vector3(0,0.4,0), 0.025, green, 4)
		var flower = base + Vector3(0,0.42,0)
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for j in range(5):
			var a0 = j * TAU / 5.0
			var a1 = (j + 0.5) * TAU / 5.0
			var a2 = (j + 1.0) * TAU / 5.0
			var p0 = flower
			var p1 = flower + Vector3(cos(a0)*0.16, 0, sin(a0)*0.16)
			var p2 = flower + Vector3(cos(a1)*0.26, 0.02, sin(a1)*0.26)
			var p3 = flower + Vector3(cos(a2)*0.16, 0, sin(a2)*0.16)
			st.set_normal(Vector3.UP)
			for v in [p0, p1, p2, p0, p2, p3]: st.add_vertex(v)
		var flower_mesh = MeshInstance3D.new()
		flower_mesh.mesh = st.commit()
		flower_mesh.material_override = mat(Color("f48c82") if i==0 else Color("ffd166"))
		parent.add_child(flower_mesh)
		lowpoly_sphere(parent, flower+Vector3(0,0.02,0), Vector3(0.10,0.07,0.10), Color("fff2aa"))

static func island(parent: Node3D, pos: Vector3, seed_n: int, theme: int) -> void:
	var sand = [Color("e5bc83"),Color("edb47d"),Color("c1bedb")][theme]
	var stone = [Color("ae805f"),Color("bb7b60"),Color("8a89a9")][theme]
	var grass = [Color("73b68b"),Color("9dbb71"),Color("8dada9")][theme]
	var count = 8
	var radii: Array[float] = []
	for i in range(count): radii.append(1.0 + sin(i*2.73+seed_n)*0.08)
	var heights = [-5.5, -2.5, -0.4, 0.35]
	var widths = [1.8, 3.5, 4.3, 4.1]
	var colors = [stone.darkened(0.1), stone, sand, grass]
	for layer in range(heights.size()-1):
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(count):
			var j = (i+1)%count
			var d0 = Vector3(cos(i*TAU/count),0,sin(i*TAU/count))*radii[i]
			var d1 = Vector3(cos(j*TAU/count),0,sin(j*TAU/count))*radii[j]
			var a = d0*widths[layer] + Vector3(0,heights[layer],0)
			var b = d0*widths[layer+1] + Vector3(0,heights[layer+1],0)
			var c = d1*widths[layer+1] + Vector3(0,heights[layer+1],0)
			var d = d1*widths[layer] + Vector3(0,heights[layer],0)
			for vertex in [a,b,c, a,c,d]: st.add_vertex(vertex)
		st.generate_normals()
		var rock = mesh(parent, st.commit(), pos, colors[layer])
		if layer < 2: rock.material_override.disable_receive_shadows = true
	var top = SurfaceTool.new()
	top.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(count):
		var j = (i+1)%count
		var p0 = Vector3(0, 0.35, 0)
		var p1 = Vector3(cos(i*TAU/count)*radii[i]*4.1, 0.35, sin(i*TAU/count)*radii[i]*4.1)
		var p2 = Vector3(cos(j*TAU/count)*radii[j]*4.1, 0.35, sin(j*TAU/count)*radii[j]*4.1)
		top.set_normal(Vector3.UP)
		for v in [p0, p1, p2]: top.add_vertex(v)
	mesh(parent, top.commit(), pos, grass)
