class_name AncientTreasures

# ═══════════════════════════════════════════════════════════════════════════
# ANCIENT TREASURES — museum-replica pieces flanking the Legendary Gems hall:
# Ancient Egypt on one side (lapis lazuli, gold, carnelian, faience) and the
# Classic Maya on the other (jadeite, obsidian, shell). Replicas are shown
# about 2.5x real size on plinths with plaques.
#
#   AncientTreasures.build(gallery, hall_start: Vector3)
# ═══════════════════════════════════════════════════════════════════════════

const EGYPT := [
	["scarab", "Lapis Lazuli Heart Scarab", "New Kingdom, c. 1550-1070 BC",
		"Lapis set in gold. Placed over the heart of the mummy; lapis came 4,000 km from Badakhshan, Afghanistan."],
	["collar", "Broad Collar (Wesekh)", "18th Dynasty, c. 1330 BC",
		"Rows of lapis, carnelian, turquoise-blue faience and gold beads, like those found with Tutankhamun."],
	["eye", "Eye of Horus (Wedjat) Pendant", "New Kingdom",
		"Amulet of protection and healing: gold cloisons inlaid with lapis lazuli."],
	["ankh", "Ankh of Gold and Lapis", "New Kingdom",
		"The hieroglyph for 'life', carried by the gods. Lapis meant the night sky and the hair of the gods."],
	["shabti", "Faience Shabti Figure", "Third Intermediate Period, c. 1000 BC",
		"Servant figure placed in tombs to work for the dead in the afterlife. Glazed quartz paste."],
	["lapis_necklace", "Lapis and Gold Bead Necklace", "Middle Kingdom, c. 1900 BC",
		"Egyptians called lapis 'khesbed' and prized it above gold for royal jewellery."],
	["pectoral", "Scarab Pectoral with Beaded Straps", "Replica in the style of Tutankhamun, c. 1330 BC",
		"Khepri the scarab pushes the sun (a carnelian disc) in the solar barque. Lapis, carnelian, turquoise and gold cloisonne."],
	["cuff", "Lapis Scarab Cuff", "Replica, New Kingdom style",
		"Gold cuff with a carved, ribbed lapis scarab framed by inlaid lapis, turquoise, carnelian and white stone."],
	["raw_scarab", "Carved Lapis Lazuli Scarab", "Badakhshan lapis, hand carved",
		"Unpolished lapis shows what the stone really is: blue lazurite, golden pyrite and grey-white calcite."],
	["tut_mask", "Funerary Mask of Tutankhamun", "18th Dynasty, c. 1323 BC (replica)",
		"10 kg of gold inlaid with lapis lazuli, carnelian, quartz, obsidian, turquoise and glass. Original: Grand Egyptian Museum, Giza."],
	["signet", "Lapis Lazuli Intaglio Seal Ring", "Gold and lapis (replica)",
		"A crest carved into the lapis in reverse, so it prints the right way round when pressed into wax."],
	["triple", "Triple-Strand Lapis and Gold Necklace", "Inspired by Egyptian royal jewellery",
		"Graduated lapis beads and gold spacers ending in a gold lotus-fan pendant."],
]

const MAYA := [
	["mask", "Jade Mosaic Mask of K'inich Janaab Pakal", "Palenque, Classic Maya, 683 AD",
		"Over 340 jadeite tesserae with shell and obsidian eyes. Original: National Museum of Anthropology, Mexico City."],
	["earspools", "Jadeite Ear Spools", "Classic Maya, 250-900 AD",
		"Ear flares worn by Maya nobility; jadeite from the Motagua Valley, Guatemala."],
	["eccentric", "Obsidian Eccentric", "Classic Maya, Copan / Tikal",
		"Ceremonial flaked blade of volcanic glass, offered in temple caches."],
	["jade_necklace", "Jadeite Bead Necklace with Pendant", "Classic Maya",
		"To the Maya, green jade meant water, maize and life itself, worth more than gold."],
	["jade_plaque", "Carved Jade Ruler Plaque", "Late Classic Maya",
		"Flat jade pendant carved with a seated lord in profile."],
	["obsidian_mirror", "Polished Obsidian Mirror", "Mesoamerica",
		"Black volcanic-glass mirror used for divination and in royal regalia."],
]

const BOUTIQUE := [
	["pouch", "Hieroglyph Pouch", "Modern lapis-print design", "Gold hieroglyphs, the Eye of Horus and scarabs on lapis-blue cloth."],
	["bangles", "Eye of Horus Bangles", "In the style of Tutankhamun's bracelets", "Lapis panels between gold bars, the wedjat eye, and chequered borders of gold and carnelian."],
	["slabs", "Faceted Lapis Slab Necklace", "Modern statement piece", "Graduated freeform lapis slabs, each with polished facets, strung with silver spacers."],
	["lapis_ring", "Carved Lapis Ring", "Ring cut from a single piece of lapis", "Shank and bezel are one stone, with a scarab carved on top."],
	["gold_scarab", "Lapis Scarab with Gold Base", "Egyptian revival", "Polished lapis beetle with pyrite, set on a gold base engraved with hieroglyphs."],
	["broad_collar", "Broad Collar with Gold Scarab", "Egyptian revival", "Rows of teal, lapis and carnelian cells in gold, a gold scarab centre and a lapis drop."],
	["relief", "Gold Relief Pendant", "Egyptian revival", "Gold plaque of offering figures, blue glass beads and a mother-of-pearl drop."],
	["aura", "Titanium Aura Quartz", "Treated quartz cluster", "Quartz points coated with vaporised titanium, giving a rainbow metallic sheen."],
	["tree", "Lapis Gem Tree", "Wire-wrapped gem tree", "Gold wire branches carrying tumbled lapis chips on a wooden base."],
	["lapis_beads", "Lapis Bead Necklace", "6 mm round beads", "Afghan lapis rounds with pyrite flecks and a silver clasp."],
	["jade_beads", "Nephrite Jade Bead Necklace", "6 mm round beads", "Mottled spinach-green nephrite with a gold clasp."],
	["jade_bracelet", "Jade Macrame Bracelet", "Square cut beads on cord", "Square jade beads knotted on black cord with a gold bar."],
]

static var _gold: StandardMaterial3D

static func gold() -> StandardMaterial3D:
	if _gold == null:
		_gold = StandardMaterial3D.new()
		_gold.albedo_color = Color(0.95, 0.74, 0.34)
		_gold.metallic = 1.0
		_gold.roughness = 0.2
	return _gold

static func build(g: Node3D, start: Vector3) -> void:
	var mats := GalleryDisplays._mats()
	for side in [-1.0, 1.0]:
		var list: Array = EGYPT if side < 0.0 else MAYA + BOUTIQUE
		if side > 0.0:
			g._label("Lapis & Jade Boutique  -  replicas and modern pieces", start + Vector3(7.0, 2.6, 1.6 + float(MAYA.size()) * 3.0 - 1.4), 0.0028)
		var length := float(list.size()) * 3.0 + 3.0
		var floor_c := start + Vector3(side * 7.0, -0.01, length * 0.5 - 0.5)
		GalleryDisplays._box(g, Vector3(5.0, 0.02, length), floor_c, mats["black"], true)
		var title := "Ancient Egypt  -  lapis lazuli, gold and carnelian" if side < 0.0 else "The Classic Maya  -  jade, obsidian and shell"
		g._label(title, start + Vector3(side * 7.0, 2.6, 0.2), 0.0032)
		for i in range(list.size()):
			var e: Array = list[i]
			var base := start + Vector3(side * 7.6, 0, 1.6 + float(i) * 3.0)
			var top := 1.05
			GalleryDisplays._box(g, Vector3(0.7, top, 0.7), base + Vector3(0, top * 0.5, 0), mats["black"], true)
			GalleryDisplays._box(g, Vector3(0.66, 0.02, 0.66), base + Vector3(0, top + 0.01, 0), mats["velvet"])
			var holder := Node3D.new()
			holder.position = base + Vector3(0, top + 0.02, 0)
			holder.rotation.y = -side * PI * 0.5          # local +Z faces the hall
			g.add_child(holder)
			_make(String(e[0]), holder)
			GalleryDisplays._spot(g, base + Vector3(-side * 1.6, 2.9, -0.5), holder.position + Vector3(0, 0.15, 0), 2.6, 18.0)
			var lb := Label3D.new()
			lb.text = "%s\n%s\n%s" % [e[1], e[2], e[3]]
			lb.font_size = 24
			lb.pixel_size = 0.0012
			lb.outline_size = 6
			lb.width = 620.0
			lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lb.modulate = Color(0.95, 0.9, 0.78)
			lb.position = base + Vector3(-side * 0.36, top * 0.7, 0)
			lb.rotation.y = -side * PI * 0.5
			g.add_child(lb)

