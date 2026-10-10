class_name MineralCrystals

# ═══════════════════════════════════════════════════════════════════════════
# MINERAL CRYSTALS — crystalline / translucent raw specimens for the gem show.
# Implements the MineralLibrary contract (catalog() / make(id, size, seed)).
#
# Each species is modelled on how the real specimen looks in the field or on a
# dealer's floor: crystal habit (faces as mineralogists list them, built as a
# convex polyhedron of half-spaces — CrysGeom), termination, colour zoning,
# inclusions and host matrix. Geometry: CrysGeom; materials: CrysShaders.
#
# A specimen is ONE MeshInstance3D per material (crystal + matrix = 2 draw
# calls at most), meshes cached per (id, seed), materials shared per species.
# Meshes are normalised to largest dimension 1 and the instances scaled by
# `size`; y = 0 is the ground line.
# ═══════════════════════════════════════════════════════════════════════════

const SPECIES := [
	{"id": "quartz_cluster", "name": "Clear Quartz Cluster", "locality": "Mount Ida, Arkansas, USA",
		"note": "Water-clear hexagonal points with striated prisms, milky bases and red-clay staining, radiating from sandstone.",
		"size": Vector2(0.5, 1.4), "placement": "outcrop"},
	{"id": "amethyst_geode", "name": "Amethyst Geode", "locality": "Artigas, Uruguay",
		"note": "Broken basalt gas-cavity: dull rind, celadonite skin and agate rim, lined with deep purple points.",
		"size": Vector2(0.6, 1.5), "placement": "boulder"},
	{"id": "citrine_points", "name": "Natural Citrine", "locality": "Kansanshi, Zambia",
		"note": "Honey-gold, faintly smoky quartz points, loose as they come out of the weathered pocket.",
		"size": Vector2(0.4, 0.9), "placement": "scatter"},
	{"id": "smoky_quartz", "name": "Smoky Quartz Cluster", "locality": "Gotthard Massif, Swiss Alps",
		"note": "Tapering Tessin-habit points, brown to near-black morion, on chlorite-dusted gneiss.",
		"size": Vector2(0.5, 1.3), "placement": "outcrop"},
	{"id": "rose_quartz", "name": "Rose Quartz", "locality": "Ambositra, Madagascar",
		"note": "Massive milky-pink quartz with no crystal faces, broken by glassy conchoidal fractures.",
		"size": Vector2(0.5, 1.6), "placement": "boulder"},
	{"id": "emerald_matrix", "name": "Emerald in Matrix", "locality": "Muzo, Boyacá, Colombia",
		"note": "Flat-topped green beryl prisms full of 'jardin', in black shale laced with white calcite and pyrite.",
		"size": Vector2(0.35, 0.9), "placement": "outcrop"},
	{"id": "aquamarine", "name": "Aquamarine", "locality": "Shigar Valley, Pakistan",
		"note": "Long, pale sea-blue hexagonal beryl prisms with flat terminations and lengthwise striations.",
		"size": Vector2(0.4, 1.0), "placement": "scatter"},
	{"id": "schorl", "name": "Black Tourmaline (Schorl)", "locality": "Erongo Mountains, Namibia",
		"note": "Glassy black, deeply striated prisms of rounded-triangular section in white feldspar.",
		"size": Vector2(0.4, 1.1), "placement": "outcrop"},
	{"id": "watermelon_tourmaline", "name": "Watermelon Tourmaline", "locality": "Minas Gerais, Brazil",
		"note": "Green-rinded elbaite crystals whose broken ends show a pink core.",
		"size": Vector2(0.3, 0.7), "placement": "scatter"},
	{"id": "fluorite", "name": "Fluorite Cubes", "locality": "Cave-in-Rock, Illinois, USA",
		"note": "Glassy interpenetrating cubes, purple rims around green phantom cores, on limestone.",
		"size": Vector2(0.35, 0.9), "placement": "outcrop"},
	{"id": "selenite", "name": "Selenite Blades", "locality": "Naica, Chihuahua, Mexico",
		"note": "Translucent, pearly gypsum blades with slanted chisel tips breaking out of the ground.",
		"size": Vector2(0.9, 2.4), "placement": "outcrop"},
	{"id": "amethyst_cathedral", "name": "Amethyst Cathedral", "locality": "Artigas, Uruguay",
		"note": "Tall geode half stood on end: grey basalt shell, white agate rim, a wall of deep purple points.",
		"size": Vector2(0.9, 1.6), "placement": "boulder"},
	{"id": "aragonite_sputnik", "name": "Aragonite Sputnik", "locality": "Tazouta, Morocco",
		"note": "Orange-brown twinned pseudo-hexagonal prisms radiating in every direction, paler at the tips.",
		"size": Vector2(0.25, 0.5), "placement": "scatter"},
	{"id": "okorusu_fluorite", "name": "Okorusu Fluorite", "locality": "Okorusu Mine, Namibia",
		"note": "Stacked teal-blue to violet cubes with phantom zoning, glassy and translucent.",
		"size": Vector2(0.3, 0.7), "placement": "outcrop"},
	{"id": "almandine_garnet", "name": "Almandine Garnet Crystals", "locality": "Wrangell, Alaska, USA",
		"note": "Wine-red rhombic dodecahedra weathered out of mica schist.",
		"size": Vector2(0.25, 0.45), "placement": "scatter"},
	{"id": "amethyst_cluster", "name": "Amethyst Cluster", "locality": "Rio Grande do Sul, Brazil",
		"note": "Hand-sized geode fragment: grey basalt back, a crust of short purple points.",
		"size": Vector2(0.1, 0.22), "placement": "boulder"},
	{"id": "citrine_cluster", "name": "Citrine Cluster (heat-treated)", "locality": "Rio Grande do Sul, Brazil",
		"note": "Amethyst baked to burnt orange: dark-tipped points on a white quartz base.",
		"size": Vector2(0.1, 0.22), "placement": "boulder"},
	{"id": "celestite_geode", "name": "Celestite Geode", "locality": "Sakoany, Mahajanga, Madagascar",
		"note": "Tan nodule broken open on pale sky-blue tabular celestine crystals.",
		"size": Vector2(0.4, 1.0), "placement": "boulder"},
]

