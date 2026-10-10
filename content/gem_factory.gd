class_name GemFactory

# ═══════════════════════════════════════════════════════════════════════════
# GEM FACTORY — procedural cut gemstones and natural-looking gem piles.
#
# CUTS (true faceted geometry, flat-shaded, cached once per cut):
#   round brilliant · oval · cushion · princess · pear · marquise · trillion
#   (all brilliant-style: table, star, bezel, upper-girdle, girdle band,
#    lower-girdle and pavilion-main facets) · emerald step cut · baguette ·
#   cabochon (smooth dome, for opal / turquoise / lapis)
#
# LOOK: every faceted gem is RAY-TRACED inside its own facets (GemCuts planes):
#   the view ray refracts in at the facet (real IOR), bounces around the
#   pavilion with real total internal reflection and Fresnel splitting, picks
#   up Beer-Lambert absorption along its path (thick paths go deep and
#   saturated, thin ones pale - real body colour), and exits into a jeweller's
#   studio lighting environment. R, G and B are traced with separate indices
#   (the stone's real dispersion) => true coloured FIRE. A light() pass adds
#   razor glints from the scene's real lights. One material per cut; colour,
#   IOR, dispersion and absorption are per instance (one draw call per cut).
#
# API
#   GemFactory.make_pile(seed, radius := 0.9, count := 220, opts := {}) -> Node3D
#       opts: "height" (mound height, default radius*0.55), "spill" (loose gems
#       scattered around, default count/8), "size" (Vector2 min/max girdle
#       radius in m, default 0.05..0.13), "bowl" (bool: sit the heap in a gilt
#       offering bowl). Base at y = 0.
#   GemFactory.make_gem(kind_name, cut, size) -> MeshInstance3D-like node (one gem)
#   GemFactory.STONES — the stone table (colour, IOR, dispersion, cut weights)
# ═══════════════════════════════════════════════════════════════════════════

const CUTS := ["round", "oval", "cushion", "princess", "radiant", "pear", "marquise", "heart", "trillion",
	"emerald", "asscher", "baguette", "old_european", "old_mine", "rose", "briolette", "cabochon"]

# Real optics: [transmission colour per unit path, refractive index,
#  dispersion (n_G - n_B, real value), absorption density].
const OPTICS := {
	"diamond":      [Color(1.00, 1.00, 1.00), 2.417, 0.044, 0.00],
	"ruby":         [Color(0.96, 0.10, 0.26), 1.770, 0.018, 0.75],
	"sapphire":     [Color(0.16, 0.32, 0.98), 1.770, 0.018, 0.80],
	"pink_sapph":   [Color(1.00, 0.42, 0.70), 1.770, 0.018, 0.45],
	"yellow_sapph": [Color(1.00, 0.80, 0.12), 1.770, 0.018, 0.75],
	"emerald":      [Color(0.10, 0.86, 0.42), 1.580, 0.014, 0.70],
	"amethyst":     [Color(0.70, 0.30, 0.98), 1.550, 0.013, 0.55],
	"citrine":      [Color(1.00, 0.70, 0.18), 1.550, 0.013, 0.45],
	"aquamarine":   [Color(0.62, 0.90, 1.00), 1.580, 0.014, 0.30],
	"blue_topaz":   [Color(0.36, 0.76, 1.00), 1.620, 0.014, 0.45],
	"peridot":      [Color(0.70, 0.95, 0.12), 1.670, 0.020, 0.45],
	"garnet":       [Color(0.85, 0.08, 0.12), 1.790, 0.024, 0.95],
	"tanzanite":    [Color(0.46, 0.36, 1.00), 1.690, 0.030, 0.65],
	"morganite":    [Color(1.00, 0.76, 0.74), 1.590, 0.014, 0.25],
	"tourmaline":   [Color(0.16, 0.82, 0.56), 1.630, 0.017, 0.60],
	"smoky_quartz": [Color(0.72, 0.58, 0.44), 1.544, 0.013, 0.70],
	"lemon_quartz": [Color(0.96, 0.92, 0.42), 1.544, 0.013, 0.40],
	"white_topaz":  [Color(1.00, 1.00, 1.00), 1.620, 0.014, 0.00],
	"pale_amethyst":[Color(0.86, 0.70, 0.96), 1.544, 0.013, 0.35],
	"rose_quartz":  [Color(1.00, 0.80, 0.84), 1.544, 0.013, 10.35],
	"carnelian":    [Color(1.00, 0.38, 0.10), 1.540, 0.000, 10.70],
	"green_onyx":   [Color(0.05, 0.62, 0.38), 1.540, 0.000, 10.85],
	"orange_sapph": [Color(1.00, 0.42, 0.06), 1.770, 0.018, 0.95],
	"green_sapph":  [Color(0.50, 0.82, 0.36), 1.770, 0.018, 0.80],
	"violet_sapph": [Color(0.74, 0.48, 0.86), 1.770, 0.018, 0.80],
	"steel_sapph":  [Color(0.44, 0.48, 0.62), 1.770, 0.018, 0.95],
	"hot_pink_sapph":[Color(1.00, 0.16, 0.50), 1.770, 0.018, 0.95],
	"iolite":       [Color(0.48, 0.48, 0.90), 1.540, 0.017, 0.60],
	"zircon_blue":  [Color(0.40, 0.86, 1.00), 1.950, 0.039, 0.40],
	"emerald_cloudy":[Color(0.05, 0.62, 0.36), 1.580, 0.014, 1.60],
}