static func _make(kind: String, h: Node3D) -> void:
	match kind:
		"scarab": _scarab(h)
		"collar": _collar(h)
		"eye": _eye(h)
		"ankh": _ankh(h)
		"shabti": _shabti(h)
		"lapis_necklace": _necklace(h, "lapis", true)
		"pectoral": _pectoral(h)
		"cuff": _cuff(h)
		"raw_scarab": _raw_scarab(h)
		"pouch": _pouch(h)
		"bangles": _bangles(h)
		"slabs": _slabs(h)
		"lapis_ring": _lapis_ring(h)
		"gold_scarab": _gold_scarab(h)
		"broad_collar": _broad_collar(h)
		"relief": _relief(h)
		"aura": _aura(h)
		"tree": _tree(h)
		"lapis_beads": _bead_strand(h, ShopStones.material("lapis"), _silver(), Color(0.72, 0.72, 0.72))
		"jade_beads": _bead_strand(h, ShopStones.material("jade_maya"), gold(), Color(0.72, 0.72, 0.72))
		"jade_bracelet": _jade_bracelet(h)
		"tut_mask": _tut_mask(h)
		"signet": _signet(h)
		"triple": _triple(h)
		"mask": _mask(h)
		"earspools": _earspools(h)
		"eccentric": _eccentric(h)
		"jade_necklace": _necklace(h, "jade_maya", false)
		"jade_plaque": _plaque(h)
		"obsidian_mirror": _mirror(h)

# ── helpers ──────────────────────────────────────────────────────────────────
static func _mi(mesh: Mesh, mat: Material, pos: Vector3, scl: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.mesh = mesh
	m.material_override = mat
	m.position = pos
	m.scale = scl
	m.rotation = rot
	return m

## Extrude a 2D outline (x right, y up) along Z, centred on z = 0.
static func _extrude(poly: PackedVector2Array, depth: float, mat: Material) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hz := depth * 0.5
	var tris := Geometry2D.triangulate_polygon(poly)
	for i in range(0, tris.size(), 3):
		var a := poly[tris[i]]
		var b := poly[tris[i + 1]]
		var c := poly[tris[i + 2]]
		MeshUtils._face_tri(st, Vector3(a.x, a.y, hz), Vector3(b.x, b.y, hz), Vector3(c.x, c.y, hz), Vector3.BACK)
		MeshUtils._face_tri(st, Vector3(a.x, a.y, -hz), Vector3(b.x, b.y, -hz), Vector3(c.x, c.y, -hz), Vector3.FORWARD)
	var area := 0.0
	for i in range(poly.size()):
		var p0 := poly[i]
		var p1 := poly[(i + 1) % poly.size()]
		area += p0.x * p1.y - p1.x * p0.y
	for i in range(poly.size()):
		var p0 := poly[i]
		var p1 := poly[(i + 1) % poly.size()]
		var e := p1 - p0
		var n2 := Vector2(e.y, -e.x).normalized()
		if area < 0.0:
			n2 = -n2
		MeshUtils._face_quad(st, Vector3(p0.x, p0.y, hz), Vector3(p1.x, p1.y, hz), Vector3(p1.x, p1.y, -hz), Vector3(p0.x, p0.y, -hz), Vector3(n2.x, n2.y, 0))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	return mi

static func _ellipse(rx: float, ry: float, n: int, cx := 0.0, cy := 0.0) -> PackedVector2Array:
	var out := PackedVector2Array()
	for k in range(n):
		var a := float(k) / float(n) * TAU
		out.append(Vector2(cx + cos(a) * rx, cy + sin(a) * ry))
	return out

# ── EGYPT ───────────────────────────────────────────────────────────────────
static func _scarab(h: Node3D) -> void:
	var sph := ShopStones.sphere_mesh()
	h.add_child(_mi(sph, gold(), Vector3(0, 0.012, 0), Vector3(0.14, 0.012, 0.19)))
	var sc := MeshInstance3D.new()
	sc.mesh = scarab_mesh(false)
	sc.material_override = ShopStones.material("lapis")
	sc.scale = Vector3.ONE * 0.17
	sc.position = Vector3(0, 0.024 + 0.17 * 0.063, 0)
	h.add_child(sc)

static func _collar(h: Node3D) -> void:
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.5
	cyl.bottom_radius = 0.5
	cyl.height = 1.0
	cyl.radial_segments = 10
	var sph := ShopStones.sphere_mesh()
	var root := Node3D.new()
	root.rotation.x = 0.35          # tilted toward the viewer
	root.position = Vector3(0, 0.06, -0.05)
	h.add_child(root)
	var rows := [["lapis", 0], ["gold", 1], ["carnelian", 0], ["faience", 0], ["lapis", 0], ["gold", 0], ["carnelian", 0], ["mixed", 2]]
	var groups := {}
	for k in range(rows.size()):
		var r := 0.09 + float(k) * 0.026
		var kind: String = rows[k][0]
		var shape: int = rows[k][1]
		var n := int(PI * r / (0.014 if shape == 1 else 0.012))
		for i in range(n + 1):
			var a := PI * float(i) / float(n)
			var radial := Vector3(cos(a), 0, -sin(a))
			var mat_key := kind
			if kind == "mixed":
				mat_key = ["lapis", "carnelian", "faience"][i % 3]
			var xf: Transform3D
			if shape == 0:          # tube bead pointing outward
				var b := Basis(Vector3.UP.cross(radial).normalized(), PI * 0.5).scaled(Vector3(0.011, 0.022, 0.011))
				xf = Transform3D(Basis.looking_at(radial, Vector3.UP) * Basis(Vector3.RIGHT, PI * 0.5) * Basis().scaled(Vector3(0.011, 0.022, 0.011)), radial * r)
			elif shape == 1:        # small gold ball
				xf = Transform3D(Basis().scaled(Vector3.ONE * 0.006), radial * r)
			else:                   # teardrop pendant
				xf = Transform3D(Basis.looking_at(radial, Vector3.UP) * Basis().scaled(Vector3(0.009, 0.006, 0.016)), radial * (r + 0.006))
			var key := "%s:%d" % [mat_key, 1 if shape == 0 else 0]
			if not groups.has(key):
				groups[key] = []
			groups[key].append(xf)
	for key in groups:
		var parts := String(key).split(":")
		var mat: Material = gold() if parts[0] == "gold" else ShopStones.material(parts[0])
		root.add_child(GalleryDisplays._mm(cyl if parts[1] == "1" else sph, groups[key], mat))
	# falcon-head terminals at both ends
	for sgn in [-1.0, 1.0]:
		var t := _mi(sph, gold(), Vector3(sgn * 0.19, 0, 0.0), Vector3(0.035, 0.012, 0.03))
		root.add_child(t)
		root.add_child(_mi(sph, ShopStones.material("lapis"), Vector3(sgn * 0.19, 0.008, 0.0), Vector3(0.012, 0.008, 0.012)))

static func _eye(h: Node3D) -> void:
	var lapis := ShopStones.material("lapis")
	var root := Node3D.new()
	root.position = Vector3(0, 0.22, 0)
	h.add_child(root)
	# gold backplate in the eye's silhouette
	var plate := PackedVector2Array()
	for k in range(24):
		var a := float(k) / 24.0 * TAU
		plate.append(Vector2(cos(a) * 0.16, sin(a) * (0.07 if sin(a) < 0.0 else 0.1) + 0.0))
	root.add_child(_extrude(plate, 0.02, gold()))
	# white eyeball (shell) and lapis pupil
	var white := _extrude(_ellipse(0.11, 0.045, 24), 0.008, ShopStones.material("shell"))
	white.position.z = 0.012
	root.add_child(white)
	var pupil := _extrude(_ellipse(0.04, 0.04, 20), 0.01, lapis)
	pupil.position.z = 0.016
	root.add_child(pupil)
	# lapis brow and eye outline, the cheek marking and spiral tail
	MeshUtils.sweep_tube(root, MeshUtils.catenary(Vector3(-0.15, 0.115, 0.012), Vector3(0.16, 0.115, 0.012), -0.03, 12), 0.012, 0.012, lapis)
	var outline := PackedVector3Array()
	for k in range(25):
		var a := float(k) / 24.0 * TAU
		outline.append(Vector3(cos(a) * 0.12, sin(a) * 0.055, 0.014))
	MeshUtils.sweep_tube(root, outline, 0.008, 0.008, lapis)
	MeshUtils.sweep_tube(root, PackedVector3Array([Vector3(-0.02, -0.05, 0.012), Vector3(-0.03, -0.11, 0.012), Vector3(-0.035, -0.16, 0.012)]), 0.01, 0.013, lapis)
	var spiral := PackedVector3Array()
	for k in range(22):
		var t := float(k) / 21.0
		var a := -PI * 0.5 + t * TAU * 1.1
		var r := 0.05 * (1.0 - t * 0.7)
		spiral.append(Vector3(0.03 + t * 0.06 + cos(a) * r, -0.11 + sin(a) * r, 0.012))
	MeshUtils.sweep_tube(root, spiral, 0.01, 0.006, lapis)
	# small gold stand
	var st := MeshUtils.make_rounded_box(Vector3(0.1, 0.06, 0.06), 0.004, gold())
	st.position = Vector3(0, -0.19, -0.02)
	root.add_child(st)

static func _ankh(h: Node3D) -> void:
	var lapis := ShopStones.material("lapis")
	var root := Node3D.new()
	root.position = Vector3(0, 0.0, 0)
	h.add_child(root)
	var loop := MeshUtils.make_revolved([Vector2(0.06, -0.012), Vector2(0.09, -0.012), Vector2(0.09, 0.012), Vector2(0.06, 0.012), Vector2(0.06, -0.012)], gold(), 48)
	loop.rotation.x = PI * 0.5
	loop.scale = Vector3(1.0, 1.0, 1.3)
	loop.position = Vector3(0, 0.46, 0)
	root.add_child(loop)
	root.add_child(_mi(BoxMesh.new(), gold(), Vector3(0, 0.2, 0), Vector3(0.05, 0.36, 0.024)))
	root.add_child(_mi(BoxMesh.new(), gold(), Vector3(0, 0.34, 0), Vector3(0.3, 0.05, 0.024)))
	# lapis inlays on the front
	root.add_child(_mi(BoxMesh.new(), lapis, Vector3(0, 0.2, 0.013), Vector3(0.028, 0.32, 0.006)))
	root.add_child(_mi(BoxMesh.new(), lapis, Vector3(0, 0.34, 0.013), Vector3(0.27, 0.028, 0.006)))
	var inl := MeshUtils.make_revolved([Vector2(0.068, -0.004), Vector2(0.082, -0.004), Vector2(0.082, 0.004), Vector2(0.068, 0.004), Vector2(0.068, -0.004)], lapis, 48)
	inl.rotation.x = PI * 0.5
	inl.scale = Vector3(1.0, 1.0, 1.3)
	inl.position = Vector3(0, 0.46, 0.013)
	root.add_child(inl)
	root.add_child(_mi(BoxMesh.new(), gold(), Vector3(0, 0.01, 0), Vector3(0.16, 0.02, 0.1)))

static func _shabti(h: Node3D) -> void:
	var prof := [Vector2(0.0, 0.0), Vector2(0.075, 0.0), Vector2(0.075, 0.04), Vector2(0.06, 0.06), Vector2(0.075, 0.22),
		Vector2(0.09, 0.34), Vector2(0.095, 0.40), Vector2(0.085, 0.44), Vector2(0.06, 0.47), Vector2(0.075, 0.52),
		Vector2(0.07, 0.56), Vector2(0.04, 0.585), Vector2(0.0, 0.59)]
	var body := MeshUtils.make_revolved(prof, ShopStones.material("faience"), 40)
	body.scale = Vector3(1.0, 1.0, 0.72)
	h.add_child(body)
	# crossed arms holding hoes, and the striped tripartite wig
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.04, 0.04, 0.05)
	dark.roughness = 0.4
	for sgn in [-1.0, 1.0]:
		h.add_child(_mi(BoxMesh.new(), ShopStones.material("faience"), Vector3(sgn * 0.02, 0.37, 0.065), Vector3(0.16, 0.03, 0.03), Vector3(0, 0, sgn * 0.6)))
		h.add_child(_mi(BoxMesh.new(), dark, Vector3(sgn * 0.05, 0.47, 0.055), Vector3(0.025, 0.1, 0.02)))
	h.add_child(_mi(ShopStones.sphere_mesh(), ShopStones.material("faience"), Vector3(0, 0.5, 0.045), Vector3(0.035, 0.045, 0.02)))