# Material presets (one ShaderMaterial each, shared by every specimen).
const MATS := {
	"quartz": {"base_col": Color(0.97, 0.97, 0.98), "tip_col": Color(0.97, 0.98, 0.99), "density": 0.4,
		"ior": 1.544, "milky_base": 0.45, "milky_len": 0.14, "veil_amt": 0.06, "refr": 1.4,
		"stri_h": 1.0, "stri_freq": 320.0, "earth_stain": 0.55, "stain_col": Color(0.55, 0.28, 0.12), "milk_tint": 0.1, "inner": 0.03, "rough": 0.01, "glint": 90.0},
	"quartz_m": {"shader": "rock", "col_a": Color(0.60, 0.53, 0.44), "col_b": Color(0.50, 0.39, 0.30),
		"vein_col": Color(0.86, 0.84, 0.78), "vein_amt": 0.35, "noise_scale": 4.0},
	"amethyst": {"base_col": Color(0.86, 0.80, 0.92), "tip_col": Color(0.30, 0.05, 0.52), "tip_start": 0.05,
		"density": 3.0, "milky_base": 0.5, "milky_len": 0.3, "veil_amt": 0.1, "stri_h": 0.0, "refr": 0.4,
		"milk_col": Color(0.88, 0.84, 0.92), "milk_tint": 0.2, "glint": 80.0, "inner": 0.28, "etch": 0.02, "rough": 0.02},
	"amethyst_m": {"shader": "rock", "col_a": Color(0.40, 0.37, 0.33), "col_b": Color(0.30, 0.28, 0.25),
		"speck_col": Color(0.22, 0.34, 0.26), "speck_amt": 0.06, "speck_scale": 40.0,
		"rim_out": Color(0.33, 0.31, 0.28), "rim_a": Color(0.62, 0.66, 0.72), "rim_b": Color(0.80, 0.82, 0.84),
		"band_freq": 3.0, "lining_col": Color(0.20, 0.08, 0.30), "rough_a": 0.9, "pits": 1.0, "bump_amt": 1.6},
	"citrine": {"base_col": Color(1.0, 0.80, 0.38), "tip_col": Color(0.95, 0.58, 0.12), "tip_start": 0.2,
		"density": 2.2, "milky_base": 0.15, "milky_len": 0.15, "veil_amt": 0.1, "stri_h": 0.8,
		"earth_stain": 0.08, "stain_col": Color(0.42, 0.26, 0.12), "milk_tint": 0.5, "refr": 0.75, "inner": 0.05, "rough": 0.02},
	"smoky": {"base_col": Color(0.60, 0.57, 0.54), "tip_col": Color(0.38, 0.35, 0.32), "tip_start": 0.2,
		"density": 1.0, "milky_base": 0.4, "milky_len": 0.22, "veil_amt": 0.12, "stri_h": 1.0, "stri_freq": 280.0,
		"refr": 0.8, "milk_col": Color(0.7, 0.62, 0.55), "milk_tint": 0.5, "inner": 0.08, "rough": 0.015, "glint": 70.0},
	"smoky_m": {"shader": "rock", "col_a": Color(0.62, 0.60, 0.57), "col_b": Color(0.42, 0.41, 0.39),
		"speck_col": Color(0.07, 0.07, 0.07), "speck_amt": 0.08, "speck_scale": 90.0,
		"vein_col": Color(0.26, 0.33, 0.22), "vein_amt": 0.8, "vein_w": 0.09, "vein_scale": 4.0, "strata": 0.3},
	"rose": {"base_col": Color(0.96, 0.70, 0.76), "tip_col": Color(0.96, 0.70, 0.76), "density": 1.1,
		"milky_all": 0.22, "milk_col": Color(0.97, 0.86, 0.88), "milk_tint": 0.55, "veil_amt": 0.9,
		"veil_scale": 3.0, "refr": 0.3, "frost": 3.0, "rough": 0.07, "etch": 0.3, "glint": 18.0, "wrap": 0.6, "inner": 0.14, "mottle": 1.0, "conch": 1.6, "bright": 1.15, "shadow": true},
	"emerald": {"base_col": Color(0.22, 0.74, 0.44), "tip_col": Color(0.22, 0.74, 0.44), "density": 2.2,
		"ior": 1.58, "milky_base": 0.25, "milky_len": 0.3, "veil_amt": 0.6, "veil_scale": 14.0, "stri_v": 0.3,
		"refr": 0.4, "milk_col": Color(0.70, 0.85, 0.74), "milk_tint": 0.5},
	"emerald_m": {"shader": "rock", "col_a": Color(0.07, 0.07, 0.075), "col_b": Color(0.13, 0.125, 0.12),
		"strata": 0.6, "strata_freq": 80.0, "vein_col": Color(0.88, 0.87, 0.82), "vein_amt": 1.0,
		"vein_scale": 4.0, "vein_w": 0.018, "speck_col": Color(0.78, 0.64, 0.33), "speck_amt": 0.012,
		"speck_metal": 1.0, "speck_scale": 70.0, "lining_col": Color(0.86, 0.85, 0.80), "lining_rough": 0.35,
		"rough_a": 0.7},
	"aquamarine": {"base_col": Color(0.62, 0.86, 0.96), "tip_col": Color(0.62, 0.86, 0.96), "density": 0.7,
		"ior": 1.577, "milky_base": 0.12, "milky_len": 0.2, "veil_amt": 0.18, "stri_v": 0.7, "refr": 0.6, "inner": 0.12},
	"schorl": {"shader": "opaque", "base_col": Color(0.022, 0.022, 0.026), "tip_col": Color(0.022, 0.022, 0.026),
		"rough": 0.10, "stri_v": 1.8, "stri_freq": 220.0, "glint": 60.0, "etch": 0.1, "veil_amt": 0.0,
		"wrap": 0.0, "stain_col": Color(0.45, 0.36, 0.26)},
	"schorl_m": {"shader": "rock", "col_a": Color(0.86, 0.83, 0.77), "col_b": Color(0.66, 0.65, 0.63),
		"speck_col": Color(0.08, 0.08, 0.08), "speck_amt": 0.02, "speck_scale": 40.0, "rough_a": 0.7},
	"watermelon": {"base_col": Color(0.16, 0.52, 0.26), "tip_col": Color(0.20, 0.58, 0.30), "zone_mode": 2.0,
		"zone_col": Color(1.0, 0.30, 0.55), "zone_col2": Color(0.96, 0.93, 0.86), "density": 1.4, "ior": 1.63,
		"stri_v": 1.6, "refr": 0.4, "veil_amt": 0.25, "milky_base": 0.0, "inner": 0.08, "rough": 0.02, "stri_freq": 420.0, "glint": 70.0},
	"fluorite": {"base_col": Color(0.74, 0.90, 0.64), "tip_col": Color(0.60, 0.90, 0.62), "zone_mode": 1.0,
		"zone_col": Color(0.46, 0.28, 0.72), "zone_edge": 0.72, "density": 0.9, "ior": 1.434,
		"veil_amt": 0.2, "etch": 0.03, "refr": 0.5, "milky_base": 0.0, "inner": 0.12},
	"fluorite_m": {"shader": "rock", "col_a": Color(0.58, 0.55, 0.50), "col_b": Color(0.44, 0.42, 0.39),
		"speck_col": Color(0.16, 0.10, 0.06), "speck_amt": 0.01, "rough_a": 0.85, "strata": 0.25},
	"selenite": {"base_col": Color(0.96, 0.95, 0.92), "tip_col": Color(0.96, 0.95, 0.93), "density": 0.15,
		"ior": 1.52, "milky_base": 0.25, "milky_len": 0.3, "veil_amt": 0.3, "veil_scale": 6.0, "stri_v": 0.5,
		"stri_freq": 320.0, "refr": 0.6, "rough": 0.12, "milk_col": Color(0.96, 0.95, 0.93),
		"earth_stain": 0.6, "stain_col": Color(0.60, 0.50, 0.38), "inner": 0.15, "milky_all": 0.22},
	"amethyst_deep": {"base_col": Color(0.80, 0.70, 0.90), "tip_col": Color(0.24, 0.03, 0.50), "tip_start": 0.0,
		"density": 4.0, "milky_base": 0.45, "milky_len": 0.25, "veil_amt": 0.08, "stri_h": 0.0, "refr": 0.4,
		"milk_col": Color(0.92, 0.88, 0.95), "milk_tint": 0.2, "glint": 90.0, "inner": 0.3, "etch": 0.01, "rough": 0.015},
	"aragonite": {"base_col": Color(0.80, 0.34, 0.14), "tip_col": Color(0.96, 0.78, 0.62), "tip_start": 0.6,
		"density": 2.4, "milky_base": 0.4, "milky_len": 0.4, "milky_all": 0.12, "veil_amt": 0.45, "veil_scale": 8.0,
		"stri_v": 0.8, "refr": 0.3, "milk_col": Color(0.96, 0.78, 0.66), "milk_tint": 0.6, "rough": 0.05, "glint": 50.0, "inner": 0.2},
	"fluorite_ok": {"base_col": Color(0.18, 0.56, 0.54), "tip_col": Color(0.18, 0.56, 0.54), "zone_mode": 1.0,
		"zone_col": Color(0.16, 0.36, 0.62), "zone_edge": 0.7, "density": 3.2, "ior": 1.434,
		"veil_amt": 0.25, "etch": 0.04, "refr": 0.5, "milky_base": 0.0, "inner": 0.18, "glint": 70.0},
	"fluorite_ok_m": {"shader": "rock", "col_a": Color(0.42, 0.40, 0.38), "col_b": Color(0.30, 0.29, 0.28),
		"speck_col": Color(0.85, 0.83, 0.78), "speck_amt": 0.03, "speck_scale": 30.0, "rough_a": 0.8, "strata": 0.15},
	"garnet_x": {"shader": "opaque", "base_col": Color(0.30, 0.03, 0.05), "tip_col": Color(0.36, 0.05, 0.06),
		"rough": 0.16, "glint": 45.0, "etch": 0.25, "veil_amt": 0.0, "wrap": 0.15, "stri_v": 0.4, "stri_freq": 160.0,
		"stain_col": Color(0.40, 0.32, 0.26)},
	"citrine_burnt": {"base_col": Color(1.0, 0.72, 0.30), "tip_col": Color(0.70, 0.20, 0.03), "tip_start": 0.1,
		"density": 3.0, "milky_base": 0.6, "milky_len": 0.3, "veil_amt": 0.1, "stri_h": 0.0, "refr": 0.4,
		"milk_col": Color(0.96, 0.92, 0.86), "milk_tint": 0.3, "glint": 90.0, "inner": 0.2, "rough": 0.015},
	"quartz_white_m": {"shader": "rock", "col_a": Color(0.93, 0.91, 0.87), "col_b": Color(0.82, 0.80, 0.76),
		"speck_col": Color(0.70, 0.62, 0.50), "speck_amt": 0.02, "speck_scale": 30.0, "rough_a": 0.6},
	"celestite": {"base_col": Color(0.76, 0.87, 0.97), "tip_col": Color(0.68, 0.82, 0.97), "density": 1.1,
		"ior": 1.62, "milky_base": 0.4, "milky_len": 0.4, "veil_amt": 0.25, "stri_v": 0.3, "refr": 0.5,
		"milk_col": Color(0.86, 0.91, 0.96), "milk_tint": 0.4, "etch": 0.02, "rough": 0.02, "glint": 70.0, "inner": 0.18},
	"celestite_m": {"shader": "rock", "col_a": Color(0.62, 0.56, 0.48), "col_b": Color(0.48, 0.43, 0.37),
		"rim_out": Color(0.52, 0.46, 0.39), "rim_a": Color(0.84, 0.86, 0.88), "rim_b": Color(0.70, 0.74, 0.79),
		"band_freq": 3.0, "lining_col": Color(0.70, 0.76, 0.82), "pits": 0.8, "bump_amt": 1.4},
}