## Batched set of individually placed gems: items = [[stone, cut, Transform3D], ...]
## (transform includes the gem's size as uniform scale). One draw call per cut.
static func make_set(items: Array) -> Node3D:
	var by_cut := {}
	for it in items:
		var stone: String = it[0]
		var cut: String = it[1]
		var xf: Transform3D = it[2]
		var row: Array
		if cut == "cabochon":
			var st: Array = stone_of(stone, "opal")
			row = [xf, st[0], Color(randf(), st[2], float(st[5]), st[1])]
		else:
			var opt: Array = optics_of(stone)
			row = [xf, opt[0], Color(randf(), opt[2], opt[3], opt[1])]
		if not by_cut.has(cut):
			by_cut[cut] = []
		by_cut[cut].append(row)
	var n := Node3D.new()
	for cut in by_cut:
		n.add_child(_multimesh_for(cut, by_cut[cut]))
	return n

# name: [body colour, IOR, dispersion strength (fire), cut list, weight, kind]
# kind 0 = faceted transparent, 1 = opal (play of colour), 2 = opaque (turquoise/lapis)
const STONES := {
	"diamond":      [Color(0.97, 0.98, 1.00), 2.42, 1.00, ["round", "round", "round", "princess", "cushion", "radiant", "pear", "marquise", "oval", "emerald", "asscher", "heart", "old_european", "old_mine", "rose", "briolette"], 1.4, 0],
	"ruby":         [Color(0.78, 0.03, 0.12), 1.77, 0.30, ["oval", "cushion", "round", "pear", "oval", "heart", "radiant"], 1.2, 0],
	"sapphire":     [Color(0.06, 0.18, 0.80), 1.77, 0.30, ["oval", "cushion", "round", "emerald", "pear", "radiant", "asscher"], 1.2, 0],
	"pink_sapph":   [Color(0.98, 0.38, 0.62), 1.77, 0.30, ["oval", "round", "cushion"], 0.5, 0],
	"yellow_sapph": [Color(1.00, 0.78, 0.10), 1.77, 0.30, ["cushion", "oval", "round"], 0.5, 0],
	"emerald":      [Color(0.02, 0.58, 0.28), 1.58, 0.18, ["emerald", "emerald", "emerald", "asscher", "baguette", "oval", "pear"], 1.2, 0],
	"amethyst":     [Color(0.56, 0.16, 0.82), 1.55, 0.20, ["oval", "cushion", "trillion", "pear", "round", "briolette", "heart"], 1.0, 0],
	"citrine":      [Color(1.00, 0.58, 0.06), 1.55, 0.20, ["cushion", "oval", "trillion", "round", "briolette"], 0.8, 0],
	"aquamarine":   [Color(0.48, 0.82, 0.96), 1.58, 0.18, ["emerald", "oval", "pear", "baguette", "asscher"], 0.8, 0],
	"blue_topaz":   [Color(0.24, 0.62, 1.00), 1.62, 0.22, ["oval", "pear", "trillion", "cushion", "princess", "radiant", "briolette"], 0.8, 0],
	"peridot":      [Color(0.58, 0.82, 0.06), 1.67, 0.25, ["oval", "round", "marquise"], 0.6, 0],
	"garnet":       [Color(0.48, 0.02, 0.06), 1.79, 0.28, ["round", "oval", "cushion", "rose", "old_mine"], 0.6, 0],
	"tanzanite":    [Color(0.32, 0.24, 0.86), 1.69, 0.25, ["trillion", "oval", "cushion", "pear"], 0.6, 0],
	"morganite":    [Color(1.00, 0.70, 0.66), 1.59, 0.18, ["oval", "cushion", "pear", "heart", "rose"], 0.5, 0],
	"tourmaline":   [Color(0.12, 0.62, 0.48), 1.63, 0.22, ["baguette", "emerald", "trillion"], 0.5, 0],
	"opal":         [Color(0.86, 0.90, 0.95), 1.45, 0.00, ["cabochon"], 0.6, 1],
	"turquoise":    [Color(0.20, 0.74, 0.70), 1.61, 0.00, ["cabochon"], 0.4, 2],
	"lapis":        [Color(0.08, 0.16, 0.62), 1.50, 0.00, ["cabochon"], 0.4, 2],
}