static func _necklace(h: Node3D, bead_kind: String, egyptian: bool) -> void:
	if not egyptian:
		_jade_necklace(h)
		return
	var sph := ShopStones.sphere_mesh()
	var root := Node3D.new()
	root.rotation.x = 0.25
	root.position = Vector3(0, 0.03, -0.04)
	h.add_child(root)
	var main := []
	var accent := []
	var n := 34
	for i in range(n):
		var a := lerpf(0.15, PI - 0.15, float(i) / float(n - 1))
		var p := Vector3(cos(a) * 0.2, 0, -sin(a) * 0.16 + 0.05)
		if egyptian and i % 2 == 1:
			accent.append(Transform3D(Basis().scaled(Vector3.ONE * 0.007), p))
		else:
			var s := 0.014 + 0.004 * sin(float(i) * 1.7) if not egyptian else 0.013
			main.append(Transform3D(Basis().scaled(Vector3(s, s * 0.9, s)), p))
	root.add_child(GalleryDisplays._mm(sph, main, ShopStones.material(bead_kind)))
	if egyptian:
		root.add_child(GalleryDisplays._mm(sph, accent, gold()))
		# central lapis drop in a gold cap
		root.add_child(_mi(sph, ShopStones.material("lapis"), Vector3(0, 0, 0.11), Vector3(0.03, 0.02, 0.045)))
		root.add_child(_mi(sph, gold(), Vector3(0, 0.006, 0.075), Vector3(0.014, 0.01, 0.012)))
	else:
		pass

# ── MAYA ────────────────────────────────────────────────────────────────────
static func _mask(h: Node3D) -> void:
	var tiles := ShopStones.material("jade_tiles")
	var face := ShopStones._deform_sphere(48, 32, func(p: Vector3) -> Vector3:
		var q := Vector3(p.x * 0.72, p.y, p.z * 0.42)
		if p.z < 0.0:
			q.z = p.z * 0.06
		else:
			var nose := 0.16 * exp(-pow(p.x / 0.13, 2.0) - pow((p.y + 0.05) / 0.28, 2.0))
			var brow := 0.05 * exp(-pow((p.y - 0.28) / 0.08, 2.0)) * (1.0 - absf(p.x))
			var socket := -0.06 * exp(-pow((absf(p.x) - 0.32) / 0.13, 2.0) - pow((p.y - 0.13) / 0.08, 2.0))
			var lips := 0.04 * exp(-pow(p.x / 0.25, 2.0) - pow((p.y + 0.45) / 0.06, 2.0))
			q.z += (nose + brow + socket + lips) * p.z
		return q)
	var root := Node3D.new()
	root.position = Vector3(0, 0.3, -0.05)
	root.scale = Vector3.ONE * 0.26
	h.add_child(root)
	var fm := MeshInstance3D.new()
	fm.mesh = face
	fm.material_override = tiles
	root.add_child(fm)
	var shell := ShopStones.material("shell")
	var obs := ShopStones.material("obsidian")
	var sph := ShopStones.sphere_mesh()
	for sgn in [-1.0, 1.0]:
		root.add_child(_mi(sph, shell, Vector3(sgn * 0.24, 0.12, 0.36), Vector3(0.13, 0.055, 0.03)))
		root.add_child(_mi(sph, obs, Vector3(sgn * 0.24, 0.12, 0.385), Vector3(0.035, 0.035, 0.012)))
		# jade ear flares
		root.add_child(_mi(sph, ShopStones.material("jade_maya"), Vector3(sgn * 0.74, 0.0, 0.05), Vector3(0.05, 0.13, 0.13)))
	root.add_child(_mi(sph, shell, Vector3(0, -0.45, 0.42), Vector3(0.16, 0.03, 0.02)))
	# stand
	var stand := MeshUtils.make_rounded_box(Vector3(0.05, 0.14, 0.05), 0.004, GalleryDisplays._mats()["black"])
	stand.position = Vector3(0, 0.07, -0.1)
	h.add_child(stand)

static func _earspools(h: Node3D) -> void:
	var jade := ShopStones.material("jade_maya")
	for sgn in [-1.0, 1.0]:
		var sp := MeshUtils.make_revolved([Vector2(0.0, 0.0), Vector2(0.022, 0.0), Vector2(0.024, 0.04), Vector2(0.035, 0.07),
			Vector2(0.07, 0.085), Vector2(0.09, 0.09), Vector2(0.088, 0.095), Vector2(0.06, 0.09), Vector2(0.03, 0.08),
			Vector2(0.016, 0.075), Vector2(0.014, 0.0)], jade, 48)
		sp.rotation.x = PI * 0.5 - 0.3
		sp.position = Vector3(sgn * 0.12, 0.1, -0.03)
		h.add_child(sp)

static func _eccentric(h: Node3D) -> void:
	# trident-like flaked blade with notched sides
	var pts := PackedVector2Array([Vector2(0.0, 0.0), Vector2(0.03, 0.02), Vector2(0.025, 0.06), Vector2(0.06, 0.09),
		Vector2(0.03, 0.12), Vector2(0.035, 0.18), Vector2(0.09, 0.22), Vector2(0.10, 0.27), Vector2(0.05, 0.25),
		Vector2(0.03, 0.30), Vector2(0.06, 0.34), Vector2(0.0, 0.42), Vector2(-0.06, 0.34), Vector2(-0.03, 0.30),
		Vector2(-0.05, 0.25), Vector2(-0.10, 0.27), Vector2(-0.09, 0.22), Vector2(-0.035, 0.18), Vector2(-0.03, 0.12),
		Vector2(-0.06, 0.09), Vector2(-0.025, 0.06), Vector2(-0.03, 0.02)])
	var blade := _extrude(pts, 0.014, ShopStones.material("obsidian"))
	blade.position = Vector3(0, 0.04, 0)
	h.add_child(blade)
	var block := MeshUtils.make_rounded_box(Vector3(0.12, 0.05, 0.06), 0.005, GalleryDisplays._mats()["black"])
	block.position = Vector3(0, 0.025, 0)
	h.add_child(block)

