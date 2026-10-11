class_name CollectorWing

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# COLLECTOR'S WING — loose-stone boxes and trays, rings and high jewellery,
# mineral specimens, a gem-show booth, a Roman coin hoard, Byzantine and Moche
# gold, a Dendera relief and the Patiala necklace. Each piece follows one of
# the reference photos.
#
#   CollectorWing.build(gallery, start: Vector3) -> float (hall length)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

const UP := Vector3.UP

const PIECES := [
	["cluster_box", "Cluster Layouts", "Loose stones laid out for a jeweller, 6x",
		"An emerald-cut sapphire in a marquise-diamond halo, a pink sapphire in pink rounds, tsavorite florets and a yellow oval.", Vector3(0.7, 1.05, 0.7)],
	["spinel_box", "Spinel Parcel", "Hearts, pears and an octagon, 6x",
		"Spinel comes in almost every colour: steel grey, hot pink, red, purple and lavender.", Vector3(0.7, 1.05, 0.7)],
	["chopard", "Gem Garden Collar", "Modern high jewellery in rose gold",
		"Pink spinels, blue and green sapphires, tsavorites and calibre emeralds among baguette diamonds, around a cushion aquamarine.", Vector3(0.9, 1.0, 0.8)],
	["patiala", "The Patiala Necklace", "Cartier, 1928 (replica, 1.3x)",
		"Made for the Maharaja of Patiala: 2,930 diamonds, Burmese rubies and the 234.6 ct yellow De Beers diamond.", Vector3(0.9, 0.3, 0.8)],
	["orange_tray", "Fire Colours Tray", "Collector's tray, 5x",
		"Sphalerite, fire opal, hessonite, spessartite, citrine, sphene and sunstone on ribbed velvet.", Vector3(0.9, 1.0, 0.8)],
	["aqua_pendant", "Aquamarine Coral Pendant", "Platinum high jewellery, 2x",
		"A huge pear aquamarine wrapped in diamond coral branches, hung from a diamond snowflake bow and a grey pearl.", Vector3(0.7, 1.0, 0.7)],
	["sapphire_rings", "Engraved Sapphire Ring Stack", "Platinum, 5x",
		"A hand-engraved crossover ring with an oval blue sapphire, and a band of graduated sapphires.", Vector3(0.7, 1.0, 0.7)],
	["wheat_necklace", "Wheat Ear Collar", "Gold and diamonds",
		"An open gold collar with seven pave diamond ears of wheat sweeping across the collarbone.", Vector3(0.8, 0.65, 0.8)],
	["peacock_necklace", "Peacock Bib Necklace", "Indian bridal style",
		"Twin peacocks in coloured stones around a watermelon tourmaline, pearl fringes and a bicolour tanzanite drop.", Vector3(0.8, 1.0, 0.8)],
	["rainbow_circles", "Rainbow Sapphire Circles", "Tiny round sapphires, 8x",
		"Fourteen colours of sapphire in each box, laid out as a colour wheel.", Vector3(0.8, 1.05, 0.7)],
	["hex_pair", "Hexagon Pair", "Silky sapphire and garnet, 5x",
		"Long hexagonal step cuts: a silky blue-violet sapphire and a deep red garnet.", Vector3(0.7, 1.05, 0.7)],
	["jade_ring", "Jade and Amethyst Ring", "Carved nephrite, 4x",
		"A ring carved from spinach-green nephrite, set across the top with cushion amethysts.", Vector3(0.7, 1.05, 0.7)],
	["tanzanite_brooch", "Tanzanite Cathedral Brooch", "Gold, 3x",
		"A polished tanzanite dome crowned with gold Gothic spires tipped with diamonds and sapphires.", Vector3(0.7, 1.05, 0.7)],
	["byz_bracelet", "Byzantine Bracelet", "Gold, pearls, sapphire, amethyst, c. 600 AD (replica, 3x)",
		"A hinged gold cuff: a central sapphire on a disc ringed with pearls, amethysts and pearls strung along the edges.", Vector3(0.7, 1.0, 0.7)],
	["coin_hoard", "Roman Silver Coin Hoard", "Antoniniani, 3rd century AD (replica)",
		"Over a hundred silver radiate coins with green copper corrosion, in a velvet-lined box.", Vector3(0.9, 0.9, 0.7)],
	["sipan", "Regalia of the Lord of Sipan", "Moche, Peru, c. 250 AD (replica)",
		"Gold mask and crescent headdress, turquoise mosaic ear spools and pectoral, and the gold-and-silver peanut necklace.", Vector3(1.4, 0.75, 0.8)],
	["dendera", "Eye of Horus Relief", "Temple of Hathor, Dendera (replica)",
		"Painted sandstone ceiling relief: the wedjat eye in the moon disc, with Thoth and columns of hieroglyphs.", Vector3(1.0, 0.35, 0.4)],
	["anglesite", "Anglesite on Galena", "Touissit, Morocco",
		"Lead sulphate crystals, honey-yellow and glassy, growing on the lead ore galena.", Vector3(0.7, 1.0, 0.7)],
	["pyromorphite", "Pyromorphite", "Daoping mine, China",
		"Lime-green barrel-shaped lead phosphate crystals packed into a crust.", Vector3(0.8, 0.95, 0.7)],
	["amethyst_flower", "Amethyst Flower", "Veracruz, Mexico",
		"Pale lavender amethyst points radiating like petals from a stem, with dark goethite.", Vector3(0.7, 1.0, 0.7)],
	["gem_booth", "Gem Show Booth", "Crystal dealer's stand",
		"Glass shelves of clear and smoky quartz clusters, crystal balls, and trays of points on a navy-draped table.", Vector3(2.2, 0.04, 1.1)],
]

## Every piece moves (see TreasuryKit.hall); flat ones sway, the booth stays put
## (its shelf specimens turn on their own).
const FLAT := ["cluster_box", "spinel_box", "chopard", "orange_tray", "aqua_pendant", "peacock_necklace",
	"rainbow_circles", "hex_pair", "coin_hoard", "sipan", "dendera"]
const STILL := ["gem_booth"]

static func build(g: Node3D, start: Vector3) -> float:
	TreasuryKit.register()
	return TreasuryKit.hall(g, start, PIECES, "The Collector's Wing  -  loose stones, jewels, minerals and antiquities",
		func(k: String, hh: Node3D) -> void: _make(k, hh), Color(0.05, 0.08, 0.16), FLAT, STILL)

static func _make(key: String, h: Node3D) -> void:
	match key:
		"cluster_box": _cluster_box(h)
		"spinel_box": _spinel_box(h)
		"chopard": _chopard(h)
		"patiala": _patiala(h)
		"orange_tray": _orange_tray(h)
		"aqua_pendant": _aqua_pendant(h)
		"sapphire_rings": _sapphire_rings(h)
		"wheat_necklace": _wheat(h)
		"peacock_necklace": _peacock(h)
		"rainbow_circles": _rainbow_circles(h)
		"hex_pair": _hex_pair(h)
		"jade_ring": _jade_ring(h)
		"tanzanite_brooch": _brooch(h)
		"byz_bracelet": _byz(h)
		"coin_hoard": _coins(h)
		"sipan": _sipan(h)
		"dendera": _dendera(h)
		"anglesite": _anglesite(h)
		"pyromorphite": _pyromorphite(h)
		"amethyst_flower": _am_flower(h)
		"gem_booth": _booth(h)

static func M(k: String) -> Material:
	return TreasuryKit.mats()[k]