static var _cache := {}
static var _stats := {}

static func catalog() -> Array:
	return SPECIES.duplicate(true)

static func make(id: String, size: float, seed_: int = 0) -> Node3D:
	var root := Node3D.new()
	root.name = id
	var key := "%s:%d" % [id, seed_]
	if not _cache.has(key):
		_cache[key] = MeshDiskCache.fetch("crys_" + key, ["res://content/mineral_crystals.gd", "res://content/crys_geom.gd"], func() -> Variant: return _build(id, seed_))
	var iv := fposmod(float(seed_) * 0.618034 + 0.13, 1.0)
	for part in _cache[key]:
		var mi := MeshInstance3D.new()
		mi.mesh = part[0]
		mi.material_override = CrysShaders.material(part[1], MATS[part[1]])
		mi.scale = Vector3.ONE * size
		var pre: Dictionary = MATS[part[1]]
		var casts: bool = pre.get("shadow", pre.get("shader", "crystal") != "crystal")
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if casts else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_instance_shader_parameter("inst_var", iv)
		root.add_child(mi)
	return root

## Triangle count per (id, seed) after a make() — for budgets/diagnostics.
static func stats(id: String, seed_: int = 0) -> Dictionary:
	var key := "%s:%d" % [id, seed_]
	if not _cache.has(key):
		_cache[key] = MeshDiskCache.fetch("crys_" + key, ["res://content/mineral_crystals.gd", "res://content/crys_geom.gd"], func() -> Variant: return _build(id, seed_))
	var tris := 0
	for part in _cache[key]:
		tris += int(part[2])
	return {"tris": tris, "draws": (_cache[key] as Array).size()}