static func _plaque(h: Node3D) -> void:
	var jade := ShopStones.material("jade_maya")
	var root := Node3D.new()
	root.position = Vector3(0, 0.18, 0)
	root.rotation.x = -0.15
	h.add_child(root)
	root.add_child(_mi(BoxMesh.new(), jade, Vector3.ZERO, Vector3(0.18, 0.24, 0.02)))
	# relief: seated lord in profile (head, headdress plumes, body, arm)
	var sph := ShopStones.sphere_mesh()
	root.add_child(_mi(sph, jade, Vector3(-0.01, 0.05, 0.012), Vector3(0.035, 0.04, 0.008)))
	root.add_child(_mi(BoxMesh.new(), jade, Vector3(0.0, -0.04, 0.012), Vector3(0.07, 0.09, 0.008)))
	for k in range(4):
		root.add_child(_mi(BoxMesh.new(), jade, Vector3(-0.02 + k * 0.015, 0.1, 0.012), Vector3(0.008, 0.05, 0.006), Vector3(0, 0, 0.4 - k * 0.25)))
	root.add_child(_mi(BoxMesh.new(), jade, Vector3(0.04, -0.01, 0.014), Vector3(0.05, 0.012, 0.006), Vector3(0, 0, -0.3)))
	var stand := MeshUtils.make_rounded_box(Vector3(0.12, 0.05, 0.06), 0.005, GalleryDisplays._mats()["black"])
	stand.position = Vector3(0, -0.15, -0.01)
	root.add_child(stand)

static func _mirror(h: Node3D) -> void:
	var m := MeshUtils.make_revolved([Vector2(0.0, 0.03), Vector2(0.12, 0.022), Vector2(0.14, 0.0), Vector2(0.12, -0.02), Vector2(0.0, -0.025)],
		ShopStones.material("obsidian"), 64)
	m.rotation.x = PI * 0.5 - 0.25
	m.position = Vector3(0, 0.16, 0)
	h.add_child(m)
	var stand := MeshUtils.make_rounded_box(Vector3(0.14, 0.05, 0.07), 0.005, GalleryDisplays._mats()["black"])
	stand.position = Vector3(0, 0.025, -0.02)
	h.add_child(stand)

# ── carved scarab (shared): pronotum, split wing cases, serrated head ──────
static var _scarab_cache := {}

## Unit scarab: length 2 along Z (head +Z), width ~1.24, flat underside at
## y = -0.063. striated = ribbed wing cases (like the cuff's scarab).
static func scarab_mesh(striated: bool) -> ArrayMesh:
	var key := "s%d" % int(striated)
	if _scarab_cache.has(key):
		return _scarab_cache[key]
	# Built from overlapping domes so the creases between wing cases, thorax
	# and head are real geometry that catches shadow (like a carved stone).
	if not _scarab_cache.has("dome"):
		_scarab_cache["dome"] = ShopStones._deform_sphere(48, 24, func(p: Vector3) -> Vector3:
			return Vector3(p.x, p.y if p.y > 0.0 else p.y * 0.05, p.z))
	var dome: ArrayMesh = _scarab_cache["dome"]
	var y0 := -0.063
	var parts := [
		[Vector3(-0.30, y0, -0.36), Vector3(0.31, 0.46, 0.64), 0.0],
		[Vector3(0.30, y0, -0.36), Vector3(0.31, 0.46, 0.64), 0.0],
		[Vector3(0.0, y0, 0.36), Vector3(0.60, 0.40, 0.30), 0.0],
		[Vector3(0.0, y0, 0.74), Vector3(0.34, 0.22, 0.24), 0.0],
		[Vector3(-0.25, y0, 0.70), Vector3(0.08, 0.13, 0.08), 0.0],
		[Vector3(0.25, y0, 0.70), Vector3(0.08, 0.13, 0.08), 0.0],
	]
	for k in range(6):
		parts.append([Vector3(-0.22 + k * 0.088, y0, 0.95), Vector3(0.05, 0.09, 0.07), 0.0])
	for sgn in [-1.0, 1.0]:
		for k in range(3):
			parts.append([Vector3(sgn * 0.6, y0, 0.25 - k * 0.32), Vector3(0.2, 0.07, 0.05), sgn * (0.5 - k * 0.45)])
		if striated:
			for k in range(4):
				var x: float = sgn * (0.08 + k * 0.08)
				var hy := 0.46 * sqrt(maxf(0.0, 1.0 - pow((absf(x) - 0.30) / 0.31, 2.0)))
				parts.append([Vector3(x, y0 + hy - 0.03, -0.42), Vector3(0.022, 0.05, 0.5), 0.0])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for pt in parts:
		var basis := Basis(Vector3.UP, pt[2]).scaled(pt[1])
		st.append_from(dome, 0, Transform3D(basis, pt[0]))
	var m := st.commit()
	_scarab_cache[key] = m
	return m

static func _scarab_node(mat: Material, length: float, striated: bool) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = scarab_mesh(striated)
	mi.material_override = mat
	mi.scale = Vector3.ONE * length * 0.5
	return mi

## Basis that lays the scarab's top along `up` with its head pointing `fwd`.
static func _lay(up: Vector3, fwd: Vector3) -> Basis:
	var z := fwd.normalized()
	var y := up.normalized()
	var x := y.cross(z).normalized()
	return Basis(x, y, z)

# ── pectoral on an inclined velvet board ───────────────────────────────────
static func _pectoral(h: Node3D) -> void:
	var board := Node3D.new()
	board.position = Vector3(0, 0.0, 0.12)
	board.rotation.x = -0.42
	h.add_child(board)
	var velvet: Material = GalleryDisplays._mats()["velvet"]
	board.add_child(_mi(BoxMesh.new(), velvet, Vector3(0, 0.42, -0.012), Vector3(0.64, 0.84, 0.02)))
	var lapis := ShopStones.material("lapis")
	var carn := ShopStones.material("carnelian")
	var turq := ShopStones.material("turquoise_inlay")
	var sph := ShopStones.sphere_mesh()
	var box := BoxMesh.new()
	var beads := {"lapis": [], "turq": [], "carn": [], "gold": []}
	var keys := ["lapis", "gold", "turq", "carn", "lapis", "gold"]
	var face := Vector3(0, 0, 1)
	# straps: from the neck (top) down to the pendant
	for sgn in [-1.0, 1.0]:
		var top := Vector3(sgn * 0.16, 0.80, 0.0)
		var bot := Vector3(sgn * 0.115, 0.36, 0.0)
		var along := (top - bot).normalized()
		var side := Vector3(along.y, -along.x, 0).normalized()
		var L := top.distance_to(bot)
		var basis := Basis(side, along, face)
		# gold strap backing
		board.add_child(_mi(box, gold(), (top + bot) * 0.5 + face * 0.004, Vector3(0.062, L, 0.006), basis.get_euler()))
		# bead edges
		var nb := int(L / 0.009)
		for k in range(nb):
			var t := float(k) / float(nb - 1)
			for e in [-1.0, 1.0]:
				var pp: Vector3 = bot.lerp(top, t) + side * e * 0.036 + face * 0.008
				beads[keys[k % keys.size()]].append(Transform3D(Basis().scaled(Vector3.ONE * 0.0045), pp))
		# panels along the strap (bottom to top)
		var n := 5
		for k in range(n):
			var t := (float(k) + 0.5) / float(n)
			var c: Vector3 = bot.lerp(top, t) + face * 0.01
			match k % 3:
				0:  # small lapis scarab with a gold sun above
					var sc := _scarab_node(lapis, 0.05, false)
					sc.transform = Transform3D(_lay(face, along).scaled(Vector3.ONE * 0.025), c - along * 0.006)
					board.add_child(sc)
					board.add_child(_mi(sph, gold(), c + along * 0.03, Vector3(0.012, 0.012, 0.004)))
				1:  # carnelian cabochon pair in gold bezels
					for e in [-1.0, 1.0]:
						var cc: Vector3 = c + side * e * 0.014
						board.add_child(_mi(sph, gold(), cc, Vector3(0.016, 0.019, 0.005)))
						board.add_child(_mi(sph, carn, cc + face * 0.003, Vector3(0.013, 0.016, 0.007)))
				2:  # cloisonne panel: lapis, turquoise and carnelian cells
					var cells := [[-0.016, lapis], [0.0, turq], [0.016, carn]]
					for cell in cells:
						board.add_child(_mi(box, cell[1], c + side * float(cell[0]) + face * 0.001, Vector3(0.012, 0.05, 0.004), basis.get_euler()))
		# gold clasp at the neck
		board.add_child(_mi(box, gold(), top + face * 0.008, Vector3(0.07, 0.03, 0.01), basis.get_euler()))
	for k in beads:
		var mat: Material = gold() if k == "gold" else (lapis if k == "lapis" else (turq if k == "turq" else carn))
		board.add_child(GalleryDisplays._mm(sph, beads[k], mat))
	# the pendant: gold frame, side columns, big scarab, sun disc, barque, lapis bar
	var pc := Vector3(0, 0.24, 0.0)
	board.add_child(_mi(box, gold(), pc + face * 0.003, Vector3(0.32, 0.20, 0.006)))
	for sgn in [-1.0, 1.0]:
		var col := pc + Vector3(sgn * 0.12, 0, 0.008)
		board.add_child(_mi(sph, gold(), col + Vector3(0, 0.07, 0), Vector3(0.024, 0.026, 0.006)))
		board.add_child(_mi(sph, carn, col + Vector3(0, 0.07, 0.004), Vector3(0.02, 0.022, 0.008)))
		var cells2 := [[0.03, lapis], [0.005, turq], [-0.02, carn], [-0.045, lapis]]
		for cell in cells2:
			board.add_child(_mi(box, cell[1], col + Vector3(0, float(cell[0]), 0), Vector3(0.05, 0.018, 0.004)))
		# little ankh signs
		board.add_child(_mi(box, gold(), col + Vector3(sgn * -0.035, -0.01, 0.002), Vector3(0.006, 0.05, 0.004)))
	var big := _scarab_node(lapis, 0.14, false)
	big.transform = Transform3D(_lay(face, Vector3.UP).scaled(Vector3.ONE * 0.07), pc + Vector3(0, -0.01, 0.01))
	board.add_child(big)
	board.add_child(_mi(sph, gold(), pc + Vector3(0, 0.115, 0.006), Vector3(0.044, 0.04, 0.008)))
	board.add_child(_mi(sph, carn, pc + Vector3(0, 0.115, 0.012), Vector3(0.036, 0.032, 0.014)))
	var barque := MeshUtils.catenary(Vector3(-0.17, 0.17, 0.012), Vector3(0.17, 0.17, 0.012), 0.045, 20)
	MeshUtils.sweep_tube(board, barque, 0.006, 0.006, gold())
	board.add_child(_mi(box, lapis, Vector3(0, 0.095, 0.006), Vector3(0.24, 0.024, 0.01)))
	board.add_child(_mi(box, gold(), Vector3(0, 0.095, 0.002), Vector3(0.25, 0.03, 0.006)))