static var _mesh_cache := {}
## Extra named stones registered at runtime (e.g. FamousGems).
static var extra_optics := {}
static var extra_stones := {}

static func optics_of(key: String) -> Array:
	if extra_optics.has(key):
		return extra_optics[key]
	return OPTICS.get(key, OPTICS["diamond"])

static func stone_of(key: String, fallback: String) -> Array:
	if extra_stones.has(key):
		return extra_stones[key]
	return STONES.get(key, STONES[fallback])
static var _faceted_mat: ShaderMaterial
static var _cabochon_mat: ShaderMaterial
static var _bowl_mat: StandardMaterial3D

# ═══════════════════════════════════════════════════════════════════════════
# PUBLIC
# ═══════════════════════════════════════════════════════════════════════════

static func make_pile(seed_: int, radius: float = 0.9, count: int = 220, opts: Dictionary = {}) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var root := Node3D.new()
	root.name = "GemPile"
	var height: float = opts.get("height", radius * 0.55)
	var spill: int = opts.get("spill", count / 8)
	var size_rng: Vector2 = opts.get("size", Vector2(0.045, 0.11))
	var in_bowl: bool = opts.get("bowl", false)

	var base_y := 0.0
	if in_bowl:
		base_y = _add_bowl(root, radius)

	# Height field the gems settle onto — later gems rest on earlier ones.
	var cell := 0.035
	var n := int(ceil((radius * 2.6) / cell))
	var hf := PackedFloat32Array()
	hf.resize(n * n)
	hf.fill(base_y)
	var half := float(n) * cell * 0.5

	var placements := {}   # cut -> Array of [Transform3D, Color, Color(custom)]
	var stone_names := STONES.keys()
	var weights: Array[float] = []
	var total_w := 0.0
	for s in stone_names:
		weights.append(STONES[s][4])
		total_w += STONES[s][4]

	for i in range(count + spill):
		var loose := i >= count
		var sname: String = _pick_weighted(rng, stone_names, weights, total_w)
		var st: Array = STONES[sname]
		var cuts: Array = st[3]
		var cut: String = cuts[rng.randi() % cuts.size()]
		var size := rng.randf_range(size_rng.x, size_rng.y)
		if rng.randf() < 0.08:
			size *= 1.45                       # the odd showpiece stone
		if cut == "cabochon":
			size *= 0.68                       # domes read much bigger than facets
		# position: a gaussian-ish mound for the heap, a ring for the spill
		var p: Vector2
		if loose:
			var a := rng.randf() * TAU
			var d := radius * rng.randf_range(0.85, 1.3)
			p = Vector2(cos(a), sin(a)) * d
		else:
			var a := rng.randf() * TAU
			var d := radius * sqrt(rng.randf()) * (0.35 + 0.65 * rng.randf())
			p = Vector2(cos(a), sin(a)) * d
		if in_bowl and not loose:
			p = p.limit_length(radius * 0.8)
		# resting height = highest heap point under the gem's footprint
		var gx := int((p.x + half) / cell)
		var gz := int((p.y + half) / cell)
		var fr := maxi(1, int(size * 0.8 / cell))
		var ground := base_y if not loose else 0.0
		if not loose:
			for zz in range(gz - fr, gz + fr + 1):
				for xx in range(gx - fr, gx + fr + 1):
					if xx >= 0 and zz >= 0 and xx < n and zz < n:
						ground = maxf(ground, hf[zz * n + xx])
		# keep the heap a mound: cap growth by the mound profile at this radius
		var r01 := clampf(p.length() / radius, 0.0, 1.0)
		var cap := base_y + height * pow(1.0 - r01 * r01, 1.4) + size * 0.4
		if not loose and ground > cap:
			ground = cap
		# orientation: mostly lying table-up with a tumble, some on edge/upside
		var basis := Basis(Vector3.UP, rng.randf() * TAU)
		var tilt := rng.randf_range(0.0, 0.55)
		var roll := rng.randf()
		if roll < 0.18:
			tilt = rng.randf_range(1.1, 1.6)       # on its side
		elif roll < 0.26:
			tilt = PI - rng.randf_range(0.0, 0.5)  # culet up
		basis = basis * Basis(Vector3(1, 0, 0).rotated(Vector3.UP, rng.randf() * TAU), tilt)
		var sink := 0.35 if cut != "cabochon" else 0.2
		var y := ground + size * (0.55 - sink * 0.5)
		var xf := Transform3D(basis.scaled(Vector3.ONE * size), Vector3(p.x, y, p.y))
		if not loose:
			var top := y + size * 0.42
			for zz in range(gz - fr, gz + fr + 1):
				for xx in range(gx - fr, gx + fr + 1):
					if xx >= 0 and zz >= 0 and xx < n and zz < n:
						var falloff := 1.0 - Vector2(xx - gx, zz - gz).length() / float(fr + 1)
						hf[zz * n + xx] = maxf(hf[zz * n + xx], lerpf(y, top, falloff))
		# per-instance appearance: slight colour variation inside each species
		var body: Color
		var custom: Color
		if cut == "cabochon":
			body = st[0]
			custom = Color(rng.randf(), st[2], float(st[5]), st[1])  # seed, -, kind, -
		else:
			var opt: Array = optics_of(sname)
			body = opt[0]
			# natural variation in saturation within a species
			var dens: float = opt[3] * rng.randf_range(0.75, 1.3) if opt[3] < 9.0 else opt[3]
			custom = Color(rng.randf(), opt[2], dens, opt[1])          # seed, dispersion, density, IOR
		if not placements.has(cut):
			placements[cut] = []
		placements[cut].append([xf, body, custom])

	for cut in placements.keys():
		root.add_child(_multimesh_for(cut, placements[cut]))
	return root