static func _build(id: String, seed_: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id) ^ (seed_ * 7919 + 17)
	var acc := {}
	var placement := "outcrop"
	match id:
		"quartz_cluster":
			_cluster(acc, rng, "quartz", "quartz_m", {"n": Vector2i(24, 36), "L": Vector2(0.06, 0.62),
				"rr": Vector2(0.12, 0.2), "up": 0.25, "jit": 0.45, "q": {}})
		"smoky_quartz":
			_cluster(acc, rng, "smoky", "smoky_m", {"n": Vector2i(6, 11), "L": Vector2(0.22, 0.85),
				"rr": Vector2(0.14, 0.2), "up": 0.55, "jit": 0.3, "q": {"taper": 0.035, "phi": 58.0}})
		"amethyst_geode":
			placement = "boulder"
			_geode(acc, rng, "amethyst_deep", "amethyst_m", {"radii": Vector3(0.5, 0.42, 0.62), "thick": 0.07,
				"n": 1900, "L": Vector2(0.05, 0.12), "kind": "quartz", "tilt": Vector2(25, 45)})
		"amethyst_cathedral":
			placement = "boulder"
			_geode(acc, rng, "amethyst_deep", "amethyst_m", {"radii": Vector3(0.40, 0.30, 0.95), "thick": 0.06,
				"n": 2600, "L": Vector2(0.05, 0.13), "kind": "quartz", "tilt": Vector2(86, 92)})
		"aragonite_sputnik":
			placement = "scatter"
			_aragonite(acc, rng)
		"okorusu_fluorite":
			_fluorite(acc, rng, "fluorite_ok", "fluorite_ok_m", {"n": Vector2i(10, 16), "s": Vector2(0.05, 0.17), "first": 0.19})
		"almandine_garnet":
			placement = "scatter"
			_garnets(acc, rng)
		"amethyst_cluster":
			placement = "boulder"
			_cluster(acc, rng, "amethyst_deep", "amethyst_m", {"n": Vector2i(110, 150), "L": Vector2(0.05, 0.14),
				"rr": Vector2(0.28, 0.36), "up": 0.85, "jit": 0.2, "q": {"irr": 0.12}})
		"citrine_cluster":
			placement = "boulder"
			_cluster(acc, rng, "citrine_burnt", "quartz_white_m", {"n": Vector2i(110, 150), "L": Vector2(0.04, 0.12),
				"rr": Vector2(0.28, 0.36), "up": 0.85, "jit": 0.2, "q": {"irr": 0.12}})
		"celestite_geode":
			placement = "boulder"
			_geode(acc, rng, "celestite", "celestite_m", {"radii": Vector3(0.5, 0.44, 0.5), "thick": 0.06,
				"n": 230, "L": Vector2(0.1, 0.22), "kind": "celestite", "tilt": Vector2(20, 40)})
		"rose_quartz":
			placement = "boulder"
			CrysGeom.rock(acc, "rose", Transform3D(Basis(Vector3.UP, rng.randf() * TAU), Vector3.ZERO), rng.randi(),
				{"subdiv": 4, "radii": Vector3(rng.randf_range(0.5, 0.6), rng.randf_range(0.46, 0.56), rng.randf_range(0.44, 0.52)),
				"amp": 0.2, "planes": rng.randi_range(6, 9), "pd": Vector2(0.6, 0.85), "bottom": -0.7,
				"th": 0.35, "rel": 1.0, "t": 1.0, "freq": 0.9})
		"emerald_matrix":
			_emerald(acc, rng)
		"schorl":
			_cluster(acc, rng, "schorl", "schorl_m", {"n": Vector2i(5, 10), "L": Vector2(0.2, 0.62),
				"rr": Vector2(0.09, 0.15), "up": 0.5, "jit": 0.35, "kind": "tourmaline"})
		"fluorite":
			_fluorite(acc, rng)
		"selenite":
			_selenite(acc, rng)
		"citrine_points":
			placement = "scatter"
			_scatter(acc, rng, "citrine", {"n": Vector2i(5, 8), "L": Vector2(0.25, 0.5), "rr": Vector2(0.15, 0.2), "kind": "quartz"})
		"aquamarine":
			placement = "scatter"
			_scatter(acc, rng, "aquamarine", {"n": Vector2i(3, 5), "L": Vector2(0.4, 0.85), "rr": Vector2(0.09, 0.14), "kind": "beryl"})
		"watermelon_tourmaline":
			placement = "scatter"
			_scatter(acc, rng, "watermelon", {"n": Vector2i(3, 6), "L": Vector2(0.20, 0.34), "rr": Vector2(0.11, 0.16), "kind": "tourmaline"})
		_:
			push_warning("MineralCrystals: unknown id '%s'" % id)
			return []
	return CrysGeom.finalize(acc, placement)