# ── scarab cuff (lying, front facing the hall) ─────────────────────────────
static func _cuff(h: Node3D) -> void:
	var R := 0.082
	var C := Vector3(0, R + 0.004, 0)
	var band := MeshUtils.make_revolved([Vector2(R - 0.004, -0.058), Vector2(R, -0.058), Vector2(R + 0.003, -0.05),
		Vector2(R + 0.004, 0.0), Vector2(R + 0.003, 0.05), Vector2(R, 0.058), Vector2(R - 0.004, 0.058), Vector2(R - 0.004, -0.058)], gold(), 72)
	band.rotation.z = PI * 0.5
	band.position = C
	h.add_child(band)
	var lapis := ShopStones.material("lapis")
	var turq := ShopStones.material("turquoise_inlay")
	var carn := ShopStones.material("carnelian")
	var shell := ShopStones.material("shell")
	var sph := ShopStones.sphere_mesh()
	var box := BoxMesh.new()
	var at := func(u: float, th: float, lift: float) -> Vector3:
		return C + Vector3(u, sin(th) * (R + lift), cos(th) * (R + lift))
	var frame := func(th: float) -> Basis:
		var d := Vector3(0, sin(th), cos(th))
		return Basis(Vector3.RIGHT, d, Vector3.RIGHT.cross(d))
	# gold oval plate + carved ribbed scarab, head to the right
	var bp: Basis = frame.call(0.0)
	h.add_child(_mi(sph, gold(), at.call(0.0, 0.0, 0.004), Vector3(0.06, 0.006, 0.045), bp.get_euler()))
	var sc := _scarab_node(lapis, 0.085, true)
	sc.transform = Transform3D(_lay(Vector3(0, 0, 1), Vector3.RIGHT).scaled(Vector3.ONE * 0.0425), at.call(0.0, 0.0, 0.006))
	h.add_child(sc)
	# inlaid border of square cells, a gold rope inside it
	var cells := {"lapis": [], "turq": [], "carn": [], "gold": []}
	var order := ["lapis", "turq", "gold", "carn", "lapis", "gold"]
	var k := 0
	for th in [-0.62, 0.62]:
		for i in range(10):
			var u := -0.063 + float(i) * 0.014
			cells[order[k % order.size()]].append(Transform3D((frame.call(th) as Basis).scaled(Vector3(0.011, 0.004, 0.011)), at.call(u, th, 0.003)))
			k += 1
	for u in [-0.07, 0.07]:
		for i in range(7):
			var th := -0.5 + float(i) * (1.0 / 6.0)
			cells[order[k % order.size()]].append(Transform3D((frame.call(th) as Basis).scaled(Vector3(0.011, 0.004, 0.011)), at.call(u, th, 0.003)))
			k += 1
	for key in cells:
		var mat: Material = gold() if key == "gold" else (lapis if key == "lapis" else (turq if key == "turq" else carn))
		h.add_child(GalleryDisplays._mm(box, cells[key], mat))
	var rope := []
	for th in [-0.52, 0.52]:
		for i in range(24):
			rope.append(Transform3D(Basis().scaled(Vector3.ONE * 0.0028), at.call(-0.058 + float(i) * 0.005, th, 0.004)))
	h.add_child(GalleryDisplays._mm(sph, rope, gold()))
	# carnelian and white stones at the sides
	for th in [-0.88, 0.88]:
		h.add_child(_mi(sph, carn, at.call(-0.03, th, 0.004), Vector3(0.011, 0.006, 0.011), (frame.call(th) as Basis).get_euler()))
		h.add_child(_mi(sph, shell, at.call(0.0, th, 0.004), Vector3(0.012, 0.007, 0.012), (frame.call(th) as Basis).get_euler()))
		h.add_child(_mi(sph, carn, at.call(0.03, th, 0.004), Vector3(0.011, 0.006, 0.011), (frame.call(th) as Basis).get_euler()))

# ── raw carved lapis scarab lying on the velvet ────────────────────────────
static func _raw_scarab(h: Node3D) -> void:
	var sc := _scarab_node(ShopStones.material("lapis_raw"), 0.26, false)
	sc.position = Vector3(0, 0.13 * 0.063, 0)
	sc.rotation.y = PI * 0.5
	h.add_child(sc)

# ── Maya jade necklace: irregular rounded beads, big melon beads, carved tubes ─
static func _jade_necklace(h: Node3D) -> void:
	var board := Node3D.new()
	board.rotation.x = -0.9
	board.position = Vector3(0, 0.0, 0.1)
	h.add_child(board)
	var linen := StandardMaterial3D.new()
	linen.albedo_color = Color(0.72, 0.66, 0.56)
	linen.roughness = 1.0
	board.add_child(_mi(BoxMesh.new(), linen, Vector3(0, 0.3, -0.012), Vector3(0.6, 0.62, 0.02)))
	var jade := ShopStones.material("jade_maya")
	var rng := RandomNumberGenerator.new()
	rng.seed = 33
	var path := []
	for i in range(120):
		var t := float(i) / 119.0 * TAU
		path.append(Vector3(sin(t) * 0.2, 0.32 - cos(t) * 0.24 + 0.05 * cos(2.0 * t), 0.0))
	var s := 0.0
	var i := 0
	var big_at := [0.22, 0.34, 0.46, 0.58, 0.70, 0.82]
	var bi := 0
	while s < 0.99:
		var idx := int(s * 119.0)
		var p: Vector3 = path[idx]
		var q: Vector3 = path[mini(idx + 1, 119)]
		var dir := (q - p).normalized()
		var r := rng.randf_range(0.012, 0.016)
		var mesh: Mesh = ShopStones.tumbled_mesh(rng.randi() % 6)
		var scl := Vector3(r, r * 0.8, r * 1.15)
		if bi < big_at.size() and s > big_at[bi]:
			bi += 1
			if bi % 3 == 0:
				scl = Vector3(0.018, 0.018, 0.04)          # carved oblong bead
			else:
				mesh = ShopStones.sphere_mesh()
				scl = Vector3(0.026, 0.024, 0.02)         # big melon bead
		var basis := Basis.looking_at(dir, Vector3(0, 0, 1)).scaled(scl)
		board.add_child(_mi(mesh, jade, p + Vector3(0, 0, scl.y * 0.6), Vector3.ONE))
		board.get_child(board.get_child_count() - 1).transform = Transform3D(basis, p + Vector3(0, 0, scl.y * 0.6))
		s += (scl.z * 1.6) / 1.4
		i += 1

