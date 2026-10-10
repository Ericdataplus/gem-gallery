class_name MineralLibrary

# ═══════════════════════════════════════════════════════════════════════════
# MINERAL LIBRARY — one front door to every raw specimen in the project.
#
# Two maker modules implement the same contract and are loaded by path, so the
# library works while either is missing or mid-edit:
#   res://content/mineral_crystals.gd  — crystalline / translucent species
#   res://content/mineral_rocks.gd     — massive / opaque stones & boulders
#
# CONTRACT each module implements (static funcs):
#   catalog() -> Array[Dictionary]   one entry per species:
#       "id":       String  unique snake_case id, e.g. "nephrite_jade_boulder"
#       "name":     String  display name, e.g. "Nephrite Jade"
#       "locality": String  real-world source, e.g. "British Columbia, Canada"
#       "note":     String  one short line about the real stone
#       "size":     Vector2 min/max overall size in metres (largest dimension)
#       "placement": String how it sits in the landscape — NO stands or tables,
#                           everything lies naturally on/in the ground:
#                           "boulder"  rests on the earth, settled ~10% into it
#                           "outcrop"  emerges from the ground (base buried; e.g.
#                                      a quartz cluster breaking out of the soil)
#                           "scatter"  small pieces lying in loose groups
#   make(id: String, size: float, seed: int) -> Node3D
#       y = 0 is the ground line: for "outcrop" the part meant to be buried
#       extends below y = 0 (so it can be dropped straight onto terrain).
#       Centred on x/z, largest dimension ~= size.
#       Same id+size+seed => identical specimen. Meshes are built once per
#       (id, seed) and cached; materials are shared per species.
# ═══════════════════════════════════════════════════════════════════════════

const MODULES := ["res://content/mineral_crystals.gd", "res://content/mineral_rocks.gd"]

static var _index := {}   # id -> module script

static func _modules() -> Array:
	var out := []
	for p in MODULES:
		if ResourceLoader.exists(p):
			var sc = load(p)
			if sc != null:
				out.append(sc)
	return out

static func catalog() -> Array:
	var all := []
	_index.clear()
	for m in _modules():
		for e in m.catalog():
			_index[e["id"]] = m
			all.append(e)
	return all

static func make(id: String, size: float, seed_: int = 0) -> Node3D:
	if _index.is_empty():
		catalog()
	if not _index.has(id):
		push_warning("MineralLibrary: unknown specimen '%s'" % id)
		return Node3D.new()
	return _index[id].make(id, size, seed_)

static func entry(id: String) -> Dictionary:
	for e in catalog():
		if e["id"] == id:
			return e
	return {}
