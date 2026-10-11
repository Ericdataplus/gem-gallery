class_name RoyalTreasury

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# ROYAL TREASURY — crowns, regalia and Kunstkammer treasures, each modelled on
# a real piece (or the photo it came from): Imperial State Crown, St Edward's
# Crown, the Holy Roman imperial crown, tiaras, high-jewellery necklaces,
# carved rock crystal and lapis, the Standard of Ur and collector stones.
#
#   RoyalTreasury.build(gallery, start: Vector3) -> float (hall length)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

const UP := Vector3.UP

const PIECES := [
	["isc", "Imperial State Crown", "British Crown Jewels, made 1937 (replica, 1.5x)",
		"2,868 diamonds, 17 sapphires, 11 emeralds, 269 pearls and 4 rubies. Front: Cullinan II and the Black Prince's Ruby; top cross: St Edward's Sapphire.", Vector3(0.8, 1.0, 0.8)],
	["st_edward", "St Edward's Crown", "Made 1661 for Charles II (replica, 1.5x)",
		"Solid gold, 2.23 kg, set with 444 stones: tourmalines, topazes, amethysts, aquamarines and more. Used only at the moment of crowning.", Vector3(0.8, 1.0, 0.8)],
	["hre", "Imperial Crown of the Holy Roman Empire", "Late 10th - early 11th century (replica, 2x)",
		"Eight hinged gold plates with about 144 gems and 144 pearls; four enamel plates show biblical kings. Original: Imperial Treasury, Vienna.", Vector3(0.8, 0.95, 0.8)],
	["emerald_crown", "Emerald Crown", "Baroque-style concept piece",
		"Gold acanthus scrollwork, emerald rosettes and step-cut emeralds, on a green velvet cushion.", Vector3(0.9, 0.9, 0.9)],
	["pageant", "Jewelled Pageant Crown", "Modern stage tiara",
		"Gilded frame set with coloured crystals around a central blue oval.", Vector3(0.7, 1.0, 0.7)],
	["kokoshnik", "Sapphire Kokoshnik Tiara", "Cartier, 1909; later Queen Marie of Romania's (replica, 1.5x)",
		"Platinum and diamond scrollwork with cushion sapphires in double diamond halos.", Vector3(0.7, 1.0, 0.7)],
	["bulgari", "Multi-gem High Jewellery Necklace", "Modern Roman high jewellery",
		"Rose gold and diamond sprays carrying seven step-cut stones: spessartite, aquamarine, London blue topaz, rubellite, peridot, amethyst and prasiolite.", Vector3(0.9, 1.0, 0.8)],
	["mackay", "Mackay Emerald Necklace", "Cartier, 1931 (replica, 1.6x)",
		"A 167.97 ct Colombian emerald, one of the largest cut emeralds at the Smithsonian, on platinum, diamonds and calibre emeralds.", Vector3(0.8, 1.0, 0.8)],
	["amethyst_egg", "Amethyst Surprise Egg", "Faberge-style objet d'art",
		"Two carved amethyst shells open on gold hinges to show a carved amethyst dog on a pedestal.", Vector3(0.7, 1.0, 0.7)],
	["galley", "Rock Crystal Galley", "Milanese workshop style, c. 1580s (replica)",
		"A table vessel shaped like a ship: dragon prow, deckhouse and gold mounts, engraved all over with scrolls.", Vector3(1.0, 0.95, 0.7)],
	["lapis_urns", "Pair of Lapis Lazuli Vases", "Campana krater form, Neoclassical (replica)",
		"Afghan lapis with golden calcite and pyrite: gadrooned bowls, scroll handles and a frieze of dancing figures.", Vector3(1.4, 0.75, 0.7)],
	["lapis_ewer", "Lapis Lazuli Bowl with Gold Triton", "Milan, c. 1570, Miseroni style (replica)",
		"A shell-shaped lapis bowl; a gold triton blowing a conch forms the handle.", Vector3(0.8, 1.0, 0.7)],
	["crystal_ewer", "Jewelled Rock Crystal Ewer", "Mughal / Ottoman court style",
		"Engraved rock crystal mounted in gold and strapped with emeralds and rubies.", Vector3(0.8, 0.95, 0.7)],
	["ur", "Standard of Ur", "Sumer, c. 2600-2400 BC (replica, 2x)",
		"A wooden box inlaid with shell, red limestone and lapis lazuli in bitumen: War on one side, Peace on the other. Original: British Museum.", Vector3(1.4, 0.8, 0.7)],
	["rainbow_obsidian", "Rainbow Obsidian", "Polished freeform, Mexico",
		"Volcanic glass; layers of tiny aligned crystals split light into thin-film rainbow bands.", Vector3(0.7, 1.0, 0.7)],
	["galaxy", "Galaxy Quartz", "Emerald cut, shown 8x in tweezers",
		"Metallic flakes of hematite and mica inside quartz glitter pink, blue and gold as it turns.", Vector3(0.7, 1.05, 0.7)],
	["kite_star", "Kite-cut Star", "Tourmaline and heliodor, 6x",
		"Six kite cuts laid point to centre into a star on a foam pad.", Vector3(0.7, 1.05, 0.7)],
	["mint_card", "Mint and Teal Tourmaline Parcel", "Gem card, 6x",
		"Pear and oval cuts from mint to deep teal, with a steel-grey spinel.", Vector3(0.7, 1.05, 0.7)],
	["hex_boxes", "Hexagon Cut Collection", "Elongated hexagon step cuts, 5x",
		"Two collector boxes sorted by colour, a neon apatite and a Miyakejima glass made with volcanic ash.", Vector3(1.2, 0.95, 0.8)],
]

## Pieces that turn on a turntable (free-standing objects; boards and boxes stay still).
const SPIN := ["isc", "st_edward", "hre", "emerald_crown", "pageant", "kokoshnik", "amethyst_egg", "galley",
	"lapis_ewer", "crystal_ewer", "rainbow_obsidian", "galaxy"]

static func build(g: Node3D, start: Vector3) -> float:
	TreasuryKit.register()
	return TreasuryKit.hall(g, start, PIECES, "The Royal Treasury  -  crowns, regalia and treasures", func(k: String, hh: Node3D) -> void: _make(k, hh), Color(0.22, 0.03, 0.06), SPIN)

static func _make(key: String, h: Node3D) -> void:
	match key:
		"isc": _isc(h)
		"st_edward": _st_edward(h)
		"hre": _hre(h)
		"emerald_crown": _emerald_crown(h)
		"pageant": _pageant(h)
		"kokoshnik": _kokoshnik(h)
		"bulgari": _bulgari(h)
		"mackay": _mackay(h)
		"amethyst_egg": _egg(h)
		"galley": _galley(h)
		"lapis_urns": _urns(h)
		"lapis_ewer": _lapis_ewer(h)
		"crystal_ewer": _crystal_ewer(h)
		"ur": _ur(h)
		"rainbow_obsidian": _obsidian(h)
		"galaxy": _galaxy(h)
		"kite_star": _kite_star(h)
		"mint_card": _mint_card(h)
		"hex_boxes": _hex_boxes(h)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# CROWN PARTS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
const PATTEE := [Vector2(-0.13, 0.63), Vector2(-0.28, 1.0), Vector2(0.28, 1.0), Vector2(0.13, 0.63), Vector2(0.5, 0.78),
	Vector2(0.5, 0.22), Vector2(0.13, 0.37), Vector2(0.28, 0.0), Vector2(-0.28, 0.0), Vector2(-0.13, 0.37), Vector2(-0.5, 0.22), Vector2(-0.5, 0.78)]
const FLEUR := [Vector2(0.0, 1.0), Vector2(0.107, 0.8), Vector2(0.133, 0.6), Vector2(0.08, 0.427), Vector2(0.267, 0.533), Vector2(0.4, 0.733),
	Vector2(0.453, 0.6), Vector2(0.373, 0.373), Vector2(0.213, 0.24), Vector2(0.187, 0.133), Vector2(0.267, 0.0), Vector2(-0.267, 0.0),
	Vector2(-0.187, 0.133), Vector2(-0.213, 0.24), Vector2(-0.373, 0.373), Vector2(-0.453, 0.6), Vector2(-0.4, 0.733), Vector2(-0.267, 0.533),
	Vector2(-0.08, 0.427), Vector2(-0.133, 0.6), Vector2(-0.107, 0.8)]

static func _ermine(root: Node3D, R: float, rr := 0.032) -> void:
	var prof := []
	for k in range(25):
		var a := -PI * 0.5 + float(k) / 24.0 * TAU
		prof.append(Vector2(R + 0.012 + cos(a) * rr, rr + sin(a) * rr * 0.95))
	root.add_child(MeshUtils.make_revolved(prof, ShopStones.material("ermine"), 96))

## Velvet cap puffing out between the arches (bulge at 45 degrees).
static func _cap(root: Node3D, prof: Array, bulge: float, mat: Material, lobes := 4) -> void:
	root.add_child(TreasuryKit.lathe(prof, mat, 96, func(th: float, v: float) -> float:
		return 1.0 + bulge * absf(sin(float(lobes) * 0.5 * th)) * sin(clampf(v, 0.0, 1.0) * PI)))

## Half-arch from the band up to the crown's centre, along direction a.
static func _arch(a: float, ctrl_ry: Array, n := 32) -> PackedVector3Array:
	var dd := TreasuryKit.d(a)
	var c := []
	for q in ctrl_ry:
		c.append(dd * float(q.x) + Vector3(0, q.y, 0))
	return TreasuryKit.spline(c, n)

static func _arch_normal(pts: PackedVector3Array, i: int, ax: Vector3, center: Vector3) -> Vector3:
	var t := (pts[mini(i + 1, pts.size() - 1)] - pts[maxi(i - 1, 0)]).normalized()
	var n := t.cross(ax).normalized()
	if n.dot(pts[i] - center) < 0.0:
		n = -n
	return n

static func _fib_sphere(items: Array, c: Vector3, r: float, count: int, size: float, stone := "diamond", cut := "round", skip_dir := Vector3.ZERO) -> void:
	for i in range(count):
		var y := 1.0 - 2.0 * (float(i) + 0.5) / float(count)
		var rr := sqrt(maxf(0.0, 1.0 - y * y))
		var ph := float(i) * 2.39996
		var n := Vector3(cos(ph) * rr, y, sin(ph) * rr)
		if skip_dir != Vector3.ZERO and n.dot(skip_dir) > 0.97:
			continue
		TreasuryKit.gem(items, stone, cut, c + n * r, n, Vector3.UP.cross(n) if absf(n.y) < 0.95 else Vector3.RIGHT, size)