# ── Tutankhamun's mask ──────────────────────────────────────────────────────
static func _tut_mask(h: Node3D) -> void:
	var nemes := ShopStones.material("nemes")
	var root := Node3D.new()
	root.position = Vector3(0, 0.02, -0.08)
	root.scale = Vector3.ONE * 1.35
	h.add_child(root)
	var sph := ShopStones.sphere_mesh()
	var g := gold()
	# broad collar sloping over the shoulders
	var collar := MeshUtils.make_revolved([Vector2(0.10, 0.20), Vector2(0.18, 0.17), Vector2(0.27, 0.11), Vector2(0.34, 0.03),
		Vector2(0.35, 0.0), Vector2(0.30, 0.0), Vector2(0.10, 0.18)], ShopStones.material("collar_bands"), 96)
	collar.scale = Vector3(1.0, 1.0, 0.62)
	root.add_child(collar)
	var rim := MeshUtils.make_ring(0.34, 0.355, 0.012, g, 96)
	rim.scale = Vector3(1.0, 1.0, 0.62)
	rim.position.y = 0.006
	root.add_child(rim)
	# neck and nemes cap
	root.add_child(_mi(sph, g, Vector3(0, 0.26, 0.0), Vector3(0.085, 0.1, 0.075)))
	root.add_child(_mi(sph, nemes, Vector3(0, 0.39, -0.06), Vector3(0.155, 0.14, 0.13)))
	# lappets falling in front of the shoulders, flaring out
	for sgn in [-1.0, 1.0]:
		var lp := PackedVector2Array([Vector2(0.0, 0.0), Vector2(0.075, 0.0), Vector2(0.058, 0.2), Vector2(0.015, 0.22)])
		var lap := _extrude(lp, 0.03, nemes)
		lap.position = Vector3(sgn * 0.11 - (0.075 if sgn < 0.0 else 0.0), 0.16, 0.03)
		lap.rotation.z = sgn * 0.08
		root.add_child(lap)
		# wing of the headcloth flaring behind the face
		root.add_child(_mi(sph, nemes, Vector3(sgn * 0.14, 0.32, -0.04), Vector3(0.06, 0.13, 0.09)))
		# ears
		root.add_child(_mi(sph, g, Vector3(sgn * 0.105, 0.33, 0.035), Vector3(0.016, 0.03, 0.012)))
	# face
	root.add_child(_mi(sph, g, Vector3(0, 0.33, 0.06), Vector3(0.088, 0.112, 0.075)))
	root.add_child(_mi(sph, g, Vector3(0, 0.325, 0.142), Vector3(0.016, 0.03, 0.018)))            # nose
	root.add_child(_mi(sph, g, Vector3(0, 0.282, 0.128), Vector3(0.028, 0.009, 0.012)))            # lips
	var white := ShopStones.material("shell")
	var obs := ShopStones.material("obsidian")
	var lapis := ShopStones.material("lapis")
	for sgn in [-1.0, 1.0]:
		root.add_child(_mi(sph, white, Vector3(sgn * 0.032, 0.352, 0.124), Vector3(0.017, 0.009, 0.01)))
		root.add_child(_mi(sph, obs, Vector3(sgn * 0.032, 0.352, 0.132), Vector3(0.007, 0.007, 0.005)))
		root.add_child(_mi(BoxMesh.new(), lapis, Vector3(sgn * 0.035, 0.372, 0.125), Vector3(0.042, 0.005, 0.008), Vector3(0, 0, sgn * -0.12)))
		root.add_child(_mi(BoxMesh.new(), lapis, Vector3(sgn * 0.058, 0.35, 0.118), Vector3(0.025, 0.004, 0.008), Vector3(0, 0, sgn * 0.15)))
	# brow band, cobra and vulture
	root.add_child(_mi(BoxMesh.new(), g, Vector3(0, 0.425, 0.075), Vector3(0.16, 0.012, 0.03)))
	root.add_child(_mi(sph, g, Vector3(0.012, 0.45, 0.1), Vector3(0.012, 0.03, 0.012)))
	root.add_child(_mi(sph, lapis, Vector3(0.012, 0.455, 0.11), Vector3(0.008, 0.016, 0.004)))
	root.add_child(_mi(sph, g, Vector3(-0.014, 0.448, 0.1), Vector3(0.014, 0.022, 0.012)))
	# braided false beard
	var beard := MeshUtils.make_revolved([Vector2(0.0, 0.0), Vector2(0.017, 0.0), Vector2(0.02, 0.09), Vector2(0.014, 0.11), Vector2(0.0, 0.11)], nemes, 24)
	beard.position = Vector3(0, 0.155, 0.075)
	root.add_child(beard)

# ── lapis intaglio seal ring ────────────────────────────────────────────────
static func _signet(h: Node3D) -> void:
	var g := gold()
	var ring := Node3D.new()
	ring.position = Vector3(0, 0.12, 0)
	ring.rotation.x = 0.75
	h.add_child(ring)
	var band := MeshUtils.make_revolved([Vector2(0.085, -0.03), Vector2(0.1, -0.035), Vector2(0.108, 0.0),
		Vector2(0.1, 0.035), Vector2(0.085, 0.03), Vector2(0.085, -0.03)], g, 64)
	band.rotation.z = PI * 0.5
	ring.add_child(band)
	var head := Node3D.new()
	head.position = Vector3(0, 0.105, 0)
	ring.add_child(head)
	head.add_child(_mi(ShopStones.sphere_mesh(), g, Vector3(0, 0.0, 0), Vector3(0.075, 0.018, 0.092)))
	head.add_child(_mi(ShopStones.sphere_mesh(), ShopStones.material("lapis"), Vector3(0, 0.012, 0), Vector3(0.066, 0.012, 0.082)))
	# carved crest (matte, slightly sunk into the polished stone): shield, bend, mantling
	var matte := ShopStones.material("lapis_raw")
	var shield := PackedVector2Array([Vector2(-0.028, 0.03), Vector2(0.028, 0.03), Vector2(0.028, -0.005), Vector2(0.0, -0.038), Vector2(-0.028, -0.005)])
	var sh := _extrude(shield, 0.003, matte)
	sh.rotation.x = -PI * 0.5
	sh.position = Vector3(0, 0.0225, 0.0)
	head.add_child(sh)
	var bend := _mi(BoxMesh.new(), ShopStones.material("lapis"), Vector3(0, 0.0245, 0.0), Vector3(0.07, 0.002, 0.012), Vector3(0, 0.7, 0))
	head.add_child(bend)
	for sgn in [-1.0, 1.0]:
		var sp := PackedVector3Array()
		for k in range(16):
			var t := float(k) / 15.0
			var a := t * TAU * 1.2
			sp.append(Vector3(sgn * (0.04 + cos(a) * 0.012 * (1.0 - t * 0.5)), 0.023, -0.03 + t * 0.05 + sin(a) * 0.01))
		MeshUtils.sweep_tube(head, sp, 0.003, 0.002, matte)

# ── triple-strand lapis and gold necklace on a linen bust ──────────────────
static func _triple(h: Node3D) -> void:
	var linen := StandardMaterial3D.new()
	linen.albedo_color = Color(0.78, 0.70, 0.58)
	linen.roughness = 1.0
	var bust := MeshUtils.make_revolved([Vector2(0.0, 0.0), Vector2(0.17, 0.0), Vector2(0.19, 0.16), Vector2(0.17, 0.3),
		Vector2(0.09, 0.38), Vector2(0.055, 0.4), Vector2(0.05, 0.56), Vector2(0.0, 0.57)], linen, 64)
	bust.scale = Vector3(1.3, 1.0, 0.6)
	h.add_child(bust)
	var sph := ShopStones.sphere_mesh()
	var lapis := ShopStones.material("lapis")
	var g := gold()
	var beads := []
	var tubes := []
	var golds := []
	var prof := [Vector2(0.0, 0.0), Vector2(0.17, 0.0), Vector2(0.19, 0.16), Vector2(0.17, 0.3), Vector2(0.09, 0.38), Vector2(0.055, 0.4), Vector2(0.05, 0.56)]
	var radius_at := func(y: float) -> float:
		for q in range(prof.size() - 1):
			var a0: Vector2 = prof[q]
			var a1: Vector2 = prof[q + 1]
			if y >= a0.y and y <= a1.y:
				return lerpf(a0.x, a1.x, (y - a0.y) / maxf(a1.y - a0.y, 1e-4))
		return 0.05
	for k in range(3):
		var depth := 0.07 + float(k) * 0.045
		var half := 0.085 + float(k) * 0.02
		var n := 34 + k * 8
		for i in range(n):
			var t := lerpf(-1.0, 1.0, float(i) / float(n - 1))
			var x := t * half
			var y := 0.385 - depth * (1.0 - t * t)
			var r0: float = radius_at.call(y) * 1.3
			var z := sqrt(maxf(0.0, 1.0 - pow(x / r0, 2.0))) * r0 * (0.6 / 1.3) + 0.008
			var p := Vector3(x, y, z)
			if i % 6 == 3:
				golds.append(Transform3D(Basis().scaled(Vector3(0.007, 0.01, 0.007)), p))
			elif k == 1 and i % 2 == 0:
				tubes.append(Transform3D(Basis(Vector3.FORWARD, atan2(-2.0 * depth * t, half)).scaled(Vector3(0.007, 0.014, 0.007)), p))
			else:
				var rr := 0.0075 + 0.003 * (1.0 - absf(t))
				beads.append(Transform3D(Basis().scaled(Vector3.ONE * rr), p))
	h.add_child(GalleryDisplays._mm(sph, beads, lapis))
	h.add_child(GalleryDisplays._mm(sph, tubes, lapis))
	h.add_child(GalleryDisplays._mm(sph, golds, g))
	# gold lotus fan pendant
	var fan := PackedVector2Array([Vector2(0.0, 0.0), Vector2(-0.03, -0.035), Vector2(-0.018, -0.042), Vector2(0.0, -0.045),
		Vector2(0.018, -0.042), Vector2(0.03, -0.035)])
	var f := _extrude(fan, 0.006, g)
	f.position = Vector3(0, 0.235, 0.115)
	h.add_child(f)
	for k in range(5):
		var rib := _mi(BoxMesh.new(), lapis, Vector3(-0.016 + k * 0.008, 0.213, 0.119), Vector3(0.002, 0.03, 0.002), Vector3(0, 0, -0.5 + k * 0.25))
		h.add_child(rib)