static func make_gem(stone: String, cut: String, size: float) -> Node3D:
	var st: Array = stone_of(stone, "diamond")
	var lift := 0.62 if cut == "briolette" else (0.12 if cut == "cabochon" else 0.86)
	var xf := Transform3D(Basis().scaled(Vector3.ONE * size), Vector3(0, size * lift, 0))
	var item: Array
	if cut == "cabochon":
		item = [xf, st[0], Color(0.5, st[2], float(st[5]), st[1])]
	else:
		var opt: Array = optics_of(stone)
		item = [xf, opt[0], Color(0.5, opt[2], opt[3], opt[1])]
	var mmi := _multimesh_for(cut, [item])
	var n := Node3D.new()
	n.add_child(mmi)
	return n

# ═══════════════════════════════════════════════════════════════════════════
# BATCHING
# ═══════════════════════════════════════════════════════════════════════════

static func _multimesh_for(cut: String, items: Array) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = get_cut_mesh(cut)
	mm.instance_count = items.size()
	for i in range(items.size()):
		mm.set_instance_transform(i, items[i][0])
		mm.set_instance_color(i, items[i][1])
		mm.set_instance_custom_data(i, items[i][2])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = _cabochon_material() if cut == "cabochon" else faceted_material(cut)
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return mmi

static func _pick_weighted(rng: RandomNumberGenerator, names: Array, w: Array[float], total: float) -> String:
	var r := rng.randf() * total
	for i in range(names.size()):
		r -= w[i]
		if r <= 0.0:
			return names[i]
	return names[names.size() - 1]

# ═══════════════════════════════════════════════════════════════════════════
# CUT GEOMETRY — unit gems: girdle "radius" ~1 on X, crown +Y, pavilion -Y.
# ═══════════════════════════════════════════════════════════════════════════

static func get_cut_mesh(cut: String) -> ArrayMesh:
	if cut == "cabochon":
		if not _mesh_cache.has(cut):
			_mesh_cache[cut] = _cabochon(1.0, 0.75, 0.55)
		return _mesh_cache[cut]
	return GemCuts.mesh(cut)