# ── Shared helpers ───────────────────────────────────────────────────────────

static func _planes_for(kind: String, rng: RandomNumberGenerator, r: float, L: float, bury: float, opt: Dictionary) -> Array:
	match kind:
		"beryl":
			return CrysGeom.beryl_planes(rng, r, L, bury, opt)
		"tourmaline":
			return CrysGeom.tourmaline_planes(rng, r, L, bury, opt)
		"celestite":
			return CrysGeom.celestite_planes(rng, r, r * 0.4, L, bury)
		_:
			return CrysGeom.quartz_planes(rng, r, L, bury, opt)

## Cluster of crystals radiating from a half-buried matrix rock (outcrop).
static func _cluster(acc: Dictionary, rng: RandomNumberGenerator, mx: String, mm: String, o: Dictionary) -> void:
	var R := Vector3(rng.randf_range(0.42, 0.55), rng.randf_range(0.18, 0.26), rng.randf_range(0.32, 0.45))
	var C := Vector3(0, -R.y * 0.35, 0)
	CrysGeom.rock(acc, mm, Transform3D(Basis.IDENTITY, C), rng.randi(),
		{"radii": R, "amp": 0.2, "planes": 4, "pd": Vector2(0.75, 0.95), "subdiv": 3})
	var n := rng.randi_range(o["n"].x, o["n"].y)
	var Lr: Vector2 = o["L"]
	var rr: Vector2 = o["rr"]
	var ref_r := (Lr.x + Lr.y) * 0.5 * (rr.x + rr.y) * 0.5
	var kind: String = o.get("kind", "quartz")
	var placed := []
	var tries := 0
	while placed.size() < n and tries < n * 30:
		tries += 1
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(0.1, 1.0), rng.randf_range(-1, 1)).normalized()
		var p := C + d * R * 0.8
		if p.y < 0.03:
			continue
		var L := lerpf(Lr.x, Lr.y, pow(rng.randf(), 1.8))
		if placed.size() < 2:
			L = lerpf(Lr.y * 0.8, Lr.y, rng.randf())          # a couple of showpiece points
		var r := L * rng.randf_range(rr.x, rr.y)
		var ok := true
		for q in placed:
			if p.distance_to(q[0]) < (r + float(q[1])) * 0.5:
				ok = false
				break
		if not ok:
			continue
		placed.append([p, r])
		var nrm := (d / R).normalized()
		var axis := CrysGeom.jitter_dir(rng, nrm.lerp(Vector3.UP, o["up"]), o["jit"])
		var opt: Dictionary = o.get("q", {}).duplicate()
		if kind == "tourmaline":
			opt["term"] = "pyramid" if rng.randf() < 0.6 else "flat"
		var planes := _planes_for(kind, rng, r, L, r * 1.5, opt)
		var xf := Transform3D(CrysGeom.basis_from_axis(axis, rng.randf() * TAU), p - axis * r * 0.4)
		CrysGeom.crystal(acc, mx, xf, planes, {"y0": -r * 0.4, "len": L + r * 0.4, "th": r,
			"rel": clampf(r / ref_r, 0.5, 2.0), "rnd": rng.randf(), "ext": L * 3.0 + r * 4.0})