# ═══════════════════════════════════════════════════════════════════════════
# BOUTIQUE
# ═══════════════════════════════════════════════════════════════════════════
static var _silver_m: StandardMaterial3D

static func _silver() -> StandardMaterial3D:
	if _silver_m == null:
		_silver_m = StandardMaterial3D.new()
		_silver_m.albedo_color = Color(0.86, 0.86, 0.88)
		_silver_m.metallic = 1.0
		_silver_m.roughness = 0.2
	return _silver_m

## Display board laid back toward the visitor; children use x/y on the board,
## z = height above it.
static func _board(h: Node3D, col: Color, size := Vector2(0.56, 0.6), tilt := -1.0) -> Node3D:
	var b := Node3D.new()
	b.rotation.x = tilt
	b.position = Vector3(0, 0.0, 0.12)
	h.add_child(b)
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = 1.0
	b.add_child(_mi(BoxMesh.new(), m, Vector3(0, size.y * 0.5, -0.012), Vector3(size.x, size.y, 0.02)))
	return b

static func _pouch(h: Node3D) -> void:
	var p := MeshUtils.make_rounded_box(Vector3(0.30, 0.22, 0.03), 0.012, ShopStones.material("hiero_cloth"))
	p.position = Vector3(0, 0.12, 0.0)
	p.rotation.x = -0.18
	h.add_child(p)
	var zip := MeshUtils.make_rounded_box(Vector3(0.3, 0.008, 0.012), 0.002, GalleryDisplays._mats()["black"])
	zip.position = Vector3(0, 0.232, -0.02)
	zip.rotation.x = -0.18
	h.add_child(zip)
	h.add_child(_mi(ShopStones.sphere_mesh(), gold(), Vector3(-0.14, 0.235, -0.018), Vector3(0.008, 0.012, 0.006)))
	var pull := MeshUtils.make_ring(0.008, 0.012, 0.004, gold(), 16)
	pull.rotation.x = PI * 0.5
	pull.position = Vector3(-0.15, 0.26, -0.022)
	h.add_child(pull)

static func _bangles(h: Node3D) -> void:
	var mat := ShopStones.material("horus_bangle")
	for k in range(2):
		var R := 0.09
		var b := MeshUtils.make_revolved([Vector2(R - 0.005, -0.05), Vector2(R, -0.052), Vector2(R + 0.004, 0.0),
			Vector2(R, 0.052), Vector2(R - 0.005, 0.05), Vector2(R - 0.005, -0.05)], mat, 96)
		b.position = Vector3(0.0, 0.052 + float(k) * 0.104, 0.0)
		b.rotation.y = float(k) * 0.9
		if k == 1:
			b.rotation.x = 0.15
		h.add_child(b)
		var inner := MeshUtils.make_ring(R - 0.006, R - 0.004, 0.1, gold(), 64)
		inner.position = b.position
		inner.rotation = b.rotation
		h.add_child(inner)

static func _slabs(h: Node3D) -> void:
	var b := _board(h, Color(0.55, 0.32, 0.27), Vector2(0.46, 0.62))
	var lapis := ShopStones.material("lapis")
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var n := 17
	for i in range(n):
		var t := (float(i) + 0.5) / float(n)
		var a := lerpf(-1.25, 1.25, t)
		var big := 1.0 - absf(a) / 1.25 * 0.45
		var p := Vector3(sin(a) * 0.16, 0.14 + (1.0 - cos(a)) * 0.42, 0.0)
		var w := 0.036 * big
		var hgt := 0.07 * big
		var poly := PackedVector2Array([Vector2(-w * rng.randf_range(0.7, 1.0), hgt * 0.5), Vector2(w * rng.randf_range(0.7, 1.0), hgt * 0.5),
			Vector2(w * 1.1, -hgt * 0.2), Vector2(w * rng.randf_range(0.5, 0.9), -hgt * 0.55), Vector2(-w * rng.randf_range(0.5, 0.9), -hgt * 0.55), Vector2(-w * 1.1, -hgt * 0.15)])
		var slab := _extrude(poly, 0.012, lapis)
		slab.position = p + Vector3(0, -hgt * 0.4, 0.008)
		slab.rotation = Vector3(rng.randf_range(-0.15, 0.15), rng.randf_range(-0.2, 0.2), a * 0.95)
		b.add_child(slab)
		b.add_child(_mi(ShopStones.sphere_mesh(), _silver(), p + Vector3(0, 0.012, 0.004), Vector3.ONE * 0.0045))

static func _lapis_ring(h: Node3D) -> void:
	var raw := ShopStones.material("lapis_raw")
	var ring := MeshUtils.make_revolved([Vector2(0.06, -0.026), Vector2(0.078, -0.03), Vector2(0.084, 0.0), Vector2(0.078, 0.03),
		Vector2(0.06, 0.026), Vector2(0.06, -0.026)], raw, 64)
	ring.rotation.z = PI * 0.5
	ring.position = Vector3(0, 0.085, 0)
	h.add_child(ring)
	h.add_child(_mi(ShopStones.sphere_mesh(), raw, Vector3(0, 0.155, 0), Vector3(0.05, 0.03, 0.056)))
	var sc := _scarab_node(raw, 0.09, false)
	sc.position = Vector3(0, 0.168, 0)
	h.add_child(sc)

static func _gold_scarab(h: Node3D) -> void:
	var base := MeshUtils.make_revolved([Vector2(0.0, 0.0), Vector2(0.12, 0.0), Vector2(0.135, 0.035), Vector2(0.125, 0.075), Vector2(0.0, 0.075)],
		ShopStones.material("gold_glyph"), 64)
	base.scale = Vector3(1.0, 1.0, 1.35)
	h.add_child(base)
	var sc := _scarab_node(ShopStones.material("lapis"), 0.24, false)
	sc.position = Vector3(0, 0.06, 0.01)
	h.add_child(sc)
	h.add_child(_mi(ShopStones.sphere_mesh(), gold(), Vector3(0, 0.07, 0.07), Vector3(0.05, 0.012, 0.012)))

static func _broad_collar(h: Node3D) -> void:
	var b := _board(h, Color(0.08, 0.08, 0.09), Vector2(0.6, 0.56))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r0 := 0.11
	var r1 := 0.25
	var seg := 64
	for k in range(seg):
		var a0 := float(k) / float(seg) * PI
		var a1 := float(k + 1) / float(seg) * PI
		var p00 := Vector3(cos(a0) * r0, 0, sin(a0) * r0)
		var p01 := Vector3(cos(a0) * r1, 0, sin(a0) * r1)
		var p10 := Vector3(cos(a1) * r0, 0, sin(a1) * r0)
		var p11 := Vector3(cos(a1) * r1, 0, sin(a1) * r1)
		MeshUtils._face_quad(st, p00, p01, p11, p10, Vector3.UP)
	st.generate_tangents()
	var collar := MeshInstance3D.new()
	collar.mesh = st.commit()
	collar.material_override = ShopStones.material("collar_bands")
	collar.rotation.x = PI * 0.5
	collar.position = Vector3(0, 0.44, 0.006)
	b.add_child(collar)
	for rr in [r0, r1]:
		var arc := PackedVector3Array()
		for k in range(41):
			var aa := float(k) / 40.0 * PI
			arc.append(Vector3(cos(aa) * float(rr), 0.44 - sin(aa) * float(rr), 0.008))
		MeshUtils.sweep_tube(b, arc, 0.004, 0.004, gold())
	var sc := _scarab_node(gold(), 0.11, true)
	sc.transform = Transform3D(_lay(Vector3(0, 0, 1), Vector3.UP).scaled(Vector3.ONE * 0.055), Vector3(0, 0.26, 0.012))
	b.add_child(sc)
	b.add_child(_mi(ShopStones.sphere_mesh(), gold(), Vector3(0, 0.155, 0.004), Vector3(0.036, 0.05, 0.008)))
	b.add_child(_mi(ShopStones.sphere_mesh(), ShopStones.material("lapis"), Vector3(0, 0.155, 0.01), Vector3(0.031, 0.044, 0.016)))
	var chain := MeshUtils.catenary(Vector3(-0.2, 0.47, 0.006), Vector3(0.2, 0.47, 0.006), -0.06, 26)
	MeshUtils.chain_links(b, chain, 0.007, 0.0016, gold())