static func _cabochon(w: float, d: float, h: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 40
	var rings := 12
	var base_y := -0.12
	var pts := []
	var nrm := []
	for r in range(rings + 1):
		var ph := float(r) / float(rings) * PI * 0.5
		var row := []
		var nrow := []
		for s in range(seg + 1):
			var a := float(s) / float(seg) * TAU
			var x := cos(a) * cos(ph) * w
			var z := sin(a) * cos(ph) * d
			var y := sin(ph) * h + base_y
			row.append(Vector3(x, y, z))
			nrow.append(Vector3(x / (w * w), (y - base_y) / (h * h), z / (d * d)).normalized())
		pts.append(row)
		nrm.append(nrow)
	for r in range(rings):
		for s in range(seg):
			var q := [[r, s], [r + 1, s], [r + 1, s + 1], [r, s + 1]]
			for tri in [[0, 2, 1], [0, 3, 2]]:
				for k in tri:
					var rr: int = q[k][0]
					var ss: int = q[k][1]
					st.set_normal(nrm[rr][ss])
					st.add_vertex(pts[rr][ss])
	# flat base
	for s in range(seg):
		var a0: Vector3 = pts[0][s]
		var a1: Vector3 = pts[0][s + 1]
		_tri(st, Vector3(0, base_y, 0), a0, a1, Vector3(0, 0.2, 0))
	var m := ArrayMesh.new()
	st.commit(m)
	return m

# One flat-shaded facet, oriented outward from `center` (convex solids).
# Godot treats CLOCKWISE (seen from outside) as front-facing, so the vertices
# are emitted with (b-a)x(c-a) pointing INWARD while the stored normal points out.
static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, center: Vector3) -> void:
	var n := (b - a).cross(c - a)
	if n.length_squared() < 1e-12:
		return
	if n.dot((a + b + c) / 3.0 - center) < 0.0:
		var tmp := b
		b = c
		c = tmp
		n = -n
	n = n.normalized()
	st.set_normal(n); st.add_vertex(a)
	st.set_normal(n); st.add_vertex(c)
	st.set_normal(n); st.add_vertex(b)

# ═══════════════════════════════════════════════════════════════════════════
# BOWL — a shallow gilt phiale (Greek offering bowl) to heap gems in
# ═══════════════════════════════════════════════════════════════════════════

static func _add_bowl(root: Node3D, radius: float) -> float:
	if _bowl_mat == null:
		_bowl_mat = StandardMaterial3D.new()
		_bowl_mat.albedo_color = Color(0.86, 0.66, 0.30)
		_bowl_mat.metallic = 1.0
		_bowl_mat.roughness = 0.28
	var r := radius * 1.05
	var bowl := MeshUtils.make_revolved([
		Vector2(0.0, 0.0), Vector2(r * 0.35, 0.0), Vector2(r * 0.42, 0.06),          # foot
		Vector2(r * 0.40, 0.12), Vector2(r * 0.8, 0.20), Vector2(r * 1.0, 0.34),      # outer wall
		Vector2(r * 1.04, 0.37), Vector2(r * 0.98, 0.38),                            # lip
		Vector2(r * 0.78, 0.25), Vector2(r * 0.38, 0.17), Vector2(0.0, 0.16),         # inner dish
	], _bowl_mat, 64)
	root.add_child(bowl)
	return 0.16

# ═══════════════════════════════════════════════════════════════════════════
# MATERIALS
# ═══════════════════════════════════════════════════════════════════════════

static var _faceted_shader: Shader
static var _faceted_mats := {}
static var _env := {"mode": 0.0, "energy": 1.0, "sun_dir": Vector3(0.35, 0.8, -0.45).normalized()}

## Lighting the gems see inside: mode 0 = jeweller's studio (black room, soft
## box overhead, strip lights, pin-point lamps for fire), 1 = open sky (temples).
static func set_environment(mode: float, energy: float = 1.0, sun_dir: Vector3 = Vector3.ZERO) -> void:
	_env["mode"] = mode
	_env["energy"] = energy
	if sun_dir != Vector3.ZERO:
		_env["sun_dir"] = sun_dir.normalized()
	for m in _faceted_mats.values():
		_apply_env(m)

static func _apply_env(m: ShaderMaterial) -> void:
	m.set_shader_parameter("env_mode", _env["mode"])
	m.set_shader_parameter("env_energy", _env["energy"])
	m.set_shader_parameter("sun_dir", _env["sun_dir"])

