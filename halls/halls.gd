class_name Halls

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# HALLS — the gallery's floor plan. Each hall is one recipe that draws into a
# HallBuilder at bake time and becomes res://baked/<id>.scn. World coordinates
# are kept absolute, so a baked hall drops in at the origin.
#
#   Halls.ORDER                 bake/stream order (spawn hall first)
#   Halls.layout() -> Dictionary  shared positions (rows depend on the catalog)
#   Halls.build(id, hb, layout)   run one recipe
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

const COLS := 7
const SPACING := 4.2

const ORDER := ["specimens", "cut_gems", "displays", "legendary", "ancient", "treasury", "collector"]

const TITLES := {
	"specimens": "Raw specimens", "cut_gems": "Cut gems and the treasure heap", "displays": "Collector displays",
	"legendary": "Legendary Gems", "ancient": "Egypt, the Maya and the boutique", "treasury": "The Royal Treasury",
	"collector": "The Collector's Wing",
}

static func layout() -> Dictionary:
	var count := MineralLibrary.catalog().size()
	var rows := int(ceil(float(count) / float(COLS)))
	var back := float(rows) * SPACING
	return {"count": count, "rows": rows, "cut_z0": back + 5.0, "display_back": back + 26.0,
		"hall_z": back + 31.0, "treasury_z": back + 31.0 + 57.0, "collector_z": back + 31.0 + 57.0 + 40.0,
		"x_left": -float(COLS) * SPACING * 0.5 - 4.5, "x_right": float(COLS) * SPACING * 0.5 + 4.5}

static func slot(i: int) -> Vector3:
	var r := i / COLS
	var c := i % COLS
	return Vector3((float(c) - float(COLS - 1) * 0.5) * SPACING, 0, float(r) * SPACING + 4.0)

static func build(id: String, hb: HallBuilder, L: Dictionary) -> void:
	match id:
		"specimens": _specimens(hb, L)
		"cut_gems": _cut_gems(hb, L)
		"displays": _displays(hb, L)
		"legendary": _legendary(hb, L)
		"ancient": _ancient(hb, L)
		"treasury": _treasury(hb, L)
		"collector": _collector(hb, L)

# ── raw specimens laid out in rows on the void floor ────────────────────────
static func _specimens(hb: HallBuilder, L: Dictionary) -> void:
	var cat := MineralLibrary.catalog()
	for i in range(cat.size()):
		var e: Dictionary = cat[i]
		var sz: Vector2 = e.get("size", Vector2(0.6, 1.0))
		var size := clampf(sz.y * 0.9, 0.7, 1.8)
		var spec := MineralLibrary.make(e["id"], size, 7 + i)
		spec.position = slot(i)
		spec.rotation.y = PI + float(i) * 0.7
		hb.add_child(spec)
		var lb := Label3D.new()
		lb.text = "%s\n%s" % [e.get("name", e["id"]), e.get("locality", "")]
		lb.font_size = 36
		lb.outline_size = 8
		lb.pixel_size = 0.0022
		lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lb.modulate = Color(0.95, 0.93, 0.88)
		lb.position = slot(i) + Vector3(0, size + 0.35, -0.2)
		hb.add_child(lb)
	for r in range(int(L["rows"])):
		for c in range(0, COLS, 2):
			var l := OmniLight3D.new()
			l.light_color = Color(1.0, 0.96, 0.9)
			l.light_energy = 0.9
			l.omni_range = 7.0
			l.position = slot(r * COLS + c) + Vector3(SPACING * 0.5, 3.2, 0)
			hb.add_child(l)
	hb.shot(Vector3(0, 0, -2.5), Vector3(0, 0.6, 8.0), "s_entrance")
	hb.shot(Vector3(-6.0, 0, 7.0), Vector3(-8.4, 0.6, 12.0), "s_rows")