## Broken-open geode lying on the ground, cavity tilted up toward +Z.
static func _geode(acc: Dictionary, rng: RandomNumberGenerator, mx: String, mm: String, o: Dictionary) -> void:
	var radii: Vector3 = o["radii"] * Vector3(rng.randf_range(0.9, 1.1), rng.randf_range(0.9, 1.1), rng.randf_range(0.9, 1.1))
	var tilt := deg_to_rad(rng.randf_range(o["tilt"].x, o["tilt"].y))
	var b := Basis(Vector3.UP, rng.randf_range(-0.4, 0.4)) * Basis(Vector3.RIGHT, tilt)
	var xf := Transform3D(b, Vector3.ZERO)
	var thick: float = o["thick"]
	var sh := CrysGeom.shell(acc, mm, xf, rng.randi(), radii, thick, {"jag": 0.10, "rings": 12, "segs": 34})
	var Lr: Vector2 = o["L"]
	var kind: String = o["kind"]
	var ref_r := (Lr.x + Lr.y) * 0.5 * 0.38
	for i in range(int(o["n"])):
		var u := rng.randf()
		var f := minf(acos(1.0 - u) / (PI * 0.5), 0.985)
		var az := rng.randf() * TAU
		var pn := CrysGeom.shell_inner(sh, f, az)
		var p: Vector3 = pn[0]
		var nrm: Vector3 = pn[1]
		var L := lerpf(Lr.x, Lr.y, pow(rng.randf(), 1.3))
		if f > 0.92:
			L *= 0.75
		# points grow off the wall and lean toward the cavity centre
		var axis := CrysGeom.jitter_dir(rng, nrm.lerp((-p).normalized(), 0.45), 0.12)
		var planes: Array
		var th := L * 0.4
		if kind == "celestite":
			var r := L * rng.randf_range(0.28, 0.4)
			th = r
			planes = CrysGeom.celestite_planes(rng, r, r * rng.randf_range(0.3, 0.45), L, r * 0.4)
		elif kind == "quartz":
			var r := L * rng.randf_range(0.16, 0.22)
			th = r
			planes = CrysGeom.quartz_planes(rng, r, L, L * 0.05, {"irr": 0.12, "phi": 51.8})
		else:
			planes = CrysGeom.pyramid_planes(rng, L, rng.randf_range(58.0, 64.0))
		var cx := xf * Transform3D(CrysGeom.basis_from_axis(axis, rng.randf() * TAU), p - axis * L * 0.06)
		CrysGeom.crystal(acc, mx, cx, planes, {"y0": 0.0, "len": L, "th": th,
			"rel": clampf(th / ref_r, 0.5, 2.0), "rnd": rng.randf(), "ext": L * 4.0})

## Loose crystals lying in a small group on the ground.
static func _scatter(acc: Dictionary, rng: RandomNumberGenerator, mx: String, o: Dictionary) -> void:
	var n := rng.randi_range(o["n"].x, o["n"].y)
	var Lr: Vector2 = o["L"]
	var rr: Vector2 = o["rr"]
	var ref_r := (Lr.x + Lr.y) * 0.5 * (rr.x + rr.y) * 0.5
	var kind: String = o["kind"]
	var placed := []
	var tries := 0
	while placed.size() < n and tries < n * 40:
		tries += 1
		var L := lerpf(Lr.x, Lr.y, rng.randf())
		if placed.is_empty():
			L = Lr.y
		var r := L * rng.randf_range(rr.x, rr.y)
		var spread := Lr.y * 0.9
		var c := Vector3(rng.randf_range(-spread, spread), 0.0, rng.randf_range(-spread, spread)) * 0.8
		if placed.is_empty():
			c = Vector3.ZERO
		var ok := true
		for q in placed:
			if Vector2(c.x, c.z).distance_to(Vector2(q[0].x, q[0].z)) < (L + float(q[1])) * 0.45:
				ok = false
				break
		if not ok:
			continue
		placed.append([c, L])
		var opt := {"broken_base": true}
		if kind == "tourmaline":
			opt["term"] = "flat" if rng.randf() < 0.65 else "pyramid"
		var planes := _planes_for(kind, rng, r, L, 0.0, opt)
		if kind == "quartz":
			var bn := (Vector3.DOWN + Vector3(rng.randf_range(-0.3, 0.3), 0, rng.randf_range(-0.3, 0.3))).normalized()
			planes[planes.size() - 1] = [bn, 0.0, 1]
		# lie it down: axis nearly horizontal, one end a little raised
		var yaw := rng.randf() * TAU
		var axis := Vector3(cos(yaw), rng.randf_range(-0.05, 0.22), sin(yaw)).normalized()
		var basis := CrysGeom.basis_from_axis(axis, rng.randf() * TAU)
		var miny := INF
		for pr in CrysGeom.convex_polys(planes, L * 3.0 + r * 4.0):
			for pv in pr[0]:
				miny = minf(miny, (basis * (pv as Vector3)).y)
		var pos := c - axis * L * 0.5
		pos.y = -miny - r * rng.randf_range(0.15, 0.35)
		var zone := 1.0 if kind == "tourmaline" else 0.0
		CrysGeom.crystal(acc, mx, Transform3D(basis, pos), planes, {"y0": 0.0, "len": L, "th": r,
			"rel": clampf(r / ref_r, 0.5, 2.0), "rnd": rng.randf(), "zone": zone, "ext": L * 3.0 + r * 4.0})