static func faceted_material(cut: String) -> ShaderMaterial:
	if _faceted_mats.has(cut):
		return _faceted_mats[cut]
	if _faceted_shader == null:
		_faceted_shader = Shader.new()
		_faceted_shader.code = FACETED_SHADER
	var m := ShaderMaterial.new()
	m.shader = _faceted_shader
	var pl: Array = GemCuts.planes(cut)
	var arr := PackedVector4Array()
	for p in pl:
		arr.append(p)
	while arr.size() < 128:
		arr.append(Vector4(0, 1, 0, 1000.0))
	m.set_shader_parameter("planes", arr)
	m.set_shader_parameter("plane_count", mini(pl.size(), 128))
	_apply_env(m)
	_faceted_mats[cut] = m
	return m

const FACETED_SHADER := """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 planes[128];
uniform int plane_count = 0;
uniform float env_mode = 0.0;        // 0 studio, 1 sky
uniform float env_energy = 1.0;
uniform vec3 sun_dir = vec3(0.35, 0.8, -0.45);
uniform float fire_boost = 1.4;      // dispersion visibility (1 = physical)
uniform float sat_boost = 1.25;      // OLED colour push

varying vec3 v_opos;
varying vec3 v_ocam;
varying vec4 v_col;
varying vec4 v_cust;   // x seed, y dispersion, z density, w IOR
varying vec3 v_onrm;

void vertex() {
	v_opos = VERTEX;
	v_onrm = NORMAL;
	v_ocam = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	v_col = COLOR;
	v_cust = INSTANCE_CUSTOM;
}

// the light the stone sees
vec3 env(vec3 e, vec3 eye) {
	e = normalize(e);
	float el = e.y;
	float az = atan(e.z, e.x);
	// STUDIO: near-black room, soft box overhead, ring of strip lights,
	// pin-point halogen lamps (these make the fire)
	// soft light-tent walls (colour stones need light from all around),
	// a brighter horizon band, black velvet below
	vec3 st = vec3(0.30, 0.29, 0.28) * smoothstep(-0.15, 0.25, el);
	st += vec3(0.55, 0.55, 0.56) * smoothstep(0.05, 0.25, el) * smoothstep(0.55, 0.30, el);
	st += vec3(0.008) * (1.0 - smoothstep(-0.15, 0.25, el));
	st += vec3(1.0, 0.97, 0.93) * smoothstep(0.62, 0.80, el) * 2.6;
	float strips = smoothstep(0.86, 0.985, cos(5.0 * az + 0.4)) * smoothstep(0.10, 0.28, el) * smoothstep(0.62, 0.42, el);
	st += vec3(0.92, 0.96, 1.0) * strips * 3.2;
	vec3 lamps[5] = vec3[](vec3(0.55, 0.62, 0.55), vec3(-0.62, 0.55, 0.35), vec3(0.15, 0.70, -0.70),
		vec3(-0.30, 0.82, -0.48), vec3(0.75, 0.40, -0.25));
	for (int i = 0; i < 5; i++) {
		st += vec3(1.0, 0.96, 0.9) * pow(max(dot(e, normalize(lamps[i])), 0.0), 1400.0) * 90.0;
	}
	st += vec3(0.02, 0.018, 0.016) * smoothstep(0.05, -0.4, el);
	// SKY: open-air temples
	vec3 sk = mix(vec3(0.55, 0.62, 0.70), vec3(0.20, 0.38, 0.75), smoothstep(0.0, 0.7, el)) * 1.2;
	sk = mix(sk, vec3(0.20, 0.16, 0.12) * 0.6, smoothstep(0.02, -0.25, el));
	sk += vec3(1.0, 0.92, 0.75) * pow(max(dot(e, normalize(sun_dir)), 0.0), 1800.0) * 120.0;
	sk += vec3(1.0, 0.85, 0.6) * pow(max(dot(e, normalize(sun_dir)), 0.0), 12.0) * 0.6;
	vec3 c = mix(st, sk, env_mode);
	// the viewer's own head and body block the light behind them: the dark
	// reflection that gives real stones their contrast pattern
	float head = smoothstep(0.80, 0.95, dot(e, eye));
	return c * (1.0 - 0.92 * head);
}

float fresnel(float cosi, float n1, float n2) {
	float r0 = (n1 - n2) / (n1 + n2);
	r0 *= r0;
	return r0 + (1.0 - r0) * pow(1.0 - clamp(cosi, 0.0, 1.0), 5.0);
}

// Trace one wavelength through the stone; returns radiance in channel ch.
float trace_ch(vec3 p, vec3 d, float ior, float sig, int ch, mat3 to_world, vec3 eye) {
	float acc = 0.0;
	float w = 1.0;
	for (int b = 0; b < 7; b++) {
		float tmin = 1e9;
		vec3 ne = vec3(0.0, 1.0, 0.0);
		for (int i = 0; i < plane_count; i++) {
			vec4 pl = planes[i];
			float dn = dot(pl.xyz, d);
			if (dn > 1e-5) {
				float t = (pl.w - dot(pl.xyz, p)) / dn;
				if (t < tmin) { tmin = t; ne = pl.xyz; }
			}
		}
		tmin = clamp(tmin, 0.0, 6.0);
		p += d * tmin;
		w *= exp(-sig * tmin);
		float cosi = dot(d, ne);
		vec3 ex = refract(d, -ne, ior);
		if (dot(ex, ex) < 1e-6) {
			d = reflect(d, -ne);          // total internal reflection
			continue;
		}
		float R = fresnel(cosi, ior, 1.0);
		acc += w * (1.0 - R) * env(to_world * ex, eye)[ch];
		w *= R;
		if (w < 0.01) break;
		d = reflect(d, -ne);
	}
	return acc;
}

void fragment() {
	mat3 m3 = mat3(MODEL_MATRIX);
	float sc = length(m3[0]);
	mat3 to_world = m3 / sc;
	vec3 n = normalize(v_onrm);
	vec3 vi = normalize(v_opos - v_ocam);
	float ior = max(v_cust.w, 1.3);
	float disp = v_cust.y * fire_boost;
	vec3 tcol = clamp(v_col.rgb, vec3(0.002), vec3(1.0));
	float milk = v_cust.z > 9.5 ? clamp(v_cust.z - 10.0, 0.0, 1.0) : 0.0;
	vec3 sig = -log(tcol) * (milk > 0.0 ? 2.6 : v_cust.z);
	float cosv = max(dot(-vi, n), 0.0);
	float Rs = fresnel(cosv, 1.0, ior);
	vec3 eye = normalize(CAMERA_POSITION_WORLD - (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz);
	vec3 refl = env(to_world * reflect(vi, n), eye);
	vec3 inside;
	vec3 p0 = v_opos - n * 1e-4;
	float ir = ior - disp * 0.5;
	float ib = ior + disp * 0.5;
	inside.r = trace_ch(p0, refract(vi, n, 1.0 / ir), ir, sig.r, 0, to_world, eye);
	inside.g = trace_ch(p0, refract(vi, n, 1.0 / ior), ior, sig.g, 1, to_world, eye);
	inside.b = trace_ch(p0, refract(vi, n, 1.0 / ib), ib, sig.b, 2, to_world, eye);
	vec3 col = Rs * refl + (1.0 - Rs) * inside;
	// translucent stones (carnelian, onyx, rose quartz): light scatters inside,
	// so the body glows with its own colour instead of showing facet patterns
	vec3 glow = tcol * tcol * (0.05 + 0.6 * inside + 0.10 * max(n.y, 0.0));
	col = mix(col, Rs * refl + glow, milk);
	float lum = dot(col, vec3(0.2126, 0.7152, 0.0722));
	col = max(vec3(0.0), mix(vec3(lum), col, sat_boost));
	ALBEDO = tcol * milk * 0.75;
	EMISSION = col * env_energy;
	ROUGHNESS = 0.02;
	METALLIC = 0.0;
	SPECULAR = 0.0;
}

void light() {
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * max(dot(NORMAL, LIGHT), 0.0) / PI;
	vec3 h = normalize(VIEW + LIGHT);
	float nh = max(dot(NORMAL, h), 0.0);
	float ndl = max(dot(NORMAL, LIGHT), 0.0);
	float g = pow(nh, 2400.0) * 60.0 + pow(nh, 300.0) * 1.5;
	SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * ndl * g * 0.1;
}
"""

