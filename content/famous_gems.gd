class_name FamousGems

# ═══════════════════════════════════════════════════════════════════════════
# FAMOUS GEMS — a museum hall of the world's legendary stones, each modelled
# on the real one (weight, cut, colour, home) and shown at a constant 6x real
# size so their sizes compare truthfully. Weights/sale prices are the commonly
# published figures; "Priceless" = state-owned / not for sale.
#
#   FamousGems.CATALOGUE    the data
#   FamousGems.build_hall(gallery, start: Vector3) -> void
#   FamousGems.display_name(key) -> String
# ═══════════════════════════════════════════════════════════════════════════

const SCALE := 6.0

# key, name, carats, specific gravity, cut, home, value/status, one-line story,
# optics [transmission colour, RI, dispersion, density]  (or "star"/"crystal")
const CATALOGUE := [
	{"key": "cullinan_i", "name": "Cullinan I  (Great Star of Africa)", "ct": 530.2, "sg": 3.52, "cut": "pear",
		"home": "Sceptre with the Cross, Tower of London", "value": "Priceless (British Crown Jewels)",
		"note": "Largest clear cut diamond, cut from the 3,106 ct Cullinan rough (1905).",
		"optics": [Color(1.0, 1.0, 1.0), 2.417, 0.044, 0.0]},
	{"key": "cullinan_ii", "name": "Cullinan II  (Second Star of Africa)", "ct": 317.4, "sg": 3.52, "cut": "cushion",
		"home": "Imperial State Crown, Tower of London", "value": "Priceless (British Crown Jewels)",
		"note": "Cushion cut from the same Cullinan rough.",
		"optics": [Color(1.0, 1.0, 1.0), 2.417, 0.044, 0.0]},
	{"key": "koh_i_noor", "name": "Koh-i-Noor", "ct": 105.6, "sg": 3.52, "cut": "oval",
		"home": "Crown of Queen Elizabeth, Tower of London", "value": "Priceless (British Crown Jewels)",
		"note": "'Mountain of Light', Indian origin, recut in 1852 from 186 ct.",
		"optics": [Color(1.0, 1.0, 1.0), 2.417, 0.044, 0.0]},
	{"key": "hope", "name": "Hope Diamond", "ct": 45.52, "sg": 3.52, "cut": "old_mine",
		"home": "Smithsonian, Washington DC", "value": "Priceless (est. $200-350M)",
		"note": "Deep grey-blue (boron); glows red-orange after UV light.",
		"optics": [Color(0.42, 0.55, 0.92), 2.417, 0.044, 1.6]},
	{"key": "regent", "name": "Regent Diamond", "ct": 140.64, "sg": 3.52, "cut": "cushion",
		"home": "Louvre, Paris", "value": "Priceless (French Crown Jewels)",
		"note": "Found in India 1698; worn by Louis XV and on Napoleon's sword.",
		"optics": [Color(1.0, 1.0, 1.0), 2.417, 0.044, 0.0]},
	{"key": "sancy", "name": "Sancy Diamond", "ct": 55.23, "sg": 3.52, "cut": "pear",
		"home": "Louvre, Paris", "value": "Priceless (French Crown Jewels)",
		"note": "Pale yellow shield shape, one of the first symmetrically faceted diamonds.",
		"optics": [Color(1.0, 0.97, 0.80), 2.417, 0.044, 0.5]},
	{"key": "orlov", "name": "Orlov Diamond", "ct": 189.62, "sg": 3.52, "cut": "rose",
		"home": "Diamond Fund, Kremlin, Moscow", "value": "Priceless (Russian Imperial Sceptre)",
		"note": "High-domed Mughal rose cut, given to Catherine the Great.",
		"optics": [Color(0.98, 1.0, 0.98), 2.417, 0.044, 0.15]},
	{"key": "dresden_green", "name": "Dresden Green", "ct": 40.70, "sg": 3.52, "cut": "pear",
		"home": "Green Vault, Dresden", "value": "Priceless",
		"note": "Largest natural green diamond (natural radiation colour).",
		"optics": [Color(0.66, 0.95, 0.62), 2.417, 0.044, 0.9]},
	{"key": "daria_i_noor", "name": "Daria-i-Noor", "ct": 182.0, "sg": 3.52, "cut": "table",
		"home": "Central Bank of Iran, Tehran", "value": "Priceless (Iranian Crown Jewels)",
		"note": "'Sea of Light', pale pink table-cut slab, one of the largest pink diamonds.",
		"optics": [Color(1.0, 0.82, 0.86), 2.417, 0.044, 0.5]},
	{"key": "tiffany_yellow", "name": "Tiffany Yellow Diamond", "ct": 128.54, "sg": 3.52, "cut": "cushion",
		"home": "Tiffany & Co., New York", "value": "Not for sale (est. $30M+)",
		"note": "82 facets; worn by only four women in its history.",
		"optics": [Color(1.0, 0.84, 0.25), 2.417, 0.044, 0.9]},
	{"key": "pink_star", "name": "Pink Star (CTF Pink Star)", "ct": 59.60, "sg": 3.52, "cut": "oval",
		"home": "Chow Tai Fook, Hong Kong", "value": "Sold $71.2M (2017)",
		"note": "Largest vivid pink diamond ever graded internally flawless.",
		"optics": [Color(1.0, 0.45, 0.66), 2.417, 0.044, 0.9]},
	{"key": "star_of_india", "name": "Star of India", "ct": 563.35, "sg": 4.0, "cut": "cabochon",
		"home": "American Museum of Natural History, NY", "value": "Priceless",
		"note": "Largest known gem star sapphire; stolen in 1964 and recovered.",
		"star": Color(0.62, 0.66, 0.80)},
	{"key": "logan", "name": "Logan Sapphire", "ct": 422.99, "sg": 4.0, "cut": "cushion",
		"home": "Smithsonian, Washington DC", "value": "Priceless",
		"note": "Sri Lankan, one of the largest faceted blue sapphires.",
		"optics": [Color(0.18, 0.34, 0.98), 1.770, 0.018, 0.55]},
	{"key": "bismarck", "name": "Bismarck Sapphire", "ct": 98.6, "sg": 4.0, "cut": "emerald",
		"home": "Smithsonian, Washington DC", "value": "Priceless",
		"note": "Burmese blue, set in a platinum and diamond necklace by Cartier.",
		"optics": [Color(0.12, 0.26, 0.95), 1.770, 0.018, 1.0]},
	{"key": "rosser_reeves", "name": "Rosser Reeves Star Ruby", "ct": 138.7, "sg": 4.0, "cut": "cabochon",
		"home": "Smithsonian, Washington DC", "value": "Priceless",
		"note": "One of the largest and finest star rubies (Sri Lanka).",
		"star": Color(0.70, 0.10, 0.20)},
	{"key": "delong", "name": "DeLong Star Ruby", "ct": 100.32, "sg": 4.0, "cut": "cabochon",
		"home": "American Museum of Natural History, NY", "value": "Priceless",
		"note": "Burmese star ruby, also taken in the 1964 heist (ransomed back).",
		"star": Color(0.80, 0.22, 0.36)},
	{"key": "black_prince", "name": "Black Prince's Ruby", "ct": 170.0, "sg": 3.6, "cut": "cushion",
		"home": "Imperial State Crown, Tower of London", "value": "Priceless (British Crown Jewels)",
		"note": "Actually a red spinel; worn by English kings since the 1300s.",
		"optics": [Color(0.95, 0.10, 0.16), 1.718, 0.020, 0.9]},
	{"key": "timur_ruby", "name": "Timur Ruby", "ct": 352.5, "sg": 3.6, "cut": "cabochon_red",
		"home": "Royal Collection, UK", "value": "Priceless",
		"note": "Polished red spinel engraved with the names of Mughal emperors.",
		"star": Color(0.70, 0.08, 0.14)},
	{"key": "hooker", "name": "Hooker Emerald", "ct": 75.47, "sg": 2.72, "cut": "asscher",
		"home": "Smithsonian, Washington DC", "value": "Priceless",
		"note": "Colombian; once belonged to an Ottoman sultan's belt buckle.",
		"optics": [Color(0.12, 0.84, 0.44), 1.580, 0.014, 0.9]},
	{"key": "chalk", "name": "Chalk Emerald", "ct": 37.82, "sg": 2.72, "cut": "emerald",
		"home": "Smithsonian, Washington DC", "value": "Priceless",
		"note": "Colombian, rich velvety green, set in a ring with diamonds.",
		"optics": [Color(0.06, 0.78, 0.36), 1.580, 0.014, 1.3]},
	{"key": "mogul", "name": "Mogul Emerald", "ct": 217.80, "sg": 2.72, "cut": "table",
		"home": "Museum of Islamic Art, Doha", "value": "Sold $2.2M (2001)",
		"note": "Flat tablet carved with Shia prayers and Mughal flowers (dated 1695).",
		"optics": [Color(0.10, 0.74, 0.40), 1.580, 0.014, 1.2]},
	{"key": "patricia", "name": "Patricia Emerald", "ct": 632.0, "sg": 2.72, "cut": "crystal12",
		"home": "American Museum of Natural History, NY", "value": "Priceless (uncut crystal)",
		"note": "Rare 12-sided (dihexagonal) Colombian emerald crystal, never cut.",
		"optics": [Color(0.12, 0.70, 0.40), 1.580, 0.014, 0.9]},
]

