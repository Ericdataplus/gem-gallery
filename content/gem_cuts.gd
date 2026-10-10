class_name GemCuts

# ═══════════════════════════════════════════════════════════════════════════
# GEM CUTS — real faceted geometry with real-world proportions, plus the
# facet-plane list each cut's ray-traced shader needs (GemFactory).
#
# Unit gems: girdle "radius" ~1 on X/Z, crown +Y, pavilion -Y, girdle at y=0.
# Every cut is a CONVEX polyhedron (heart: nearly) so light can be traced
# inside it against its own facet planes.
#
#   GemCuts.CUTS            ordered list of cut ids
#   GemCuts.NAMES[id]       display name
#   GemCuts.mesh(id)        cached ArrayMesh (flat facets)
#   GemCuts.planes(id)      cached Array[Vector4] (outward normal xyz, offset w)
# ═══════════════════════════════════════════════════════════════════════════

const CUTS := ["round", "oval", "cushion", "princess", "radiant", "pear", "marquise", "heart",
	"trillion", "emerald", "asscher", "baguette", "old_european", "old_mine", "rose", "briolette"]

const NAMES := {
	"round": "Round brilliant", "oval": "Oval brilliant", "cushion": "Cushion", "princess": "Princess",
	"radiant": "Radiant", "pear": "Pear", "marquise": "Marquise", "heart": "Heart", "trillion": "Trillion",
	"emerald": "Emerald cut", "asscher": "Asscher", "baguette": "Baguette",
	"old_european": "Old European", "old_mine": "Old mine", "rose": "Rose cut", "briolette": "Briolette", "hexagon": "Hexagon step cut", "kite": "Kite cut", "table": "Table cut", "crystal12": "Crystal",
	"cabochon": "Cabochon",
}

# Brilliant-family parameters (real proportions):
#  table = table diameter / girdle diameter, crown/pav = facet angles in degrees,
#  lg = lower-girdle facet length, culet = open culet size (0 = pointed).
const BRILLIANT := {
	# Tolkowsky ideal: 53-57% table, 34.5 deg crown, 40.75 deg pavilion
	"round":    {"shape": "round", "mains": 8, "table": 0.56, "crown": 34.5, "pav": 40.75, "lg": 0.78},
	"oval":     {"shape": "oval", "mains": 8, "table": 0.56, "crown": 34.0, "pav": 41.0, "lg": 0.76},
	"cushion":  {"shape": "cushion", "mains": 8, "table": 0.58, "crown": 35.0, "pav": 41.5, "lg": 0.70},
	"princess": {"shape": "princess", "mains": 8, "table": 0.66, "crown": 33.0, "pav": 41.5, "lg": 0.62},
	"radiant":  {"shape": "radiant", "mains": 8, "table": 0.64, "crown": 34.0, "pav": 41.5, "lg": 0.66},
	"pear":     {"shape": "pear", "mains": 8, "table": 0.56, "crown": 34.0, "pav": 41.0, "lg": 0.74},
	"marquise": {"shape": "marquise", "mains": 8, "table": 0.54, "crown": 33.0, "pav": 41.0, "lg": 0.72},
	"heart":    {"shape": "heart", "mains": 8, "table": 0.56, "crown": 34.0, "pav": 41.0, "lg": 0.72},
	"trillion": {"shape": "trillion", "mains": 6, "table": 0.62, "crown": 32.0, "pav": 41.5, "lg": 0.70},
	# antique cuts: small table, tall crown, deep pavilion, open culet
	"old_european": {"shape": "round", "mains": 8, "table": 0.42, "crown": 40.0, "pav": 42.5, "lg": 0.55, "culet": 0.10},
	"old_mine":     {"shape": "cushion", "mains": 8, "table": 0.44, "crown": 39.0, "pav": 42.5, "lg": 0.55, "culet": 0.12},
}

static var _mesh_cache := {}
static var _plane_cache := {}

static func mesh(cut: String) -> ArrayMesh:
	if not _mesh_cache.has(cut):
		_build(cut)
	return _mesh_cache[cut]

static func planes(cut: String) -> Array:
	if not _plane_cache.has(cut):
		_build(cut)
	return _plane_cache[cut]