static func _cabochon_material() -> ShaderMaterial:
	if _cabochon_mat:
		return _cabochon_mat
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

varying vec4 v_col;
varying vec4 v_cust;
varying vec3 v_obj;

void vertex() {
	v_col = COLOR;
	v_cust = INSTANCE_CUSTOM;
	v_obj = VERTEX;
}

float h31(vec3 p) {
	p = fract(p * vec3(0.1031, 0.1030, 0.0973));
	p += dot(p, p.yxz + 33.33);
	return fract((p.x + p.y) * p.z);
}
float vnoise(vec3 p) {
	vec3 i = floor(p); vec3 f = fract(p);
	f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return mix(mix(mix(h31(i), h31(i + vec3(1,0,0)), f.x), mix(h31(i + vec3(0,1,0)), h31(i + vec3(1,1,0)), f.x), f.y),
	           mix(mix(h31(i + vec3(0,0,1)), h31(i + vec3(1,0,1)), f.x), mix(h31(i + vec3(0,1,1)), h31(i + vec3(1,1,1)), f.x), f.y), f.z);
}
vec3 hue(float h) {
	return clamp(abs(fract(h + vec3(0.0, 0.6667, 0.3333)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
}

void fragment() {
	float seed = v_cust.x * 37.0;
	vec3 body = v_col.rgb;
	vec3 p = v_obj * 3.0 + vec3(seed);
	vec3 v_w = normalize((INV_VIEW_MATRIX * vec4(VIEW, 0.0)).xyz);
	vec3 v_o = normalize(transpose(mat3(MODEL_MATRIX)) * v_w);
	if (v_cust.z < 1.5) {
		// OPAL: milky body with patches of spectral play-of-colour that shift
		// with the viewing angle
		float patch = smoothstep(0.52, 0.7, vnoise(p * 2.2));
		float hh = vnoise(p * 1.3 + v_o * 1.6) * 2.0 + v_o.x * 0.6;
		vec3 play = hue(hh) * (0.6 + 0.6 * vnoise(p * 6.0 + v_o * 3.0));
		ALBEDO = mix(body * 0.82, play, patch * 0.75);
		EMISSION = play * patch * 0.08;
		ROUGHNESS = 0.08;
		SPECULAR = 0.6;
		SSS_STRENGTH = 0.4;
	} else if (v_cust.z > 2.5) {
		// STAR SAPPHIRE / RUBY (kind 3): silky translucent body with a six-rayed
		// star from rutile silk at 60 degrees, gliding over the dome with the
		// view. Kind 4 = polished spinel/ruby cabochon (no star).
		vec3 n_o = normalize(transpose(mat3(MODEL_MATRIX)) * normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz));
		vec3 dir = normalize(v_o + vec3(0.0, 1.4, 0.0));
		vec3 sv = n_o - dir;
		float star = 0.0;
		for (int i = 0; i < 3; i++) {
			float a = float(i) * 1.0472;
			vec2 ax = vec2(cos(a), sin(a));
			vec2 perp = vec2(-ax.y, ax.x);
			float along = dot(sv.xz, ax);
			float across = dot(sv.xz, perp);
			star += exp(-across * across * 2500.0) * exp(-abs(along) * 3.0);
		}
		star *= step(v_cust.z, 3.5);
		float silk = vnoise(v_obj * 40.0 + vec3(seed)) * 0.12;
		float face = max(dot(n_o, v_o), 0.0);
		vec3 c = body * body * (0.30 + silk + 0.15 * face);
		ALBEDO = c;
		EMISSION = vec3(1.0, 0.97, 0.92) * star * 1.6 + body * body * 0.04;
		ROUGHNESS = v_cust.z > 3.5 ? 0.05 : 0.12;
		SPECULAR = 0.55;
		SSS_STRENGTH = 0.5;
	} else {
		// TURQUOISE / LAPIS: opaque, mottled, with a dark matrix web and (for
		// lapis) pyrite flecks
		float m = vnoise(p * 1.8);
		vec3 cq = v_obj * 3.4 + vec3(seed);
		vec3 ci = floor(cq);
		vec3 cf = fract(cq);
		float d1 = 8.0;
		float d2 = 8.0;
		for (int z = -1; z <= 1; z++) for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
			vec3 gq = vec3(float(x), float(y), float(z));
			vec3 o = vec3(h31(ci + gq), h31(ci + gq + 7.1), h31(ci + gq + 13.7));
			float dd = length(gq + o - cf);
			if (dd < d1) { d2 = d1; d1 = dd; } else if (dd < d2) { d2 = dd; }
		}
		float web = 1.0 - smoothstep(0.03, 0.09, d2 - d1);
		vec3 c = body * (0.78 + 0.35 * m);
		c = mix(c, vec3(0.06, 0.05, 0.04), web * 0.9);
		float fleck = step(0.985, h31(floor(v_obj * 70.0) + vec3(seed)));
		float is_lapis = step(body.g * 1.6, body.b);
		c = mix(c, vec3(0.95, 0.80, 0.42), fleck * is_lapis);
		ALBEDO = c;
		METALLIC = fleck * is_lapis;
		ROUGHNESS = mix(0.22, 0.35, m);
		SPECULAR = 0.5;
	}
}
"""
	_cabochon_mat = ShaderMaterial.new()
	_cabochon_mat.shader = sh
	return _cabochon_mat