## Muzo: flat-topped emerald prisms + white calcite rhombs in black shale.
static func _emerald(acc: Dictionary, rng: RandomNumberGenerator) -> void:
	var R := Vector3(rng.randf_range(0.48, 0.56), rng.randf_range(0.2, 0.26), rng.randf_range(0.3, 0.38))
	var C := Vector3(0, -R.y * 0.3, 0)
	CrysGeom.rock(acc, "emerald_m", Transform3D(Basis(Vector3.UP, rng.randf() * TAU), C), rng.randi(),
		{"radii": R, "amp": 0.18, "planes": 6, "pd": Vector2(0.6, 0.85), "subdiv": 3, "up_bias": 0.6})
	var n := rng.randi_range(5, 9)
	var placed := []
	var tries := 0
	while placed.size() < n and tries < 300:
		tries += 1
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(0.2, 1.0), rng.randf_range(-1, 1)).normalized()
		var p := C + d * R * 0.75
		if p.y < 0.04:
			continue
		var L := rng.randf_range(0.1, 0.3) if placed.size() > 0 else 0.32
		var r := L * rng.randf_range(0.2, 0.3)
		var ok := true
		for q in placed:
			if p.distance_to(q[0]) < (r + float(q[1])) * 1.1:
				ok = false
		if not ok:
			continue
		placed.append([p, r])
		var axis := CrysGeom.jitter_dir(rng, (d / R).normalized().lerp(Vector3.UP, 0.3), 0.5)
		var planes := CrysGeom.beryl_planes(rng, r, L, r * 2.0, {"bevel": 0.12,
			"top_tilt": Vector3(rng.randf_range(-0.12, 0.12), 0, rng.randf_range(-0.12, 0.12))})
		var xf := Transform3D(CrysGeom.basis_from_axis(axis, rng.randf() * TAU), p - axis * r * rng.randf_range(0.3, 1.2))
		CrysGeom.crystal(acc, "emerald", xf, planes, {"y0": -r, "len": L + r, "th": r,
			"rel": clampf(r / 0.05, 0.6, 1.8), "rnd": rng.randf(), "ext": L * 3.0 + r * 4.0})
	# white calcite rhombohedra (rock material, lining zone = calcite white)
	for i in range(rng.randi_range(4, 8)):
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(0.0, 1.0), rng.randf_range(-1, 1)).normalized()
		var p := C + d * R * 0.82
		if p.y < 0.02:
			continue
		var s := rng.randf_range(0.025, 0.05)
		var planes := []
		var phi := deg_to_rad(44.6)
		for k in range(3):
			var a := float(k) * TAU / 3.0
			var nn := Vector3(sin(phi) * cos(a), cos(phi), sin(phi) * sin(a))
			planes.append([nn, s, 1])
			planes.append([-nn, s, 1])
		var xf := Transform3D(Basis.from_euler(Vector3(rng.randf() * TAU, rng.randf() * TAU, 0)), p)
		CrysGeom.crystal(acc, "emerald_m", xf, planes, {"th": s, "zone": 1.0, "ext": s * 6.0})

## Illinois fluorite: cubes and penetration twins on limestone.
static func _fluorite(acc: Dictionary, rng: RandomNumberGenerator, mat := "fluorite", mmat := "fluorite_m", o := {}) -> void:
	var R := Vector3(rng.randf_range(0.45, 0.55), rng.randf_range(0.16, 0.22), rng.randf_range(0.34, 0.42))
	var C := Vector3(0, -R.y * 0.35, 0)
	CrysGeom.rock(acc, mmat, Transform3D(Basis.IDENTITY, C), rng.randi(),
		{"radii": R, "amp": 0.16, "planes": 5, "pd": Vector2(0.7, 0.9), "subdiv": 3, "up_bias": 0.8})
	var nr: Vector2i = o.get("n", Vector2i(6, 11))
	var sr: Vector2 = o.get("s", Vector2(0.04, 0.14))
	var n := rng.randi_range(nr.x, nr.y)
	var placed := []
	var tries := 0
	while placed.size() < n and tries < 400:
		tries += 1
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(0.3, 1.0), rng.randf_range(-1, 1)).normalized()
		var p := C + d * R * 0.85
		if p.y < 0.03:
			continue
		var s := lerpf(sr.x, sr.y, pow(rng.randf(), 1.5))
		if placed.is_empty():
			s = o.get("first", 0.15)
		var ok := true
		for q in placed:
			if p.distance_to(q[0]) < (s + float(q[1])) * 0.85:
				ok = false
		if not ok:
			continue
		placed.append([p, s])
		var b := Basis.from_euler(Vector3(rng.randf_range(-0.6, 0.6), rng.randf() * TAU, rng.randf_range(-0.6, 0.6)))
		var c := p + (d / R).normalized() * s * 0.25
		var opt := {"y0": -s, "len": 2.0 * s, "th": s, "rel": clampf(s / 0.09, 0.6, 1.8), "rnd": rng.randf(), "ext": s * 6.0}
		CrysGeom.crystal(acc, mat, Transform3D(b, c), CrysGeom.cube_planes(rng, s, 0.08), opt)
		if rng.randf() < 0.4:
			var tw := b * Basis(Vector3(1, 1, 1).normalized(), PI / 3.0)
			var s2 := s * rng.randf_range(0.7, 0.9)
			var opt2 := opt.duplicate()
			opt2["th"] = s2
			opt2["rnd"] = rng.randf()
			CrysGeom.crystal(acc, mat, Transform3D(tw, c + Vector3(0, s * 0.1, 0)), CrysGeom.cube_planes(rng, s2, 0.05), opt2)