static func _build(cut: String) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	if BRILLIANT.has(cut):
		_brilliant(st, BRILLIANT[cut])
	else:
		match cut:
			"emerald":
				_step(st, 1.0, 0.70, 0.24, 0.30, 0.66, 4, 4, 0.10)
			"asscher":
				_step(st, 1.0, 1.0, 0.34, 0.40, 0.72, 4, 4, 0.0)
			"baguette":
				_step(st, 1.0, 0.40, 0.0, 0.18, 0.48, 2, 3, 0.12)
			"rose":
				_rose(st)
			"table":
				_step(st, 1.0, 0.72, 0.10, 0.10, 0.16, 1, 1, 0.75)
			"crystal12":
				_prism12(st)
			"hexagon":
				_step(st, 1.0, 0.46, 0.0, 0.24, 0.56, 3, 3, 0.12, [Vector2(1.0, 0.0), Vector2(0.62, 0.46), Vector2(-0.62, 0.46), Vector2(-1.0, 0.0), Vector2(-0.62, -0.46), Vector2(0.62, -0.46)])
			"kite":
				_step(st, 1.0, 0.36, 0.0, 0.22, 0.52, 3, 3, 0.1, [Vector2(1.0, 0.0), Vector2(-0.05, 0.36), Vector2(-0.58, 0.0), Vector2(-0.05, -0.36)])
			"briolette":
				_briolette(st)
			_:
				_brilliant(st, BRILLIANT["round"])
	var m := ArrayMesh.new()
	st.commit(m)
	_mesh_cache[cut] = m
	_plane_cache[cut] = _extract_planes(m)

# ── girdle outlines ──────────────────────────────────────────────────────────
static func outline(shape: String, a: float) -> Vector2:
	var c := cos(a)
	var s := sin(a)
	match shape:
		"oval":
			return Vector2(c, 0.70 * s)
		"cushion":
			return Vector2(signf(c) * pow(absf(c), 0.55), 0.92 * signf(s) * pow(absf(s), 0.55)) * 0.94
		"princess":
			return _ray_poly(a, [Vector2(0.8, 0.8), Vector2(-0.8, 0.8), Vector2(-0.8, -0.8), Vector2(0.8, -0.8)])
		"radiant":
			var w := 0.86
			var d := 0.70
			var k := 0.20
			return _ray_poly(a, [Vector2(w, d - k), Vector2(w - k, d), Vector2(-w + k, d), Vector2(-w, d - k),
				Vector2(-w, -d + k), Vector2(-w + k, -d), Vector2(w - k, -d), Vector2(w, -d + k)])
		"marquise":
			return Vector2(c, 0.48 * s * pow(absf(s), 0.6))
		"pear":
			if c > 0.0:
				return Vector2(c * 1.05, 0.62 * s * pow(absf(s), 0.7))
			return Vector2(c * 0.75, 0.62 * s)
		"heart":
			# lobes toward -x, point toward +x; shallow cleft so it stays near-convex
			var r := 0.80 + 0.22 * cos(a) * cos(a) - 0.10 * maxf(-c, 0.0) * exp(-pow(s / 0.25, 2.0))
			var pt := Vector2(c, s * 0.95) * r
			if c > 0.0:
				pt.y *= 1.0 - 0.55 * pow(c, 1.6)
			return pt
		"trillion":
			var seg := TAU / 3.0
			var kk := fposmod(a + PI / 2.0, seg) - seg / 2.0
			var tri := 0.5 / cos(kk)
			return Vector2(c, s) * lerpf(tri, 0.62, 0.30) * 1.35
		_:
			return Vector2(c, s)

static func _ray_poly(a: float, poly: Array) -> Vector2:
	var dir := Vector2(cos(a), sin(a))
	var best := 1e9
	for i in range(poly.size()):
		var p0: Vector2 = poly[i]
		var p1: Vector2 = poly[(i + 1) % poly.size()]
		var e := p1 - p0
		var den := dir.x * e.y - dir.y * e.x
		if absf(den) < 1e-9:
			continue
		var t := (p0.x * e.y - p0.y * e.x) / den
		var u := (p0.x * dir.y - p0.y * dir.x) / den
		if t > 0.0 and u >= -1e-6 and u <= 1.0 + 1e-6:
			best = minf(best, t)
	return dir * best

