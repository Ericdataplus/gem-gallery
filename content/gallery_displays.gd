class_name GalleryDisplays

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# GALLERY DISPLAYS — collector-style displays for the gem gallery, modelled on
# real ones: a framed gem-box case, a rainbow sapphire line on white felt, a
# loose parcel on black velvet with signet rings and coins, a light-box parcel,
# amethyst cathedrals on metal stands, Okorusu fluorite on acrylic blocks, a
# Mughal-style jewelled bowl and a diamond bib necklace on a velvet bust.
#
#   GalleryDisplays.build(gallery, x_left, x_right, z_start, z_back)
#   (gallery must provide _label(text, pos, px) for the floating labels)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

static var _m := {}

static func _mats() -> Dictionary:
	if not _m.is_empty():
		return _m
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.03, 0.03, 0.035)
	black.roughness = 0.6
	var velvet := StandardMaterial3D.new()
	velvet.albedo_color = Color(0.008, 0.008, 0.01)
	velvet.roughness = 1.0
	velvet.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	velvet.rim_enabled = true
	velvet.rim = 0.3
	velvet.rim_tint = 0.0
	var felt := StandardMaterial3D.new()
	felt.albedo_color = Color(0.62, 0.62, 0.61)
	felt.roughness = 1.0
	var plastic := StandardMaterial3D.new()
	plastic.albedo_color = Color(0.93, 0.93, 0.92)
	plastic.roughness = 0.32
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.82, 0.68, 0.50)
	wood.roughness = 0.55
	var dark_wood := StandardMaterial3D.new()
	dark_wood.albedo_color = Color(0.14, 0.10, 0.08)
	dark_wood.roughness = 0.5
	var steel := StandardMaterial3D.new()
	steel.albedo_color = Color(0.80, 0.80, 0.82)
	steel.metallic = 1.0
	steel.roughness = 0.16
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.92, 0.72, 0.36)
	gold.metallic = 1.0
	gold.roughness = 0.22
	var brass := StandardMaterial3D.new()
	brass.albedo_color = Color(0.84, 0.66, 0.34)
	brass.metallic = 1.0
	brass.roughness = 0.34
	var enamel := StandardMaterial3D.new()
	enamel.albedo_color = Color(0.015, 0.20, 0.09)
	enamel.roughness = 0.10
	enamel.clearcoat_enabled = true
	enamel.clearcoat = 0.8
	var red_enamel := StandardMaterial3D.new()
	red_enamel.albedo_color = Color(0.32, 0.03, 0.04)
	red_enamel.roughness = 0.12
	var acrylic := StandardMaterial3D.new()
	acrylic.albedo_color = Color(0.92, 0.96, 1.0, 0.16)
	acrylic.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	acrylic.roughness = 0.03
	acrylic.metallic_specular = 0.9
	var lightbox := StandardMaterial3D.new()
	lightbox.albedo_color = Color(0.95, 0.95, 0.95)
	lightbox.emission_enabled = true
	lightbox.emission = Color(1.0, 0.99, 0.97)
	lightbox.emission_energy_multiplier = 0.7
	_m = {"black": black, "velvet": velvet, "felt": felt, "plastic": plastic, "wood": wood,
		"dark_wood": dark_wood, "steel": steel, "gold": gold, "brass": brass, "enamel": enamel,
		"red_enamel": red_enamel, "acrylic": acrylic, "lightbox": lightbox}
	return _m

# ── shared bits ──────────────────────────────────────────────────────────────
static func _box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material, collide := false) -> MeshInstance3D:
	var mi := MeshUtils.make_rounded_box(size, -1.0, mat)
	mi.position = pos
	parent.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = size
		cs.shape = sh
		body.add_child(cs)
		body.position = pos
		parent.add_child(body)
	return mi

## A display table: dark body, chosen top surface. Returns the top height.
static func _table(parent: Node3D, pos: Vector3, size: Vector2, top: Material, h := 0.95) -> float:
	var mats := _mats()
	_box(parent, Vector3(size.x, h - 0.03, size.y), pos + Vector3(0, (h - 0.03) * 0.5, 0), mats["dark_wood"], true)
	_box(parent, Vector3(size.x - 0.04, 0.03, size.y - 0.04), pos + Vector3(0, h - 0.015, 0), top)
	return h

static func _spot(parent: Node3D, from: Vector3, to: Vector3, energy := 5.0, angle := 26.0) -> void:
	var sl := SpotLight3D.new()
	sl.light_color = Color(1.0, 0.98, 0.95)
	sl.light_energy = energy
	sl.spot_range = from.distance_to(to) * 1.6
	sl.spot_angle = angle
	sl.shadow_enabled = true
	parent.add_child(sl)
	sl.look_at_from_position(from, to, Vector3.UP)

static func _table_up(rng: RandomNumberGenerator, size: float, tilt := 0.18) -> Basis:
	var b := Basis(Vector3.UP, rng.randf() * TAU)
	b = b * Basis(Vector3(1, 0, 0).rotated(Vector3.UP, rng.randf() * TAU), rng.randf_range(0.0, tilt))
	return b.scaled(Vector3.ONE * size)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
static func build(g: Node3D, x_left: float, x_right: float, z_start: float, z_back: float) -> void:
	_gem_case(g, Vector3(x_left - 2.6, 0, z_start + 4.0))
	_rainbow(g, Vector3(x_left, 0, z_start + 11.0))
	_cathedrals(g, Vector3(x_left - 0.6, 0, z_start + 17.0))
	_velvet_parcel(g, Vector3(x_right, 0, z_start + 3.0))
	_lightbox_parcel(g, Vector3(x_right, 0, z_start + 9.5))
	_fluorite_table(g, Vector3(x_right, 0, z_start + 16.5))
	_mughal_bowl(g, Vector3(-2.2, 0, z_back))
	_necklace(g, Vector3(2.2, 0, z_back))
	_emerald_ring(g, Vector3(0.0, 0, z_back + 0.2))
	_turquoise(g, Vector3(0.0, 0, z_back - 1.6))
	_shop_bins(g, Vector3(x_right, 0, z_start + 24.5))
	_glass_case(g, Vector3(x_left, 0, z_start + 28.0))