static func _relief(h: Node3D) -> void:
	var linen := StandardMaterial3D.new()
	linen.albedo_color = Color(0.78, 0.70, 0.58)
	linen.roughness = 1.0
	var bust := MeshUtils.make_revolved([Vector2(0.0, 0.0), Vector2(0.17, 0.0), Vector2(0.19, 0.16), Vector2(0.17, 0.3),
		Vector2(0.09, 0.38), Vector2(0.055, 0.4), Vector2(0.05, 0.56), Vector2(0.0, 0.57)], linen, 64)
	bust.scale = Vector3(1.3, 1.0, 0.6)
	h.add_child(bust)
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.20, 0.27, 0.40, 0.88)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.06
	glass.metallic_specular = 0.8
	var box := MeshUtils.make_rounded_box(Vector3(1, 1, 1), 0.2, null).mesh
	var beads := []
	for i in range(16):
		var t := lerpf(-1.0, 1.0, float(i) / 15.0)
		var x := t * 0.07
		var y := 0.385 - 0.09 * (1.0 - t * t)
		beads.append(Transform3D(Basis(Vector3.FORWARD, t * 0.7).scaled(Vector3(0.026, 0.026, 0.022)), Vector3(x, y, 0.09 + 0.02 * (1.0 - absf(t)))))
	h.add_child(GalleryDisplays._mm(box, beads, glass))
	var plaque := MeshUtils.make_rounded_box(Vector3(0.13, 0.1, 0.008), 0.002, ShopStones.material("gold_glyph"))
	plaque.position = Vector3(0, 0.235, 0.118)
	h.add_child(plaque)
	for k in range(4):
		var bd := MeshUtils.make_rounded_box(Vector3(0.028, 0.028, 0.016), 0.005, glass)
		bd.position = Vector3(-0.045 + k * 0.03, 0.172, 0.12)
		h.add_child(bd)
	h.add_child(_mi(ShopStones.sphere_mesh(), gold(), Vector3(0, 0.12, 0.118), Vector3(0.027, 0.034, 0.006)))
	h.add_child(_mi(ShopStones.sphere_mesh(), ShopStones.material("shell"), Vector3(0, 0.12, 0.124), Vector3(0.023, 0.03, 0.008)))

static func _aura(h: Node3D) -> void:
	var spec := MineralLibrary.make("quartz_cluster", 0.3, 77)
	_override(spec, ShopStones.material("bismuth"))
	h.add_child(spec)

static func _override(n: Node, m: Material) -> void:
	if n is GeometryInstance3D:
		(n as GeometryInstance3D).material_override = m
	for c in n.get_children():
		_override(c, m)

static func _tree(h: Node3D) -> void:
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.25, 0.15)
	wood.roughness = 0.6
	var base := MeshUtils.make_cylinder(0.075, 0.08, 0.035, wood, 48)
	base.position.y = 0.0175
	h.add_child(base)
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	var leaves := []
	var brown := StandardMaterial3D.new()
	brown.albedo_color = Color(0.32, 0.18, 0.10)
	brown.roughness = 0.8
	MeshUtils.sweep_tube(h, PackedVector3Array([Vector3(0, 0.03, 0), Vector3(0.005, 0.1, 0), Vector3(-0.004, 0.16, 0)]), 0.012, 0.007, brown)
	var stack := [[Vector3(-0.004, 0.16, 0), Vector3.UP, 0.07, 0]]
	while not stack.is_empty():
		var it: Array = stack.pop_back()
		var o: Vector3 = it[0]
		var d: Vector3 = it[1]
		var L: float = it[2]
		var depth: int = it[3]
		for c in range(3 if depth < 3 else 4):
			var nd := (d + Vector3(rng.randf_range(-0.9, 0.9), rng.randf_range(0.0, 0.5), rng.randf_range(-0.9, 0.9))).normalized()
			var e := o + nd * L * rng.randf_range(0.8, 1.1)
			MeshUtils.sweep_tube(h, PackedVector3Array([o, (o + e) * 0.5 + Vector3(0, 0.005, 0), e]), 0.0014, 0.001, gold())
			if depth < 3:
				stack.append([e, nd, L * 0.7, depth + 1])
			else:
				for q in range(3):
					var lp := e + Vector3(rng.randf_range(-0.012, 0.012), rng.randf_range(-0.01, 0.012), rng.randf_range(-0.012, 0.012))
					leaves.append(Transform3D(Basis.from_euler(Vector3(rng.randf() * TAU, rng.randf() * TAU, 0)).scaled(Vector3(0.008, 0.006, 0.006)), lp))
	for q in range(14):
		var a := rng.randf() * TAU
		leaves.append(Transform3D(Basis().scaled(Vector3.ONE * 0.008), Vector3(cos(a) * 0.05, 0.04, sin(a) * 0.05)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = ShopStones.tumbled_mesh(1)
	mm.instance_count = leaves.size()
	for i in range(leaves.size()):
		mm.set_instance_transform(i, leaves[i])
		mm.set_instance_custom_data(i, Color(rng.randf(), 0, 0, 0))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = ShopStones.material("lapis")
	h.add_child(mmi)

static func _bead_strand(h: Node3D, mat: Material, clasp: Material, board_col: Color) -> void:
	var b := _board(h, board_col, Vector2(0.46, 0.58))
	var n := 80
	var beads := []
	for i in range(n):
		var t := float(i) / float(n) * TAU
		var x := sin(t) * 0.16
		var y := 0.5 - (0.5 - 0.5 * cos(t)) * 0.42 - 0.04 * absf(sin(t))
		beads.append(Transform3D(Basis().scaled(Vector3.ONE * 0.0075), Vector3(x, y, 0.0075)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = ShopStones.sphere_mesh()
	mm.instance_count = beads.size()
	for i in range(beads.size()):
		mm.set_instance_transform(i, beads[i])
		mm.set_instance_custom_data(i, Color(float(i) * 0.137, 0, 0, 0))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = mat
	b.add_child(mmi)
	b.add_child(_mi(BoxMesh.new(), clasp, Vector3(0, 0.505, 0.006), Vector3(0.03, 0.008, 0.008)))
	MeshUtils.chain_links(b, MeshUtils.catenary(Vector3(0.015, 0.505, 0.006), Vector3(0.03, 0.44, 0.006), 0.0, 8), 0.004, 0.001, clasp)

static func _jade_bracelet(h: Node3D) -> void:
	var jade := ShopStones.material("jade_maya")
	var cord: Material = GalleryDisplays._mats()["black"]
	var R := 0.075
	var n := 11
	var box := MeshUtils.make_rounded_box(Vector3(1, 1, 1), 0.15, null).mesh
	var xfs := []
	for i in range(n):
		var a := float(i) / float(n + 2) * TAU
		var p := Vector3(cos(a) * R, 0.012, sin(a) * R)
		xfs.append(Transform3D(Basis(Vector3.UP, -a).scaled(Vector3(0.03, 0.03, 0.03)), Vector3(p.x, 0.02, p.z)))
	h.add_child(GalleryDisplays._mm(box, xfs, jade))
	var ring := MeshUtils.make_ring(R - 0.004, R + 0.004, 0.006, cord, 48)
	ring.position.y = 0.02
	h.add_child(ring)
	var a2 := float(n + 1) / float(n + 2) * TAU
	var bar := MeshUtils.make_rounded_box(Vector3(0.026, 0.008, 0.008), 0.002, gold())
	bar.position = Vector3(cos(a2) * R, 0.012, sin(a2) * R)
	bar.rotation.y = -a2 + PI * 0.5
	h.add_child(bar)
	for sgn in [-1.0, 1.0]:
		MeshUtils.sweep_tube(h, PackedVector3Array([bar.position, bar.position + Vector3(sgn * 0.03, 0.0, 0.04)]), 0.0012, 0.0012, cord)
		h.add_child(_mi(ShopStones.sphere_mesh(), gold(), bar.position + Vector3(sgn * 0.03, 0.0, 0.04), Vector3.ONE * 0.004))