# ── Imperial State Crown ────────────────────────────────────────────────────
static func _isc(h: Node3D) -> void:
	var root := Node3D.new()
	h.add_child(root)
	var met: Material = TreasuryKit.mats()["platinum"]
	var items := []
	var pearls := []
	var R := 0.13
	_ermine(root, R)
	root.add_child(MeshUtils.make_revolved([Vector2(R - 0.006, 0.05), Vector2(R, 0.05), Vector2(R, 0.145), Vector2(R - 0.006, 0.145), Vector2(R - 0.006, 0.05)], met, 96))
	_cap(root, [Vector2(0.0, 0.318), Vector2(0.05, 0.326), Vector2(0.095, 0.315), Vector2(0.128, 0.285), Vector2(0.142, 0.235), Vector2(0.138, 0.185), Vector2(0.126, 0.14)],
		0.07, TreasuryKit.mats()["purple"])
	for yy in [0.056, 0.142]:
		var n := int(TAU * R / 0.0105)
		for k in range(n):
			TreasuryKit.ball(pearls, TreasuryKit.d(float(k) / float(n) * TAU) * (R + 0.004) + Vector3(0, yy, 0), 0.005)
	var mains := []
	for k in range(12):
		var a := float(k) / 12.0 * TAU
		var dd := TreasuryKit.d(a)
		var ax := UP.cross(dd)
		var p := dd * (R + 0.002) + Vector3(0, 0.099, 0)
		var st := "sapphire"
		var cut := "cushion"
		var sz := 0.013
		if k == 0:
			st = "cullinan_ii"
			sz = 0.026
		elif k == 6:
			cut = "oval"
			sz = 0.022
		elif k % 2 == 1:
			st = "emerald"
			cut = "emerald"
			sz = 0.014
		TreasuryKit.gem(items, st, cut, p, dd, ax, sz)
		TreasuryKit.halo(items, p + dd * 0.001, ax, UP, sz * 1.18 + 0.004, 0.0032 if k != 0 else 0.0038)
		mains.append([p, sz * 1.18 + 0.008])
	var y := 0.066
	while y < 0.136:
		var n := int(TAU * R / 0.0085)
		for k in range(n):
			var a := (float(k) + 0.5 * float(int(y * 1000.0) % 2)) / float(n) * TAU
			var p := TreasuryKit.d(a) * (R + 0.001) + Vector3(0, y, 0)
			var ok := true
			for m in mains:
				if p.distance_to(m[0]) < float(m[1]):
					ok = false
					break
			if ok:
				TreasuryKit.gem(items, "diamond", "round", p, TreasuryKit.d(a), UP.cross(TreasuryKit.d(a)), 0.0032)
		y += 0.0085
	# crosses pattee and fleurs-de-lis on the rim
	for k in range(8):
		var a := float(k) * PI * 0.25
		var dd := TreasuryKit.d(a)
		var ax := UP.cross(dd)
		var o := dd * (R + 0.003) + Vector3(0, 0.145, 0)
		var face := o + dd * 0.0045
		var skip := []
		var poly: PackedVector2Array
		if k % 2 == 0:
			poly = TreasuryKit.scaled_poly(PATTEE, 0.095)
			var c := face + UP * 0.0475
			if k == 0:
				TreasuryKit.gem(items, "black_prince", "cushion", c, dd, UP, 0.022)
				skip.append([Vector2(0, 0.0475), 0.026])
			else:
				TreasuryKit.gem(items, "emerald" if k != 4 else "sapphire", "emerald" if k != 4 else "cushion", c, dd, UP, 0.011)
				skip.append([Vector2(0, 0.0475), 0.014])
		else:
			poly = TreasuryKit.scaled_poly(FLEUR, 0.075)
			TreasuryKit.gem(items, "ruby", "oval", face + UP * 0.03, dd, UP, 0.0065)
			skip.append([Vector2(0, 0.03), 0.008])
		TreasuryKit.plate(root, poly, 0.007, met, o, ax, UP)
		TreasuryKit.pave(items, poly, face, ax, UP, 0.0068, 0.0028, skip)
	# arches with pave, pearls along both edges
	var ctrl := [Vector2(R - 0.004, 0.2), Vector2(R + 0.012, 0.25), Vector2(R - 0.006, 0.3), Vector2(0.085, 0.33), Vector2(0.035, 0.327), Vector2(0.0, 0.32)]
	for k in range(4):
		var a := float(k) * PI * 0.5
		var pts := _arch(a, ctrl, 36)
		MeshUtils.sweep_tube(root, pts, 0.009, 0.008, met)
		var ax := UP.cross(TreasuryKit.d(a))
		for i in range(1, pts.size() - 1):
			var n := _arch_normal(pts, i, ax, Vector3(0, 0.15, 0))
			for off in [-0.0062, 0.0, 0.0062]:
				TreasuryKit.gem(items, "diamond", "round", pts[i] + n * 0.0085 + ax * off, n, ax, 0.0028)
			if i % 3 == 0:
				for s in [-1.0, 1.0]:
					TreasuryKit.ball(pearls, pts[i] + ax * s * 0.014 + n * 0.003, 0.0055)
	# monde, top cross and the drop pearls
	var mc := Vector3(0, 0.356, 0)
	var monde := TreasuryKit.lathe([Vector2(0.0, 0.03), Vector2(0.021, 0.021), Vector2(0.03, 0.0), Vector2(0.021, -0.021), Vector2(0.0, -0.03)], met, 32)
	monde.position = mc
	root.add_child(monde)
	_fib_sphere(items, mc, 0.0305, 210, 0.0028)
	var ring := MeshUtils.make_ring(0.03, 0.034, 0.006, met, 48)
	ring.position = mc
	root.add_child(ring)
	var cp := TreasuryKit.scaled_poly(PATTEE, 0.085)
	var co := mc + Vector3(0, 0.024, 0)
	TreasuryKit.plate(root, cp, 0.008, met, co, Vector3.RIGHT, UP)
	TreasuryKit.gem(items, "sapphire", "cushion", co + Vector3(0, 0.0425, 0.0045), Vector3.BACK, Vector3.RIGHT, 0.0115)
	TreasuryKit.pave(items, cp, co + Vector3(0, 0, 0.0045), Vector3.RIGHT, UP, 0.0068, 0.0028, [[Vector2(0, 0.0425), 0.014]])
	for k in range(4):
		var a := float(k) * PI * 0.5 + PI * 0.25
		pearls.append(Transform3D(Basis().scaled(Vector3(0.0065, 0.0095, 0.0065)), TreasuryKit.d(a) * 0.032 + Vector3(0, 0.29, 0)))
	root.add_child(TreasuryKit.balls(pearls, TreasuryKit.mats()["pearl"]))
	root.add_child(GemFactory.make_set(items))

# ── St Edward's Crown (gold, coloured stones in collets) ────────────────────
static func _st_edward(h: Node3D) -> void:
	var root := Node3D.new()
	h.add_child(root)
	var fil := ShopStones.material("filigree")
	var gold: Material = TreasuryKit.mats()["gold"]
	var items := []
	var cols := []
	var beads := []
	var pearls := []
	var R := 0.13
	_ermine(root, R)
	root.add_child(MeshUtils.make_revolved([Vector2(R - 0.006, 0.05), Vector2(R, 0.05), Vector2(R, 0.145), Vector2(R - 0.006, 0.145), Vector2(R - 0.006, 0.05)], fil, 96))
	_cap(root, [Vector2(0.0, 0.33), Vector2(0.05, 0.345), Vector2(0.1, 0.33), Vector2(0.132, 0.29), Vector2(0.145, 0.235), Vector2(0.14, 0.185), Vector2(0.126, 0.14)],
		0.06, TreasuryKit.mats()["purple"])
	for yy in [0.056, 0.142]:
		var n := int(TAU * R / 0.006)
		for k in range(n):
			TreasuryKit.ball(beads, TreasuryKit.d(float(k) / float(n) * TAU) * (R + 0.002) + Vector3(0, yy, 0), 0.0033)
	var palette := [["emerald", "emerald"], ["sapphire", "oval"], ["amethyst", "cushion"], ["aquamarine", "oval"],
		["tourmaline", "emerald"], ["citrine", "cushion"], ["pink_sapph", "oval"], ["white_topaz", "cushion"]]
	for k in range(16):
		var a := float(k) / 16.0 * TAU
		var dd := TreasuryKit.d(a)
		var ax := UP.cross(dd)
		var p := dd * (R + 0.004) + Vector3(0, 0.099, 0)
		var pc: Array = palette[k % palette.size()]
		var sz := 0.0135 if k % 2 == 0 else 0.011
		var box: bool = pc[1] == "emerald"
		TreasuryKit.gem(items, pc[0], pc[1], p, dd, ax if k % 2 == 0 else UP, sz)
		TreasuryKit.collet(cols, p, dd, ax if k % 2 == 0 else UP, sz * 1.08, 1.0 if box else 1.0, 0.72 if not box else 0.72, box)
		# small pair of stones between
		var a2 := a + TAU / 32.0
		for s in [-1.0, 1.0]:
			var p2 := TreasuryKit.d(a2) * (R + 0.003) + Vector3(0, 0.099 + s * 0.022, 0)
			TreasuryKit.gem(items, "garnet" if s > 0 else "peridot", "round", p2, TreasuryKit.d(a2), UP, 0.0045)
			TreasuryKit.collet(cols, p2, TreasuryKit.d(a2), UP, 0.005)
	for k in range(8):
		var a := float(k) * PI * 0.25
		var dd := TreasuryKit.d(a)
		var ax := UP.cross(dd)
		var o := dd * (R + 0.004) + Vector3(0, 0.145, 0)
		var face := o + dd * 0.005
		if k % 2 == 0:
			var poly := TreasuryKit.scaled_poly(PATTEE, 0.1)
			TreasuryKit.plate(root, poly, 0.008, fil, o, ax, UP)
			var c := face + UP * 0.05
			var big: Array = [["emerald", "emerald"], ["sapphire", "cushion"], ["aquamarine", "emerald"], ["amethyst", "oval"]][k / 2]
			TreasuryKit.gem(items, big[0], big[1], c, dd, UP, 0.014)
			TreasuryKit.collet(cols, c, dd, UP, 0.015, 1.0, 0.75, big[1] == "emerald")
			for arm in [Vector2(0, 0.088), Vector2(0, 0.012), Vector2(0.038, 0.05), Vector2(-0.038, 0.05)]:
				var pa: Vector3 = face + ax * arm.x + UP * arm.y
				TreasuryKit.gem(items, "ruby" if arm.y != 0.05 else "white_topaz", "round", pa, dd, ax, 0.0055)
				TreasuryKit.collet(cols, pa, dd, ax, 0.006)
		else:
			var poly2 := TreasuryKit.scaled_poly(FLEUR, 0.085)
			TreasuryKit.plate(root, poly2, 0.008, fil, o, ax, UP)
			var pf := face + UP * 0.034
			TreasuryKit.gem(items, "sapphire", "oval", pf, dd, UP, 0.0085)
			TreasuryKit.collet(cols, pf, dd, UP, 0.009, 1.0, 0.72)
	var ctrl := [Vector2(R - 0.004, 0.2), Vector2(R + 0.03, 0.27), Vector2(R + 0.008, 0.345), Vector2(0.07, 0.385), Vector2(0.02, 0.362), Vector2(0.0, 0.358)]
	for k in range(4):
		var a := float(k) * PI * 0.5
		var pts := _arch(a, ctrl, 30)
		MeshUtils.sweep_tube(root, pts, 0.011, 0.009, fil)
		var ax := UP.cross(TreasuryKit.d(a))
		for i in range(1, pts.size() - 1):
			var n := _arch_normal(pts, i, ax, Vector3(0, 0.2, 0))
			for s in [-1.0, 1.0]:
				TreasuryKit.ball(beads, pts[i] + ax * s * 0.011 + n * 0.004, 0.0035)
			if i % 4 == 2:
				var pc: Array = palette[(i / 4 + k) % palette.size()]
				TreasuryKit.gem(items, pc[0], "oval", pts[i] + n * 0.011, n, ax, 0.0085)
				TreasuryKit.collet(cols, pts[i] + n * 0.011, n, ax, 0.009, 1.0, 0.72)
			elif i % 4 == 0:
				TreasuryKit.ball(pearls, pts[i] + n * 0.012, 0.006)
	var mc := Vector3(0, 0.39, 0)
	var monde := TreasuryKit.lathe([Vector2(0.0, 0.032), Vector2(0.023, 0.023), Vector2(0.032, 0.0), Vector2(0.023, -0.023), Vector2(0.0, -0.032)], gold, 32)
	monde.position = mc
	root.add_child(monde)
	for k in range(10):
		var a := float(k) / 10.0 * TAU
		var pc: Array = palette[k % palette.size()]
		TreasuryKit.gem(items, pc[0], "oval", mc + TreasuryKit.d(a) * 0.033, TreasuryKit.d(a), UP, 0.007)
		TreasuryKit.collet(cols, mc + TreasuryKit.d(a) * 0.033, TreasuryKit.d(a), UP, 0.0075, 1.0, 0.72)
	var cp := TreasuryKit.scaled_poly(PATTEE, 0.09)
	var co := mc + Vector3(0, 0.026, 0)
	TreasuryKit.plate(root, cp, 0.008, fil, co, Vector3.RIGHT, UP)
	TreasuryKit.gem(items, "aquamarine", "emerald", co + Vector3(0, 0.045, 0.005), Vector3.BACK, UP, 0.012)
	TreasuryKit.collet(cols, co + Vector3(0, 0.045, 0.005), Vector3.BACK, UP, 0.013, 1.0, 0.75, true)
	for e in [Vector2(0, 0.096), Vector2(0.05, 0.045), Vector2(-0.05, 0.045)]:
		TreasuryKit.ball(pearls, co + Vector3(e.x, e.y, 0.0), 0.007)
	root.add_child(TreasuryKit.balls(beads, gold))
	root.add_child(TreasuryKit.balls(pearls, TreasuryKit.mats()["pearl"]))
	root.add_child(TreasuryKit.collet_node(cols, gold))
	root.add_child(GemFactory.make_set(items))