# ── brilliant: table, stars, bezels (kites), upper/lower girdle, mains ──────
static func _brilliant(st: SurfaceTool, p: Dictionary) -> void:
	var shape: String = p["shape"]
	var mains: int = p["mains"]
	var t: float = p["table"]
	var hc: float = (1.0 - t) * tan(deg_to_rad(p["crown"]))
	var hp: float = tan(deg_to_rad(p["pav"]))
	var lg: float = p["lg"]
	var culet: float = p.get("culet", 0.0)
	var g := 0.022
	var gcount := mains * 2
	var step := TAU / float(mains)
	var gt: Array[Vector3] = []
	var gb: Array[Vector3] = []
	for j in range(gcount):
		var o := outline(shape, float(j) / float(gcount) * TAU)
		gt.append(Vector3(o.x, g, o.y))
		gb.append(Vector3(o.x, -g, o.y))
	var tbl: Array[Vector3] = []
	var stars: Array[Vector3] = []
	var mids: Array[Vector3] = []
	var cul: Array[Vector3] = []
	for k in range(mains):
		var a := float(k) * step
		var o := outline(shape, a)
		tbl.append(Vector3(o.x * t, g + hc, o.y * t))
		var o2 := outline(shape, a + step * 0.5)
		var sf := 0.5
		stars.append(Vector3(o2.x * lerpf(1.0, t, sf), g + hc * sf, o2.y * lerpf(1.0, t, sf)))
		var mr := 1.0 - lg
		mids.append(Vector3(o.x * mr, -g - hp * lg, o.y * mr))
		cul.append(Vector3(o.x * culet, -g - hp * (1.0 - culet), o.y * culet))
	var cen := Vector3(0, -0.1, 0)
	var tc := Vector3(0, g + hc, 0)
	for k in range(mains):
		_tri(st, tc, tbl[k], tbl[(k + 1) % mains], cen)
	for k in range(mains):
		var kn := (k + 1) % mains
		var s := stars[k]
		var sp := stars[(k - 1 + mains) % mains]
		_tri(st, tbl[k], tbl[kn], s, cen)
		_quad(st, tbl[k], s, gt[2 * k], sp, cen)                       # bezel kite
		_tri(st, s, gt[2 * k], gt[2 * k + 1], cen)                     # upper girdle pair
		_tri(st, s, gt[2 * k + 1], gt[(2 * k + 2) % gcount], cen)
	for j in range(gcount):
		_quad(st, gt[j], gb[j], gb[(j + 1) % gcount], gt[(j + 1) % gcount], cen)
	var tip := Vector3(0, -g - hp, 0)
	for k in range(mains):
		var kn := (k + 1) % mains
		_tri(st, mids[k], gb[2 * k], gb[2 * k + 1], cen)               # lower girdle pair
		_tri(st, mids[kn], gb[2 * k + 1], gb[(2 * k + 2) % gcount], cen)
		if culet > 0.0:
			_quad(st, mids[k], gb[2 * k + 1], mids[kn], cul[kn], cen)
			_tri(st, mids[k], cul[kn], cul[k], cen)
		else:
			_tri(st, mids[k], gb[2 * k + 1], mids[kn], cen)
			_tri(st, tip, mids[k], mids[kn], cen)                       # pavilion main
	if culet > 0.0:
		var cc := Vector3(0, cul[0].y, 0)
		for k in range(mains):
			_tri(st, cc, cul[k], cul[(k + 1) % mains], cen)