static func _sph(parent: Node3D, mat: Material, pos: Vector3, scl: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = ShopStones.sphere_mesh()
	mi.material_override = mat
	mi.position = pos
	mi.scale = scl
	parent.add_child(mi)
	return mi

# ── loose-stone boxes ───────────────────────────────────────────────────────
static func _cluster_box(h: Node3D) -> void:
	var top := TreasuryKit.gem_box(h, Vector2(0.4, 0.34), TreasuryKit.crystal(Color(0.95, 0.97, 1.0), 0.0, 0.05), M("grey_velvet"), 0.5)
	var it := []
	var c := Vector3(-0.07, 0.012, -0.03)
	TreasuryKit.gem(it, "sapphire", "emerald", c, UP, Vector3(0, 0, 1), 0.03)
	for k in range(10):
		var a := float(k) / 10.0 * TAU
		var dv := Vector3(cos(a), 0, sin(a))
		TreasuryKit.gem(it, "diamond", "marquise" if k % 2 == 0 else "pear", c + Vector3(dv.x * 0.06, 0, dv.z * 0.07), UP, dv, 0.016 if k % 2 == 0 else 0.012)
	for k in range(4):
		var a := float(k) / 4.0 * TAU + 0.4
		TreasuryKit.gem(it, "tsavorite", "round", c + Vector3(cos(a) * 0.088, 0, sin(a) * 0.095), UP, Vector3.RIGHT, 0.008)
	var pc := Vector3(0.1, 0.012, 0.09)
	TreasuryKit.gem(it, "hot_pink_sapph", "emerald", pc, UP, Vector3(0, 0, 1), 0.02)
	for k in range(8):
		var a := float(k) / 8.0 * TAU
		TreasuryKit.gem(it, "pink_sapph", "round", pc + Vector3(cos(a) * 0.032, 0, sin(a) * 0.038), UP, Vector3.RIGHT, 0.0085)
	var gc := Vector3(0.11, 0.012, -0.09)
	TreasuryKit.gem(it, "diamond", "round", gc, UP, Vector3.RIGHT, 0.007)
	for k in range(4):
		var a := float(k) / 4.0 * TAU
		TreasuryKit.gem(it, "tsavorite", "round", gc + Vector3(cos(a), 0, sin(a)) * 0.016, UP, Vector3.RIGHT, 0.0085)
	TreasuryKit.gem(it, "yellow_diamond", "oval", Vector3(-0.06, 0.012, 0.12), UP, Vector3.RIGHT, 0.022)
	top.add_child(GemFactory.make_set(it))

static func _spinel_box(h: Node3D) -> void:
	var top := TreasuryKit.gem_box(h, Vector2(0.34, 0.34), M("white_foam"), M("white_foam"), 0.55)
	var it := []
	for s in [[Vector2(0.0, -0.1), "grey_spinel", "heart", 0.032, -PI * 0.5], [Vector2(-0.09, 0.0), "pink_spinel", "pear", 0.042, -PI * 0.5],
			[Vector2(0.0, 0.0), "red_spinel", "asscher", 0.028, 0.0], [Vector2(0.09, 0.0), "purple_spinel", "heart", 0.034, -PI * 0.5],
			[Vector2(0.0, 0.1), "lavender_spinel", "pear", 0.034, -PI * 0.5]]:
		var q: Vector2 = s[0]
		TreasuryKit.gem(it, s[1], s[2], Vector3(q.x, 0.014, q.y), UP, Vector3(cos(float(s[4])), 0, sin(float(s[4]))), s[3])
	top.add_child(GemFactory.make_set(it))

static func _rainbow_circles(h: Node3D) -> void:
	var cols := ["ruby", "pink_sapph", "rubellite", "violet_sapph", "iolite", "steel_sapph", "green_sapph", "peridot", "lemon_quartz",
		"yellow_sapph", "citrine", "orange_sapph", "morganite", "hot_pink_sapph"]
	for b in range(3):
		var holder := Node3D.new()
		holder.position = [Vector3(-0.17, 0, -0.05), Vector3(0.17, 0, -0.08), Vector3(0.0, 0, 0.17)][b]
		holder.rotation.y = [0.25, -0.3, 0.05][b]
		h.add_child(holder)
		var top := TreasuryKit.gem_box(holder, Vector2(0.26, 0.26), M("black_plastic"), M("white_foam"), 0.35)
		var it := []
		for k in range(14):
			var a := float(k) / 14.0 * TAU + float(b)
			TreasuryKit.gem(it, cols[(k + b * 3) % cols.size()], "round", Vector3(cos(a) * 0.065, 0.01, sin(a) * 0.065), UP, Vector3.RIGHT, 0.0085)
		top.add_child(GemFactory.make_set(it))

static func _ribbed(h: Node3D, mat: Material, size: Vector2, ribs: int) -> Node3D:
	var tray := Node3D.new()
	tray.position.y = 0.06
	tray.rotation.x = 0.35
	h.add_child(tray)
	var base := MeshUtils.make_rounded_box(Vector3(size.x, 0.03, size.y), 0.006, mat)
	base.position.y = -0.015
	tray.add_child(base)
	var r := size.y / float(ribs) * 0.5
	for k in range(ribs):
		var cyl := MeshUtils.make_cylinder(r, r, size.x - 0.01, mat, 16)
		cyl.rotation.z = PI * 0.5
		cyl.position = Vector3(0, 0.0, -size.y * 0.5 + r + float(k) * r * 2.0)
		tray.add_child(cyl)
	var st := MeshUtils.make_rounded_box(Vector3(size.x * 0.6, 0.12, 0.03), 0.004, mat)
	st.position = Vector3(0, 0.05, -size.y * 0.3)
	h.add_child(st)
	return tray

static func _orange_tray(h: Node3D) -> void:
	var rows := [
		[["heliodor", "trillion", 0.02], ["olive_tourm", "trillion", 0.019], ["hessonite", "round", 0.012], ["garnet", "round", 0.012], ["garnet", "round", 0.012], ["sphene", "cushion", 0.013], ["smoky_quartz", "radiant", 0.018], ["rhodolite", "cushion", 0.015]],
		[["spessartite", "emerald", 0.017], ["sphalerite", "round", 0.026], ["sphalerite", "round", 0.022], ["hessonite", "round", 0.021], ["red_spinel", "round", 0.021], ["sunstone", "round", 0.021], ["smoky_dark", "emerald", 0.016]],
		[["smoky_dark", "briolette", 0.024], ["fire_opal", "round", 0.017], ["fire_opal", "round", 0.017], ["spessartite", "trillion", 0.017], ["smoky_quartz", "princess", 0.024], ["fire_opal", "cabochon", 0.016], ["mandarin", "trillion", 0.022]],
		[["sphalerite", "oval", 0.03], ["imperial_topaz", "emerald", 0.025], ["yellow_sapph", "round", 0.034], ["hessonite", "round", 0.012], ["smoky_dark", "oval", 0.018], ["sphene", "oval", 0.025]],
	]
	var tray := _ribbed(h, M("grey_velvet"), Vector2(0.62, 0.48), 9)
	var it := []
	for r in range(rows.size()):
		var list: Array = rows[r]
		var z := -0.18 + float(r) * 0.106
		var x := -0.26
		var stepx := 0.52 / float(list.size() - 1)
		for s in list:
			var stn: String = s[1]
			if stn == "cabochon":
				TreasuryKit.gem(it, "cab_carnelian", "cabochon", Vector3(x, 0.022, z), UP, Vector3.RIGHT, s[2])
			else:
				TreasuryKit.gem(it, s[0], stn, Vector3(x, 0.024, z), UP, Vector3.RIGHT if stn != "trillion" else Vector3(0, 0, -1), s[2])
			x += stepx
	tray.add_child(GemFactory.make_set(it))

static func _hex_pair(h: Node3D) -> void:
	var tray := _ribbed(h, M("pink_velvet"), Vector2(0.44, 0.4), 4)
	var it := []
	TreasuryKit.gem(it, "bicolor_tanz", "hexagon", Vector3(-0.09, 0.03, 0.0), UP, Vector3(0.45, 0, -1).normalized(), 0.075)
	TreasuryKit.gem(it, "rhodolite", "hexagon", Vector3(0.09, 0.03, 0.0), UP, Vector3(0.35, 0, -1).normalized(), 0.08)
	tray.add_child(GemFactory.make_set(it))

# ── necklaces on boards and busts ───────────────────────────────────────────
static func _leaf() -> Mesh:
	return RoyalTreasury._leaf_mesh()

static func _chopard(h: Node3D) -> void:
	var b := AncientTreasures._board(h, Color(0.07, 0.07, 0.08), Vector2(0.72, 0.66), -0.95)
	var rg: Material = M("rose_gold")
	var it := []
	var leaves := []
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	var c := Vector2(0, 0.4)
	var rx := 0.2
	var ry := 0.26
	var colours := ["pink_spinel", "rubellite", "blue_sapph_pale", "aquamarine", "peridot", "tsavorite", "lavender_spinel", "hot_pink_sapph", "green_sapph"]
	var a := deg_to_rad(165.0)
	while a < deg_to_rad(375.0):
		var p := c + Vector2(cos(a) * rx, sin(a) * ry)
		var o := Vector2(cos(a) / rx, sin(a) / ry).normalized()
		var t := Vector2(-o.y, o.x)
		var wv := 0.034
		for k in range(3):
			var q := p + o * rng.randf_range(-wv, wv) + t * rng.randf_range(-0.005, 0.005)
			var r := rng.randf()
			var pos := Vector3(q.x, q.y, 0.012)
			if r < 0.35:
				var cut: String = ["oval", "pear", "cushion", "oval"][rng.randi() % 4]
				TreasuryKit.gem(it, colours[rng.randi() % colours.size()], cut, pos, Vector3.BACK, Vector3(o.x, o.y, 0), rng.randf_range(0.009, 0.013))
			elif r < 0.5:
				for j in range(4):
					TreasuryKit.gem(it, "emerald", "baguette", pos + Vector3(t.x, t.y, 0) * (float(j) - 1.5) * 0.006, Vector3.BACK, Vector3(o.x, o.y, 0), 0.0045)
			elif r < 0.75:
				TreasuryKit.gem(it, "diamond", "baguette", pos, Vector3.BACK, Vector3(o.x, o.y, 0), 0.006)
			else:
				TreasuryKit.gem(it, "diamond", "round", pos, Vector3.BACK, Vector3.RIGHT, 0.004)
		leaves.append(Transform3D(TreasuryKit.frame(Vector3.BACK, Vector3(o.x, o.y, 0).rotated(Vector3.BACK, rng.randf_range(-0.8, 0.8))).scaled(Vector3.ONE * 0.06), Vector3(p.x, p.y, 0.004) - Vector3(o.x, o.y, 0) * 0.03))
		a += 0.012 / ry
	var bc := c + Vector2(0, -ry)
	TreasuryKit.gem(it, "aquamarine_big", "cushion", Vector3(bc.x, bc.y, 0.018), Vector3.BACK, Vector3.UP, 0.032)
	TreasuryKit.halo(it, Vector3(bc.x, bc.y, 0.012), Vector3.RIGHT, Vector3.UP, 0.04, 0.0045, "diamond", "baguette", 16)
	b.add_child(GalleryDisplays._mm(_leaf(), leaves, rg))
	b.add_child(GemFactory.make_set(it))

static func _bust(h: Node3D, mat: Material, s := 1.0) -> Callable:
	var prof := [Vector2(0.0, 0.0), Vector2(0.30, 0.0), Vector2(0.34, 0.22), Vector2(0.31, 0.45), Vector2(0.18, 0.56), Vector2(0.10, 0.60), Vector2(0.095, 0.95), Vector2(0.0, 0.97)]
	var sp := []
	for p in prof:
		sp.append((p as Vector2) * s)
	var torso := MeshUtils.make_revolved(sp, mat, 64)
	torso.scale = Vector3(1.0, 1.0, 0.55)
	h.add_child(torso)
	return func(x: float, y: float) -> Array:
		var r := 0.1 * s
		for i in range(sp.size() - 1):
			var a: Vector2 = sp[i]
			var bb: Vector2 = sp[i + 1]
			if y >= a.y and y <= bb.y:
				r = lerpf(a.x, bb.x, (y - a.y) / maxf(bb.y - a.y, 1e-4))
				break
		var xx := clampf(x, -r * 0.97, r * 0.97)
		var z := 0.55 * sqrt(maxf(r * r - xx * xx, 0.0)) + 0.004
		var n := Vector3(xx / (r * r), 0.25 / r, z / (0.55 * 0.55 * r * r)).normalized()
		return [Vector3(xx, y, z), n]

static func _patiala(h: Node3D) -> void:
	var at := _bust(h, M("aubergine"), 1.3)
	var it := []
	var plat: Material = M("platinum")
	var place := func(x: float, y: float, stone: String, cut: String, size: float, along := Vector3.RIGHT) -> void:
		var r: Array = at.call(x, y)
		TreasuryKit.gem(it, stone, cut, r[0], r[1], along, size)
	# choker of diamond roundels on the neck
	for k in range(5):
		var x := (float(k) - 2.0) * 0.042
		var y := 1.13
		place.call(x, y, "diamond" if k != 2 else "yellow_diamond", "old_european", 0.012)
		for j in range(12):
			var a := float(j) / 12.0 * TAU
			place.call(x + cos(a) * 0.019, y + sin(a) * 0.019, "diamond", "round", 0.0035)
	# five rows of looped links
	for row in range(5):
		var depth := 0.1 + float(row) * 0.055
		var half := 0.13 + float(row) * 0.03
		var n := 13 + row * 2
		for i in range(n):
			var t := lerpf(-1.0, 1.0, float(i) / float(n - 1))
			var x := t * half
			var y := 0.82 - depth * (1.0 - t * t)
			for j in range(10):
				var a := float(j) / 10.0 * TAU
				place.call(x + cos(a) * 0.012, y + sin(a) * 0.01, "diamond", "round", 0.0032)
			place.call(x, y, "diamond", "round", 0.0045)
	place.call(0.0, 0.72, "brown_diamond", "cushion", 0.014)
	place.call(0.0, 0.66, "diamond", "old_mine", 0.016)
	place.call(0.0, 0.61, "diamond", "old_mine", 0.016)
	place.call(-0.1, 0.64, "ruby", "oval", 0.012)
	place.call(0.1, 0.64, "ruby", "oval", 0.012)
	place.call(0.0, 0.545, "diamond", "old_european", 0.03)
	for j in range(22):
		var a := float(j) / 22.0 * TAU
		place.call(cos(a) * 0.04, 0.545 + sin(a) * 0.04, "diamond", "round", 0.004)
	place.call(0.0, 0.47, "diamond", "emerald", 0.014, Vector3.UP)
	place.call(0.0, 0.38, "yellow_diamond", "cushion", 0.045)
	for j in range(14):
		var t := lerpf(-1.0, 1.0, float(j) / 13.0)
		var x := t * 0.24
		if absf(x) < 0.04:
			continue
		var y := 0.82 - 0.32 * (1.0 - t * t) - 0.05
		place.call(x, y, "diamond", "old_european", 0.01)
		for k in range(10):
			var a := float(k) / 10.0 * TAU
			place.call(x + cos(a) * 0.015, y + sin(a) * 0.022 - 0.004, "diamond", "round", 0.003)
	for k in range(3):
		var x := (float(k) - 1.0) * 0.045
		var y := 0.3 - absf(float(k) - 1.0) * -0.02 - 0.02
		place.call(x, y, "diamond", "old_european", 0.013)
		for j in range(12):
			var a := float(j) / 12.0 * TAU
			place.call(x + cos(a) * 0.02, y + sin(a) * 0.028, "diamond", "round", 0.0032)
	h.add_child(GemFactory.make_set(it))
	var _p := plat

static func _wheat(h: Node3D) -> void:
	var at := _bust(h, M("bust_white"), 1.0)
	var gold: Material = M("gold")
	var it := []
	var collar := PackedVector3Array()
	for k in range(41):
		var a := lerpf(0.0, TAU * 0.86, float(k) / 40.0) + PI * 0.57
		collar.append(Vector3(cos(a) * 0.115, 0.6 + 0.01 * sin(a), sin(a) * 0.07) + Vector3(0, 0, 0.01))
	MeshUtils.sweep_tube(h, collar, 0.004, 0.004, gold)
	for k in range(1, collar.size() - 1):
		var n := (collar[k] - Vector3(0, 0.6, 0)).normalized()
		TreasuryKit.gem(it, "diamond", "round", collar[k] + Vector3(0, 0.004, 0), (n + UP).normalized(), Vector3.RIGHT, 0.0028)
	var grains := []
	var ears := [[0.06, 0.5, -2.5], [0.07, 0.48, -2.3], [0.08, 0.46, -2.0], [0.09, 0.44, -1.75], [0.1, 0.43, -1.55], [0.11, 0.44, -1.35], [0.12, 0.5, -2.8]]
	var root := Vector2(0.09, 0.56)
	for e in ears:
		var ang: float = e[2]
		var dirv := Vector2(cos(ang), sin(ang))
		var L := 0.2
		var stem := PackedVector3Array()
		for i in range(12):
			var t := float(i) / 11.0
			var q := root + dirv * L * t
			var r: Array = at.call(q.x, q.y)
			stem.append((r[0] as Vector3) + (r[1] as Vector3) * 0.008)
		MeshUtils.sweep_tube(h, stem, 0.0018, 0.0012, gold)
		for j in range(12):
			var t := 0.45 + float(j) / 11.0 * 0.55
			for s in [-1.0, 1.0]:
				var q: Vector2 = root + dirv * L * t + Vector2(-dirv.y, dirv.x) * s * 0.008
				var r: Array = at.call(q.x, q.y)
				var gp: Vector3 = (r[0] as Vector3) + (r[1] as Vector3) * 0.01
				var ga := Vector3(dirv.x, dirv.y, 0).rotated(r[1], -s * 0.5)
				grains.append(Transform3D(TreasuryKit.frame(r[1], ga).scaled(Vector3.ONE * 0.022), gp - ga * 0.008))
				TreasuryKit.gem(it, "diamond", "round", gp + (r[1] as Vector3) * 0.0015 + ga * 0.003, r[1], ga, 0.0022)
				if j % 2 == 0:
					MeshUtils.sweep_tube(h, PackedVector3Array([gp + ga * 0.01, gp + ga * 0.03]), 0.0007, 0.0003, gold)
	h.add_child(GalleryDisplays._mm(_leaf(), grains, gold))
	h.add_child(GemFactory.make_set(it))

static func _peacock(h: Node3D) -> void:
	var b := AncientTreasures._board(h, Color(0.62, 0.58, 0.5), Vector2(0.6, 0.8), -0.6)
	var gold: Material = M("gold")
	var it := []
	var pearls := []
	var c := Vector2(0, 0.62)
	# collar rows of coloured rounds
	var cols := ["yellow_sapph", "aquamarine", "pink_sapph", "yellow_sapph", "blue_sapph_pale", "pink_spinel"]
	for row in range(4):
		var rr := 0.1 + float(row) * 0.03
		var n := 16 + row * 4
		for i in range(n):
			var a := lerpf(PI * 1.12, PI * 1.88, float(i) / float(n - 1))
			var p := c + Vector2(cos(a) * rr * 1.35, sin(a) * rr * 1.0 + 0.08)
			TreasuryKit.gem(it, cols[row % cols.size()], "round", Vector3(p.x, p.y, 0.01), Vector3.BACK, Vector3.RIGHT, 0.0075)
	for s in [-1.0, 1.0]:
		var pc := Vector2(s * 0.07, 0.5)
		TreasuryKit.gem(it, "sapphire", "pear", Vector3(pc.x, pc.y + 0.03, 0.012), Vector3.BACK, Vector3(-s * 0.3, 1, 0).normalized(), 0.022)
		TreasuryKit.gem(it, "tsavorite", "round", Vector3(pc.x - s * 0.01, pc.y + 0.065, 0.012), Vector3.BACK, Vector3.RIGHT, 0.008)
		for f in range(5):
			var ang := lerpf(0.1, 1.2, float(f) / 4.0)
			for j in range(4):
				var p := pc + Vector2(s * cos(ang), -sin(ang) * 0.4 + 0.2) * (0.03 + float(j) * 0.02)
				var stn: String = ["hot_pink_sapph", "tsavorite", "yellow_sapph", "sapphire"][j]
				TreasuryKit.gem(it, stn, "pear" if j == 3 else "round", Vector3(p.x, p.y, 0.012), Vector3.BACK, Vector3(s * cos(ang), 0.3, 0).normalized(), 0.008)
	TreasuryKit.gem(it, "watermelon", "emerald", Vector3(0, 0.45, 0.014), Vector3.BACK, Vector3.UP, 0.026)
	TreasuryKit.halo(it, Vector3(0, 0.45, 0.01), Vector3.RIGHT, Vector3.UP, 0.034, 0.0035, "diamond", "round", 22, 1.25)
	for k in range(11):
		var x := lerpf(-0.14, 0.14, float(k) / 10.0)
		TreasuryKit.ball(pearls, Vector3(x, 0.385 - 0.04 * (1.0 - pow(x / 0.14, 2.0)), 0.012), 0.011)
	var dc := Vector3(0, 0.24, 0.016)
	TreasuryKit.gem(it, "bicolor_tanz", "pear", dc, Vector3.BACK, Vector3.DOWN, 0.048)
	TreasuryKit.halo(it, dc - Vector3(0, 0, 0.005), Vector3.RIGHT, Vector3.UP, 0.052, 0.0035, "diamond", "round", 30, 1.0)
	for k in range(7):
		var x := lerpf(-0.06, 0.06, float(k) / 6.0)
		TreasuryKit.gem(it, ["pink_spinel", "heliodor", "tsavorite", "blue_sapph_pale", "pink_spinel", "aquamarine", "rubellite"][k], "briolette",
			Vector3(x, 0.165 - 0.02 * (1.0 - absf(x) / 0.06), 0.012), Vector3.DOWN, Vector3.BACK, 0.009)
		TreasuryKit.ball(pearls, Vector3(x, 0.19, 0.012), 0.008)
	b.add_child(TreasuryKit.balls(pearls, M("pearl")))
	b.add_child(GemFactory.make_set(it))

static func _aqua_pendant(h: Node3D) -> void:
	var b := AncientTreasures._board(h, Color(0.01, 0.01, 0.012), Vector2(0.5, 0.8), -0.45)
	var plat: Material = M("platinum")
	var it := []
	var c := Vector3(0, 0.3, 0.06)
	TreasuryKit.gem(it, "aquamarine_big", "pear", c, Vector3.BACK, Vector3.DOWN, 0.14)
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var stack := [[Vector2(0.0, 0.44), Vector2(0.15, -1.0).normalized(), 0.09, 0], [Vector2(-0.05, 0.2), Vector2(0.3, 1.0).normalized(), 0.08, 0],
		[Vector2(0.06, 0.25), Vector2(-0.2, -1.0).normalized(), 0.07, 0]]
	while not stack.is_empty():
		var e: Array = stack.pop_back()
		var o: Vector2 = e[0]
		var dv: Vector2 = e[1]
		var L: float = e[2]
		var depth: int = e[3]
		var end := o + dv * L
		var steps := int(L / 0.007)
		for i in range(steps):
			var q := o.lerp(end, float(i) / float(steps))
			var dx := (q.x) / 0.1
			var dy := (q.y - 0.27) / 0.16
			var dome := 1.0 - clampf(dx * dx + dy * dy, 0.0, 1.0)
			var z := 0.06 + 0.04 * sqrt(dome) + 0.004
			TreasuryKit.gem(it, "diamond", "round", Vector3(q.x, q.y, z), Vector3(dx * 0.4, dy * 0.3, 1).normalized(), Vector3.RIGHT, 0.0032)
		if depth < 3:
			for k in range(2):
				var nd := dv.rotated(rng.randf_range(0.5, 1.1) * (1.0 if k == 0 else -1.0))
				stack.append([end, nd, L * 0.6, depth + 1])
	# snowflake bow and grey pearl
	var bc := Vector3(0, 0.5, 0.015)
	for k in range(6):
		var a := float(k) / 6.0 * TAU + PI / 6.0
		var dv := Vector3(cos(a), sin(a), 0)
		for i in range(1, 7):
			TreasuryKit.gem(it, "diamond", "round", bc + dv * float(i) * 0.0085, Vector3.BACK, dv, 0.0034)
		for s in [-1.0, 1.0]:
			var bd := dv.rotated(Vector3.BACK, s * 0.8)
			for i in range(1, 4):
				TreasuryKit.gem(it, "diamond", "round", bc + dv * 0.035 + bd * float(i) * 0.008, Vector3.BACK, bd, 0.003)
	for k in range(3):
		TreasuryKit.gem(it, "diamond", "baguette", bc + Vector3((float(k) - 1.0) * 0.014, 0.0, 0.003), Vector3.BACK, Vector3.UP, 0.009)
	TreasuryKit.gem(it, "diamond", "round", bc + Vector3(0, -0.022, 0.003), Vector3.BACK, Vector3.RIGHT, 0.007)
	var bk := MeshUtils.make_rounded_box(Vector3(0.1, 0.09, 0.006), 0.004, M("dark_plat"))
	bk.position = bc - Vector3(0, 0, 0.006)
	b.add_child(bk)
	var pr := []
	TreasuryKit.ball(pr, bc + Vector3(0, 0.06, 0.004), 0.014)
	b.add_child(TreasuryKit.balls(pr, M("grey_pearl")))
	b.add_child(GemFactory.make_set(it))
	var _p := plat

# ── rings, brooch, bracelet ─────────────────────────────────────────────────
static func _sapphire_rings(h: Node3D) -> void:
	var stand := MeshUtils.make_cylinder(0.042, 0.042, 0.34, M("white_foam"), 32)
	stand.position.y = 0.17
	h.add_child(stand)
	var plat: Material = M("platinum")
	var it := []
	var prongs := []
	var R := 0.045
	var band := MeshUtils.make_ring(R, R + 0.008, 0.022, plat, 64)
	band.position.y = 0.09
	h.add_child(band)
	for k in range(9):
		var a := lerpf(-0.9, 0.9, float(k) / 8.0)
		var dd := TreasuryKit.d(a)
		var st: String = ["blue_sapph_pale", "cornflower", "sapphire", "cornflower", "blue_sapph_pale", "cornflower", "sapphire", "cornflower", "blue_sapph_pale"][k]
		TreasuryKit.gem(it, st, "round", dd * (R + 0.01) + Vector3(0, 0.09, 0), dd, UP, 0.0085)
		for s in [-1.0, 1.0]:
			TreasuryKit.ball(prongs, TreasuryKit.d(a + 0.105) * (R + 0.011) + Vector3(0, 0.09 + s * 0.009, 0), 0.0025)
	var eng := ShopStones.material("gold_glyph")
	var shank := MeshUtils.make_ring(R, R + 0.007, 0.018, plat, 64)
	shank.position.y = 0.16
	shank.rotation.z = 0.12
	h.add_child(shank)
	var top := PackedVector3Array()
	var low := PackedVector3Array()
	for k in range(25):
		var a := lerpf(-1.2, 1.2, float(k) / 24.0)
		top.append(TreasuryKit.d(a) * (R + 0.005) + Vector3(0, 0.17 + 0.03 * cos(a * 1.3), 0))
		low.append(TreasuryKit.d(a) * (R + 0.005) + Vector3(0, 0.15 - 0.025 * cos(a * 1.3), 0))
	MeshUtils.sweep_tube(h, top, 0.007, 0.007, plat)
	MeshUtils.sweep_tube(h, low, 0.006, 0.006, plat)
	for k in range(4, 21, 3):
		var a := lerpf(-1.2, 1.2, float(k) / 24.0)
		TreasuryKit.gem(it, "diamond", "round", low[k] + TreasuryKit.d(a) * 0.006, TreasuryKit.d(a), UP, 0.006)
	TreasuryKit.gem(it, "cornflower", "round", top[3] + TreasuryKit.d(-0.95) * 0.007, TreasuryKit.d(-0.95), UP, 0.009)
	TreasuryKit.gem(it, "blue_sapph_pale", "oval", low[22] + TreasuryKit.d(1.0) * 0.007, TreasuryKit.d(1.0), UP, 0.008)
	var hc := TreasuryKit.d(0.0) * (R + 0.03) + Vector3(0, 0.2, 0)
	TreasuryKit.gem(it, "sapphire", "oval", hc, Vector3.BACK, UP, 0.034)
	for k in range(4):
		var a := float(k) / 4.0 * TAU + PI * 0.25
		var pp := hc + Vector3(cos(a) * 0.022, sin(a) * 0.03, 0.006)
		MeshUtils.sweep_tube(h, PackedVector3Array([pp - Vector3(0, 0, 0.02), pp]), 0.0028, 0.0024, plat)
	var basket := MeshUtils.make_ring(0.012, 0.016, 0.02, plat, 24)
	basket.rotation.x = PI * 0.5
	basket.position = hc - Vector3(0, 0, 0.02)
	h.add_child(basket)
	h.add_child(TreasuryKit.balls(prongs, plat))
	h.add_child(GemFactory.make_set(it))
	var _e := eng

static func _jade_ring(h: Node3D) -> void:
	var jade := ShopStones.material("nephrite")
	var root := Node3D.new()
	root.position.y = 0.13
	root.rotation.x = PI * 0.5
	h.add_child(root)
	var ring := TreasuryKit.lathe([Vector2(0.075, 0.03), Vector2(0.098, 0.033), Vector2(0.11, 0.0), Vector2(0.098, -0.033), Vector2(0.075, -0.03), Vector2(0.072, 0.0), Vector2(0.075, 0.03)], jade, 64,
		func(th: float, v: float) -> float: return 1.0 + 0.22 * pow(maxf(0.0, sin(th)), 3.0) * (1.0 if v < 0.55 else 0.0))
	root.add_child(ring)
	var inner := MeshUtils.make_ring(0.068, 0.073, 0.05, M("gold"), 48)
	root.add_child(inner)
	var it := []
	var prongs := []
	for k in range(7):
		var a := lerpf(0.75, 2.4, float(k) / 6.0)
		var r := 0.11 * (1.0 + 0.22 * pow(sin(a), 3.0)) + 0.004
		var p := Vector3(cos(a) * r, 0.0, sin(a) * r)
		var n := Vector3(cos(a), 0, sin(a))
		var sz := 0.03 if k == 3 else (0.022 if absf(k - 3) == 1 else 0.016)
		TreasuryKit.gem(it, "amethyst_deep", "cushion", p, n, UP, sz)
		for s in [-1.0, 1.0]:
			TreasuryKit.ball(prongs, p + Vector3(-sin(a), 0, cos(a)) * sz * 0.9 + UP * s * sz * 0.85, 0.004)
	TreasuryKit.gem(it, "lavender_spinel", "round", Vector3(cos(1.0) * 0.14, 0.03, sin(1.0) * 0.14), Vector3(cos(1.0), 0, sin(1.0)), UP, 0.004)
	root.add_child(TreasuryKit.balls(prongs, M("platinum")))
	root.add_child(GemFactory.make_set(it))

static func _brooch(h: Node3D) -> void:
	var gold: Material = M("gold")
	var root := Node3D.new()
	root.position = Vector3(0, 0.18, 0)
	root.rotation.x = -0.35
	h.add_child(root)
	var st := MeshUtils.make_rounded_box(Vector3(0.12, 0.18, 0.04), 0.01, M("black_velvet"))
	st.position = Vector3(0, -0.09, -0.04)
	st.rotation.x = 0.35
	h.add_child(st)
	var it := []
	var sp := []
	TreasuryKit.gem(it, "cab_tanzanite", "cabochon", Vector3(0, 0, 0.0), Vector3.BACK, Vector3.RIGHT, 0.1)
	var rim := MeshUtils.make_ring(0.098, 0.106, 0.02, gold, 64)
	rim.rotation.x = PI * 0.5
	rim.scale = Vector3(1.0, 1.0, 0.76)
	root.add_child(rim)
	for k in range(9):
		var x := lerpf(-0.08, 0.08, float(k) / 8.0)
		var hgt := 0.04 + 0.07 * exp(-pow(x / 0.04, 2.0)) + 0.015 * float(k % 2)
		var y0 := 0.06 - 0.12 * pow(x / 0.1, 2.0)
		var tower := MeshUtils.make_rounded_box(Vector3(0.014, hgt, 0.012), 0.002, gold)
		tower.position = Vector3(x, y0 + hgt * 0.5, 0.0)
		root.add_child(tower)
		var cone := MeshUtils.make_cylinder(0.0, 0.009, 0.022, gold, 8)
		cone.position = Vector3(x, y0 + hgt + 0.011, 0)
		root.add_child(cone)
		TreasuryKit.gem(it, "diamond" if k % 2 == 0 else "sapphire", "trillion" if k % 2 == 0 else "round", Vector3(x, y0 + hgt * 0.7, 0.008), Vector3.BACK, Vector3.UP, 0.006)
		TreasuryKit.ball(sp, Vector3(x, y0 + hgt + 0.024, 0), 0.003)
		for w in range(int(hgt / 0.018)):
			var win := MeshUtils.make_rounded_box(Vector3(0.006, 0.01, 0.002), 0.001, M("dark_wood"))
			win.position = Vector3(x, y0 + 0.01 + float(w) * 0.018, 0.0065)
			root.add_child(win)
	TreasuryKit.gem(it, "sapphire", "round", Vector3(0, 0.19, 0.004), Vector3.BACK, Vector3.UP, 0.007)
	root.add_child(TreasuryKit.balls(sp, gold))
	root.add_child(GemFactory.make_set(it))

static func _byz(h: Node3D) -> void:
	var gold: Material = M("gold")
	var root := Node3D.new()
	root.position.y = 0.0
	h.add_child(root)
	var R := 0.12
	var band := MeshUtils.make_revolved([Vector2(R - 0.006, 0.0), Vector2(R, 0.0), Vector2(R, 0.09), Vector2(R - 0.006, 0.09), Vector2(R - 0.006, 0.0)], ShopStones.material("filigree"), 96)
	root.add_child(band)
	var it := []
	var pearls := []
	var claws := []
	for yy in [0.012, 0.078]:
		for k in range(40):
			var a := float(k) / 40.0 * TAU
			if absf(wrapf(a, -PI, PI)) < 0.45:
				continue
			TreasuryKit.ball(pearls, TreasuryKit.d(a) * (R + 0.012) + Vector3(0, yy, 0), 0.0115)
	for yy in [0.0, 0.09]:
		var rr := MeshUtils.make_ring(R - 0.002, R + 0.006, 0.006, gold, 64)
		rr.position.y = yy
		root.add_child(rr)
	var dc := Vector3(0, 0.07, R + 0.012)
	var disc := MeshUtils.make_cylinder(0.075, 0.075, 0.006, gold, 48)
	disc.rotation.x = PI * 0.5
	disc.position = dc
	root.add_child(disc)
	TreasuryKit.gem(it, "cab_pale_sapph", "cabochon", dc + Vector3(0, 0, 0.004), Vector3.BACK, Vector3.RIGHT, 0.034)
	for k in range(10):
		var a := float(k) / 10.0 * TAU
		var pp := dc + Vector3(cos(a) * 0.055, sin(a) * 0.055, 0.012)
		TreasuryKit.ball(pearls, pp, 0.0115)
		MeshUtils.sweep_tube(root, PackedVector3Array([dc + Vector3(cos(a) * 0.02, sin(a) * 0.02, 0.004), pp]), 0.002, 0.002, gold)
		TreasuryKit.ball(claws, dc + Vector3(cos(a + 0.3) * 0.036, sin(a + 0.3) * 0.032, 0.008), 0.004)
	for s in [-1.0, 1.0]:
		var a: float = s * 0.8
		var p := TreasuryKit.d(a) * (R + 0.005) + Vector3(0, 0.045, 0)
		TreasuryKit.gem(it, "cab_pink", "cabochon", p, TreasuryKit.d(a), UP, 0.018)
		var a2: float = s * 1.35
		TreasuryKit.gem(it, "emerald_cloudy", "table", TreasuryKit.d(a2) * (R + 0.003) + Vector3(0, 0.045, 0), TreasuryKit.d(a2), UP, 0.016)
	var pin := MeshUtils.make_cylinder(0.003, 0.003, 0.12, gold, 8)
	pin.position = TreasuryKit.d(-0.5) * (R + 0.01) + Vector3(0, 0.05, 0)
	root.add_child(pin)
	root.add_child(TreasuryKit.balls(pearls, M("pearl")))
	root.add_child(TreasuryKit.balls(claws, gold))
	root.add_child(GemFactory.make_set(it))

# ── coin hoard ──────────────────────────────────────────────────────────────
static func _coins(h: Node3D) -> void:
	var wood: Material = M("mahogany")
	var felt: Material = M("red_felt")
	var W := 0.5
	var D := 0.34
	var Hh := 0.07
	var bottom := MeshUtils.make_rounded_box(Vector3(W, 0.015, D), 0.004, wood)
	bottom.position.y = 0.0075
	h.add_child(bottom)
	for w in [[Vector3(W, Hh, 0.015), Vector3(0, Hh * 0.5, D * 0.5)], [Vector3(W, Hh, 0.015), Vector3(0, Hh * 0.5, -D * 0.5)],
			[Vector3(0.015, Hh, D), Vector3(W * 0.5, Hh * 0.5, 0)], [Vector3(0.015, Hh, D), Vector3(-W * 0.5, Hh * 0.5, 0)]]:
		var wall := MeshUtils.make_rounded_box(w[0], 0.003, wood)
		wall.position = w[1]
		h.add_child(wall)
	var fl := MeshUtils.make_rounded_box(Vector3(W - 0.03, 0.006, D - 0.03), 0.002, felt)
	fl.position.y = 0.018
	h.add_child(fl)
	var lid := Node3D.new()
	lid.position = Vector3(0, Hh, -D * 0.5)
	lid.rotation.x = -1.85
	h.add_child(lid)
	var lw := MeshUtils.make_rounded_box(Vector3(W, 0.03, D), 0.004, wood)
	lw.position = Vector3(0, 0.015, D * 0.5)
	lid.add_child(lw)
	var lf := MeshUtils.make_rounded_box(Vector3(W - 0.03, 0.004, D - 0.03), 0.002, felt)
	lf.position = Vector3(0, -0.002, D * 0.5)
	lid.add_child(lf)
	for s in [-1.0, 1.0]:
		var hinge := MeshUtils.make_rounded_box(Vector3(0.03, 0.02, 0.004), 0.001, M("brass"))
		hinge.position = Vector3(s * W * 0.35, Hh, -D * 0.5 - 0.009)
		h.add_child(hinge)
	var rng := RandomNumberGenerator.new()
	rng.seed = 260
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.0
	cyl.bottom_radius = 1.0
	cyl.height = 0.12
	cyl.radial_segments = 28
	var placed := []
	var xfs := []
	for i in range(120):
		var p := Vector2(rng.randf_range(-0.17, 0.17), rng.randf_range(-0.12, 0.12))
		p *= Vector2(1.0, 1.0) * (0.4 + 0.6 * sqrt(rng.randf()))
		var r := rng.randf_range(0.0105, 0.0125)
		var yb := 0.021
		for q in placed:
			if p.distance_to(q[0]) < r + float(q[1]) - 0.002:
				yb = maxf(yb, float(q[2]) + 0.0028)
		var tilt := minf(0.25, (yb - 0.021) * 6.0)
		placed.append([p, r, yb])
		var bs := Basis(Vector3.UP, rng.randf() * TAU) * Basis(Vector3.RIGHT, rng.randf_range(-tilt, tilt))
		xfs.append(Transform3D(bs * Basis.from_scale(Vector3(r, 0.022, r)), Vector3(p.x, yb + 0.0015, p.y)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = cyl
	mm.instance_count = xfs.size()
	for i in range(xfs.size()):
		mm.set_instance_transform(i, xfs[i])
		mm.set_instance_custom_data(i, Color(rng.randf(), 0, 0, 0))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = ShopStones.material("coin_silver")
	h.add_child(mmi)

# ── Lord of Sipan regalia ───────────────────────────────────────────────────
static func _sipan(h: Node3D) -> void:
	var gold: Material = M("gold")
	var silver: Material = M("platinum")
	var turq := ShopStones.material("turq_mosaic")
	var back := MeshUtils.make_rounded_box(Vector3(0.5, 0.42, 0.2), 0.01, GalleryDisplays._mats()["black"])
	back.position = Vector3(0, 0.21, -0.12)
	h.add_child(back)
	var root := Node3D.new()
	root.position = Vector3(0, 0.0, -0.02)
	h.add_child(root)
	# mask face
	var face := _sph(root, gold, Vector3(0, 0.58, 0.0), Vector3(0.075, 0.1, 0.06))
	face.name = "face"
	_sph(root, gold, Vector3(0, 0.57, 0.056), Vector3(0.014, 0.03, 0.016))
	_sph(root, gold, Vector3(0, 0.52, 0.05), Vector3(0.03, 0.007, 0.01))
	for s in [-1.0, 1.0]:
		_sph(root, silver, Vector3(s * 0.03, 0.6, 0.05), Vector3(0.016, 0.008, 0.008))
		_sph(root, M("black_plastic"), Vector3(s * 0.03, 0.6, 0.056), Vector3(0.006, 0.006, 0.004))
	# headband with mosaic and the figure, crescent headdress
	var hb := MeshUtils.make_rounded_box(Vector3(0.18, 0.04, 0.03), 0.006, gold)
	hb.position = Vector3(0, 0.67, 0.02)
	root.add_child(hb)
	var cap := _sph(root, turq, Vector3(0, 0.71, -0.0), Vector3(0.08, 0.06, 0.05))
	cap.name = "cap"
	_sph(root, gold, Vector3(0, 0.74, 0.04), Vector3(0.014, 0.03, 0.012))
	var cres := PackedVector2Array()
	for k in range(25):
		var a := lerpf(0.05, PI - 0.05, float(k) / 24.0)
		cres.append(Vector2(cos(a) * 0.26, sin(a) * 0.17))
	for k in range(25):
		var a := lerpf(PI - 0.05, 0.05, float(k) / 24.0)
		cres.append(Vector2(cos(a) * 0.17, sin(a) * 0.1 + 0.02))
	TreasuryKit.plate(root, cres, 0.006, gold, Vector3(0, 0.74, -0.03), Vector3.RIGHT, UP)
	for s in [-1.0, 1.0]:
		var spool := MeshUtils.make_cylinder(0.06, 0.06, 0.012, turq, 40)
		spool.rotation.x = PI * 0.5
		spool.position = Vector3(s * 0.15, 0.56, 0.0)
		root.add_child(spool)
		var srim := MeshUtils.make_ring(0.058, 0.064, 0.016, gold, 40)
		srim.rotation.x = PI * 0.5
		srim.position = spool.position
		root.add_child(srim)
		_sph(root, gold, spool.position + Vector3(0, 0, 0.012), Vector3(0.012, 0.022, 0.006))
	# peanut necklace
	var pn := []
	var ps := []
	for k in range(15):
		var t := lerpf(-1.0, 1.0, float(k) / 14.0)
		var p := Vector3(t * 0.17, 0.44 - 0.1 * (1.0 - t * t), 0.04)
		var arr: Array = pn if t < 0.0 else ps
		arr.append(Transform3D(Basis().scaled(Vector3(0.018, 0.024, 0.016)), p))
		arr.append(Transform3D(Basis().scaled(Vector3(0.016, 0.02, 0.015)), p + Vector3(0, -0.03, 0.005)))
	root.add_child(TreasuryKit.balls(pn, gold))
	root.add_child(TreasuryKit.balls(ps, silver))
	# mosaic pectoral with gold disc fringe
	var pect := PackedVector2Array()
	for k in range(21):
		var a := lerpf(PI, TAU, float(k) / 20.0)
		pect.append(Vector2(cos(a) * 0.22, sin(a) * 0.13))
	for k in range(21):
		var a := lerpf(TAU, PI, float(k) / 20.0)
		pect.append(Vector2(cos(a) * 0.1, sin(a) * 0.04))
	TreasuryKit.plate(root, pect, 0.012, turq, Vector3(0, 0.24, 0.06), Vector3.RIGHT, UP)
	var discs := []
	for k in range(17):
		var a := lerpf(PI * 1.04, PI * 1.96, float(k) / 16.0)
		discs.append(Transform3D(Basis(Vector3.RIGHT, PI * 0.5).scaled(Vector3(0.018, 0.003, 0.018)), Vector3(cos(a) * 0.235, 0.24 + sin(a) * 0.145, 0.065)))
	root.add_child(GalleryDisplays._mm(MeshUtils.make_cylinder(1.0, 1.0, 1.0, null, 20).mesh, discs, gold))
	_sph(root, gold, Vector3(0, 0.17, 0.07), Vector3(0.02, 0.04, 0.012))
	# cuffs, sceptre and rattle
	for s in [-1.0, 1.0]:
		var cuff := MeshUtils.make_revolved([Vector2(0.05, 0.0), Vector2(0.056, 0.0), Vector2(0.056, 0.09), Vector2(0.05, 0.09), Vector2(0.05, 0.0)], gold, 48)
		cuff.position = Vector3(s * 0.48, 0.0, 0.05)
		root.add_child(cuff)
		for k in range(3):
			var a := float(k - 1) * 0.6
			_sph(root, turq, cuff.position + TreasuryKit.d(a) * 0.058 + Vector3(0, 0.045, 0), Vector3(0.012, 0.016, 0.006))
		var tool := PackedVector2Array([Vector2(-0.015, 0.0), Vector2(0.015, 0.0), Vector2(0.015, 0.2), Vector2(0.06, 0.26), Vector2(0.06, 0.3), Vector2(-0.06, 0.3), Vector2(-0.06, 0.26), Vector2(-0.015, 0.2)])
		TreasuryKit.plate(root, tool, 0.006, gold, Vector3(s * 0.42, 0.1, -0.06), Vector3.RIGHT, UP)
	var stand := MeshUtils.make_rounded_box(Vector3(0.08, 0.1, 0.06), 0.004, GalleryDisplays._mats()["black"])
	stand.position = Vector3(0, 0.45, -0.02)
	root.add_child(stand)

static func _dendera(h: Node3D) -> void:
	var panel := AncientTreasures._extrude(PackedVector2Array([Vector2(-0.45, -0.55), Vector2(0.45, -0.55), Vector2(0.45, 0.55), Vector2(-0.45, 0.55)]), 0.08, ShopStones.material("dendera"))
	panel.position = Vector3(0, 0.56, 0)
	h.add_child(panel)

# ── mineral specimens ───────────────────────────────────────────────────────
static func _matrix(h: Node3D, mat: Material, scl: Vector3, pos: Vector3, v := 2) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = ShopStones.tumbled_mesh(v)
	mi.material_override = mat
	mi.scale = scl
	mi.position = pos
	h.add_child(mi)
	return mi

static func _anglesite(h: Node3D) -> void:
	var galena := StandardMaterial3D.new()
	galena.albedo_color = Color(0.18, 0.18, 0.2)
	galena.metallic = 0.85
	galena.roughness = 0.3
	_matrix(h, galena, Vector3(0.16, 0.08, 0.11), Vector3(0, 0.06, 0), 4)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var cubes := []
	for k in range(40):
		var a := rng.randf() * TAU
		cubes.append(Transform3D(Basis.from_euler(Vector3(rng.randf(), rng.randf(), rng.randf())).scaled(Vector3.ONE * rng.randf_range(0.01, 0.025)),
			Vector3(cos(a) * rng.randf_range(0.0, 0.14), 0.09 + rng.randf_range(0.0, 0.03), sin(a) * rng.randf_range(0.0, 0.09))))
	h.add_child(GalleryDisplays._mm(BoxMesh.new(), cubes, galena))
	var amber := TreasuryKit.crystal(Color(1.0, 0.68, 0.18), 0.0, 0.25, 20.0)
	var prism := TreasuryKit.lathe([Vector2(0.0, 1.0), Vector2(0.3, 0.72), Vector2(0.34, 0.1), Vector2(0.3, -0.05), Vector2(0.0, -0.1)], amber, 4)
	for c in [[Vector3(-0.04, 0.1, 0.0), Vector3(0.0, 0.0, 0.35), 0.12], [Vector3(0.03, 0.11, 0.02), Vector3(0.1, 0.0, -0.2), 0.1], [Vector3(0.08, 0.1, -0.02), Vector3(0.0, 0.0, -0.6), 0.07], [Vector3(-0.1, 0.08, 0.04), Vector3(0.2, 0.0, 0.8), 0.07]]:
		var mi := MeshInstance3D.new()
		mi.mesh = prism.mesh
		mi.material_override = amber
		mi.position = c[0]
		mi.rotation = c[1]
		mi.scale = Vector3(0.6, 1.0, 1.0) * float(c[2])
		h.add_child(mi)

static func _pyromorphite(h: Node3D) -> void:
	var rock := StandardMaterial3D.new()
	rock.albedo_color = Color(0.22, 0.15, 0.08)
	rock.roughness = 0.9
	_matrix(h, rock, Vector3(0.22, 0.12, 0.13), Vector3(0, 0.1, 0), 1)
	var green := StandardMaterial3D.new()
	green.albedo_color = Color(0.34, 0.56, 0.03)
	green.roughness = 0.22
	green.subsurf_scatter_enabled = true
	green.subsurf_scatter_strength = 0.4
	green.rim_enabled = true
	green.rim = 0.2
	var barrel := TreasuryKit.lathe([Vector2(0.0, 1.0), Vector2(0.42, 0.98), Vector2(0.48, 0.8), Vector2(0.4, 0.0), Vector2(0.0, 0.0)], null, 6).mesh
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var xfs := []
	for k in range(1500):
		var u := rng.randf() * TAU
		var v := rng.randf_range(-0.2, 1.0)
		var n := Vector3(cos(u) * sqrt(1.0 - v * v), v, sin(u) * sqrt(1.0 - v * v))
		if n.z < -0.2 or rng.randf() < 0.15:
			continue
		var p := Vector3(n.x * 0.2, 0.1 + n.y * 0.11, n.z * 0.12)
		var d := (n + Vector3(rng.randf_range(-0.6, 0.6), rng.randf_range(-0.3, 0.6), rng.randf_range(-0.6, 0.6))).normalized()
		var s := rng.randf_range(0.009, 0.017)
		xfs.append(Transform3D(TreasuryKit.frame(d, Vector3.RIGHT) * Basis.from_scale(Vector3(s, s * rng.randf_range(2.0, 3.5), s)), p - d * s))
	h.add_child(GalleryDisplays._mm(barrel, xfs, green))

static func _am_flower(h: Node3D) -> void:
	var block := MeshUtils.make_rounded_box(Vector3(0.1, 0.05, 0.1), 0.004, TreasuryKit.crystal(Color(0.9, 0.95, 1.0), 0.0, 0.1))
	block.position.y = 0.025
	h.add_child(block)
	var am := TreasuryKit.crystal(Color(0.88, 0.70, 1.0), 0.0, 0.35, 20.0)
	var dark := TreasuryKit.crystal(Color(0.55, 0.42, 0.68), 0.0, 0.5, 20.0)
	var point := TreasuryKit.lathe([Vector2(0.0, 1.0), Vector2(0.22, 0.78), Vector2(0.22, 0.0), Vector2(0.0, -0.02)], null, 6).mesh
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var petals := []
	var stem := []
	for k in range(8):
		var y := 0.05 + float(k) * 0.025
		stem.append(Transform3D(TreasuryKit.frame(Vector3(rng.randf_range(-0.3, 0.3), 1, rng.randf_range(-0.3, 0.3)).normalized(), Vector3.RIGHT).scaled(Vector3.ONE * 0.05), Vector3(rng.randf_range(-0.01, 0.01), y, rng.randf_range(-0.01, 0.01))))
	var c := Vector3(0, 0.27, 0)
	for k in range(16):
		var a := float(k) / 16.0 * TAU
		var d := Vector3(cos(a), rng.randf_range(0.2, 1.1), sin(a) * 0.6 + 0.3).normalized()
		petals.append(Transform3D(TreasuryKit.frame(d, Vector3.RIGHT).scaled(Vector3.ONE * rng.randf_range(0.07, 0.1)), c))
	h.add_child(GalleryDisplays._mm(point, petals, am))
	h.add_child(GalleryDisplays._mm(point, stem, dark))
	var goe := StandardMaterial3D.new()
	goe.albedo_color = Color(0.18, 0.12, 0.06)
	goe.roughness = 0.7
	var balls := []
	for k in range(30):
		TreasuryKit.ball(balls, Vector3(-0.018 + rng.randf_range(-0.006, 0.006), 0.07 + rng.randf() * 0.12, rng.randf_range(-0.012, 0.012)), rng.randf_range(0.004, 0.007))
	h.add_child(TreasuryKit.balls(balls, goe))

# ── gem show booth ──────────────────────────────────────────────────────────
static func _booth(h: Node3D) -> void:
	var navy := MeshUtils.make_rounded_box(Vector3(1.9, 0.74, 0.8), 0.01, M("navy_cloth"))
	navy.position = Vector3(0, 0.37, 0.05)
	h.add_child(navy)
	var cloth := MeshUtils.make_rounded_box(Vector3(1.94, 0.02, 0.84), 0.004, M("white_cloth"))
	cloth.position = Vector3(0, 0.75, 0.05)
	h.add_child(cloth)
	var glass := TreasuryKit.crystal(Color(0.92, 0.96, 0.98), 0.0, 0.03)
	var shelves := [0.98, 1.3, 1.62]
	for y in shelves:
		var sh := MeshUtils.make_rounded_box(Vector3(1.6, 0.012, 0.38), 0.002, glass)
		sh.position = Vector3(0, y, -0.14)
		h.add_child(sh)
	for x in [-0.8, 0.0, 0.8]:
		for z in [-0.32, 0.04]:
			var post := MeshUtils.make_cylinder(0.006, 0.006, 0.9, M("steel"), 8)
			post.position = Vector3(x, 1.2, z)
			h.add_child(post)
	var rng := RandomNumberGenerator.new()
	rng.seed = 252
	var ids := ["quartz_cluster", "smoky_quartz", "quartz_cluster", "citrine_points", "quartz_cluster"]
	for si in range(2):
		for k in range(6):
			var spec := MineralLibrary.make("quartz_cluster", rng.randf_range(0.11, 0.18), rng.randi() % 50)
			spec.position = Vector3(-0.7 + float(k) * 0.28 + rng.randf_range(-0.03, 0.03), float(shelves[si]) + 0.006, -0.14 + rng.randf_range(-0.05, 0.05))
			spec.rotation.y = rng.randf() * TAU
			h.add_child(spec)
			Turntable.mark(spec, 0.35 + rng.randf() * 0.2)
	var balls := []
	for k in range(9):
		TreasuryKit.ball(balls, Vector3(-0.72 + float(k) * 0.18, float(shelves[2]) + 0.05, -0.14), 0.04)
	h.add_child(TreasuryKit.balls(balls, TreasuryKit.crystal(Color(0.97, 0.98, 1.0), 0.0, 0.0)))
	for k in range(4):
		var tray := MeshUtils.make_rounded_box(Vector3(0.4, 0.03, 0.28), 0.004, M("black_plastic"))
		tray.position = Vector3(-0.66 + float(k) * 0.44, 0.775, 0.24)
		h.add_child(tray)
		var pile := ShopStones.heap("selenite" if k == 2 else "rose_quartz" if k == 3 else "aquamarine", Vector2(0.36, 0.24), 40, Vector2(0.012, 0.02), 30 + k)
		pile.position = tray.position + Vector3(0, 0.015, 0)
		h.add_child(pile)
	var flags := MeshUtils.catenary(Vector3(-0.8, 1.55, 0.05), Vector3(0.8, 1.55, 0.05), 0.08, 16)
	MeshUtils.sweep_tube(h, flags, 0.002, 0.002, M("white_cloth"))
	var fc := [Color(0.15, 0.3, 0.8), Color(0.95, 0.95, 0.95), Color(0.85, 0.12, 0.1), Color(0.1, 0.6, 0.25), Color(0.95, 0.75, 0.1)]
	for k in range(1, flags.size() - 1):
		var fm := StandardMaterial3D.new()
		fm.albedo_color = fc[k % fc.size()]
		fm.roughness = 1.0
		var f := MeshUtils.make_rounded_box(Vector3(0.07, 0.09, 0.002), 0.0005, fm)
		f.position = flags[k] - Vector3(0, 0.05, 0)
		h.add_child(f)
	var sign_m := StandardMaterial3D.new()
	sign_m.albedo_color = Color(0.1, 0.2, 0.75)
	var sign := MeshUtils.make_rounded_box(Vector3(0.32, 0.22, 0.01), 0.003, sign_m)
	sign.position = Vector3(0, 1.85, -0.14)
	h.add_child(sign)
	var _i := ids