# ── Holy Roman imperial crown: eight hinged plates ─────────────────────────
static func _plate_poly(w: float, H: float, segs := 12) -> PackedVector2Array:
	var p := PackedVector2Array()
	p.append(Vector2(w * 0.5, 0.0))
	for k in range(segs + 1):
		var a := float(k) / float(segs) * PI
		p.append(Vector2(cos(a) * w * 0.5, H - w * 0.5 + sin(a) * w * 0.5))
	p.append(Vector2(-w * 0.5, 0.0))
	return p

static func _hre(h: Node3D) -> void:
	var root := Node3D.new()
	h.add_child(root)
	var fil := ShopStones.material("filigree")
	var gold: Material = TreasuryKit.mats()["gold"]
	var items := []
	var cols := []
	var claws := []
	var pearls := []
	var a0 := 0.19
	var w := 2.0 * a0 * tan(PI / 8.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 962
	var cabs := ["cab_sapphire", "cab_pale_sapph", "cab_amethyst", "cab_spinel", "cab_garnet", "emerald_tab", "cab_sapphire", "cab_amethyst"]
	root.add_child(TreasuryKit.lathe([Vector2(0.0, 0.215), Vector2(0.1, 0.2), Vector2(0.16, 0.14), Vector2(0.172, 0.02)], TreasuryKit.mats()["red_velvet"], 48))
	var heights := [0.30, 0.19, 0.25, 0.19, 0.28, 0.19, 0.25, 0.19]
	for k in range(8):
		var th := float(k) * PI * 0.25
		var dd := TreasuryKit.d(th)
		var ax := UP.cross(dd)
		var H: float = heights[k]
		var poly := _plate_poly(w, H)
		var o := dd * a0
		TreasuryKit.plate(root, poly, 0.01, fil, o, ax, UP)
		var face := o + dd * 0.005
		# hinge pins at the corners
		var hp := MeshUtils.make_cylinder(0.005, 0.005, 0.17, gold, 10)
		hp.position = TreasuryKit.d(th + PI / 8.0) * (a0 / cos(PI / 8.0)) + Vector3(0, 0.09, 0)
		root.add_child(hp)
		if k % 2 == 1:
			var pl := _plate_poly(w * 0.74, H * 0.8)
			TreasuryKit.plate(root, pl, 0.003, ShopStones.material("enamel_plaque"), face + UP * H * 0.08 + dd * 0.0015, ax, UP)
			# pearl and sapphire frame
			var per := pl.size()
			for i in range(per):
				var p0: Vector2 = pl[i]
				var p1: Vector2 = pl[(i + 1) % per]
				var steps := maxi(1, int(p0.distance_to(p1) / 0.016))
				for s in range(steps):
					var q := p0.lerp(p1, float(s) / float(steps)) * 1.12 + Vector2(0, H * 0.08 - 0.004)
					var wp := face + ax * q.x + UP * q.y + dd * 0.002
					if (i + s) % 3 == 0:
						TreasuryKit.gem(items, "cab_sapphire", "cabochon", wp, dd, ax, 0.0055)
					else:
						TreasuryKit.ball(pearls, wp + dd * 0.003, 0.0048)
			continue
		# jewel plate: pack big cabochons, then pearls, then tiny garnets
		var placed := []
		var sizes := [0.03, 0.022, 0.022, 0.02, 0.02, 0.018, 0.018, 0.016, 0.016, 0.014, 0.014] if k == 0 else [0.024, 0.02, 0.02, 0.018, 0.016, 0.016, 0.014, 0.014]
		var ci := k
		for s in sizes:
			var sz: float = s
			for tries in range(300):
				var q := Vector2(rng.randf_range(-w * 0.5, w * 0.5), rng.randf_range(0.0, H))
				if k == 0 and placed.is_empty():
					q = Vector2(0, H * 0.45)
				var ok := true
				for j in range(8):
					var aa := float(j) / 8.0 * TAU
					if not Geometry2D.is_point_in_polygon(q + Vector2(cos(aa), sin(aa)) * (sz * 1.15 + 0.008), poly):
						ok = false
						break
				if ok:
					for pp in placed:
						if q.distance_to(pp[0]) < sz * 1.15 + float(pp[1]) * 1.15 + 0.008:
							ok = false
							break
				if not ok:
					continue
				placed.append([q, sz])
				var stn: String = cabs[ci % cabs.size()]
				ci += 1
				var wp := face + ax * q.x + UP * q.y
				var along := UP if rng.randf() < 0.5 else ax
				if stn == "emerald_tab":
					TreasuryKit.gem(items, "emerald_cloudy", "table", wp + dd * 0.002, dd, along, sz * 0.95)
					TreasuryKit.collet(cols, wp, dd, along, sz, 1.0, 0.75, true)
				else:
					TreasuryKit.gem(items, stn, "cabochon", wp + dd * 0.002, dd, along, sz)
					TreasuryKit.collet(cols, wp, dd, along, sz * 1.05, 1.0, 0.78)
				for j in range(6):
					var aa := float(j) / 6.0 * TAU + 0.3
					var cp := wp + (ax * cos(aa) + UP * sin(aa) * 0.8) * sz * 1.08 + dd * sz * 0.35
					claws.append(Transform3D(TreasuryKit.frame((cp - wp).normalized(), dd).scaled(Vector3(0.0022, 0.0055, 0.0022)), cp))
				break
		for tries in range(500):
			var q := Vector2(rng.randf_range(-w * 0.5, w * 0.5), rng.randf_range(0.0, H))
			var ok := Geometry2D.is_point_in_polygon(q, poly) and Geometry2D.is_point_in_polygon(q + Vector2(0.008, 0), poly) and Geometry2D.is_point_in_polygon(q - Vector2(0.008, 0), poly) and Geometry2D.is_point_in_polygon(q + Vector2(0, 0.008), poly) and q.y > 0.008
			if ok:
				for pp in placed:
					if q.distance_to(pp[0]) < float(pp[1]) * 1.2 + 0.01:
						ok = false
						break
			if ok:
				placed.append([q, 0.0055])
				if rng.randf() < 0.75:
					TreasuryKit.ball(pearls, face + ax * q.x + UP * q.y + dd * 0.004, 0.0058)
				else:
					TreasuryKit.gem(items, "cab_garnet", "cabochon", face + ax * q.x + UP * q.y, dd, ax, 0.0045)
	# the front cross
	var cross := PackedVector2Array([Vector2(-0.028, 0), Vector2(0.028, 0), Vector2(0.028, 0.11), Vector2(0.075, 0.11), Vector2(0.075, 0.16),
		Vector2(0.028, 0.16), Vector2(0.028, 0.2), Vector2(-0.028, 0.2), Vector2(-0.028, 0.16), Vector2(-0.075, 0.16), Vector2(-0.075, 0.11), Vector2(-0.028, 0.11)])
	var co := Vector3(0, 0.28, a0 + 0.012)
	TreasuryKit.plate(root, cross, 0.01, fil, co, Vector3.RIGHT, UP)
	var cf := co + Vector3(0, 0, 0.005)
	for st in [[Vector2(0, 0.135), "cab_pale_sapph", 0.016], [Vector2(-0.052, 0.135), "cab_amethyst", 0.012], [Vector2(0.052, 0.135), "cab_carnelian", 0.012],
			[Vector2(0, 0.182), "cab_sapphire", 0.01], [Vector2(0, 0.08), "emerald_tab", 0.011], [Vector2(0, 0.035), "cab_sapphire", 0.009]]:
		var q: Vector2 = st[0]
		var wp := cf + Vector3(q.x, q.y, 0)
		if st[1] == "emerald_tab":
			TreasuryKit.gem(items, "emerald_cloudy", "table", wp, Vector3.BACK, UP, float(st[2]))
			TreasuryKit.collet(cols, wp, Vector3.BACK, UP, float(st[2]) * 1.05, 1.0, 0.75, true)
		else:
			TreasuryKit.gem(items, st[1], "cabochon", wp, Vector3.BACK, UP, float(st[2]))
			TreasuryKit.collet(cols, wp, Vector3.BACK, UP, float(st[2]) * 1.06, 1.0, 0.78)
	for i in range(cross.size()):
		var p0: Vector2 = cross[i]
		var p1: Vector2 = cross[(i + 1) % cross.size()]
		var steps := maxi(1, int(p0.distance_to(p1) / 0.012))
		for s in range(steps):
			var q := p0.lerp(p1, float(s) / float(steps))
			q = q.move_toward(Vector2(clampf(q.x, -0.02, 0.02), clampf(q.y, 0.118, 0.152)), 0.007)
			TreasuryKit.ball(pearls, cf + Vector3(q.x, q.y, 0.003), 0.0042)
	# the arch from back to front
	var arch := TreasuryKit.spline([Vector3(0, 0.27, -a0 + 0.01), Vector3(0, 0.35, -0.11), Vector3(0, 0.38, 0.0), Vector3(0, 0.36, 0.11), Vector3(0, 0.3, a0 - 0.01)], 30)
	MeshUtils.sweep_tube(root, arch, 0.009, 0.009, fil)
	for i in range(1, arch.size() - 1):
		for s in [-1.0, 1.0]:
			TreasuryKit.ball(pearls, arch[i] + Vector3(s * 0.012, 0.004, 0), 0.0045)
	root.add_child(TreasuryKit.balls(pearls, TreasuryKit.mats()["pearl"]))
	root.add_child(TreasuryKit.balls(claws, gold))
	root.add_child(TreasuryKit.collet_node(cols, gold))
	root.add_child(GemFactory.make_set(items))

# ── emerald crown on a green velvet cushion ─────────────────────────────────
static var _leaf: Mesh

static func _leaf_mesh() -> Mesh:
	if _leaf == null:
		var mi := AncientTreasures._extrude(AncientTreasures._ellipse(0.5, 0.17, 12, 0.5, 0.0), 0.1, null)
		_leaf = mi.mesh
	return _leaf

static func _flower(items: Array, c: Vector3, n: Vector3, ax: Vector3, s: float, stone := "emerald") -> void:
	var ay := n.cross(ax).normalized() * -1.0
	TreasuryKit.gem(items, stone, "round", c, n, ax, s * 0.55)
	for k in range(6):
		var a := float(k) / 6.0 * TAU
		var dir := ax * cos(a) + ay * sin(a)
		TreasuryKit.gem(items, stone, "oval", c + dir * s * 1.25, n, dir, s * 0.6)

static func _emerald_crown(h: Node3D) -> void:
	var cushion := MeshUtils.make_rounded_box(Vector3(0.56, 0.09, 0.56), 0.035, TreasuryKit.mats()["green_velvet"])
	cushion.position.y = 0.045
	h.add_child(cushion)
	var gold: Material = TreasuryKit.mats()["gold"]
	var fil := ShopStones.material("filigree")
	var braid := PackedVector3Array()
	for k in range(41):
		var t := float(k) / 40.0 * 4.0
		var side := int(t) % 4
		var u := t - float(int(t))
		var c := [Vector3(-0.255, 0.087, -0.255), Vector3(0.255, 0.087, -0.255), Vector3(0.255, 0.087, 0.255), Vector3(-0.255, 0.087, 0.255)]
		braid.append((c[side] as Vector3).lerp(c[(side + 1) % 4], u))
	MeshUtils.sweep_tube(h, braid, 0.006, 0.006, gold)
	var root := Node3D.new()
	root.position.y = 0.09
	h.add_child(root)
	var items := []
	var cols := []
	var beads := []
	var leaves := []
	var R := 0.17
	root.add_child(MeshUtils.make_revolved([Vector2(R - 0.008, 0.0), Vector2(R, 0.0), Vector2(R, 0.075), Vector2(R - 0.008, 0.075), Vector2(R - 0.008, 0.0)], fil, 96))
	for yy in [0.004, 0.071]:
		var n := int(TAU * R / 0.008)
		for k in range(n):
			TreasuryKit.ball(beads, TreasuryKit.d(float(k) / float(n) * TAU) * (R + 0.003) + Vector3(0, yy, 0), 0.0042)
	for k in range(24):
		var a := float(k) / 24.0 * TAU
		var dd := TreasuryKit.d(a)
		var ax := UP.cross(dd)
		var p := dd * (R + 0.004) + Vector3(0, 0.0375, 0)
		if k % 2 == 0:
			TreasuryKit.gem(items, "emerald", "emerald", p, dd, UP, 0.016)
			TreasuryKit.collet(cols, p, dd, UP, 0.017, 1.0, 0.72, true)
		else:
			_flower(items, p, dd, ax, 0.011)
	var panel := [Vector2(0, 0.17), Vector2(0.02, 0.14), Vector2(0.05, 0.13), Vector2(0.055, 0.09), Vector2(0.04, 0.06), Vector2(0.055, 0.03),
		Vector2(0.04, 0.0), Vector2(-0.04, 0.0), Vector2(-0.055, 0.03), Vector2(-0.04, 0.06), Vector2(-0.055, 0.09), Vector2(-0.05, 0.13), Vector2(-0.02, 0.14)]
	for k in range(8):
		var a := float(k) * PI * 0.25
		var dd := TreasuryKit.d(a)
		var ax := UP.cross(dd)
		var ay := (UP - dd * 0.22).normalized()
		var nn := ax.cross(ay)
		var o := dd * (R - 0.002) + Vector3(0, 0.072, 0)
		TreasuryKit.plate(root, PackedVector2Array(panel), 0.008, fil, o, ax, ay)
		var f := o + nn * 0.005
		TreasuryKit.gem(items, "emerald", "emerald", f + ay * 0.045, nn, ay, 0.013)
		TreasuryKit.collet(cols, f + ay * 0.045, nn, ay, 0.014, 1.0, 0.72, true)
		_flower(items, f + ay * 0.105, nn, ax, 0.01)
		TreasuryKit.gem(items, "emerald", "round", f + ay * 0.152, nn, ax, 0.0065)
		for s in [-1.0, 1.0]:
			TreasuryKit.gem(items, "emerald", "round", f + ay * 0.022 + ax * s * 0.034, nn, ax, 0.006)
			for j in range(3):
				var lp: Vector3 = f + ay * (0.07 + j * 0.03) + ax * s * 0.05
				leaves.append(Transform3D(TreasuryKit.frame(nn, ay.rotated(nn, s * (0.6 + j * 0.2))).scaled(Vector3.ONE * 0.034), lp))
	var ctrl := [Vector2(R * 0.97, 0.235), Vector2(R + 0.012, 0.3), Vector2(0.12, 0.38), Vector2(0.06, 0.418), Vector2(0.0, 0.425)]
	for k in range(4):
		var a := float(k) * PI * 0.5
		var pts := _arch(a, ctrl, 30)
		MeshUtils.sweep_tube(root, pts, 0.011, 0.009, fil)
		var ax := UP.cross(TreasuryKit.d(a))
		for i in range(1, pts.size() - 1):
			var n := _arch_normal(pts, i, ax, Vector3(0, 0.2, 0))
			if i % 5 == 0:
				TreasuryKit.gem(items, "emerald", "emerald", pts[i] + n * 0.011, n, (pts[i + 1] - pts[i - 1]).normalized(), 0.0095)
				TreasuryKit.collet(cols, pts[i] + n * 0.011, n, (pts[i + 1] - pts[i - 1]).normalized(), 0.0105, 1.0, 0.72, true)
			else:
				TreasuryKit.gem(items, "emerald", "round", pts[i] + n * 0.011, n, ax, 0.0055)
			if i % 2 == 0:
				for s in [-1.0, 1.0]:
					leaves.append(Transform3D(TreasuryKit.frame(n, ax * s).scaled(Vector3.ONE * 0.026), pts[i] + ax * s * 0.009))
	var orb := TreasuryKit.lathe([Vector2(0.0, 0.045), Vector2(0.032, 0.032), Vector2(0.045, 0.0), Vector2(0.032, -0.032), Vector2(0.0, -0.045)], gold, 40)
	orb.position = Vector3(0, 0.47, 0)
	root.add_child(orb)
	for k in range(40):
		TreasuryKit.ball(beads, TreasuryKit.d(float(k) / 40.0 * TAU) * 0.046 + Vector3(0, 0.47, 0), 0.003)
	var cross := PackedVector2Array([Vector2(-0.01, 0), Vector2(0.01, 0), Vector2(0.01, 0.06), Vector2(0.035, 0.06), Vector2(0.035, 0.08), Vector2(0.01, 0.08),
		Vector2(0.01, 0.105), Vector2(-0.01, 0.105), Vector2(-0.01, 0.08), Vector2(-0.035, 0.08), Vector2(-0.035, 0.06), Vector2(-0.01, 0.06)])
	var co := Vector3(0, 0.512, 0)
	TreasuryKit.plate(root, cross, 0.01, gold, co, Vector3.RIGHT, UP)
	for q in [Vector2(0, 0.07), Vector2(0, 0.03), Vector2(0, 0.093), Vector2(0.024, 0.07), Vector2(-0.024, 0.07)]:
		TreasuryKit.gem(items, "emerald", "emerald" if q != Vector2(0, 0.07) else "round", co + Vector3(q.x, q.y, 0.005), Vector3.BACK, UP, 0.007)
	for q in [Vector2(0, 0.11), Vector2(0.04, 0.07), Vector2(-0.04, 0.07)]:
		TreasuryKit.ball(beads, co + Vector3(q.x, q.y, 0), 0.006)
	root.add_child(TreasuryKit.balls(beads, gold))
	root.add_child(GalleryDisplays._mm(_leaf_mesh(), leaves, fil))
	root.add_child(TreasuryKit.collet_node(cols, gold))
	root.add_child(GemFactory.make_set(items))

# ── pageant crown ───────────────────────────────────────────────────────────
static func _pageant(h: Node3D) -> void:
	var gold: Material = TreasuryKit.mats()["gold"]
	var disc := MeshUtils.make_cylinder(0.2, 0.21, 0.04, TreasuryKit.mats()["black_velvet"], 48)
	disc.position.y = 0.02
	h.add_child(disc)
	var root := Node3D.new()
	root.position.y = 0.04
	h.add_child(root)
	var items := []
	var cols := []
	var R := 0.115
	root.add_child(MeshUtils.make_revolved([Vector2(R, 0.0), Vector2(R + 0.006, 0.0), Vector2(R + 0.006, 0.014), Vector2(R, 0.014), Vector2(R, 0.0)], gold, 96))
	var pos_at := func(phi: float, y: float) -> Vector3:
		return TreasuryKit.d(phi) * (R + 0.004 + y * 0.12) + Vector3(0, y, 0)
	var nrm_at := func(phi: float) -> Vector3:
		return (TreasuryKit.d(phi) - UP * 0.12).normalized()
	var Hf := func(phi: float) -> float:
		return 0.06 + 0.21 * exp(-pow(phi / 0.7, 2.0))
	var specials := [[0.0, 0.125, "sapphire", "oval", 0.028, true], [0.0, 0.045, "ruby", "oval", 0.016, false], [0.0, 0.245, "hot_pink_sapph", "marquise", 0.016, true],
		[0.14, 0.215, "zircon_blue", "pear", 0.014, true], [-0.14, 0.215, "zircon_blue", "pear", 0.014, true], [0.35, 0.12, "pink_sapph", "oval", 0.014, true],
		[-0.35, 0.12, "pink_sapph", "oval", 0.014, true], [0.75, 0.06, "ruby", "oval", 0.015, false], [-0.75, 0.06, "ruby", "oval", 0.015, false]]
	var skip := []
	for sp in specials:
		var phi: float = sp[0]
		var y: float = sp[1]
		var p: Vector3 = pos_at.call(phi, y)
		var n: Vector3 = nrm_at.call(phi)
		var along := UP if sp[5] else UP.cross(TreasuryKit.d(phi))
		TreasuryKit.gem(items, sp[2], sp[3], p, n, along, sp[4])
		TreasuryKit.collet(cols, p, n, along, float(sp[4]) * 1.05, 1.0, 0.72)
		skip.append([phi * R, y, float(sp[4]) * 1.3 + 0.006])
	TreasuryKit.halo(items, (pos_at.call(0.0, 0.125) as Vector3) + TreasuryKit.d(0.0) * 0.003, Vector3.RIGHT, UP, 0.036, 0.0055, "white_topaz", "round", 16, 1.35)
	skip.append([0.0, 0.125, 0.05])
	var palette := ["ruby", "sapphire", "emerald", "pink_sapph", "amethyst", "zircon_blue", "hot_pink_sapph", "tourmaline"]
	var cuts := ["round", "oval", "pear", "round", "marquise"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var y := 0.024
	var row := 0
	while y < 0.28:
		var step := 0.02
		var phi := -1.75 + float(row % 2) * 0.5 * step / R
		while phi < 1.75:
			var pj := phi + rng.randf_range(-0.002, 0.002) / R
			if y < float(Hf.call(pj)) - 0.008:
				var ok := true
				for s in skip:
					if Vector2(pj * R, y).distance_to(Vector2(s[0], s[1])) < float(s[2]):
						ok = false
						break
				if ok:
					var white := rng.randf() < 0.4
					var st: String = "white_topaz" if white else palette[rng.randi() % palette.size()]
					var cut: String = "round" if white else cuts[rng.randi() % cuts.size()]
					var sz := rng.randf_range(0.0065, 0.0085)
					var p: Vector3 = pos_at.call(pj, y)
					var n: Vector3 = nrm_at.call(pj)
					TreasuryKit.gem(items, st, cut, p, n, UP, sz)
					TreasuryKit.collet(cols, p, n, UP, sz * 1.08, 1.0, 1.0 if cut == "round" else 0.7)
			phi += step / R
		y += 0.019
		row += 1
	for k in range(120):
		var phi := -PI + float(k) / 120.0 * TAU
		for yy in [0.004, 0.011]:
			TreasuryKit.gem(items, "white_topaz", "round", TreasuryKit.d(phi) * (R + 0.007) + Vector3(0, yy, 0), TreasuryKit.d(phi), UP, 0.0033)
	for s in [-1.0, 1.0]:
		for j in range(4):
			var pts := PackedVector3Array()
			for i in range(16):
				var t := float(i) / 15.0
				var phi: float = s * (0.1 + j * 0.28 + t * 0.35)
				pts.append(pos_at.call(phi, 0.03 + t * (0.08 + j * 0.03) + 0.02 * sin(t * PI)) as Vector3)
			MeshUtils.sweep_tube(root, pts, 0.0022, 0.0018, gold)
	root.add_child(TreasuryKit.collet_node(cols, gold))
	root.add_child(GemFactory.make_set(items))

# ── sapphire kokoshnik on a black velvet head form ─────────────────────────
static func _kokoshnik(h: Node3D) -> void:
	var vel: Material = TreasuryKit.mats()["black_velvet"]
	var stand := MeshUtils.make_cylinder(0.04, 0.06, 0.08, vel, 24)
	stand.position.y = 0.04
	h.add_child(stand)
	var head := MeshInstance3D.new()
	head.mesh = ShopStones.sphere_mesh()
	head.material_override = vel
	head.scale = Vector3(0.1, 0.12, 0.118)
	head.position.y = 0.17
	h.add_child(head)
	var root := Node3D.new()
	root.position.y = 0.2
	h.add_child(root)
	var plat: Material = TreasuryKit.mats()["platinum"]
	var items := []
	var rx := 0.104
	var rz := 0.122
	var P := func(phi: float, y: float) -> Vector3:
		var k := 1.0 + y * 1.2
		return Vector3(sin(phi) * rx * k, y, cos(phi) * rz * k)
	var N := func(phi: float) -> Vector3:
		return (Vector3(sin(phi) / rx, 0.0, cos(phi) / rz).normalized() - UP * 0.1).normalized()
	root.add_child(TreasuryKit.surface(func(u: float, v: float) -> Vector3:
		return P.call(lerpf(1.45, -1.45, u), lerpf(0.082, 0.0, v)), 48, 6, TreasuryKit.mats()["dark_plat"], false))
	var row := func(y: float, sz: float, sp: float) -> void:
		var phi := -1.45
		while phi <= 1.45:
			var p: Vector3 = P.call(phi, y)
			TreasuryKit.gem(items, "diamond", "round", p + (N.call(phi) as Vector3) * 0.002, N.call(phi), UP, sz)
			phi += sp / rx
	row.call(0.079, 0.0046, 0.0098)
	row.call(0.069, 0.0028, 0.0064)
	row.call(0.004, 0.0042, 0.009)
	row.call(0.012, 0.0026, 0.006)
	var halos := []
	for sp in [[0.0, 0.021, "cushion"], [0.42, 0.015, "cushion"], [-0.42, 0.015, "cushion"], [0.84, 0.017, "cushion"], [-0.84, 0.017, "cushion"], [1.22, 0.012, "oval"], [-1.22, 0.012, "oval"]]:
		var phi: float = sp[0]
		var c: Vector3 = P.call(phi, 0.04)
		var n: Vector3 = N.call(phi)
		var ax := UP.cross(n).normalized()
		var ay := n.cross(ax)
		TreasuryKit.gem(items, "sapphire", sp[2], c + n * 0.003, n, ay, sp[1])
		var r1: float = float(sp[1]) * 1.1 + 0.0045
		TreasuryKit.halo(items, c + n * 0.002, ax, ay, r1, 0.0034)
		TreasuryKit.halo(items, c + n * 0.002, ax, ay, r1 + 0.0085, 0.0028)
		halos.append([phi, r1 + 0.012])
	for k in range(6):
		var phi: float = [0.21, -0.21, 0.63, -0.63, 1.03, -1.03][k]
		var c: Vector3 = P.call(phi, 0.04)
		var n: Vector3 = N.call(phi)
		var ax := UP.cross(n).normalized()
		TreasuryKit.gem(items, "diamond", "old_european", c + n * 0.003, n, ax, 0.0065)
		TreasuryKit.halo(items, c + n * 0.002, ax, n.cross(ax), 0.0105, 0.0026, "diamond", "round", 10)
		halos.append([phi, 0.016])
	var phi2 := -1.45
	while phi2 <= 1.45:
		var y := 0.02
		while y < 0.063:
			var p: Vector3 = P.call(phi2, y)
			var ok := absf(sin(phi2 * 38.0 + sin(y * 120.0) * 2.0)) < 0.55
			for hh in halos:
				if Vector2(phi2 * rx, y).distance_to(Vector2(float(hh[0]) * rx, 0.04)) < float(hh[1]):
					ok = false
					break
			if ok:
				TreasuryKit.gem(items, "diamond", "round", p + (N.call(phi2) as Vector3) * 0.0015, N.call(phi2), UP, 0.0024)
			y += 0.0055
		phi2 += 0.0055 / rx
	root.add_child(GemFactory.make_set(items))

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# NECKLACES
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
static func _bulgari(h: Node3D) -> void:
	var b := AncientTreasures._board(h, Color(0.58, 0.55, 0.5), Vector2(0.74, 0.66), -1.05)
	var rg: Material = TreasuryKit.mats()["rose_gold"]
	var items := []
	var beads := []
	var cols := []
	var c := Vector2(0.0, 0.36)
	var rx := 0.2
	var ry := 0.22
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var pt := func(a: float) -> Vector2: return c + Vector2(cos(a) * rx, sin(a) * ry)
	var outw := func(a: float) -> Vector2: return Vector2(cos(a) / rx, sin(a) / ry).normalized()
	var a := 0.0
	while a < TAU:
		var p: Vector2 = pt.call(a)
		var o: Vector2 = outw.call(a)
		for j in range(3):
			var off := rng.randf_range(-0.017, 0.017)
			var q := p + o * off + Vector2(o.y, -o.x) * rng.randf_range(-0.004, 0.004)
			var sz := rng.randf_range(0.0035, 0.0062)
			TreasuryKit.gem(items, "diamond", "round", Vector3(q.x, q.y, 0.007), Vector3.BACK, Vector3.RIGHT, sz)
			TreasuryKit.ball(beads, Vector3(q.x, q.y, 0.003), sz * 1.05)
		if rng.randf() < 0.35:
			var s := 1.0 if rng.randf() < 0.5 else -1.0
			var q2 := p + o * s * 0.026
			TreasuryKit.gem(items, "diamond", "pear" if rng.randf() < 0.6 else "marquise", Vector3(q2.x, q2.y, 0.006), Vector3.BACK, Vector3(o.x * s, o.y * s, 0), 0.0062)
		a += 0.011 / ry
	var stones := [[205.0, "mandarin"], [228.0, "aquamarine"], [250.0, "london_topaz"], [272.0, "rubellite"], [294.0, "peridot"], [316.0, "amethyst"], [342.0, "prasiolite"]]
	for s in stones:
		var aa := deg_to_rad(float(s[0]))
		var o: Vector2 = outw.call(aa)
		var p: Vector2 = (pt.call(aa) as Vector2) + o * 0.032
		var pos := Vector3(p.x, p.y, 0.012)
		var al := Vector3(o.x, o.y, 0)
		TreasuryKit.gem(items, s[1], "emerald", pos, Vector3.BACK, al, 0.03)
		TreasuryKit.collet(cols, pos, Vector3.BACK, al, 0.031, 1.0, 0.72, true)
		for k in range(4):
			var ca := float(k) / 4.0 * TAU + PI * 0.25
			var cp := pos + (al * cos(ca) * 0.03 + Vector3(-o.y, o.x, 0) * sin(ca) * 0.021)
			TreasuryKit.ball(beads, cp + Vector3(0, 0, 0.004), 0.004)
		var dp: Vector2 = p + o * 0.042
		TreasuryKit.gem(items, "diamond", "pear", Vector3(dp.x, dp.y, 0.007), Vector3.BACK, al, 0.0075)
		var tp := p - o * 0.012
		TreasuryKit.gem(items, "diamond", "round", Vector3(tp.x, tp.y, 0.01) + Vector3(-o.y, o.x, 0) * 0.026, Vector3.BACK, al, 0.0045)
		TreasuryKit.gem(items, "diamond", "round", Vector3(tp.x, tp.y, 0.01) - Vector3(-o.y, o.x, 0) * 0.026, Vector3.BACK, al, 0.0045)
	b.add_child(TreasuryKit.balls(beads, rg))
	b.add_child(TreasuryKit.collet_node(cols, rg))
	b.add_child(GemFactory.make_set(items))

static func _mackay(h: Node3D) -> void:
	var b := AncientTreasures._board(h, Color(0.012, 0.012, 0.014), Vector2(0.62, 0.86), -0.5)
	var plat: Material = TreasuryKit.mats()["platinum"]
	var items := []
	var pc := Vector3(0, 0.17, 0.012)
	var bk := MeshUtils.make_rounded_box(Vector3(0.112, 0.142, 0.008), 0.003, plat)
	bk.position = pc - Vector3(0, 0, 0.008)
	b.add_child(bk)
	TreasuryKit.gem(items, "mackay", "cushion", pc + Vector3(0, 0, 0.004), Vector3.BACK, Vector3.UP, 0.045)
	var prongs := []
	for k in range(8):
		var a := float(k) / 8.0 * TAU + PI / 8.0
		TreasuryKit.ball(prongs, pc + Vector3(cos(a) * 0.042, sin(a) * 0.04, 0.012), 0.0035)
	# baguette frame
	var hw := 0.05
	var hh := 0.065
	var edges := [[Vector3(-hw, hh, 0), Vector3(hw, hh, 0)], [Vector3(hw, hh, 0), Vector3(hw, -hh, 0)], [Vector3(hw, -hh, 0), Vector3(-hw, -hh, 0)], [Vector3(-hw, -hh, 0), Vector3(-hw, hh, 0)]]
	for e in edges:
		var p0: Vector3 = e[0]
		var p1: Vector3 = e[1]
		var dirv := (p1 - p0).normalized()
		var n := int(p0.distance_to(p1) / 0.018)
		for i in range(n):
			var t := (float(i) + 0.5) / float(n)
			TreasuryKit.gem(items, "diamond", "baguette", pc + p0.lerp(p1, t) + Vector3(0, 0, 0.002), Vector3.BACK, dirv, 0.0085)
		TreasuryKit.gem(items, "diamond", "round", pc + p0 + Vector3(0, 0, 0.003), Vector3.BACK, dirv, 0.0055)
	TreasuryKit.gem(items, "diamond", "emerald", pc + Vector3(0, hh + 0.012, 0.002), Vector3.BACK, Vector3.UP, 0.008)
	TreasuryKit.gem(items, "diamond", "emerald", pc + Vector3(0, -hh - 0.012, 0.002), Vector3.BACK, Vector3.UP, 0.008)
	# bail of calibre emeralds
	var bc := pc + Vector3(0, hh + 0.03, 0)
	for k in range(9):
		var a := PI * float(k) / 8.0
		var p := bc + Vector3(cos(a) * 0.026, sin(a) * 0.022, 0.002)
		TreasuryKit.gem(items, "emerald", "baguette", p, Vector3.BACK, Vector3(-sin(a), cos(a), 0), 0.0058)
	TreasuryKit.gem(items, "diamond", "emerald", bc + Vector3(0, 0.03, 0.003), Vector3.BACK, Vector3.UP, 0.0085)
	TreasuryKit.gem(items, "diamond", "round", bc + Vector3(0, 0.048, 0.003), Vector3.BACK, Vector3.UP, 0.005)
	# chain of links
	for s in [-1.0, 1.0]:
		var path := TreasuryKit.spline([Vector3(s * 0.015, 0.29, 0.006), Vector3(s * 0.06, 0.38, 0.006), Vector3(s * 0.13, 0.52, 0.006), Vector3(s * 0.2, 0.66, 0.006), Vector3(s * 0.25, 0.82, 0.006)], 200)
		var acc := 0.0
		var li := 0
		for i in range(1, path.size()):
			acc += path[i].distance_to(path[i - 1])
			if acc < 0.034:
				continue
			acc = 0.0
			var p := path[i]
			var t := (path[mini(i + 1, path.size() - 1)] - path[i - 1]).normalized()
			var nrm := Vector3(-t.y, t.x, 0)
			if li == 4:
				TreasuryKit.gem(items, "emerald", "asscher", p, Vector3.BACK, t, 0.0085)
				for sg in [-1.0, 1.0]:
					for k in range(6):
						var a := lerpf(-1.0, 1.0, float(k) / 5.0)
						var q: Vector3 = p + nrm * sg * 0.017 + t * a * 0.016 - nrm * sg * 0.004 * (1.0 - a * a)
						TreasuryKit.gem(items, "emerald", "baguette", q, Vector3.BACK, t, 0.0045)
				TreasuryKit.halo(items, p, t, nrm, 0.012, 0.0024, "diamond", "round", 12)
			elif li % 2 == 0:
				TreasuryKit.halo(items, p, t, nrm, 0.0115, 0.0027, "diamond", "round", 14, 0.75)
				var tor := MeshInstance3D.new()
				var tm := TorusMesh.new()
				tm.inner_radius = 0.0085
				tm.outer_radius = 0.0145
				tm.rings = 16
				tm.ring_segments = 6
				tor.mesh = tm
				tor.material_override = plat
				tor.transform = Transform3D(Basis(t, Vector3.BACK, nrm).scaled(Vector3(1.0, 0.25, 0.75)), p - Vector3(0, 0, 0.002))
				b.add_child(tor)
			else:
				for k in range(3):
					TreasuryKit.gem(items, "diamond", "round", p + t * (float(k) - 1.0) * 0.0075, Vector3.BACK, t, 0.0033)
				TreasuryKit.gem(items, "diamond", "baguette", p + nrm * 0.0065, Vector3.BACK, t, 0.0055)
				TreasuryKit.gem(items, "diamond", "baguette", p - nrm * 0.0065, Vector3.BACK, t, 0.0055)
				var bar := MeshUtils.make_rounded_box(Vector3(0.028, 0.022, 0.004), 0.002, plat)
				bar.transform = Transform3D(Basis(t, nrm, Vector3.BACK), p - Vector3(0, 0, 0.002))
				b.add_child(bar)
			li += 1
	b.add_child(TreasuryKit.balls(prongs, plat))
	b.add_child(GemFactory.make_set(items))

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# OBJETS D'ART
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
static func _egg(h: Node3D) -> void:
	var gold: Material = TreasuryKit.mats()["gold"]
	var am := TreasuryKit.crystal(Color(0.78, 0.55, 0.95), 0.0, 0.35, 12.0)
	var am_dark := TreasuryKit.crystal(Color(0.45, 0.22, 0.62), 0.0, 0.5, 12.0)
	var foot := TreasuryKit.lathe([Vector2(0.02, 0.11), Vector2(0.03, 0.085), Vector2(0.06, 0.05), Vector2(0.1, 0.02), Vector2(0.11, 0.008), Vector2(0.105, 0.0), Vector2(0.0, 0.0)], am, 48)
	h.add_child(foot)
	for band in [[0.108, 0.006, 0.006], [0.032, 0.11, 0.008], [0.026, 0.135, 0.006], [0.03, 0.19, 0.01], [0.034, 0.205, 0.006]]:
		var r := MeshUtils.make_ring(float(band[0]) - 0.006, float(band[0]) + 0.002, float(band[2]), gold, 40)
		r.position.y = band[1]
		h.add_child(r)
	var stem := MeshUtils.make_cylinder(0.02, 0.022, 0.08, gold, 24)
	stem.position.y = 0.15
	h.add_child(stem)
	var knop := MeshInstance3D.new()
	knop.mesh = ShopStones.sphere_mesh()
	knop.material_override = am_dark
	knop.scale = Vector3.ONE * 0.032
	knop.position.y = 0.16
	h.add_child(knop)
	var cup := TreasuryKit.lathe([Vector2(0.06, 0.245), Vector2(0.05, 0.23), Vector2(0.03, 0.212), Vector2(0.026, 0.205)], gold, 32)
	h.add_child(cup)
	var axle := MeshUtils.make_cylinder(0.006, 0.006, 0.11, gold, 12)
	axle.rotation.z = PI * 0.5
	axle.position.y = 0.245
	h.add_child(axle)
	# the two opened halves, hinged at the bottom of the egg
	var hinge := Vector3(0, 0.245, 0)
	var ex := 0.095
	var ey := 0.13
	for s in [-1.0, 1.0]:
		var m := ShopStones._deform_sphere(40, 24, func(p: Vector3) -> Vector3:
			var q := p
			if s < 0.0:
				q.x = -absf(p.x) if p.x <= 1e-5 else -p.x * 0.82
				if p.x > 1e-5:
					q.y *= 0.86
					q.z *= 0.82
			else:
				q.x = absf(p.x) if p.x >= -1e-5 else -p.x * 0.82
				if p.x < -1e-5:
					q.y *= 0.86
					q.z *= 0.82
			return Vector3(q.x * ex, q.y * ey + ey, q.z * ex))
		var half := MeshInstance3D.new()
		half.mesh = m
		half.material_override = am
		var piv := Node3D.new()
		piv.position = hinge
		piv.rotation.z = -s * 0.62
		h.add_child(piv)
		half.position = Vector3(s * 0.006, 0, 0)
		piv.add_child(half)
		var rp := PackedVector3Array()
		for k in range(33):
			var a := float(k) / 32.0 * TAU
			rp.append(Vector3(s * 0.006, ey + sin(a) * ey, cos(a) * ex))
		MeshUtils.sweep_tube(piv, rp, 0.004, 0.004, gold)
		var fin := MeshInstance3D.new()
		fin.mesh = ShopStones.sphere_mesh()
		fin.material_override = am_dark
		fin.scale = Vector3(0.011, 0.014, 0.011)
		fin.position = Vector3(s * 0.03, ey * 2.0 - 0.004, 0)
		piv.add_child(fin)
		var fc := MeshUtils.make_cylinder(0.008, 0.012, 0.01, gold, 16)
		fc.position = Vector3(s * 0.03, ey * 2.0 - 0.016, 0)
		piv.add_child(fc)
	# pedestal and carved dog inside
	for x in [-0.025, 0.025]:
		for z in [-0.02, 0.02]:
			var post := MeshUtils.make_cylinder(0.003, 0.003, 0.07, gold, 8)
			post.position = Vector3(x, 0.28, z)
			h.add_child(post)
	var platf := MeshUtils.make_rounded_box(Vector3(0.075, 0.012, 0.055), 0.004, TreasuryKit.crystal(Color(0.9, 0.78, 1.0), 0.0, 0.6, 12.0))
	platf.position.y = 0.318
	h.add_child(platf)
	var dog := Node3D.new()
	dog.position = Vector3(0, 0.324, 0)
	h.add_child(dog)
	var dm := TreasuryKit.crystal(Color(0.72, 0.5, 0.92), 0.0, 0.75, 12.0)
	for part in [[Vector3(0, 0.015, -0.004), Vector3(0.026, 0.015, 0.03)], [Vector3(0, 0.03, 0.022), Vector3(0.017, 0.016, 0.016)],
			[Vector3(0, 0.026, 0.037), Vector3(0.008, 0.006, 0.008)], [Vector3(-0.013, 0.036, 0.02), Vector3(0.006, 0.01, 0.004)],
			[Vector3(0.013, 0.036, 0.02), Vector3(0.006, 0.01, 0.004)], [Vector3(0, 0.028, -0.03), Vector3(0.012, 0.014, 0.012)],
			[Vector3(-0.012, 0.006, 0.026), Vector3(0.006, 0.006, 0.014)], [Vector3(0.012, 0.006, 0.026), Vector3(0.006, 0.006, 0.014)]]:
		var mi := MeshInstance3D.new()
		mi.mesh = ShopStones.sphere_mesh()
		mi.material_override = dm
		mi.position = part[0]
		mi.scale = part[1]
		dog.add_child(mi)

static func _galley(h: Node3D) -> void:
	var cr := TreasuryKit.crystal(Color(0.97, 0.98, 1.0), 1.0, 0.05, 40.0)
	var plain := TreasuryKit.crystal(Color(0.97, 0.98, 1.0), 0.0, 0.0)
	var gold: Material = TreasuryKit.mats()["gold"]
	var foot := TreasuryKit.lathe([Vector2(0.012, 0.13), Vector2(0.014, 0.1), Vector2(0.02, 0.05), Vector2(0.05, 0.02), Vector2(0.06, 0.006), Vector2(0.058, 0.0), Vector2(0.0, 0.0)], plain, 40)
	foot.scale = Vector3(1.0, 1.0, 0.75)
	h.add_child(foot)
	var fr := MeshUtils.make_ring(0.054, 0.062, 0.008, gold, 48)
	fr.scale = Vector3(1, 1, 0.75)
	fr.position.y = 0.006
	h.add_child(fr)
	var root := Node3D.new()
	root.position.y = 0.2
	h.add_child(root)
	var L := 0.24
	var W := 0.085
	var D := 0.085
	var hull := MeshInstance3D.new()
	hull.mesh = ShopStones._deform_sphere(56, 28, func(p: Vector3) -> Vector3:
		var y := p.y * D if p.y < 0.0 else p.y * 0.008
		y += 0.035 * pow(absf(p.x), 4.0)
		return Vector3(p.x * L, y, p.z * W * (1.0 - 0.15 * p.x * p.x)))
	hull.material_override = cr
	root.add_child(hull)
	var rail := PackedVector3Array()
	for k in range(65):
		var a := float(k) / 64.0 * TAU
		var x := cos(a)
		rail.append(Vector3(x * L, 0.006 + 0.035 * pow(absf(x), 4.0), sin(a) * W * (1.0 - 0.15 * x * x)))
	MeshUtils.sweep_tube(root, rail, 0.0045, 0.0045, gold)
	var bal := TreasuryKit.lathe([Vector2(0.0, 0.032), Vector2(0.006, 0.028), Vector2(0.004, 0.02), Vector2(0.007, 0.012), Vector2(0.003, 0.004), Vector2(0.005, 0.0), Vector2(0.0, 0.0)], plain, 12)
	var bx := []
	for s in [-1.0, 1.0]:
		for k in range(8):
			var x := lerpf(0.0, 0.8, float(k) / 7.0)
			bx.append(Transform3D(Basis(), Vector3(x * L, 0.008 + 0.035 * pow(x, 4.0), s * W * (1.0 - 0.15 * x * x) * 0.92)))
	root.add_child(GalleryDisplays._mm(bal.mesh, bx, plain))
	# deckhouse
	for x in [-0.15, -0.07]:
		for z in [-0.04, 0.04]:
			var col := MeshUtils.make_cylinder(0.005, 0.005, 0.06, plain, 10)
			col.position = Vector3(x, 0.04, z)
			root.add_child(col)
	for yy in [0.01, 0.072]:
		var pb := MeshUtils.make_rounded_box(Vector3(0.1, 0.006, 0.095), 0.002, gold)
		pb.position = Vector3(-0.11, yy, 0)
		root.add_child(pb)
	var roof := MeshInstance3D.new()
	roof.mesh = ShopStones.sphere_mesh()
	roof.material_override = cr
	roof.scale = Vector3(0.055, 0.03, 0.05)
	roof.position = Vector3(-0.11, 0.085, 0)
	root.add_child(roof)
	var curl := PackedVector3Array()
	for k in range(20):
		var t := float(k) / 19.0
		curl.append(Vector3(-0.11 + t * 0.05 + 0.012 * cos(t * 7.0), 0.11 + t * 0.03 + 0.012 * sin(t * 7.0), 0))
	MeshUtils.sweep_tube(root, curl, 0.008, 0.003, plain)
	# dragon prow (left) and eagle stern (right)
	var neck := TreasuryKit.spline([Vector3(-L * 0.95, 0.03, 0), Vector3(-L * 1.08, 0.07, 0), Vector3(-L * 1.12, 0.12, 0), Vector3(-L * 1.2, 0.14, 0)], 16)
	MeshUtils.sweep_tube(root, neck, 0.02, 0.013, plain)
	var dh := MeshInstance3D.new()
	dh.mesh = ShopStones.sphere_mesh()
	dh.material_override = cr
	dh.scale = Vector3(0.034, 0.018, 0.016)
	dh.position = Vector3(-L * 1.27, 0.145, 0)
	dh.rotation.z = -0.25
	root.add_child(dh)
	var tail := TreasuryKit.spline([Vector3(-L * 1.05, 0.06, 0), Vector3(-L * 1.12, -0.02, 0), Vector3(-L * 1.05, -0.12, 0), Vector3(-L * 0.8, -0.17, 0)], 18)
	MeshUtils.sweep_tube(root, tail, 0.011, 0.005, plain)
	MeshUtils.chain_links(root, MeshUtils.catenary(Vector3(-L * 0.8, -0.17, 0), Vector3(-0.012, -0.17, 0), 0.02, 14), 0.005, 0.0012, gold)
	var gc := MeshUtils.make_ring(0.012, 0.022, 0.012, gold, 20)
	gc.position = Vector3(-L * 1.08, 0.07, 0)
	gc.rotation.z = 0.8
	root.add_child(gc)
	var sn := TreasuryKit.spline([Vector3(L * 0.95, 0.03, 0), Vector3(L * 1.06, 0.07, 0), Vector3(L * 1.1, 0.1, 0)], 10)
	MeshUtils.sweep_tube(root, sn, 0.016, 0.012, plain)
	var eh := MeshInstance3D.new()
	eh.mesh = ShopStones.sphere_mesh()
	eh.material_override = cr
	eh.scale = Vector3(0.026, 0.022, 0.02)
	eh.position = Vector3(L * 1.13, 0.115, 0)
	root.add_child(eh)
	var beak := MeshUtils.make_cylinder(0.0, 0.01, 0.03, plain, 10)
	beak.position = Vector3(L * 1.2, 0.11, 0)
	beak.rotation.z = PI * 0.5
	root.add_child(beak)
	# carved figure on the side with wings
	var fig := TreasuryKit.spline([Vector3(0.02, -0.07, W + 0.004), Vector3(0.02, -0.03, W + 0.01), Vector3(0.02, 0.0, W + 0.012)], 8)
	MeshUtils.sweep_tube(root, fig, 0.008, 0.012, plain)
	var fh := MeshInstance3D.new()
	fh.mesh = ShopStones.sphere_mesh()
	fh.material_override = plain
	fh.scale = Vector3.ONE * 0.011
	fh.position = Vector3(0.02, 0.018, W + 0.014)
	root.add_child(fh)
	for s in [-1.0, 1.0]:
		var wing := TreasuryKit.spline([Vector3(0.02 + s * 0.01, -0.005, W + 0.01), Vector3(0.02 + s * 0.035, 0.0, W + 0.012), Vector3(0.02 + s * 0.05, -0.03, W + 0.008)], 8)
		MeshUtils.sweep_tube(root, wing, 0.007, 0.003, plain)
	var gr := MeshUtils.make_ring(0.006, 0.01, 0.004, gold, 16)
	gr.rotation.x = PI * 0.5
	gr.position = Vector3(0.02, -0.075, W + 0.01)
	root.add_child(gr)

static func _urn(root: Node3D, x: float, seed_: int) -> void:
	var lap := ShopStones.material("lapis_calcite")
	var u := Node3D.new()
	u.position.x = x
	root.add_child(u)
	var base := MeshUtils.make_rounded_box(Vector3(0.2, 0.05, 0.2), 0.006, lap)
	base.position.y = 0.025
	u.add_child(base)
	var prof := [Vector2(0.0, 0.47), Vector2(0.15, 0.49), Vector2(0.168, 0.585), Vector2(0.182, 0.6), Vector2(0.186, 0.592), Vector2(0.175, 0.57),
		Vector2(0.15, 0.45), Vector2(0.135, 0.36), Vector2(0.138, 0.33), Vector2(0.125, 0.27), Vector2(0.085, 0.225), Vector2(0.048, 0.212),
		Vector2(0.056, 0.2), Vector2(0.036, 0.18), Vector2(0.03, 0.17), Vector2(0.032, 0.12), Vector2(0.045, 0.1), Vector2(0.07, 0.07),
		Vector2(0.088, 0.055), Vector2(0.088, 0.05), Vector2(0.0, 0.05)]
	u.add_child(TreasuryKit.lathe(prof, lap, 96, func(th: float, v: float) -> float:
		var gad := smoothstep(0.38, 0.45, v) * smoothstep(0.62, 0.55, v)
		var flute := smoothstep(0.72, 0.78, v) * smoothstep(0.93, 0.88, v)
		return 1.0 + 0.07 * (absf(cos(th * 12.0)) - 0.6) * gad - 0.06 * absf(sin(th * 16.0)) * flute, 120))
	var eggs := []
	for k in range(60):
		var a := float(k) / 60.0 * TAU
		eggs.append(Transform3D(Basis().scaled(Vector3(0.006, 0.008, 0.006)), Vector3(cos(a) * 0.188, 0.598, sin(a) * 0.188)))
	u.add_child(GalleryDisplays._mm(ShopStones.sphere_mesh(), eggs, lap))
	for s in [-1.0, 1.0]:
		var hd := TreasuryKit.spline([Vector3(s * 0.13, 0.31, 0), Vector3(s * 0.19, 0.33, 0), Vector3(s * 0.215, 0.38, 0), Vector3(s * 0.2, 0.43, 0), Vector3(s * 0.17, 0.42, 0), Vector3(s * 0.175, 0.39, 0)], 24)
		MeshUtils.sweep_tube(u, hd, 0.018, 0.009, lap)
	var cream := StandardMaterial3D.new()
	cream.albedo_color = Color(0.78, 0.66, 0.45)
	cream.roughness = 0.3
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	for k in range(5):
		var a := -0.9 + float(k) * 0.45 + rng.randf_range(-0.05, 0.05) + PI * 0.5
		var r := 0.152
		var y := 0.5
		var dd := Vector3(cos(a), 0, sin(a))
		var body := MeshInstance3D.new()
		body.mesh = ShopStones.sphere_mesh()
		body.material_override = cream if k == 2 else lap
		body.transform = Transform3D(TreasuryKit.frame(dd, UP).scaled(Vector3(0.018, 0.008, 0.055)), dd * r + Vector3(0, y, 0))
		u.add_child(body)
		var hd2 := MeshInstance3D.new()
		hd2.mesh = ShopStones.sphere_mesh()
		hd2.material_override = body.material_override
		hd2.scale = Vector3.ONE * 0.011
		hd2.position = dd * (r + 0.004) + Vector3(0, y + 0.062, 0)
		u.add_child(hd2)

static func _urns(h: Node3D) -> void:
	_urn(h, -0.3, 1)
	_urn(h, 0.3, 2)

static func _lapis_ewer(h: Node3D) -> void:
	var lap := ShopStones.material("lapis_calcite")
	var gold: Material = TreasuryKit.mats()["gold"]
	var foot := TreasuryKit.lathe([Vector2(0.03, 0.045), Vector2(0.06, 0.03), Vector2(0.09, 0.012), Vector2(0.092, 0.0), Vector2(0.0, 0.0)], gold, 48)
	foot.scale = Vector3(1.25, 1.0, 1.0)
	h.add_child(foot)
	var stem := TreasuryKit.lathe([Vector2(0.03, 0.17), Vector2(0.022, 0.15), Vector2(0.02, 0.1), Vector2(0.026, 0.06), Vector2(0.034, 0.045)], lap, 32)
	h.add_child(stem)
	var knop := MeshUtils.make_ring(0.02, 0.032, 0.014, gold, 32)
	knop.position.y = 0.1
	h.add_child(knop)
	var rim_y := func(th: float) -> float:
		var spout := exp(-pow(wrapf(th - PI, -PI, PI) / 0.5, 2.0))
		var back := exp(-pow(wrapf(th, -PI, PI) / 0.7, 2.0))
		return 0.29 + 0.08 * spout + 0.04 * back + 0.012 * sin(th * 5.0)
	var outer := func(u: float, v: float) -> Vector3:
		var th := u * TAU
		var r := lerpf(0.13, 0.03, pow(v, 1.6)) * (1.0 + 0.04 * cos(th * 14.0) * smoothstep(0.4, 0.85, v))
		var sx := 1.35 + 0.2 * exp(-pow(wrapf(th - PI, -PI, PI) / 0.5, 2.0)) * (1.0 - v)
		var y := lerpf(float(rim_y.call(th)), 0.17, pow(v, 1.2))
		return Vector3(cos(th) * r * sx, y, sin(th) * r)
	h.add_child(TreasuryKit.surface(outer, 96, 24, lap))
	var inner := func(u: float, v: float) -> Vector3:
		var p: Vector3 = outer.call(1.0 - u, v)
		return Vector3(p.x * 0.92, p.y + 0.012 * v, p.z * 0.92)
	h.add_child(TreasuryKit.surface(inner, 96, 24, lap))
	var lip := PackedVector3Array()
	for k in range(97):
		var p: Vector3 = outer.call(float(k) / 96.0, 0.0)
		lip.append(p * Vector3(0.96, 1.0, 0.96))
	MeshUtils.sweep_tube(h, lip, 0.006, 0.006, lap)
	# triton handle at the back (+x): torso, head, arm with conch, fish tail
	var torso := TreasuryKit.spline([Vector3(0.17, 0.3, 0), Vector3(0.17, 0.36, 0), Vector3(0.14, 0.41, 0)], 8)
	MeshUtils.sweep_tube(h, torso, 0.022, 0.016, gold)
	var head := MeshInstance3D.new()
	head.mesh = ShopStones.sphere_mesh()
	head.material_override = gold
	head.scale = Vector3.ONE * 0.019
	head.position = Vector3(0.115, 0.432, 0)
	h.add_child(head)
	var arm := TreasuryKit.spline([Vector3(0.14, 0.4, 0.012), Vector3(0.11, 0.42, 0.02), Vector3(0.085, 0.44, 0.012)], 8)
	MeshUtils.sweep_tube(h, arm, 0.007, 0.006, gold)
	var horn := TreasuryKit.lathe([Vector2(0.004, 0.0), Vector2(0.006, 0.03), Vector2(0.014, 0.05), Vector2(0.018, 0.055)], gold, 16)
	horn.position = Vector3(0.1, 0.44, 0.0)
	horn.rotation.z = 1.1
	h.add_child(horn)
	var tail := TreasuryKit.spline([Vector3(0.17, 0.3, 0), Vector3(0.19, 0.24, 0.0), Vector3(0.17, 0.2, 0.0), Vector3(0.13, 0.21, 0.0), Vector3(0.12, 0.24, 0.0)], 20)
	MeshUtils.sweep_tube(h, tail, 0.016, 0.006, gold)
	for s in [-1.0, 1.0]:
		var fin := TreasuryKit.spline([Vector3(0.12, 0.24, 0), Vector3(0.1, 0.25 + s * 0.012, s * 0.015), Vector3(0.09, 0.27 + s * 0.02, s * 0.02)], 6)
		MeshUtils.sweep_tube(h, fin, 0.006, 0.002, gold)

static func _crystal_ewer(h: Node3D) -> void:
	var cr := TreasuryKit.crystal(Color(0.97, 0.98, 1.0), 1.0, 0.04, 45.0)
	var gold: Material = TreasuryKit.mats()["gold"]
	var items := []
	var cols := []
	var beads := []
	var body_prof := [Vector2(0.0, 0.47), Vector2(0.03, 0.47), Vector2(0.032, 0.42), Vector2(0.045, 0.38), Vector2(0.09, 0.3), Vector2(0.126, 0.21),
		Vector2(0.128, 0.15), Vector2(0.1, 0.085), Vector2(0.06, 0.065), Vector2(0.0, 0.065)]
	h.add_child(TreasuryKit.lathe(body_prof, cr, 64, Callable(), 40))
	var foot := TreasuryKit.lathe([Vector2(0.06, 0.07), Vector2(0.07, 0.04), Vector2(0.11, 0.02), Vector2(0.12, 0.0), Vector2(0.0, 0.0)], gold, 64)
	h.add_child(foot)
	var gem_ring := func(y: float, r: float, n: int, sz: float) -> void:
		for k in range(n):
			var a := float(k) / float(n) * TAU
			var dd := TreasuryKit.d(a)
			var p := dd * r + Vector3(0, y, 0)
			var em := k % 2 == 0
			TreasuryKit.gem(items, "emerald" if em else "cab_ruby", "emerald" if em else "cabochon", p, dd, UP, sz)
			TreasuryKit.collet(cols, p, dd, UP, sz * 1.1, 1.0, 0.75, em)
	for band in [[0.06, 0.062, 0.012], [0.38, 0.046, 0.01], [0.42, 0.034, 0.01], [0.466, 0.032, 0.012], [0.15, 0.13, 0.008]]:
		var rr := MeshUtils.make_ring(float(band[1]) - 0.004, float(band[1]) + 0.004, float(band[2]), gold, 48)
		rr.position.y = band[0]
		h.add_child(rr)
	gem_ring.call(0.03, 0.105, 10, 0.012)
	gem_ring.call(0.4, 0.043, 8, 0.0065)
	# vertical straps
	for k in range(4):
		var a := float(k) * PI * 0.5 + PI * 0.25
		var dd := TreasuryKit.d(a)
		var pts := PackedVector3Array()
		for i in range(25):
			var v := lerpf(0.88, 0.2, float(i) / 24.0)
			var p := TreasuryKit.prof_at(body_prof, v)
			pts.append(dd * (p.x + 0.004) + Vector3(0, p.y, 0))
		MeshUtils.sweep_tube(h, pts, 0.006, 0.006, gold)
		for i in range(2, 24, 3):
			var p := pts[i]
			var nrm := (dd + Vector3(0, 0.3, 0)).normalized()
			var em := (i / 3) % 2 == 0
			TreasuryKit.gem(items, "emerald" if em else "cab_ruby", "emerald" if em else "cabochon", p + dd * 0.004, dd, UP, 0.0085)
			TreasuryKit.collet(cols, p + dd * 0.003, dd, UP, 0.0095, 1.0, 0.72, em)
			TreasuryKit.ball(beads, pts[i + 1] + dd * 0.006, 0.0032)
	var lid := TreasuryKit.lathe([Vector2(0.0, 0.53), Vector2(0.015, 0.525), Vector2(0.03, 0.505), Vector2(0.036, 0.48), Vector2(0.034, 0.47)], gold, 48)
	h.add_child(lid)
	gem_ring.call(0.49, 0.033, 8, 0.006)
	TreasuryKit.gem(items, "emerald", "pear", Vector3(0, 0.555, 0), Vector3.BACK, UP, 0.014)
	TreasuryKit.ball(beads, Vector3(0, 0.535, 0), 0.008)
	var spout := TreasuryKit.spline([Vector3(-0.03, 0.44, 0), Vector3(-0.07, 0.47, 0), Vector3(-0.1, 0.51, 0), Vector3(-0.125, 0.53, 0)], 14)
	MeshUtils.sweep_tube(h, spout, 0.015, 0.006, gold)
	var handle := TreasuryKit.spline([Vector3(0.03, 0.46, 0), Vector3(0.1, 0.49, 0), Vector3(0.15, 0.44, 0), Vector3(0.15, 0.33, 0), Vector3(0.13, 0.25, 0), Vector3(0.12, 0.2, 0)], 30)
	MeshUtils.sweep_tube(h, handle, 0.009, 0.007, gold)
	for i in range(3, 28, 4):
		var t := (handle[i + 1] - handle[i - 1]).normalized()
		var n := Vector3(t.y, -t.x, 0).normalized()
		if n.x < 0.0:
			n = -n
		var em := (i / 4) % 2 == 0
		TreasuryKit.gem(items, "emerald" if em else "cab_ruby", "emerald" if em else "cabochon", handle[i] + Vector3(0, 0, 0.009), Vector3.BACK, t, 0.0065)
	h.add_child(TreasuryKit.balls(beads, gold))
	h.add_child(TreasuryKit.collet_node(cols, gold))
	h.add_child(GemFactory.make_set(items))

static func _ur(h: Node3D) -> void:
	var mos := ShopStones.material("ur_mosaic")
	var Lh := 0.495
	var H := 0.435
	var db := 0.12
	var dt := 0.055
	var tilt := atan((db - dt) / H)
	for s in [-1.0, 1.0]:
		var face := AncientTreasures._extrude(PackedVector2Array([Vector2(-Lh, -H * 0.5), Vector2(Lh, -H * 0.5), Vector2(Lh, H * 0.5), Vector2(-Lh, H * 0.5)]), 0.012, mos)
		face.position = Vector3(0, H * 0.5, s * (db + dt) * 0.5)
		face.rotation = Vector3(-tilt, 0.0 if s > 0.0 else PI, 0)
		h.add_child(face)
		var end := AncientTreasures._extrude(PackedVector2Array([Vector2(-db, -H * 0.5), Vector2(db, -H * 0.5), Vector2(dt, H * 0.5), Vector2(-dt, H * 0.5)]), 0.012, mos)
		end.position = Vector3(s * Lh, H * 0.5, 0)
		end.rotation.y = s * PI * 0.5
		h.add_child(end)
	var top := MeshUtils.make_rounded_box(Vector3(Lh * 2.0, 0.01, dt * 2.0 + 0.01), 0.002, GalleryDisplays._mats()["black"])
	top.position.y = H + 0.002
	h.add_child(top)

static func _obsidian(h: Node3D) -> void:
	var st := MeshUtils.make_rounded_box(Vector3(0.14, 0.03, 0.1), 0.006, TreasuryKit.mats()["black_plastic"])
	st.position.y = 0.015
	h.add_child(st)
	var mi := MeshInstance3D.new()
	mi.mesh = ShopStones.tumbled_mesh(3)
	mi.material_override = ShopStones.material("rainbow_obsidian")
	mi.scale = Vector3(0.16, 0.2, 0.11)
	mi.rotation = Vector3(-0.3, 0.2, 0.0)
	mi.position.y = 0.2
	h.add_child(mi)

static func _galaxy(h: Node3D) -> void:
	var steel: Material = TreasuryKit.mats()["steel"]
	var base := MeshUtils.make_rounded_box(Vector3(0.24, 0.03, 0.16), 0.008, TreasuryKit.mats()["black_plastic"])
	base.position.y = 0.015
	h.add_child(base)
	var post := MeshUtils.make_cylinder(0.008, 0.01, 0.16, steel, 12)
	post.position = Vector3(-0.08, 0.11, 0)
	h.add_child(post)
	var gem := MeshInstance3D.new()
	gem.mesh = GemCuts.mesh("emerald")
	gem.material_override = TreasuryKit.galaxy()
	gem.transform = Transform3D(TreasuryKit.frame(Vector3(0, 0.25, 1).normalized(), Vector3(cos(-0.45), sin(-0.45), 0)).scaled(Vector3.ONE * 0.075), Vector3(0.03, 0.24, 0.0))
	h.add_child(gem)
	var acr := TreasuryKit.crystal(Color(0.95, 0.97, 1.0), 0.0, 0.08)
	for s in [-1.0, 1.0]:
		var arm := MeshUtils.make_rounded_box(Vector3(0.2, 0.012, 0.006), 0.002, acr)
		arm.transform = Transform3D(Basis(Vector3.FORWARD, -0.45 + s * 0.04), Vector3(-0.045, 0.255 + s * 0.012, 0.0))
		h.add_child(arm)

static func _kite_star(h: Node3D) -> void:
	var top := TreasuryKit.gem_box(h, Vector2(0.34, 0.34), TreasuryKit.mats()["white_foam"], TreasuryKit.mats()["white_foam"])
	var items := []
	var stones := ["olive_tourm", "heliodor", "olive_tourm", "pale_heliodor", "olive_tourm", "heliodor"]
	for k in range(6):
		var a := float(k) / 6.0 * TAU
		var dir := Vector3(cos(a), 0, sin(a))
		TreasuryKit.gem(items, stones[k], "kite", dir * 0.026 + Vector3(0, 0.012, 0), UP, dir, 0.04)
	top.add_child(GemFactory.make_set(items))

static func _mint_card(h: Node3D) -> void:
	var top := TreasuryKit.gem_box(h, Vector2(0.27, 0.38), TreasuryKit.mats()["white_foam"], TreasuryKit.mats()["white_foam"], 0.6)
	var items := []
	for g in [[Vector2(-0.05, -0.1), "mint_tourm", "oval", 0.028], [Vector2(0.06, -0.06), "mint_tourm", "pear", 0.02], [Vector2(-0.07, -0.01), "mint_tourm", "pear", 0.02],
			[Vector2(0.01, 0.02), "teal_tourm", "pear", 0.021], [Vector2(-0.04, 0.08), "teal_tourm", "pear", 0.021], [Vector2(0.05, 0.1), "mint_tourm", "pear", 0.027],
			[Vector2(0.09, -0.14), "grey_spinel", "round", 0.011], [Vector2(-0.09, 0.15), "teal_tourm", "round", 0.012]]:
		var q: Vector2 = g[0]
		TreasuryKit.gem(items, g[1], g[2], Vector3(q.x, 0.012, q.y), UP, Vector3(0, 0, -1) if g[2] == "pear" else Vector3(0.3, 0, -1).normalized(), g[3])
	top.add_child(GemFactory.make_set(items))

static func _hex_boxes(h: Node3D) -> void:
	var items_by_box := [
		["citrine", "white_topaz", "aquamarine", "lemon_quartz", "demantoid", "blue_topaz", "white_topaz", "smoky_quartz", "aquamarine", "peridot",
			"teal_tourm", "london_topaz", "emerald", "tsavorite", "iolite", "white_topaz", "blue_chalcedony", "prasiolite", "mint_tourm", "tanzanite", "zircon_blue"],
		["white_topaz", "rose_quartz", "smoky_quartz", "amethyst", "pale_amethyst", "rhodolite", "pink_tourm", "watermelon", "citrine", "imperial_topaz",
			"red_spinel", "morganite", "sunstone", "yellow_opal", "garnet", "lemon_quartz", "pink_sapph", "smoky_dark", "rubellite", "spessartite", "white_topaz"],
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = 314
	for bi in range(2):
		var holder := Node3D.new()
		holder.position.x = -0.2 + bi * 0.4
		h.add_child(holder)
		var top := TreasuryKit.gem_box(holder, Vector2(0.32, 0.4), TreasuryKit.crystal(Color(0.95, 0.97, 1.0), 0.0, 0.05), TreasuryKit.mats()["black_velvet"], 0.5)
		var items := []
		var list: Array = items_by_box[bi]
		var placed := []
		for st in list:
			var sz := rng.randf_range(0.014, 0.03)
			for t in range(200):
				var q := Vector2(rng.randf_range(-0.13, 0.13), rng.randf_range(-0.17, 0.17))
				var ok := absf(q.x) + sz * 0.5 < 0.14 and absf(q.y) + sz < 0.18
				for p in placed:
					if q.distance_to(p[0]) < (sz + float(p[1])) * 1.0 + 0.006:
						ok = false
						break
				if ok:
					placed.append([q, sz])
					TreasuryKit.gem(items, st, "hexagon", Vector3(q.x, 0.01, q.y), UP, Vector3(0, 0, 1).rotated(UP, rng.randf_range(-0.25, 0.25)), sz)
					break
		top.add_child(GemFactory.make_set(items))
	for bi in range(2):
		var holder2 := Node3D.new()
		holder2.position = Vector3(-0.08 + bi * 0.16, 0, 0.3)
		h.add_child(holder2)
		var top2 := TreasuryKit.gem_box(holder2, Vector2(0.13, 0.13), TreasuryKit.mats()["white_foam"], ShopStones.material("selenite") if bi == 0 else TreasuryKit.mats()["cream"], 0.4)
		var items2 := []
		TreasuryKit.gem(items2, "neon_apatite" if bi == 0 else "miyake_glass", "hexagon", Vector3(0, 0.01, 0), UP, Vector3(0, 0, 1), 0.03)
		top2.add_child(GemFactory.make_set(items2))
