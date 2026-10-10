class_name MineralRocks

# ═══════════════════════════════════════════════════════════════════════════
# MINERAL ROCKS — massive / opaque raw specimens for the gem show, each a
# procedural likeness of a real-world stone. Implements MineralLibrary's
# contract: catalog() and make(id, size, seed).
#
# Geometry: RockMesh (knapped icospheres, botryoidal blisters, log sections,
# pyrite cubes). Materials: RockShaders (one object-space shader per species).
# Each specimen = ONE MeshInstance3D (one draw call), meshes cached per
# (id, seed), materials shared per species. 1.3k-5.2k triangles per piece.
# ═══════════════════════════════════════════════════════════════════════════

const LAB_L := Vector3(0.24, 0.94, 0.24)   # labradorite lamella normal (matches shader)

const SPECIES := {
	"nephrite_jade_boulder": {
		"name": "Nephrite Jade", "locality": "Cassiar, British Columbia, Canada",
		"note": "Felted tremolite-actinolite; spinach-green boulders so tough they break in waxy conchoidal faces.",
		"size": Vector2(0.6, 1.6), "placement": "boulder", "shader": "nephrite", "sink": 0.08,
		"mesh": {"subdiv": 4, "pexp": 3.0, "stretch": Vector3(1.1, 1.0, 1.0), "noise_amp": 0.10,
			"noise_freq": 1.1, "planes": 30, "plane_frac": Vector2(0.62, 0.86), "dish": 0.07, "edge_soft": 0.015,
			"bed": 0.80, "smooth_deg": 30.0},
	},
	"jadeite_boulder": {
		"name": "Jadeite", "locality": "Hpakant, Kachin State, Myanmar",
		"note": "River boulder in a brown weathered skin, a polished window showing apple-green and white jade.",
		"size": Vector2(0.35, 0.9), "placement": "boulder", "shader": "jadeite", "sink": 0.10,
		"mesh": {"subdiv": 4, "pexp": 2.2, "stretch": Vector3(1.3, 0.78, 1.0), "noise_amp": 0.09,
			"noise_freq": 1.0, "planes": 2, "plane_frac": Vector2(0.92, 0.97), "dish": 0.05,
			"cuts": [[Vector3(0.55, 0.7, -0.45), 0.80, 0.0, 2]], "bed": 0.82, "smooth_deg": 36.0},
	},
	"malachite_botryoidal": {
		"name": "Malachite", "locality": "Kolwezi, Katanga, DR Congo",
		"note": "Copper carbonate: bubbly botryoidal crust, banded light and dark green where broken.",
		"size": Vector2(0.25, 0.6), "placement": "scatter", "shader": "malachite", "sink": 0.10,
		"mesh": {"subdiv": 4, "pexp": 2.0, "stretch": Vector3(1.2, 0.85, 1.0), "noise_amp": 0.05,
			"noise_freq": 1.4, "bumps": 55, "bump_ang": Vector2(0.12, 0.32), "bump_h": 0.55, "bump_bias": 1.1,
			"planes": 2, "plane_frac": Vector2(0.62, 0.75), "plane_bias": Vector3(0, -0.3, 0), "dish": 0.05,
			"bed": 0.70, "smooth_deg": 38.0},
	},
	"lapis_lazuli_rough": {
		"name": "Lapis Lazuli", "locality": "Sar-i Sang, Badakhshan, Afghanistan",
		"note": "Lazurite rock with pyrite flecks and white calcite, mined in the same valley for 6,000 years.",
		"size": Vector2(0.18, 0.5), "placement": "scatter", "shader": "lapis", "sink": 0.10,
		"mesh": {"subdiv": 4, "pexp": 2.6, "stretch": Vector3(1.25, 0.8, 1.0), "noise_amp": 0.12,
			"noise_freq": 1.4, "planes": 9, "plane_frac": Vector2(0.78, 0.95), "dish": 0.12,
			"bed": 0.75, "smooth_deg": 32.0},
	},
	"sodalite_rough": {
		"name": "Sodalite", "locality": "Itaju do Colonia, Bahia, Brazil",
		"note": "Royal-blue feldspathoid veined with white; lighter and less pyritic than lapis.",
		"size": Vector2(0.3, 0.7), "placement": "boulder", "shader": "sodalite", "sink": 0.10,
		"mesh": {"subdiv": 4, "pexp": 2.8, "stretch": Vector3(1.2, 0.85, 1.0), "noise_amp": 0.10,
			"noise_freq": 1.2, "planes": 11, "plane_frac": Vector2(0.80, 0.95), "dish": 0.15,
			"bed": 0.78, "smooth_deg": 30.0},
	},
	"turquoise_nugget": {
		"name": "Turquoise", "locality": "Kingman Mine, Arizona, USA",
		"note": "Sky-blue copper phosphate nugget laced with a brown-black spiderweb matrix.",
		"size": Vector2(0.07, 0.22), "placement": "scatter", "shader": "turquoise", "sink": 0.12,
		"mesh": {"subdiv": 3, "pexp": 2.0, "stretch": Vector3(1.3, 0.75, 1.0), "noise_amp": 0.22,
			"noise_freq": 1.7, "planes": 2, "plane_frac": Vector2(0.9, 0.97), "dish": 0.05,
			"bed": 0.80, "smooth_deg": 40.0},
	},
	"obsidian": {
		"name": "Obsidian", "locality": "Glass Buttes, Oregon, USA",
		"note": "Volcanic glass: razor conchoidal fractures with ripple rings under a matte cortex.",
		"size": Vector2(0.3, 0.9), "placement": "boulder", "shader": "obsidian", "sink": 0.06,
		"mesh": {"subdiv": 4, "pexp": 2.3, "stretch": Vector3(1.2, 0.85, 1.0), "noise_amp": 0.10,
			"noise_freq": 1.2, "planes": 14, "plane_frac": Vector2(0.6, 0.88), "dish": 0.16, "edge_soft": 0.012,
			"bed": 0.8, "smooth_deg": 26.0},
	},
	"labradorite": {
		"name": "Labradorite", "locality": "Tsarasaotra, Madagascar",
		"note": "Grey plagioclase whose cleavage faces flash blue, teal and gold (labradorescence).",
		"size": Vector2(0.3, 0.8), "placement": "boulder", "shader": "labradorite", "sink": 0.08,
		"mesh": {"subdiv": 4, "pexp": 3.2, "stretch": Vector3(1.2, 0.85, 1.0), "noise_amp": 0.08,
			"noise_freq": 1.1, "planes": 7, "plane_frac": Vector2(0.82, 0.95), "dish": 0.08,
			"cuts": [[LAB_L, 0.78, 0.01, 1], [Vector3(0.9, 0.1, -0.4), 0.85, 0.02, 1]],
			"bed": 0.82, "smooth_deg": 30.0},
	},
	"pyrite_cubes": {
		"name": "Pyrite Cubes in Marl", "locality": "Navajún, La Rioja, Spain",
		"note": "Naturally perfect brassy cubes with striated faces, grown inside soft grey marl.",
		"size": Vector2(0.15, 0.45), "placement": "scatter", "shader": "pyrite", "sink": 0.10,
		"mesh": {"subdiv": 3, "pexp": 2.4, "stretch": Vector3(1.35, 0.55, 1.05), "noise_amp": 0.16,
			"noise_freq": 1.3, "planes": 4, "plane_frac": Vector2(0.8, 0.95), "dish": 0.1,
			"bed": 0.7, "smooth_deg": 36.0, "cubes": true},
	},
	"agate_nodule": {
		"name": "Agate Nodule (broken open)", "locality": "Rio Grande do Sul, Brazil",
		"note": "A dull basalt-cavity nodule cracked open on concentric chalcedony bands and a quartz core.",
		"size": Vector2(0.12, 0.35), "placement": "scatter", "shader": "agate", "sink": 0.10,
		"mesh": {"subdiv": 4, "pexp": 2.0, "stretch": Vector3(1.15, 0.9, 1.0), "noise_amp": 0.12,
			"noise_freq": 1.6, "noise_oct": 5, "planes": 0,
			"cuts": [[Vector3(0.25, 0.9, -0.35), 0.30, 0.03, 2]], "bed": 0.78, "smooth_deg": 40.0},
	},
	"petrified_wood_log": {
		"name": "Petrified Wood", "locality": "Petrified Forest, Arizona, USA",
		"note": "Triassic conifer trunk turned to jasper and quartz; logs break into near-square sections.",
		"size": Vector2(0.5, 1.4), "placement": "boulder", "shader": "petrified", "sink": 0.06,
		"mesh": {"subdiv": 4, "log": true, "log_len": 1.7, "noise_amp": 0.12, "noise_freq": 1.3,
			"noise_aniso": Vector3(0.25, 1.6, 1.6), "planes": 2, "plane_frac": Vector2(0.9, 0.97), "dish": 0.05,
			"cuts": [[Vector3(1, 0.08, 0.05), 0.86, 0.02, 1], [Vector3(-1, 0.1, -0.06), 0.84, 0.03, 1]],
			"bed": 0.86, "smooth_deg": 36.0},
	},
	"rhodochrosite_stalactite": {
		"name": "Rhodochrosite", "locality": "Capillitas Mine, Catamarca, Argentina",
		"note": "Inca rose: a stalactite of manganese carbonate in concentric pink and white bands.",
		"size": Vector2(0.12, 0.35), "placement": "scatter", "shader": "rhodochrosite", "sink": 0.08,
		"mesh": {"subdiv": 4, "log": true, "log_len": 1.4, "noise_amp": 0.10, "noise_freq": 2.4,
			"planes": 1, "plane_frac": Vector2(0.92, 0.97), "dish": 0.05,
			"cuts": [[Vector3(1, 0.1, 0.1), 0.88, 0.0, 1], [Vector3(-1, 0.25, -0.1), 0.78, 0.25, 1]],
			"bed": 0.85, "smooth_deg": 36.0},
	},
	"tigers_eye": {
		"name": "Tiger's Eye", "locality": "Griqualand West, Northern Cape, South Africa",
		"note": "Quartz after crocidolite: golden fibre bands that shimmer as you walk past.",
		"size": Vector2(0.15, 0.4), "placement": "scatter", "shader": "tigers_eye", "sink": 0.08,
		"mesh": {"subdiv": 4, "pexp": 3.5, "stretch": Vector3(1.35, 0.7, 0.95), "noise_amp": 0.06,
			"noise_freq": 1.2, "planes": 12, "plane_frac": Vector2(0.7, 0.9), "dish": 0.08,
			"plane_bias": Vector3(0, 0, 0), "bed": 0.85, "smooth_deg": 28.0, "no_rot": true},
	},
	"hematite_kidney_ore": {
		"name": "Hematite (Kidney Ore)", "locality": "Florence Mine, Egremont, Cumbria, England",
		"note": "Botryoidal iron oxide: steel-black metallic lobes, rusty red where weathered.",
		"size": Vector2(0.18, 0.5), "placement": "scatter", "shader": "hematite", "sink": 0.10,
		"mesh": {"subdiv": 4, "pexp": 2.0, "stretch": Vector3(1.25, 0.8, 1.0), "noise_amp": 0.04,
			"noise_freq": 1.2, "bumps": 48, "bump_ang": Vector2(0.14, 0.36), "bump_h": 0.55, "bump_bias": 1.4,
			"planes": 1, "plane_frac": Vector2(0.72, 0.8), "plane_bias": Vector3(0, -0.6, 0), "dish": 0.05,
			"bed": 0.7, "smooth_deg": 38.0},
	},
}