# ── step cut (emerald / asscher / baguette) ─────────────────────────────────
static func _step(st: SurfaceTool, w: float, d: float, chamfer: float, crown_h: float, pav_h: float,
		crown_steps: int, pav_steps: int, keel: float, custom: Array = []) -> void:
	var base := [Vector2(w, d - chamfer), Vector2(w - chamfer, d), Vector2(-w + chamfer, d), Vector2(-w, d - chamfer),
		Vector2(-w, -d + chamfer), Vector2(-w + chamfer, -d), Vector2(w - chamfer, -d), Vector2(w, -d + chamfer)]
	if chamfer <= 0.0:
		base = [Vector2(w, d), Vector2(-w, d), Vector2(-w, -d), Vector2(w, -d)]
	if not custom.is_empty():
		base = custom
	var g := 0.022
	var cen := Vector3(0, -0.1, 0)
	var crown: Array = []
	for i in range(crown_steps + 1):
		var f := float(i) / float(crown_steps)
		var sc := 1.0 - 0.36 * pow(f, 0.85)
		crown.append(_ring(base, sc, sc, g + crown_h * sin(f * PI * 0.5)))
	var pav: Array = []
	for i in range(pav_steps + 1):
		var f := float(i) / float(pav_steps)
		var sx := lerpf(1.0, keel / w if w > 0 else 0.0, pow(f, 0.9))
		var sz := lerpf(1.0, 0.02, pow(f, 0.9))
		pav.append(_ring(base, maxf(sx, 0.02), sz, -g - pav_h * pow(f, 1.15)))
	var top: Array = crown[crown_steps]
	var tc := Vector3(0, top[0].y, 0)
	for i in range(top.size()):
		_tri(st, tc, top[i], top[(i + 1) % top.size()], cen)
	for r in range(crown_steps):
		_band(st, crown[r], crown[r + 1], cen)
	_band(st, crown[0], pav[0], cen)
	for r in range(pav_steps):
		_band(st, pav[r], pav[r + 1], cen)
	var last: Array = pav[pav_steps]
	var kc := Vector3(0, last[0].y - 0.02, 0)
	for i in range(last.size()):
		_tri(st, kc, last[i], last[(i + 1) % last.size()], cen)

static func _ring(base: Array, sx: float, sz: float, y: float) -> Array:
	var out := []
	for p in base:
		out.append(Vector3(p.x * sx, y, p.y * sz))
	return out

static func _band(st: SurfaceTool, a: Array, b: Array, cen: Vector3) -> void:
	var n := a.size()
	for i in range(n):
		_quad(st, a[i], b[i], b[(i + 1) % n], a[(i + 1) % n], cen)

# ── rose cut: flat back, domed crown of triangles meeting at a point ────────
static func _rose(st: SurfaceTool) -> void:
	var n := 6
	var cen := Vector3(0, 0.2, 0)
	var r0: Array[Vector3] = []
	var r1: Array[Vector3] = []
	for k in range(n * 2):
		var a := float(k) / float(n * 2) * TAU
		r0.append(Vector3(cos(a), 0.0, sin(a)))
	for k in range(n):
		var a := (float(k) + 0.5) / float(n) * TAU
		r1.append(Vector3(cos(a) * 0.62, 0.36, sin(a) * 0.62))
	var apex := Vector3(0, 0.58, 0)
	for k in range(n):
		var kn := (k + 1) % n
		var b0 := r0[2 * k + 1]
		_tri(st, r0[2 * k], b0, r1[k], cen)
		_tri(st, b0, r0[(2 * k + 2) % (n * 2)], r1[k], cen)
		_tri(st, r1[k], r0[(2 * k + 2) % (n * 2)], r1[kn], cen)
		_tri(st, apex, r1[k], r1[kn], cen)
	var b := Vector3(0, -0.06, 0)
	var ring_b: Array[Vector3] = []
	for k in range(n * 2):
		ring_b.append(r0[k] + Vector3(0, -0.06, 0))
	for k in range(n * 2):
		var kn := (k + 1) % (n * 2)
		_quad(st, r0[k], ring_b[k], ring_b[kn], r0[kn], cen)
		_tri(st, b, ring_b[k], ring_b[kn], cen)