# ── 1. framed gem-box case on a wall (faces +X) ─────────────────────────────
static func _gem_case(g: Node3D, base: Vector3) -> void:
	var mats := _mats()
	var root := Node3D.new()
	root.position = base
	g.add_child(root)
	# wall
	_box(root, Vector3(0.2, 3.2, 5.2), Vector3(-0.15, 1.6, 0), mats["black"], true)
	var cols := 5
	var rows := 8
	var cell := 0.135
	var boxw := 0.118
	var panel_w := cols * cell
	var gap := 0.06
	var total := 3.0 * panel_w + 2.0 * gap
	var cy := 1.55
	var x_face := 0.0
	# frame + black backing
	_box(root, Vector3(0.04, rows * cell + 0.06, total + 0.06), Vector3(x_face, cy, 0), mats["black"])
	for sgn in [-1.0, 1.0]:
		_box(root, Vector3(0.1, rows * cell + 0.22, 0.08), Vector3(x_face + 0.03, cy, sgn * (total * 0.5 + 0.07)), mats["wood"])
		_box(root, Vector3(0.1, 0.08, total + 0.22), Vector3(x_face + 0.03, cy + sgn * (rows * cell * 0.5 + 0.07), 0), mats["wood"])
	# the stones: 120 picks sorted by colour like a real collection case
	var rng := RandomNumberGenerator.new()
	rng.seed = 120
	var stones: Array = GemFactory.OPTICS.keys()
	var cut_pool := ["round", "oval", "oval", "cushion", "pear", "emerald", "princess", "trillion", "marquise",
		"radiant", "heart", "baguette", "asscher", "old_european"]
	var picks := []
	for i in range(cols * rows * 3):
		var st: String = stones[rng.randi() % stones.size()]
		var c: Color = GemFactory.OPTICS[st][0]
		var key := c.h if c.s > 0.12 else -1.0 + c.v
		picks.append([key, st, cut_pool[rng.randi() % cut_pool.size()], rng.randf_range(0.012, 0.03)])
	picks.sort_custom(func(a, b): return a[0] < b[0])
	var box_xf: Array = []
	var foam_xf: Array = []
	var items := []
	var k := 0
	for p in range(3):
		var z0 := -total * 0.5 + p * (panel_w + gap) + cell * 0.5
		for c in range(cols):
			for r in range(rows):
				var z := z0 + c * cell
				var y := cy + (float(rows - 1) * 0.5 - r) * cell
				box_xf.append(Transform3D(Basis(), Vector3(x_face + 0.045, y, z)))
				foam_xf.append(Transform3D(Basis(), Vector3(x_face + 0.068, y, z)))
				var pk: Array = picks[k]
				k += 1
				var b := Basis(Vector3(0, 0, 1), -PI * 0.5) * Basis(Vector3.UP, rng.randf() * TAU)
				items.append([pk[1], pk[2], Transform3D(b.scaled(Vector3.ONE * float(pk[3])), Vector3(x_face + 0.073 + float(pk[3]) * 0.3, y, z))])
	root.add_child(_mm(MeshUtils.make_rounded_box(Vector3(0.05, boxw, boxw), 0.008, null).mesh, box_xf, mats["plastic"]))
	root.add_child(_mm(MeshUtils.make_rounded_box(Vector3(0.008, boxw * 0.8, boxw * 0.8), 0.002, null).mesh, foam_xf, mats["felt"]))
	root.add_child(GemFactory.make_set(items))
	for zz in [-1.6, 0.0, 1.6]:
		_spot(root, Vector3(1.8, 2.9, zz), Vector3(0, cy, zz), 5.0, 40.0)
	g._label("Gem case  -  120 stones in gem jars", base + Vector3(0.3, cy + rows * cell * 0.5 + 0.35, 0), 0.0024)