static var _mesh_cache := {}

static func catalog() -> Array:
	var out: Array = []
	for id in SPECIES:
		var s: Dictionary = SPECIES[id]
		out.append({"id": id, "name": s["name"], "locality": s["locality"], "note": s["note"],
			"size": s["size"], "placement": s["placement"]})
	return out

static func make(id: String, size: float, seed_: int = 0) -> Node3D:
	var root := Node3D.new()
	if not SPECIES.has(id):
		push_warning("MineralRocks: unknown specimen '%s'" % id)
		return root
	var sp: Dictionary = SPECIES[id]
	root.name = id.to_pascal_case()
	root.set_meta("mineral_id", id)
	var mi := MeshInstance3D.new()
	mi.name = "Specimen"
	mi.mesh = mesh(id, seed_)
	mi.material_override = RockShaders.material(sp["shader"])
	mi.scale = Vector3.ONE * size
	mi.rotation.y = fmod(float(seed_) * 2.399963, TAU)
	mi.visibility_range_end = clampf(size * 140.0, 35.0, 220.0)
	mi.visibility_range_end_margin = 4.0
	mi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	root.add_child(mi)
	return root

static func mesh(id: String, seed_: int) -> ArrayMesh:
	var key := "%s:%d" % [id, seed_]
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var m: ArrayMesh = MeshDiskCache.fetch("rock_" + key, ["res://content/mineral_rocks.gd", "res://content/rock_mesh.gd"], func() -> Variant:
		var sp: Dictionary = SPECIES[id]
		var o: Dictionary = sp["mesh"]
		var hseed := hash(key)
		var b := RockMesh.body(o, hseed)
		if o.get("cubes", false):
			_add_pyrite_cubes(b, hseed)
		return RockMesh.finish(b, sp["sink"]))
	_mesh_cache[key] = m
	return m

# Navajún habit: a few sharp cubes of very different sizes, each half sunk in
# the marl at its own random orientation.
static func _add_pyrite_cubes(b: RockMesh.Build, seed_: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_ ^ 0x5f3759df
	var shash: float = b.col[0].a if b.col.size() > 0 else 0.0
	var tops: Array[int] = []
	var hi := -INF
	for i in range(b.pos.size()):
		hi = maxf(hi, b.pos[i].y)
	for i in range(b.pos.size()):
		if b.nrm[i].y > 0.55 and b.pos[i].y > hi * 0.4:
			tops.append(i)
	if tops.is_empty():
		return
	var count := rng.randi_range(3, 6)
	for k in range(count):
		var i: int = tops[rng.randi() % tops.size()]
		var half := rng.randf_range(0.26, 0.36) if k == 0 else rng.randf_range(0.07, 0.17)
		var basis := Basis.from_euler(Vector3(rng.randf_range(-0.6, 0.6), rng.randf() * TAU, rng.randf_range(-0.6, 0.6)))
		var c: Vector3 = b.pos[i] - b.nrm[i] * half * rng.randf_range(0.15, 0.55)
		RockMesh.add_box(b, c, Vector3.ONE * half, basis, 1.0, shash)