# ── cut catalogue, every stone, cabochons and the treasure heap ────────────
static func _cut_gems(hb: HallBuilder, L: Dictionary) -> void:
	var z0: float = L["cut_z0"]
	var velvet := StandardMaterial3D.new()
	velvet.albedo_color = Color(0.008, 0.008, 0.01)
	velvet.roughness = 1.0
	velvet.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	velvet.rim_enabled = true
	velvet.rim = 0.25
	velvet.rim_tint = 0.0
	var pad := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(34.0, 20.0)
	pad.mesh = pm
	pad.material_override = velvet
	pad.position = Vector3(0, 0.004, z0 + 8.0)
	hb.add_child(pad)
	_gem_row(hb, GemCuts.CUTS.map(func(c): return ["diamond", c]), z0 + 1.5, 1.7, "Cut catalogue (diamond)")
	var stones: Array = GemFactory.OPTICS.keys()
	_gem_row(hb, stones.map(func(sn): return [sn, GemFactory.STONES[sn][3][0] if GemFactory.STONES.has(sn) else "oval"]), z0 + 5.5, 1.25, "Stones")
	_gem_row(hb, [["opal", "cabochon"], ["turquoise", "cabochon"], ["lapis", "cabochon"]], z0 + 9.0, 2.2, "Cabochons")
	var heap := GemFactory.make_pile(4242, 1.6, 600)
	heap.position = Vector3(0, 0, z0 + 13.5)
	hb.add_child(heap)
	for k in range(3):
		var hl := OmniLight3D.new()
		hl.light_energy = 1.6
		hl.omni_range = 6.0
		hl.position = Vector3((float(k) - 1.0) * 2.0, 3.2, z0 + 12.2)
		hb.add_child(hl)
	hb._label("Treasure heap  -  every stone, every cut", Vector3(0, 1.9, z0 + 13.5), 0.0025)
	hb.shots.append([Vector3(-3.0, 0, z0 - 1.6), PI + 0.2, -0.22, "cuts_row"])
	hb.shots.append([Vector3(2.0, 0, z0 + 2.6), PI - 0.1, -0.25, "stones_row"])
	hb.shots.append([Vector3(0, 0, z0 + 10.0), PI, -0.55, "cut_heap"])

## One row of gems, each on a waist-high pedestal with a turntable and pin
## lights (the visitor faces +z when walking in, so the lights sit on the -z side).
const PEDESTAL_H := 0.82

static func _gem_row(hb: HallBuilder, items: Array, z: float, step: float, title: String) -> void:
	var n := items.size()
	var dm: Dictionary = GalleryDisplays._mats()
	hb._label(title, Vector3(-float(n - 1) * 0.5 * step - 1.6, PEDESTAL_H + 0.7, z), 0.0026)
	for i in range(n):
		var stone: String = items[i][0]
		var cut: String = items[i][1]
		var x := (float(i) - float(n - 1) * 0.5) * step
		var size := 0.12
		var pw := minf(step * 0.62, 0.36)
		GalleryDisplays._box(hb, Vector3(pw, PEDESTAL_H, pw), Vector3(x, PEDESTAL_H * 0.5, z), dm["black"], true)
		var spin := Turntable.stand(hb, Vector3(x, PEDESTAL_H, z), minf(pw * 0.42, 0.15), 0.035, 0.45 + 0.07 * float(i % 4))
		spin.rotation.y = float(i) * 0.9
		var g := GemFactory.make_gem(stone, cut, size)
		g.position.y = 0.014 + (0.0 if cut == "cabochon" else size * 0.12)
		g.rotation.x = 0.0 if cut == "cabochon" else -0.3
		spin.add_child(g)
		Turntable.no_shadow(g)
		hb.add_inspect_spot(spin.position + Vector3(0, size * 0.8, 0), stone, cut, g)
		var nice := stone.replace("_", " ").capitalize().replace("Sapph", "Sapphire")
		hb._label("%s\n%s" % [nice, GemCuts.NAMES.get(cut, cut)], Vector3(x, PEDESTAL_H + 0.42, z), 0.0016)
		Turntable.pin_lights(hb, spin.position + Vector3(0, size * 0.6, 0), Vector3(0, 0, -1), 3.5)