static func _mm(mesh: Mesh, xfs: Array, mat: Material) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xfs.size()
	for i in range(xfs.size()):
		mm.set_instance_transform(i, xfs[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = mat
	return mmi

# ── 2. rainbow sapphire line on white felt ──────────────────────────────────
static func _rainbow(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var top := _table(g, pos, Vector2(1.3, 1.0), mats["felt"])
	var line := [["orange_sapph", "pear"], ["orange_sapph", "oval"], ["yellow_sapph", "pear"], ["yellow_sapph", "pear"],
		["green_sapph", "pear"], ["green_sapph", "pear"], ["steel_sapph", "oval"], ["violet_sapph", "oval"], ["hot_pink_sapph", "oval"]]
	var items := []
	for i in range(line.size()):
		var t := float(i) / float(line.size() - 1)
		var p := Vector3(lerpf(-0.48, 0.48, t), top + 0.035, lerpf(0.34, -0.34, t))
		var b := Basis(Vector3.UP, -0.65).scaled(Vector3.ONE * 0.055)
		items.append([line[i][0], line[i][1], Transform3D(b, p)])
	var set := GemFactory.make_set(items)
	set.position = pos
	g.add_child(set)
	_spot(g, pos + Vector3(0.8, 2.6, -0.6), pos + Vector3(0, top, 0), 2.2)
	g._label("Rainbow sapphires on white felt", pos + Vector3(0, 1.45, -0.5), 0.0022)

# ── 3. loose parcel on black velvet with signet rings and coins ─────────────
const PARCEL_MIX := [["citrine", 6], ["lemon_quartz", 3], ["pale_amethyst", 6], ["rose_quartz", 3], ["white_topaz", 4],
	["smoky_quartz", 4], ["peridot", 4], ["carnelian", 3], ["green_onyx", 1], ["garnet", 3], ["morganite", 2],
	["blue_topaz", 2], ["amethyst", 2]]

static func _parcel_items(rng: RandomNumberGenerator, n: int, area: Vector2, y: float, smin: float, smax: float) -> Array:
	var bag := []
	for e in PARCEL_MIX:
		for i in range(int(e[1])):
			bag.append(e[0])
	var items := []
	var placed := []
	var tries := 0
	while items.size() < n and tries < n * 40:
		tries += 1
		var st: String = bag[rng.randi() % bag.size()]
		var cut: String = ["oval", "oval", "pear", "pear", "round", "emerald", "cushion", "marquise"][rng.randi() % 8]
		if st == "rose_quartz" and rng.randf() < 0.6:
			cut = "emerald"
		var s := rng.randf_range(smin, smax)
		var p := Vector2(rng.randfn() * area.x * 0.35, rng.randfn() * area.y * 0.35).clamp(-area * 0.5, area * 0.5)
		var ok := true
		for q in placed:
			if p.distance_to(q[0]) < (s + float(q[1])) * 0.95:
				ok = false
				break
		if not ok:
			continue
		placed.append([p, s])
		items.append([st, cut, Transform3D(_table_up(rng, s), Vector3(p.x, y + s * 0.62, p.y))])
	return items

static func _velvet_parcel(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var top := _table(g, pos, Vector2(1.5, 1.2), mats["velvet"])
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var root := Node3D.new()
	root.position = pos
	g.add_child(root)
	# gold dollar coins under the stones
	for i in range(6):
		var c := Node3D.new()
		var a := float(i) * 1.1
		c.position = Vector3(cos(a) * 0.26 + rng.randf_range(-0.05, 0.05), top + 0.008 + i * 0.002, sin(a) * 0.2)
		c.rotation = Vector3(rng.randf_range(-0.05, 0.05), rng.randf() * TAU, rng.randf_range(-0.05, 0.05))
		var face := MeshUtils.make_cylinder(0.13, 0.13, 0.012, mats["brass"], 64)
		c.add_child(face)
		var rim := MeshUtils.make_ring(0.118, 0.132, 0.016, mats["brass"], 64)
		c.add_child(rim)
		root.add_child(c)
	root.add_child(GemFactory.make_set(_parcel_items(rng, 46, Vector2(0.9, 0.7), top + 0.02, 0.022, 0.05)))
	_signet(root, Vector3(-0.42, top, -0.36), "sapphire", 0.4)
	_signet(root, Vector3(0.40, top, -0.38), "emerald", -0.3)
	_spot(g, pos + Vector3(-0.5, 2.7, -0.9), pos + Vector3(0, top, 0), 5.5)
	g._label("Loose parcel on black velvet, signet rings and coins", pos + Vector3(0, 1.5, -0.6), 0.0022)

static func _signet(root: Node3D, at: Vector3, stone: String, yaw: float) -> void:
	var mats := _mats()
	var ring := Node3D.new()
	var ri := 0.085
	var ro := 0.105
	var w := 0.05
	ring.position = at + Vector3(0, ro, 0)
	ring.rotation.y = yaw
	root.add_child(ring)
	var band := MeshUtils.make_revolved([Vector2(ri, -w), Vector2(ro, -w), Vector2(ro + 0.006, -w * 0.4),
		Vector2(ro + 0.006, w * 0.4), Vector2(ro, w), Vector2(ri, w), Vector2(ri, -w)], mats["steel"], 64)
	band.rotation.z = PI * 0.5          # ring axis along X, standing upright
	ring.add_child(band)
	# ribbed shoulders
	for sgn in [-1.0, 1.0]:
		for k in range(4):
			var rib := MeshUtils.make_rounded_box(Vector3(w * 2.05, 0.004, 0.035), 0.0, mats["black"])
			var ang: float = sgn * (0.55 + k * 0.12)
			rib.position = Vector3(0, cos(ang) * (ro + 0.004), sin(ang) * (ro + 0.004))
			rib.rotation.x = -ang
			ring.add_child(rib)
	# bezel table + the step-cut stone set flush
	_box(ring, Vector3(w * 2.2, 0.03, 0.15), Vector3(0, ro + 0.006, 0), mats["steel"])
	var set := GemFactory.make_set([[stone, "emerald", Transform3D(Basis(Vector3.UP, PI * 0.5).scaled(Vector3.ONE * 0.06), Vector3(0, ro + 0.02, 0))]])
	ring.add_child(set)

# ── 4. light-box parcel (stones over a glowing white panel) ────────────────
static func _lightbox_parcel(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var top := _table(g, pos, Vector2(1.5, 1.2), mats["lightbox"])
	var rng := RandomNumberGenerator.new()
	rng.seed = 314
	var set := GemFactory.make_set(_parcel_items(rng, 40, Vector2(1.1, 0.85), top, 0.025, 0.065))
	set.position = pos
	g.add_child(set)
	g._label("Light box parcel", pos + Vector3(0, 1.5, -0.6), 0.0022)

# ── 5. amethyst cathedrals on black metal stands ───────────────────────────
static func _cathedrals(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var sizes := [1.5, 1.15, 1.35, 0.95]
	for i in range(sizes.size()):
		var p := pos + Vector3(0, 0, float(i) * 1.6)
		var s: float = sizes[i]
		_box(g, Vector3(0.5, 0.05, 0.42), p + Vector3(0, 0.025, 0), mats["black"], true)
		_box(g, Vector3(0.06, s * 0.55, 0.06), p + Vector3(-0.12, s * 0.275 + 0.05, 0), mats["black"])
		var spec := MineralLibrary.make("amethyst_cathedral", s, 11 + i)
		spec.position = p + Vector3(0, 0.05 + s * 0.1, 0)
		spec.rotation.y = PI * 0.5
		g.add_child(spec)
		_spot(g, p + Vector3(2.0, 2.8, 0), p + Vector3(0, s * 0.5, 0), 4.0, 22.0)
	g._label("Amethyst cathedrals  -  Artigas, Uruguay", pos + Vector3(0.3, 2.0, 2.4), 0.0026)

# ── 6. Okorusu fluorite on clear acrylic blocks ─────────────────────────────
static func _fluorite_table(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var top := _table(g, pos, Vector2(1.8, 1.3), mats["wood"])
	var spots := [Vector3(-0.55, 0, -0.35), Vector3(0.0, 0, -0.38), Vector3(0.55, 0, -0.33),
		Vector3(-0.55, 0, 0.3), Vector3(0.0, 0, 0.32), Vector3(0.55, 0, 0.28)]
	for i in range(spots.size()):
		var bh := 0.08 + float(i % 3) * 0.04
		var bp: Vector3 = pos + spots[i] + Vector3(0, top + bh * 0.5, 0)
		_box(g, Vector3(0.36, bh, 0.3), bp, mats["acrylic"])
		var s := 0.32 + float(i % 2) * 0.1
		var spec := MineralLibrary.make("okorusu_fluorite", s, 40 + i)
		spec.position = bp + Vector3(0, bh * 0.5 + s * 0.06, 0)
		spec.rotation.y = float(i) * 1.3
		g.add_child(spec)
		var lb := Label3D.new()
		lb.text = "Fluorite\nOkorusu Mine, Namibia"
		lb.font_size = 22
		lb.pixel_size = 0.0011
		lb.modulate = Color(0.1, 0.1, 0.12)
		lb.outline_size = 0
		lb.position = bp + Vector3(0, 0, -0.152)
		lb.rotation.y = PI
		g.add_child(lb)
	_spot(g, pos + Vector3(-0.9, 2.8, -1.0), pos + Vector3(0, top, 0), 5.0, 34.0)
	g._label("Okorusu fluorite on acrylic blocks", pos + Vector3(0, 1.65, -0.7), 0.0022)

# ── 7. Mughal-style jewelled bowl: green enamel, gold, ~800 diamonds ───────
static func _jewel_band(items: Array, prof: Array, t0: float, t1: float, rows: int, spacing: float, size: float, cut: String, stone: String, phase: float) -> void:
	# stones along a revolved profile (Vector2 radius, y) between params t0..t1
	for r in range(rows):
		var t := lerpf(t0, t1, (float(r) + 0.5) / float(rows))
		var f := t * float(prof.size() - 1)
		var i := clampi(int(f), 0, prof.size() - 2)
		var a: Vector2 = prof[i]
		var b: Vector2 = prof[i + 1]
		var u := f - float(i)
		var pt := a.lerp(b, u)
		var tang := (b - a).normalized()
		var n2 := Vector2(tang.y, -tang.x)
		if n2.x < 0.0:
			n2 = -n2
		var count := maxi(6, int(TAU * pt.x / spacing))
		for k in range(count):
			var ang := (float(k) + phase * float(r % 2)) / float(count) * TAU
			var radial := Vector3(cos(ang), 0, sin(ang))
			var nrm := (radial * n2.x + Vector3.UP * n2.y).normalized()
			var up := (radial * tang.x + Vector3.UP * tang.y).normalized()
			var side := nrm.cross(up).normalized()
			var basis := Basis(up, nrm, -side)          # x = along profile, y = outward
			var p := Vector3(radial.x * pt.x, pt.y, radial.z * pt.x) + nrm * size * 0.02
			items.append([stone, cut, Transform3D(basis.scaled(Vector3.ONE * size), p)])

static func _mughal_bowl(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var top := _table(g, pos, Vector2(1.6, 1.6), mats["velvet"], 0.9)
	var root := Node3D.new()
	root.position = pos + Vector3(0, top, 0)
	g.add_child(root)
	var plate := [Vector2(0.0, 0.10), Vector2(0.55, 0.10), Vector2(0.60, 0.115), Vector2(0.61, 0.13), Vector2(0.56, 0.135), Vector2(0.0, 0.125)]
	var bowl := [Vector2(0.10, 0.13), Vector2(0.13, 0.17), Vector2(0.22, 0.21), Vector2(0.29, 0.29), Vector2(0.31, 0.37), Vector2(0.315, 0.40)]
	var lid := [Vector2(0.325, 0.40), Vector2(0.33, 0.425), Vector2(0.30, 0.47), Vector2(0.22, 0.53), Vector2(0.10, 0.565), Vector2(0.0, 0.575)]
	root.add_child(MeshUtils.make_revolved(plate, mats["enamel"], 96))
	root.add_child(MeshUtils.make_revolved(bowl + [Vector2(0.0, 0.40)], mats["enamel"], 96))
	root.add_child(MeshUtils.make_revolved(lid, mats["enamel"], 96))
	# gold bands and the red enamel rim of the lid
	for band in [[0.58, 0.125, 0.012], [0.32, 0.405, 0.012], [0.31, 0.385, 0.008], [0.13, 0.165, 0.008], [0.48, 0.135, 0.006]]:
		var ring := MeshUtils.make_ring(float(band[0]) - 0.012, float(band[0]) + 0.004, float(band[2]), mats["gold"], 96)
		ring.position.y = band[1]
		root.add_child(ring)
	var red := MeshUtils.make_ring(0.312, 0.33, 0.016, mats["red_enamel"], 96)
	red.position.y = 0.392
	root.add_child(red)
	# four gold feet
	for k in range(4):
		var a := float(k) / 4.0 * TAU + PI * 0.25
		_box(root, Vector3(0.05, 0.1, 0.05), Vector3(cos(a) * 0.5, 0.05, sin(a) * 0.5), mats["gold"])
	# finial: gold collet with a cushion ruby
	var collet := MeshUtils.make_cylinder(0.05, 0.035, 0.035, mats["gold"], 32)
	collet.position.y = 0.59
	root.add_child(collet)
	var items := []
	items.append(["ruby", "cushion", Transform3D(Basis().scaled(Vector3.ONE * 0.045), Vector3(0, 0.62, 0))])
	_jewel_band(items, plate, 0.12, 0.42, 5, 0.04, 0.014, "rose", "diamond", 0.5)
	_jewel_band(items, plate, 0.0, 0.08, 1, 0.032, 0.012, "pear", "diamond", 0.0)
	_jewel_band(items, bowl, 0.08, 0.92, 9, 0.036, 0.013, "rose", "diamond", 0.5)
	_jewel_band(items, bowl, 0.35, 0.65, 2, 0.05, 0.016, "pear", "diamond", 0.25)
	_jewel_band(items, lid, 0.12, 0.85, 8, 0.034, 0.012, "rose", "diamond", 0.5)
	_jewel_band(items, lid, 0.0, 0.1, 1, 0.03, 0.01, "pear", "diamond", 0.0)
	root.add_child(GemFactory.make_set(items))
	_spot(g, pos + Vector3(-1.0, 2.9, -1.2), pos + Vector3(0, top + 0.3, 0), 6.0, 24.0)
	_spot(g, pos + Vector3(1.2, 2.4, -0.6), pos + Vector3(0, top + 0.3, 0), 3.0, 24.0)
	g._label("Jewelled bowl  -  Mughal style, green enamel and diamonds", pos + Vector3(0, 1.95, -0.6), 0.0022)

# ── 8. diamond bib necklace on a black velvet bust ─────────────────────────
static func _necklace(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var top := _table(g, pos, Vector2(1.3, 1.1), mats["black"], 0.85)
	var bust := Node3D.new()
	bust.position = pos + Vector3(0, top, 0)
	g.add_child(bust)
	var torso_prof := [Vector2(0.0, 0.0), Vector2(0.30, 0.0), Vector2(0.34, 0.22), Vector2(0.31, 0.45),
		Vector2(0.18, 0.56), Vector2(0.10, 0.60), Vector2(0.095, 0.95), Vector2(0.0, 0.97)]
	var torso := MeshUtils.make_revolved(torso_prof, mats["velvet"], 64)
	torso.scale = Vector3(1.0, 1.0, 0.55)
	bust.add_child(torso)
	# chest surface: front of the elliptical torso
	var R := func(y: float) -> float:
		for i in range(torso_prof.size() - 1):
			var a: Vector2 = torso_prof[i]
			var b: Vector2 = torso_prof[i + 1]
			if y >= a.y and y <= b.y:
				return lerpf(a.x, b.x, (y - a.y) / maxf(b.y - a.y, 1e-4))
		return 0.1
	var items := []
	var place := func(x: float, y: float, cut: String, size: float, up := Vector3.UP) -> void:
		var r: float = R.call(y)
		var xx := clampf(x, -r * 0.97, r * 0.97)
		var z := -0.55 * sqrt(maxf(r * r - xx * xx, 0.0)) - 0.004
		var nrm := Vector3(xx / (r * r), 0.25, z / (0.55 * 0.55 * r * r)).normalized()
		var up2 := (up - nrm * up.dot(nrm)).normalized()
		var basis := Basis(up2, nrm, up2.cross(nrm))
		items.append(["diamond", cut, Transform3D(basis.scaled(Vector3.ONE * size), Vector3(xx, y, z))])
	# collar rows: U-shaped arcs hanging from the neck
	for k in range(5):
		var rk := 0.09 + k * 0.03
		var steps := 22 + k * 5
		for i in range(steps):
			var th := lerpf(-1.25, 1.25, float(i) / float(steps - 1))
			place.call(rk * 1.35 * sin(th), 0.60 - rk * cos(th) * 0.9, "round", 0.0085 - k * 0.0004)
	# scrolls either side
	for sgn in [-1.0, 1.0]:
		for i in range(26):
			var s := float(i) / 25.0
			place.call(sgn * (0.07 + 0.11 * s), 0.43 - 0.12 * s + 0.035 * sin(s * 7.0), "round", 0.0075)
		for i in range(14):
			var s := float(i) / 13.0
			place.call(sgn * (0.05 + 0.06 * s), 0.30 + 0.03 * sin(s * 5.0) - 0.05 * s, "round", 0.0065)
	# central pear in an oval frame of small rounds
	place.call(0.0, 0.37, "pear", 0.045, Vector3.DOWN)
	for i in range(30):
		var a := float(i) / 30.0 * TAU
		place.call(cos(a) * 0.06, 0.37 + sin(a) * 0.075, "round", 0.0065)
	# pear drops along the lower edge and a descending pendant
	for i in range(9):
		var th := lerpf(-1.1, 1.1, float(i) / 8.0)
		var rk := 0.21
		place.call(rk * 1.35 * sin(th), 0.60 - rk * cos(th) * 0.9 - 0.035, "pear", 0.016, Vector3.DOWN)
	for i in range(3):
		place.call(0.0, 0.27 - i * 0.05, "pear", 0.018 - i * 0.002, Vector3.DOWN)
		place.call(0.0, 0.295 - i * 0.05, "round", 0.006)
	bust.add_child(GemFactory.make_set(items))
	_spot(g, pos + Vector3(0.5, 2.8, -1.4), pos + Vector3(0, top + 0.45, 0), 6.0, 22.0)
	_spot(g, pos + Vector3(-0.9, 2.2, -1.0), pos + Vector3(0, top + 0.45, 0), 3.0, 22.0)
	g._label("Diamond bib necklace", pos + Vector3(0, 2.0, -0.4), 0.0022)

# ── 9. ornate two-tone emerald ring (oxidised silver + gold, emerald halo) ──
static func _emerald_ring(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var mirror := StandardMaterial3D.new()
	mirror.albedo_color = Color(0.0, 0.0, 0.0)
	mirror.roughness = 0.04
	mirror.metallic_specular = 0.8
	var top := _table(g, pos, Vector2(0.9, 0.9), mirror, 1.05)
	var oxsilver := StandardMaterial3D.new()
	oxsilver.albedo_color = Color(0.30, 0.30, 0.32)
	oxsilver.metallic = 1.0
	oxsilver.roughness = 0.35
	var eng := NoiseTexture2D.new()
	var fnz := FastNoiseLite.new()
	fnz.frequency = 0.06
	fnz.fractal_type = FastNoiseLite.FRACTAL_RIDGED
	eng.noise = fnz
	eng.as_normal_map = true
	eng.bump_strength = 6.0
	eng.seamless = true
	oxsilver.normal_enabled = true
	oxsilver.normal_texture = eng
	oxsilver.normal_scale = 1.2
	oxsilver.uv1_triplanar = true
	oxsilver.uv1_scale = Vector3(6, 6, 6)
	var gold: StandardMaterial3D = mats["gold"]
	var ring := Node3D.new()
	var ri := 0.10
	var ro := 0.135
	var w := 0.06
	ring.position = pos + Vector3(0, top + ro, 0)
	ring.rotation = Vector3(0.0, -0.5, 0.0)
	g.add_child(ring)
	var band := MeshUtils.make_revolved([Vector2(ri, -w), Vector2(ro, -w * 1.15), Vector2(ro + 0.012, -w * 0.5),
		Vector2(ro + 0.012, w * 0.5), Vector2(ro, w * 1.15), Vector2(ri, w), Vector2(ri, -w)], oxsilver, 72)
	band.rotation.z = PI * 0.5
	ring.add_child(band)
	# head: hexagonal gold frame around a big oval emerald, halo of small emeralds
	var head := Node3D.new()
	head.position = Vector3(0, ro + 0.03, 0)
	ring.add_child(head)
	var plate := MeshUtils.make_revolved([Vector2(0.0, -0.035), Vector2(0.15, -0.035), Vector2(0.15, 0.0), Vector2(0.0, 0.0)], oxsilver, 6)
	plate.scale = Vector3(1.0, 1.0, 0.82)
	plate.rotation.y = PI / 6.0
	head.add_child(plate)
	var frame := MeshUtils.make_revolved([Vector2(0.115, -0.005), Vector2(0.16, -0.005), Vector2(0.155, 0.025),
		Vector2(0.12, 0.03), Vector2(0.115, -0.005)], gold, 6)
	frame.scale = Vector3(1.0, 1.0, 0.82)
	frame.rotation.y = PI / 6.0
	head.add_child(frame)
	var items := []
	items.append(["emerald_cloudy", "oval", Transform3D(Basis(Vector3.UP, PI * 0.5).scaled(Vector3.ONE * 0.12), Vector3(0, 0.062, 0))])
	for k in range(26):
		var a := float(k) / 26.0 * TAU
		items.append(["emerald", "round", Transform3D(Basis().scaled(Vector3.ONE * 0.0085),
			Vector3(cos(a) * 0.135, 0.032, sin(a) * 0.135 * 0.82))])
	for k in range(4):
		var a := float(k) / 4.0 * TAU + PI * 0.25
		var claw := MeshUtils.make_rounded_box(Vector3(0.022, 0.05, 0.03), 0.004, gold)
		claw.position = Vector3(cos(a) * 0.118, 0.05, sin(a) * 0.118 * 0.82)
		claw.rotation.y = -a
		claw.rotation.z = 0.5
		head.add_child(claw)
	head.add_child(GemFactory.make_set(items))
	# side rosettes on both shoulders: gold disc, ring of tiny emeralds, centre stone, leaves
	for sgn in [-1.0, 1.0]:
		var ros := Node3D.new()
		ros.position = Vector3(sgn * (w + 0.018), ro * 0.55, 0.0)
		ros.rotation.z = sgn * -PI * 0.5
		ring.add_child(ros)
		ros.add_child(MeshUtils.make_cylinder(0.045, 0.045, 0.01, gold, 32))
		var sub := []
		for k in range(10):
			var a := float(k) / 10.0 * TAU
			sub.append(["emerald", "round", Transform3D(Basis().scaled(Vector3.ONE * 0.0075), Vector3(cos(a) * 0.033, 0.012, sin(a) * 0.033))])
		sub.append(["emerald", "round", Transform3D(Basis().scaled(Vector3.ONE * 0.012), Vector3(0, 0.016, 0))])
		ros.add_child(GemFactory.make_set(sub))
		for k in range(2):
			var leaf := MeshUtils.make_sphere(0.02, gold)
			leaf.scale = Vector3(0.6, 0.4, 1.4)
			leaf.position = Vector3(0, 0.005, (float(k) * 2.0 - 1.0) * 0.06)
			ros.add_child(leaf)
	_spot(g, pos + Vector3(-0.6, 2.4, -0.9), pos + Vector3(0, top + 0.15, 0), 5.0, 18.0)
	_spot(g, pos + Vector3(0.8, 2.0, -0.4), pos + Vector3(0, top + 0.15, 0), 2.5, 18.0)
	g._label("Emerald ring  -  oxidised silver and gold, emerald halo", pos + Vector3(0, 1.75, -0.3), 0.0019)

# ── 10. rock-shop bins: old tin loaf pans on a wooden counter, priced ───────
static func _pan(parent: Node3D, center: Vector3, size: Vector2, tin: Material) -> void:
	var h := 0.09
	var t := 0.006
	_box(parent, Vector3(size.x, t, size.y), center + Vector3(0, t * 0.5, 0), tin)
	for sgn in [-1.0, 1.0]:
		_box(parent, Vector3(size.x, h, t), center + Vector3(0, h * 0.5, sgn * size.y * 0.5), tin)
		_box(parent, Vector3(t, h, size.y), center + Vector3(sgn * size.x * 0.5, h * 0.5, 0), tin)

static func _price(g: Node3D, text: String, at: Vector3, yaw: float) -> void:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation = Vector3(0, yaw, 0)
	g.add_child(holder)
	var card := MeshUtils.make_rounded_box(Vector3(0.17, 0.11, 0.004), 0.0, _mats()["felt"])
	card.rotation.x = -0.35
	holder.add_child(card)
	var lb := Label3D.new()
	lb.text = text
	lb.font_size = 26
	lb.pixel_size = 0.0011
	lb.outline_size = 0
	lb.modulate = Color(0.05, 0.05, 0.05)
	lb.rotation.x = -0.35
	lb.position = Vector3(0, 0, 0.004)
	holder.add_child(lb)

static func _shop_bins(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var tin := StandardMaterial3D.new()
	tin.albedo_color = Color(0.36, 0.33, 0.30)
	tin.metallic = 0.7
	tin.roughness = 0.6
	var top := _table(g, pos, Vector2(1.4, 2.2), mats["dark_wood"], 0.9)
	var bins := [
		["selenite_sticks", "Selenite Sticks\nSmall $8  Medium $10\nLarge $15"],
		["selenite_tumbled", "Tumbled Selenite\n$5 Each"],
		["trilobite", "Paleozoic Trilobite\nFossil  $8 Each"],
		["lava", "Lava Rock\n$2 Each"],
		["amethyst", "Amethyst Clusters\n$5 Each"],
		["citrine", "Citrine Clusters\n$10 Each"],
		["rose", "Tumbled Rose Quartz\n$3 Each"],
		["amazonite", "Tumbled Amazonite\n$3 Each"],
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = 55
	for i in range(bins.size()):
		var col := i % 2
		var row := i / 2
		var c := pos + Vector3((float(col) - 0.5) * 0.62, top, (float(row) - 1.5) * 0.5)
		var area := Vector2(0.5, 0.36)
		_pan(g, c, area, tin)
		var kind: String = bins[i][0]
		var inside := c + Vector3(0, 0.006, 0)
		match kind:
			"selenite_sticks":
				for k in range(9):
					var stick := MeshUtils.make_rounded_box(Vector3(0.035, 0.32, 0.035), 0.006, ShopStones.material("selenite"))
					stick.position = inside + Vector3(-0.18 + k * 0.045, 0.02 + float(k % 3) * 0.02, rng.randf_range(-0.03, 0.03))
					stick.rotation = Vector3(PI * 0.5 + rng.randf_range(-0.06, 0.06), rng.randf_range(-0.12, 0.12), 0)
					g.add_child(stick)
			"selenite_tumbled":
				var hp := ShopStones.heap("selenite", area * 0.9, 34, Vector2(0.022, 0.032), 7, true)
				hp.position = inside
				g.add_child(hp)
			"trilobite":
				for k in range(9):
					var tb := MeshInstance3D.new()
					tb.mesh = ShopStones.trilobite_mesh()
					tb.material_override = ShopStones.material("trilobite")
					var s := rng.randf_range(0.04, 0.06)
					tb.scale = Vector3.ONE * s
					tb.position = inside + Vector3(rng.randf_range(-0.18, 0.18), s * 0.12 + float(k / 5) * 0.012, rng.randf_range(-0.12, 0.12))
					tb.rotation = Vector3(rng.randf_range(-0.2, 0.2), rng.randf() * TAU, rng.randf_range(-0.2, 0.2))
					g.add_child(tb)
			"lava":
				var hp2 := ShopStones.heap("lava", area * 0.55, 10, Vector2(0.03, 0.045), 9)
				hp2.position = inside
				g.add_child(hp2)
			"amethyst", "citrine":
				for k in range(9):
					var sid := "amethyst_cluster" if kind == "amethyst" else "citrine_cluster"
					var spec := MineralLibrary.make(sid, rng.randf_range(0.09, 0.13), 200 + k + (0 if kind == "amethyst" else 50))
					spec.position = inside + Vector3(-0.15 + float(k % 3) * 0.15, 0.01 + float(k / 3) * 0.015, -0.1 + float(k / 3) * 0.1)
					spec.rotation = Vector3(rng.randf_range(-0.3, 0.3), rng.randf() * TAU, rng.randf_range(-0.3, 0.3))
					g.add_child(spec)
			"rose", "amazonite":
				var hp3 := ShopStones.heap("rose_quartz" if kind == "rose" else "amazonite", area * 0.9, 40, Vector2(0.02, 0.03), 11 + i)
				hp3.position = inside
				g.add_child(hp3)
		var edge := -0.33 if col == 0 else 0.33
		_price(g, bins[i][1], c + Vector3(edge, 0.08, 0), -PI * 0.5 if col == 0 else PI * 0.5)
	_spot(g, pos + Vector3(-1.2, 2.8, 0), pos + Vector3(0, top, 0), 6.0, 40.0)
	g._label("Rock shop bins", pos + Vector3(0, 1.6, -1.2), 0.0024)

# ── 11. glass display case: malachite, lapis, aquamarine, onyx, apatite... ──
static func _glass_case(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var top := _table(g, pos, Vector2(1.2, 2.4), mats["dark_wood"], 0.95)
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.85, 0.95, 0.95, 0.08)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.02
	glass.metallic_specular = 1.0
	_box(g, Vector3(1.16, 0.004, 2.36), pos + Vector3(0, top + 0.45, 0), glass)
	for sgn in [-1.0, 1.0]:
		_box(g, Vector3(1.16, 0.45, 0.004), pos + Vector3(0, top + 0.225, sgn * 1.18), glass)
		_box(g, Vector3(0.004, 0.45, 2.36), pos + Vector3(sgn * 0.58, top + 0.225, 0), glass)
	var t := top + 0.004
	var acryl: StandardMaterial3D = mats["acrylic"]
	_box(g, Vector3(0.3, 0.004, 0.3), pos + Vector3(0, t, -0.85), acryl)
	for sgn in [-1.0, 1.0]:
		_box(g, Vector3(0.3, 0.09, 0.004), pos + Vector3(0, t + 0.045, -0.85 + sgn * 0.15), acryl)
		_box(g, Vector3(0.004, 0.09, 0.3), pos + Vector3(sgn * 0.15, t + 0.045, -0.85), acryl)
	var mal := ShopStones.heap("malachite", Vector2(0.27, 0.27), 16, Vector2(0.035, 0.05), 31)
	mal.position = pos + Vector3(0, t + 0.004, -0.85)
	g.add_child(mal)
	for d in [[Vector3(0.25, 0, -0.35), "lapis", false], [Vector3(-0.25, 0, -0.35), "aquamarine", true]]:
		var c: Vector3 = pos + d[0] + Vector3(0, t, 0)
		var dish := MeshUtils.make_ring(0.13, 0.135, 0.03, acryl, 48)
		dish.position = c + Vector3(0, 0.015, 0)
		g.add_child(dish)
		var sz := Vector2(0.014, 0.02) if d[2] else Vector2(0.016, 0.024)
		var hp := ShopStones.heap(d[1], Vector2(0.2, 0.2), 30, sz, 41, d[2])
		hp.position = c
		g.add_child(hp)
	for k in range(4):
		var c2 := pos + Vector3(-0.3 + k * 0.2, t, 0.15)
		_box(g, Vector3(0.14, 0.004, 0.2), c2 + Vector3(0, 0.002, 0), mats["black"])
		var wand := MeshInstance3D.new()
		wand.mesh = ShopStones.wand_mesh()
		wand.material_override = ShopStones.material("lapis")
		wand.scale = Vector3(0.11, 0.11, 0.11)
		wand.rotation = Vector3(0.0, 0.2 * k, PI * 0.5)
		wand.position = c2 + Vector3(0, 0.035, 0)
		g.add_child(wand)
	var ap := MeshInstance3D.new()
	ap.mesh = ShopStones.tumbled_mesh(2)
	ap.material_override = ShopStones.material("apatite")
	ap.scale = Vector3(0.11, 0.13, 0.08)
	ap.position = pos + Vector3(0.3, t + 0.09, 0.6)
	ap.rotation = Vector3(1.1, 0.4, 0)
	g.add_child(ap)
	for k in range(2):
		var die := MeshUtils.make_rounded_box(Vector3(0.05, 0.05, 0.05), 0.008, ShopStones.material("green_onyx"))
		die.position = pos + Vector3(-0.1 + k * 0.07, t + 0.025, 0.55)
		g.add_child(die)
		for pip in range(5):
			var pp := MeshUtils.make_sphere(0.005, mats["black"])
			pp.position = die.position + Vector3(-0.012 + float(pip % 3) * 0.012, 0.025, -0.012 + float(pip / 3) * 0.024)
			g.add_child(pp)
	var rq := MeshInstance3D.new()
	rq.mesh = ShopStones.sphere_mesh()
	rq.material_override = ShopStones.material("rose_quartz")
	rq.scale = Vector3.ONE * 0.06
	rq.position = pos + Vector3(-0.3, t + 0.075, 0.95)
	g.add_child(rq)
	var stand := MeshUtils.make_ring(0.025, 0.035, 0.015, mats["gold"], 32)
	stand.position = pos + Vector3(-0.3, t + 0.008, 0.95)
	g.add_child(stand)
	for k in range(3):
		var bi := ShopStones.bismuth(0.07 + k * 0.02)
		bi.position = pos + Vector3(0.1 + k * 0.13, t, 0.95 - k * 0.05)
		bi.rotation.y = k * 0.7
		g.add_child(bi)
	_spot(g, pos + Vector3(1.2, 2.8, 0), pos + Vector3(0, top, 0), 6.0, 42.0)
	g._label("Glass case  -  malachite, lapis, aquamarine, apatite, onyx, bismuth", pos + Vector3(0, 1.7, -1.3), 0.0022)

# ── 12. spiderweb turquoise freeform on a velvet pedestal (pick it up: E) ──
static func _turquoise(g: Node3D, pos: Vector3) -> void:
	var mats := _mats()
	var top := _table(g, pos, Vector2(0.55, 0.55), mats["velvet"], 1.05)
	var pc := ShopStones.piece("turquoise_web", 0.07)
	pc.position = pos + Vector3(0, top + 0.012, 0)
	pc.rotation = Vector3(0.0, 0.6, 0.0)
	g.add_child(pc)
	if g.has_method("add_inspect_spot"):
		g.add_inspect_spot(pc.position + Vector3(0, 0.02, 0), "shop:turquoise_web", "Freeform cabochon", pc)
	_spot(g, pos + Vector3(-0.5, 2.2, -0.7), pos + Vector3(0, top, 0), 4.0, 16.0)
	g._label("Spiderweb turquoise  -  press E to pick it up", pos + Vector3(0, 1.55, 0), 0.0019)