static func display_name(key: String) -> String:
	for e in CATALOGUE:
		if e["key"] == key:
			return e["name"]
	return key.replace("_", " ").capitalize()

## Real girdle radius (m) from carats and density: a 1 ct diamond round is
## ~6.5 mm across; other materials scale with (3.52/SG)^(1/3).
static func real_radius(ct: float, sg: float) -> float:
	return 0.5 * 6.5 * pow(ct * 3.52 / sg, 1.0 / 3.0) / 1000.0

## Register every famous stone's optics with GemFactory (as named stones).
static func register() -> void:
	for e in CATALOGUE:
		if e.has("optics"):
			GemFactory.extra_optics[e["key"]] = e["optics"]
		elif e.has("star"):
			var kind := 3 if e["cut"] == "cabochon" else 4
			GemFactory.extra_stones[e["key"]] = [e["star"], 1.77, 0.0, ["cabochon"], 0.0, kind]

static func build_hall(g: Node3D, start: Vector3) -> void:
	register()
	var mats := GalleryDisplays._mats()
	var n := CATALOGUE.size()
	var per_side := int(ceil(float(n) / 2.0))
	var spacing := 2.4
	var length := float(per_side) * spacing + 4.0
	# floor, carpet runner and a header
	GalleryDisplays._box(g, Vector3(9.0, 0.02, length), start + Vector3(0, -0.01, length * 0.5 - 1.0), mats["black"], true)
	var carpet := StandardMaterial3D.new()
	carpet.albedo_color = Color(0.28, 0.03, 0.05)
	carpet.roughness = 1.0
	GalleryDisplays._box(g, Vector3(1.6, 0.01, length - 1.0), start + Vector3(0, 0.005, length * 0.5 - 1.0), carpet)
	g._label("Legendary Gems  -  museum hall  (all shown at 6x real size)", start + Vector3(0, 2.6, -0.4), 0.004)
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.9, 0.96, 1.0, 0.07)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.02
	glass.metallic_specular = 1.0
	for i in range(n):
		var e: Dictionary = CATALOGUE[i]
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := start.z + 1.5 + float(i / 2) * spacing
		var base := Vector3(start.x + side * 2.0, 0, z)
		var top := 1.15
		GalleryDisplays._box(g, Vector3(0.6, top, 0.6), base + Vector3(0, top * 0.5, 0), mats["black"], true)
		GalleryDisplays._box(g, Vector3(0.56, 0.02, 0.56), base + Vector3(0, top + 0.01, 0), mats["velvet"])
		# the stone, tilted toward the aisle
		var size := real_radius(float(e["ct"]), float(e["sg"])) * SCALE
		var cut: String = e["cut"]
		var gcut := "cabochon" if cut.begins_with("cabochon") else cut
		# the stone turns slowly on a velvet turntable under its own pin lights,
		# tilted so the table, crown and pavilion all swing through the light
		var holder := Turntable.stand(g, base + Vector3(0, top + 0.02, 0), clampf(size * 1.25, 0.1, 0.22), 0.045, 0.42 + 0.06 * float(i % 3))
		holder.rotation.y = float(i) * 1.3
		var stone := GemFactory.make_gem(e["key"], gcut, size)
		stone.position.y = 0.014 + (0.0 if gcut == "cabochon" else size * 0.12)
		stone.rotation.x = 0.0 if gcut == "crystal12" or gcut == "cabochon" else -0.3
		holder.add_child(stone)
		Turntable.no_shadow(stone)
		if g.has_method("add_inspect_spot"):
			g.add_inspect_spot(holder.position + Vector3(0, size, 0), e["key"], gcut, stone)
		# jeweller's spot from the aisle side, plus the turntable's pin lights
		GalleryDisplays._spot(g, base + Vector3(-side * 1.3, 2.9, -0.4), holder.position, 5.0, 14.0)
		Turntable.pin_lights(g, holder.position + Vector3(0, size * 0.7, 0), Vector3(-side, 0, 0), 3.5)
		# plaque on the aisle face of the plinth
		var lb := Label3D.new()
		lb.text = "%s\n%.2f ct  -  %s\n%s\n%s\n%s" % [e["name"], float(e["ct"]), GemCuts.NAMES.get(gcut, "Crystal" if gcut == "crystal12" else gcut),
			e["home"], e["value"], e["note"]]
		lb.font_size = 24
		lb.pixel_size = 0.0012
		lb.outline_size = 6
		lb.width = 600.0
		lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lb.modulate = Color(0.95, 0.9, 0.78)
		lb.position = base + Vector3(-side * 0.31, top * 0.72, 0)
		lb.rotation.y = -side * PI * 0.5
		g.add_child(lb)