## Naica-style gypsum: long blades breaking out of the ground, one fallen.
static func _selenite(acc: Dictionary, rng: RandomNumberGenerator) -> void:
	var n := rng.randi_range(7, 11)
	for i in range(n):
		var a := rng.randf() * TAU
		var rad := rng.randf_range(0.0, 0.22)
		var base := Vector3(cos(a) * rad, -0.25, sin(a) * rad)
		var L := rng.randf_range(0.7, 1.5) if i > 0 else 1.6
		var w := L * rng.randf_range(0.045, 0.07)
		var t := w * rng.randf_range(0.35, 0.5)
		var lean := deg_to_rad(rng.randf_range(8.0, 45.0))
		var axis := Vector3(cos(a) * sin(lean), cos(lean), sin(a) * sin(lean)).normalized()
		var planes := CrysGeom.selenite_planes(rng, w, t, L, 0.0)
		var xf := Transform3D(CrysGeom.basis_from_axis(axis, rng.randf() * TAU), base)
		CrysGeom.crystal(acc, "selenite", xf, planes, {"y0": 0.0, "len": L, "th": t * 2.0,
			"rel": 1.0, "rnd": rng.randf(), "ext": L * 3.0})
	# a fallen blade lying in the grass
	var yaw := rng.randf() * TAU
	var L2 := rng.randf_range(0.6, 0.9)
	var w2 := L2 * 0.08
	var axis2 := Vector3(cos(yaw), 0.05, sin(yaw)).normalized()
	var b0 := CrysGeom.basis_from_axis(axis2, 0.0)
	var b2 := b0 * Basis(Vector3.UP, atan2(b0.x.y, b0.z.y))   # broad {010} face up
	var planes2 := CrysGeom.selenite_planes(rng, w2, w2 * 0.4, L2, 0.0)
	planes2[planes2.size() - 1] = [Vector3.DOWN, 0.0, 1]
	var start := Vector3(cos(yaw + 1.2), 0.0, sin(yaw + 1.2)) * 0.45
	start.y = w2 * 0.4 * 0.6
	CrysGeom.crystal(acc, "selenite", Transform3D(b2, start), planes2, {"y0": 0.0, "len": L2, "th": w2 * 0.8,
		"rel": 1.0, "rnd": rng.randf(), "ext": L2 * 3.0})


## Moroccan aragonite "sputnik": stubby pseudo-hexagonal prisms radiating out
## of a small core in every direction (not straight down), flat tips.
static func _aragonite(acc: Dictionary, rng: RandomNumberGenerator) -> void:
	var n := rng.randi_range(26, 36)
	var core := Vector3(0, 0.16, 0)
	for i in range(n):
		var d := Vector3(rng.randfn(), absf(rng.randfn()) * 0.9 - 0.25, rng.randfn()).normalized()
		var L := rng.randf_range(0.14, 0.28)
		var r := L * rng.randf_range(0.17, 0.25)
		var planes := CrysGeom.beryl_planes(rng, r, L, r * 0.2, {})
		var xf := Transform3D(CrysGeom.basis_from_axis(d, rng.randf() * TAU), core + d * 0.02)
		CrysGeom.crystal(acc, "aragonite", xf, planes, {"y0": 0.0, "len": L, "th": r,
			"rel": 1.0, "rnd": rng.randf(), "ext": L * 4.0})

## Almandine: loose rhombic dodecahedra (12 rhomb faces) lying in a group.
static func _garnets(acc: Dictionary, rng: RandomNumberGenerator) -> void:
	var n := rng.randi_range(5, 9)
	var placed := []
	var tries := 0
	while placed.size() < n and tries < 200:
		tries += 1
		var s := rng.randf_range(0.05, 0.11) if placed.size() > 0 else 0.12
		var p := Vector3(rng.randf_range(-0.4, 0.4), s * 0.92, rng.randf_range(-0.3, 0.3))
		var ok := true
		for q in placed:
			if Vector2(p.x - q[0].x, p.z - q[0].z).length() < s + float(q[1]) + 0.02:
				ok = false
		if not ok:
			continue
		placed.append([p, s])
		var planes := []
		for a in [[1, 1, 0], [1, -1, 0], [-1, 1, 0], [-1, -1, 0], [1, 0, 1], [1, 0, -1],
				[-1, 0, 1], [-1, 0, -1], [0, 1, 1], [0, 1, -1], [0, -1, 1], [0, -1, -1]]:
			var nv := Vector3(a[0], a[1], a[2]).normalized()
			planes.append([nv, s * rng.randf_range(0.96, 1.04), 0])
		# small trapezohedral bevels on some edges, like real almandine
		for k in range(6):
			var bn := Vector3(rng.randfn(), rng.randfn(), rng.randfn()).normalized()
			planes.append([bn, s * 1.02, 1])
		var b := Basis.from_euler(Vector3(rng.randf() * TAU, rng.randf() * TAU, rng.randf() * TAU))
		CrysGeom.crystal(acc, "garnet_x", Transform3D(b, p), planes, {"y0": -s, "len": 2.0 * s, "th": s,
			"rel": 1.0, "rnd": rng.randf(), "ext": s * 6.0})