# ── briolette: faceted teardrop (drilled-drop shape), long axis = X ─────────
static func _briolette(st: SurfaceTool) -> void:
	var rings := 6
	var seg := 8
	var cen := Vector3(0, 0, 0)
	var pts: Array = []
	for i in range(1, rings):
		var t := float(i) / float(rings)
		var r := pow(sin(t * PI), 0.75) * (1.0 - 0.45 * t) * 0.62
		var x := lerpf(-1.0, 1.0, t)
		var ring := []
		for k in range(seg):
			var a := (float(k) + 0.5 * float(i % 2)) / float(seg) * TAU
			ring.append(Vector3(x, cos(a) * r, sin(a) * r))
		pts.append(ring)
	var tip0 := Vector3(-1.0, 0, 0)
	var tip1 := Vector3(1.05, 0, 0)
	var first: Array = pts[0]
	var last: Array = pts[pts.size() - 1]
	for k in range(seg):
		_tri(st, tip0, first[k], first[(k + 1) % seg], cen)
		_tri(st, tip1, last[k], last[(k + 1) % seg], cen)
	for i in range(pts.size() - 1):
		var a: Array = pts[i]
		var b: Array = pts[i + 1]
		for k in range(seg):
			var kn := (k + 1) % seg
			if i % 2 == 0:
				_tri(st, a[k], a[kn], b[k], cen)
				_tri(st, a[kn], b[kn], b[k], cen)
			else:
				_tri(st, a[k], b[kn], b[k], cen)
				_tri(st, a[k], a[kn], b[kn], cen)

# ── 12-sided (dihexagonal-looking) prism crystal, flat terminations ────────
static func _prism12(st: SurfaceTool) -> void:
	var cen := Vector3.ZERO
	var n := 12
	var top: Array[Vector3] = []
	var bot: Array[Vector3] = []
	var cap: Array[Vector3] = []
	for k in range(n):
		var a := float(k) / float(n) * TAU
		top.append(Vector3(cos(a) * 0.62, 1.05, sin(a) * 0.62))
		bot.append(Vector3(cos(a) * 0.62, -1.1, sin(a) * 0.62))
		cap.append(Vector3(cos(a) * 0.5, 1.15, sin(a) * 0.5))
	for k in range(n):
		var kn := (k + 1) % n
		_quad(st, bot[k], top[k], top[kn], bot[kn], cen)
		_quad(st, top[k], cap[k], cap[kn], top[kn], cen)
		_tri(st, Vector3(0, 1.15, 0), cap[k], cap[kn], cen)
		_tri(st, Vector3(0, -1.1, 0), bot[k], bot[kn], cen)

# ── facet emitters ───────────────────────────────────────────────────────────
# Godot front faces are CLOCKWISE seen from outside: emit with (b-a)x(c-a)
# pointing inward while the stored flat normal points out.
static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, cen: Vector3) -> void:
	var n := (b - a).cross(c - a)
	if n.length_squared() < 1e-14:
		return
	if n.dot((a + b + c) / 3.0 - cen) < 0.0:
		var tmp := b
		b = c
		c = tmp
		n = -n
	n = n.normalized()
	st.set_normal(n); st.add_vertex(a)
	st.set_normal(n); st.add_vertex(c)
	st.set_normal(n); st.add_vertex(b)

static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, cen: Vector3) -> void:
	# one facet: shared best-fit normal so both triangles shade identically
	var n := ((c - a).cross(d - b))
	if n.dot((a + b + c + d) * 0.25 - cen) < 0.0:
		n = -n
	if n.length_squared() < 1e-14:
		return
	n = n.normalized()
	for tri in [[a, b, c], [a, c, d]]:
		var p0: Vector3 = tri[0]
		var p1: Vector3 = tri[1]
		var p2: Vector3 = tri[2]
		if (p1 - p0).cross(p2 - p0).dot(n) > 0.0:
			var tmp := p1
			p1 = p2
			p2 = tmp
		st.set_normal(n); st.add_vertex(p0)
		st.set_normal(n); st.add_vertex(p1)
		st.set_normal(n); st.add_vertex(p2)

# Unique facet planes (outward normal, offset) for the in-shader ray tracer.
static func _extract_planes(m: ArrayMesh) -> Array:
	var arr := m.surface_get_arrays(0)
	var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var nr: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
	var out: Array = []
	for i in range(0, v.size(), 3):
		var n := nr[i].normalized()
		var w := n.dot((v[i] + v[i + 1] + v[i + 2]) / 3.0)
		var dup := false
		for q in out:
			var qv: Vector4 = q
			if Vector3(qv.x, qv.y, qv.z).dot(n) > 0.9995 and absf(qv.w - w) < 0.004:
				dup = true
				break
		if not dup:
			out.append(Vector4(n.x, n.y, n.z, w))
	return out