# ── collector displays around the specimen floor ───────────────────────────
static func _displays(hb: HallBuilder, L: Dictionary) -> void:
	GalleryDisplays.build(hb, L["x_left"], L["x_right"], 2.0, L["display_back"])
	var b: float = L["display_back"]
	for s in [[Vector3(-19.6, 0, 6.0), Vector3(-21.8, 1.5, 6.0), "d_gemcase"], [Vector3(-18.0, 0, 11.8), Vector3(-19.2, 0.95, 13.0), "d_rainbow"],
			[Vector3(17.6, 0, 3.6), Vector3(19.2, 0.95, 5.0), "d_velvet"], [Vector3(17.6, 0, 10.1), Vector3(19.2, 0.95, 11.5), "d_lightbox"],
			[Vector3(17.4, 0, 17.2), Vector3(19.2, 1.0, 18.5), "d_fluorite"], [Vector3(-16.5, 0, 21.0), Vector3(-19.8, 0.9, 21.5), "d_cathedrals"],
			[Vector3(17.4, 0, 26.5), Vector3(19.2, 0.9, 26.5), "d_bins"], [Vector3(-17.6, 0, 30.0), Vector3(-19.2, 0.95, 30.0), "d_case"],
			[Vector3(0.0, 0, b - 2.6), Vector3(0.0, 1.06, b - 1.6), "d_turquoise"],
			[Vector3(0.0, 0, b - 0.6), Vector3(0.0, 1.15, b + 0.2), "d_ring"]]:
		hb.shots.append(s)
	hb.shots.append([Vector3(-2.2, 0, b - 1.7), PI, -0.5, "d_bowl"])
	hb.shots.append([Vector3(2.2, 0, b - 1.4), PI, -0.32, "d_necklace"])

# ── the legendary gems hall ─────────────────────────────────────────────────
static func _legendary(hb: HallBuilder, L: Dictionary) -> void:
	var z: float = L["hall_z"]
	FamousGems.build_hall(hb, Vector3(0, 0, z))
	hb.shot(Vector3(0.0, 0, z - 0.8), Vector3(0.0, 1.0, z + 9.0), "f_hall")
	hb.shot(Vector3(-0.6, 0, z + 1.5), Vector3(-2.0, 1.2, z + 1.5), "f_cullinan")
	hb.shot(Vector3(0.6, 0, z + 6.3), Vector3(2.0, 1.2, z + 6.3), "f_hope")

# ── Egypt, Maya and the lapis & jade boutique ───────────────────────────────
static func _ancient(hb: HallBuilder, L: Dictionary) -> void:
	var z: float = L["hall_z"]
	AncientTreasures.build(hb, Vector3(0, 0, z))
	var left := AncientTreasures.EGYPT.size()
	for i in range(left):
		hb.shot(Vector3(-6.5, 0, z + 1.6 + float(i) * 3.0), Vector3(-7.6, 1.2, z + 1.6 + float(i) * 3.0), "a_%s" % AncientTreasures.EGYPT[i][0])
	var right: Array = AncientTreasures.MAYA + AncientTreasures.BOUTIQUE
	for i in range(right.size()):
		hb.shot(Vector3(6.6, 0, z + 1.6 + float(i) * 3.0), Vector3(7.6, 1.2, z + 1.6 + float(i) * 3.0), "b_%s" % right[i][0])

# ── the two newest halls share the TreasuryKit plinth layout ───────────────
static func _kit_shots(hb: HallBuilder, pieces: Array, z0: float, prefix: String) -> void:
	for i in range(pieces.size()):
		var side := -1.0 if i % 2 == 0 else 1.0
		var e: Array = pieces[i]
		var pl: Vector3 = e[4]
		var zz := z0 + 1.6 + float(i / 2) * 3.4
		var far: bool = e[0] == "gem_booth" or e[0] == "sipan" or e[0] == "dendera" or e[0] == "patiala"
		var ty := pl.y + (1.1 if e[0] == "gem_booth" else (0.5 if far else 0.2))
		hb.shot(Vector3(side * (0.6 if far else 1.5), 0, zz + 0.15), Vector3(side * 2.3, ty, zz), prefix + String(e[0]))

static func _treasury(hb: HallBuilder, L: Dictionary) -> void:
	var z: float = L["treasury_z"]
	RoyalTreasury.build(hb, Vector3(0, 0, z))
	_kit_shots(hb, RoyalTreasury.PIECES, z, "t_")

static func _collector(hb: HallBuilder, L: Dictionary) -> void:
	var z: float = L["collector_z"]
	CollectorWing.build(hb, Vector3(0, 0, z))
	_kit_shots(hb, CollectorWing.PIECES, z, "c_")
