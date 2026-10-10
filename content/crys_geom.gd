class_name CrysGeom

# ═══════════════════════════════════════════════════════════════════════════
# CRYS GEOM — geometry kernel for MineralCrystals.
#
#   Buf             per-material vertex accumulator (non-indexed triangles)
#   convex_polys()  a convex polyhedron from half-spaces n.p <= d: every plane
#                   seeds a big quad that is clipped by all the others. Crystal
#                   habits are written the way mineralogists describe them —
#                   as a set of crystal FACES (prism, rhombohedron, pinacoid…)
#                   with per-face offsets, so unequal faces come out naturally.
#   crystal()       emits one crystal (flat-shaded) with the shader attributes
#   rock()          noise-displaced icosphere chipped by fracture planes
#   shell()         a broken-open geode: rind, rim, lined cavity
#   finalize()      normalise to largest dimension 1, centre x/z, ground rule,
#                   one ArrayMesh per material.
#
# Vertex attributes (consumed by CrysShaders):
#   UV      x = position along the crystal axis 0 (base) .. 1 (tip)
#           y = axial coordinate (object units) — across-axis striations
#   UV2     face-local coordinates (object units) about the crystal centre
#   COLOR   r = per-crystal random, g = face kind (0 side, 1 end/termination),
#           b = zone flag (species specific), a = 1
#   CUSTOM0 x = crystal half-thickness (object units), y = relative thickness
#           (absorption path multiplier), z = rock zone depth (geode rim bands)
#
# Godot treats CLOCKWISE (seen from the normal side) as front-facing; every
# emitter here checks (b-a)x(c-a) against the intended normal and swaps.
# ═══════════════════════════════════════════════════════════════════════════

class Buf:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var uv := PackedVector2Array()
	var uv2 := PackedVector2Array()
	var c := PackedColorArray()
	var cu := PackedFloat32Array()

	func add(p: Vector3, nn: Vector3, a: Vector2, b: Vector2, col: Color, cus: Vector3) -> void:
		v.append(p); n.append(nn); uv.append(a); uv2.append(b); c.append(col)
		cu.append(cus.x); cu.append(cus.y); cu.append(cus.z); cu.append(0.0)

static func buf(acc: Dictionary, key: String) -> Buf:
	if not acc.has(key):
		acc[key] = Buf.new()
	return acc[key]

# ── Basis helpers ────────────────────────────────────────────────────────────
static func basis_from_axis(axis: Vector3, spin: float) -> Basis:
	var y := axis.normalized()
	var ref := Vector3.RIGHT if absf(y.x) < 0.9 else Vector3.FORWARD
	var x := ref.cross(y).normalized()
	var z := x.cross(y).normalized()
	var b := Basis(x, y, z)
	return b * Basis(Vector3.UP, spin)

static func jitter_dir(rng: RandomNumberGenerator, d: Vector3, amt: float) -> Vector3:
	return (d.normalized() + Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * amt).normalized()

# ── Convex polyhedron from planes ────────────────────────────────────────────
# planes: Array of [Vector3 n (unit), float d, int kind]; inside is n.p <= d.
# Returns Array of [Array[Vector3] polygon, plane index].
static func convex_polys(planes: Array, ext: float) -> Array:
	var out := []
	for i in range(planes.size()):
		var n: Vector3 = planes[i][0]
		var d: float = planes[i][1]
		var u := n.cross(Vector3.UP if absf(n.y) < 0.9 else Vector3.RIGHT).normalized()
		var w := n.cross(u)
		var c := n * d
		var poly: Array = [c + (u + w) * ext, c + (u - w) * ext, c + (-u - w) * ext, c + (-u + w) * ext]
		for j in range(planes.size()):
			if j == i:
				continue
			poly = _clip(poly, planes[j][0], planes[j][1])
			if poly.size() < 3:
				break
		if poly.size() >= 3:
			out.append([poly, i])
	return out

static func _clip(poly: Array, n: Vector3, d: float) -> Array:
	var res := []
	var k := poly.size()
	for a in range(k):
		var p: Vector3 = poly[a]
		var q: Vector3 = poly[(a + 1) % k]
		var dp := p.dot(n) - d
		var dq := q.dot(n) - d
		if dp <= 0.0:
			res.append(p)
		if (dp < 0.0 and dq > 0.0) or (dp > 0.0 and dq < 0.0):
			res.append(p + (q - p) * (dp / (dp - dq)))
	return res

# ── One crystal ──────────────────────────────────────────────────────────────
# xf: rotation + translation only (local units are object units).
# opt: y0, len (for UV.x), th (half thickness), rel (absorption multiplier),
#      rnd, zone, center (local Vector3, face-coordinate origin), ext
static func crystal(acc: Dictionary, key: String, xf: Transform3D, planes: Array, opt: Dictionary) -> int:
	var b := buf(acc, key)
	var polys := convex_polys(planes, opt.get("ext", 4.0))
	var y0: float = opt.get("y0", 0.0)
	var ln: float = maxf(opt.get("len", 1.0), 1e-4)
	var th: float = opt.get("th", 0.05)
	var rel: float = opt.get("rel", 1.0)
	var rnd: float = opt.get("rnd", 0.5)
	var zone: float = opt.get("zone", 0.0)
	var cen: Vector3 = opt.get("center", Vector3.ZERO)
	var tris := 0
	for pr in polys:
		var pl: Array = planes[pr[1]]
		var kind: int = pl[2]
		if kind == 2:
			continue
		var n: Vector3 = pl[0]
		var u := (Vector3.UP.cross(n) if absf(n.y) < 0.97 else Vector3.RIGHT.cross(n)).normalized()
		var w := n.cross(u)
		var nw := (xf.basis * n).normalized()
		var col := Color(rnd, float(kind), zone, 1.0)
		var poly: Array = pr[0]
		var pts: Array = []
		var a1: Array = []
		var a2: Array = []
		for p in poly:
			var pv: Vector3 = p
			pts.append(xf * pv)
			a1.append(Vector2(clampf((pv.y - y0) / ln, 0.0, 1.0), pv.y))
			a2.append(Vector2((pv - cen).dot(u), (pv - cen).dot(w)))
		for k in range(1, pts.size() - 1):
			if _tri_attr(b, pts, a1, a2, [0, k, k + 1], nw, col, Vector3(th, rel, 0.0)):
				tris += 1
	return tris

static func _tri_attr(b: Buf, pts: Array, a1: Array, a2: Array, idx: Array, nrm: Vector3, col: Color, cus: Vector3) -> bool:
	var i0: int = idx[0]
	var i1: int = idx[1]
	var i2: int = idx[2]
	var p0: Vector3 = pts[i0]
	var p1: Vector3 = pts[i1]
	var p2: Vector3 = pts[i2]
	var cr := (p1 - p0).cross(p2 - p0)
	if cr.length_squared() < 1e-16:
		return false
	if cr.dot(nrm) > 0.0:
		var t := i1; i1 = i2; i2 = t
	b.add(pts[i0], nrm, a1[i0], a2[i0], col, cus)
	b.add(pts[i1], nrm, a1[i1], a2[i1], col, cus)
	b.add(pts[i2], nrm, a1[i2], a2[i2], col, cus)
	return true

# ── Crystal habits (local frame: c-axis = +Y, base buried to y = -bury) ──────

## Quartz: 6 unequal prism faces m + 3 large (r) and 3 small (z) rhombohedral
## faces meeting at the apex (y = L). taper > 0 leans the prism faces inward
## (Tessin habit). phi = angle between a termination-face normal and the axis.
static func quartz_planes(rng: RandomNumberGenerator, r: float, L: float, bury: float, opt: Dictionary = {}) -> Array:
	var planes := []
	var rot := rng.randf() * TAU
	var taper: float = opt.get("taper", 0.0)
	var phi: float = deg_to_rad(opt.get("phi", 51.8))
	var irr: float = opt.get("irr", 0.18)
	for i in range(6):
		var a := rot + float(i) * TAU / 6.0
		var rad := Vector3(cos(a), 0.0, sin(a))
		var n := (rad + Vector3(0, taper, 0)).normalized()
		var ri := r * rng.randf_range(1.0 - irr, 1.0 + irr)
		planes.append([n, n.dot(rad * ri), 0])
	var big_first := rng.randi() % 2
	for i in range(6):
		var a := rot + float(i) * TAU / 6.0
		var n := Vector3(sin(phi) * cos(a), cos(phi), sin(phi) * sin(a))
		var off := 0.0
		if i % 2 == big_first:
			off = r * rng.randf_range(0.05, 0.35)      # dominant r faces
		else:
			off = -r * rng.randf_range(0.0, 0.18)      # small z faces
		planes.append([n, n.dot(Vector3(0, L, 0)) + off * sin(phi), 1])
	planes.append([Vector3.DOWN, bury, 2])
	return planes

## Bare rhombohedral point (geode lining): 3 large + 3 small faces meeting at
## the apex (y = L), cut flat at y = 0 where it grows from the cavity wall.
static func pyramid_planes(rng: RandomNumberGenerator, L: float, phi_deg: float) -> Array:
	var planes := []
	var rot := rng.randf() * TAU
	var phi := deg_to_rad(phi_deg)
	var big_first := rng.randi() % 2
	for i in range(6):
		var a := rot + float(i) * TAU / 6.0 + rng.randf_range(-0.06, 0.06)
		var n := Vector3(sin(phi) * cos(a), cos(phi), sin(phi) * sin(a))
		var off := L * (rng.randf_range(0.03, 0.12) if i % 2 == big_first else -rng.randf_range(0.0, 0.05))
		planes.append([n, n.dot(Vector3(0, L, 0)) + off * sin(phi), 1])
	planes.append([Vector3.DOWN, 0.0, 2])
	return planes

## Beryl (emerald, aquamarine): hexagonal prism, flat basal pinacoid at y = L,
## narrow bevel (pyramid) faces on some top edges.
static func beryl_planes(rng: RandomNumberGenerator, r: float, L: float, bury: float, opt: Dictionary = {}) -> Array:
	var planes := []
	var rot := rng.randf() * TAU
	var irr: float = opt.get("irr", 0.12)
	var ris := []
	for i in range(6):
		var a := rot + float(i) * TAU / 6.0
		var n := Vector3(cos(a), 0.0, sin(a))
		var ri := r * rng.randf_range(1.0 - irr, 1.0 + irr)
		ris.append(ri)
		planes.append([n, ri, 0])
	var top_tilt: Vector3 = opt.get("top_tilt", Vector3.ZERO)
	var tn := (Vector3.UP + top_tilt).normalized()
	planes.append([tn, tn.dot(Vector3(0, L, 0)), 1])
	var bevel: float = opt.get("bevel", 0.15)
	for i in range(6):
		if rng.randf() < 0.35:
			continue
		var a := rot + float(i) * TAU / 6.0
		var rad := Vector3(cos(a), 0.0, sin(a))
		var n := (rad + Vector3.UP).normalized()
		planes.append([n, n.dot(rad * ris[i] + Vector3(0, L, 0)) - r * bevel * rng.randf_range(0.3, 1.0), 1])
	if opt.get("broken_base", false):
		var bn := (Vector3.DOWN + Vector3(rng.randf_range(-0.3, 0.3), 0, rng.randf_range(-0.3, 0.3))).normalized()
		planes.append([bn, bury, 1])
	else:
		planes.append([Vector3.DOWN, bury, 2])
	return planes

## Tourmaline: curved-triangular prism (12 side faces whose offsets follow
## 1 + k cos 3a, so three convex striated sides meet at narrow rounded corners)
## + a low trigonal pyramid or a flat broken end.
static func tourmaline_planes(rng: RandomNumberGenerator, r: float, L: float, bury: float, opt: Dictionary = {}) -> Array:
	var planes := []
	var rot := rng.randf() * TAU
	# Rounded-triangular section with deep lengthwise ridges: 18 prism faces,
	# alternating in/out so the striations read as real grooves in silhouette.
	for i in range(18):
		var a := float(i) * TAU / 18.0
		var n := Vector3(cos(a + rot), 0.0, sin(a + rot))
		var d := r * (1.0 + 0.30 * cos(3.0 * a)) * (1.0 + 0.05 * float(i % 2)) * rng.randf_range(0.97, 1.03)
		planes.append([n, d, 0])
	var term: String = opt.get("term", "pyramid")
	if term == "pyramid":
		var phi := deg_to_rad(rng.randf_range(38.0, 50.0))
		for k in range(3):
			var a := rot + PI / 3.0 + float(k) * TAU / 3.0
			var n := Vector3(sin(phi) * cos(a), cos(phi), sin(phi) * sin(a))
			planes.append([n, n.dot(Vector3(0, L, 0)) + r * rng.randf_range(-0.05, 0.12), 1])
		if rng.randf() < 0.5:
			planes.append([Vector3.UP, L - r * rng.randf_range(0.15, 0.4), 1])
	else:
		var tn := (Vector3.UP + Vector3(rng.randf_range(-0.25, 0.25), 0, rng.randf_range(-0.25, 0.25))).normalized()
		planes.append([tn, L, 1])
	if opt.get("broken_base", false):
		var bn := (Vector3.DOWN + Vector3(rng.randf_range(-0.25, 0.25), 0, rng.randf_range(-0.25, 0.25))).normalized()
		planes.append([bn, bury, 1])
	else:
		planes.append([Vector3.DOWN, bury, 2])
	return planes

## Fluorite cube (half size s) with tiny octahedral corner truncations.
static func cube_planes(rng: RandomNumberGenerator, s: float, corner: float) -> Array:
	var planes := []
	for ax in [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.BACK, Vector3.FORWARD]:
		planes.append([ax, s * rng.randf_range(0.94, 1.06), 0])
	if corner > 0.0:
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				for sz in [-1.0, 1.0]:
					var n := Vector3(sx, sy, sz).normalized()
					planes.append([n, s * sqrt(3.0) * (1.0 - corner * rng.randf_range(0.5, 1.0)), 1])
	return planes

## Gypsum (selenite) blade: flattened lozenge prism with a slanted chisel tip.
static func selenite_planes(rng: RandomNumberGenerator, w: float, t: float, L: float, bury: float) -> Array:
	var planes := []
	planes.append([Vector3.BACK, t, 0])
	planes.append([Vector3.FORWARD, t * rng.randf_range(0.8, 1.2), 0])
	var beta := deg_to_rad(rng.randf_range(18.0, 30.0))
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var n := Vector3(sx * cos(beta), 0.0, sz * sin(beta))
			planes.append([n, w * rng.randf_range(0.9, 1.1), 0])
	var s := 1.0 if rng.randf() < 0.5 else -1.0
	var n1 := Vector3(s * rng.randf_range(0.5, 0.9), 1.0, rng.randf_range(-0.15, 0.15)).normalized()
	var n2 := Vector3(-s * rng.randf_range(1.3, 2.2), 1.0, rng.randf_range(-0.1, 0.1)).normalized()
	planes.append([n1, n1.dot(Vector3(0, L, 0)), 1])
	planes.append([n2, n2.dot(Vector3(0, L - w * 0.4, 0)), 1])
	planes.append([Vector3.DOWN, bury, 2])
	return planes

## Celestite: tabular orthorhombic crystal with a wedge (dome) termination.
static func celestite_planes(rng: RandomNumberGenerator, w: float, t: float, L: float, bury: float) -> Array:
	var planes := []
	planes.append([Vector3.BACK, t, 0])
	planes.append([Vector3.FORWARD, t, 0])
	planes.append([Vector3.RIGHT, w, 0])
	planes.append([Vector3.LEFT, w * rng.randf_range(0.85, 1.15), 0])
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var n := Vector3(sx, 0.0, sz * 1.4).normalized()
			planes.append([n, n.dot(Vector3(sx * w, 0, sz * t)) - w * rng.randf_range(0.08, 0.2), 0])
	var dome := rng.randf_range(1.3, 2.1)
	for sz in [-1.0, 1.0]:
		var n := Vector3(0.0, 1.0, sz * dome).normalized()
		planes.append([n, n.dot(Vector3(0, L, 0)), 1])
	for sx in [-1.0, 1.0]:
		var n := Vector3(sx * 1.6, 1.0, 0.0).normalized()
		planes.append([n, n.dot(Vector3(0, L, 0)) + w * rng.randf_range(0.1, 0.4), 1])
	planes.append([Vector3.DOWN, bury, 2])
	return planes

# ── Rock / matrix: displaced icosphere chipped by fracture planes ────────────
# opt: subdiv, radii (Vector3), amp, freq, planes (int), pd (Vector2 plane
# distance range, fraction of radius), bottom (y below which it flattens, in
# unit-sphere space, < -1 = none), zone, th, rel, t (UV.x), crisp (bool)
static func rock(acc: Dictionary, key: String, xf: Transform3D, seed_: int, opt: Dictionary = {}) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var nz := FastNoiseLite.new()
	nz.seed = seed_
	nz.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	nz.fractal_type = FastNoiseLite.FRACTAL_FBM
	nz.fractal_octaves = 4
	nz.frequency = opt.get("freq", 1.2)
	var ico := GeoUtil.icosphere(opt.get("subdiv", 3))
	var verts: PackedVector3Array = ico[0]
	var faces: PackedInt32Array = ico[1]
	var unit := verts.duplicate()
	var radii: Vector3 = opt.get("radii", Vector3.ONE)
	var amp: float = opt.get("amp", 0.15)
	var np: int = opt.get("planes", 5)
	var pd: Vector2 = opt.get("pd", Vector2(0.7, 0.9))
	var bottom: float = opt.get("bottom", -2.0)
	var up_bias: float = opt.get("up_bias", 0.0)
	var planes := []
	for k in range(np):
		var pn := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1) + up_bias, rng.randf_range(-1, 1)).normalized()
		planes.append([pn, rng.randf_range(pd.x, pd.y)])
	var on_plane := PackedInt32Array()
	on_plane.resize(verts.size())
	for i in range(verts.size()):
		var v := verts[i]
		var p := v * (1.0 + nz.get_noise_3dv(v * 1.7) * amp)
		on_plane[i] = -1
		var best := 0.0
		for k in range(planes.size()):
			var pn: Vector3 = planes[k][0]
			var e := p.dot(pn) - float(planes[k][1])
			if e > 0.0:
				p -= pn * e
				if e > best:
					best = e
					on_plane[i] = k
		if bottom > -1.5 and p.y < bottom:
			p.y = lerpf(p.y, bottom, 0.85)
		verts[i] = p * radii
	# area-weighted smooth normals; triangle orientation from the unit sphere
	var vn := PackedVector3Array()
	vn.resize(verts.size())
	var tri_ok := []
	for i in range(0, faces.size(), 3):
		var a := faces[i]; var b := faces[i + 1]; var c := faces[i + 2]
		var fn := (verts[b] - verts[a]).cross(verts[c] - verts[a])
		var outward := unit[a] + unit[b] + unit[c]
		if fn.dot(outward) < 0.0:
			fn = -fn
		vn[a] += fn; vn[b] += fn; vn[c] += fn
	for i in range(vn.size()):
		vn[i] = vn[i].normalized()
	var bf := buf(acc, key)
	var crisp: bool = opt.get("crisp", true)
	var col := Color(rng.randf(), 0.0, opt.get("zone", 0.0), 1.0)
	var cus := Vector3(opt.get("th", 0.3), opt.get("rel", 1.0), 0.0)
	var tval: float = opt.get("t", 0.5)
	var nb := xf.basis.orthonormalized()
	for i in range(0, faces.size(), 3):
		var ids := [faces[i], faces[i + 1], faces[i + 2]]
		var fp: int = on_plane[ids[0]]
		var flat := crisp and fp >= 0 and on_plane[ids[1]] == fp and on_plane[ids[2]] == fp
		var pw := []
		var nws := []
		for id in ids:
			pw.append(xf * verts[id])
			var nn: Vector3 = (planes[fp][0] * radii.inverse()).normalized() if flat else (vn[id] as Vector3)
			nws.append((nb * nn).normalized())
		var cr: Vector3 = (pw[1] - pw[0]).cross(pw[2] - pw[0])
		var navg: Vector3 = nws[0] + nws[1] + nws[2]
		var order := [0, 1, 2]
		if cr.dot(navg) > 0.0:
			order = [0, 2, 1]
		for k in order:
			var lp: Vector3 = verts[ids[k]]
			bf.add(pw[k], nws[k], Vector2(tval, lp.y), Vector2(lp.x, lp.z), col, cus)
	return verts

# ── Geode shell (opening along local +Y, rim near y = 0) ─────────────────────
# Returns a dictionary used by shell_inner() to seat crystals on the lining.
static func shell(acc: Dictionary, key: String, xf: Transform3D, seed_: int, radii: Vector3, thick: float, opt: Dictionary = {}) -> Dictionary:
	var nz := FastNoiseLite.new()
	nz.seed = seed_
	nz.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	nz.fractal_type = FastNoiseLite.FRACTAL_FBM
	nz.fractal_octaves = 4
	nz.frequency = 1.0
	var sh := {"nz": nz, "radii": radii, "thick": thick, "amp": opt.get("amp", 0.07),
		"knob": opt.get("knob", 0.08), "jag": opt.get("jag", 0.12), "xf": xf}
	var NR: int = opt.get("rings", 14)
	var NS: int = opt.get("segs", 40)
	var outer := []
	var inner := []
	for j in range(NR + 1):
		var ro := []
		var ri := []
		for s in range(NS + 1):
			var az := float(s % NS) / float(NS) * TAU
			var f := float(j) / float(NR)
			ro.append(_shell_pt(sh, f, az, false))
			ri.append(_shell_pt(sh, f, az, true))
		outer.append(ro)
		inner.append(ri)
	var b := buf(acc, key)
	var cen := Vector3.ZERO
	# outer rind (zone 0), lining (zone 1)
	_grid(b, xf, outer, cen, true, Color(0.5, 0.0, 0.0, 1.0), 0.0)
	_grid(b, xf, inner, cen, false, Color(0.5, 0.0, 1.0, 1.0), 1.0)
	# rim: outer edge -> inner edge, in 3 bands so the agate layers have vertices
	var rim := []
	for k in range(4):
		var row := []
		for s in range(NS + 1):
			var po: Vector3 = outer[NR][s]
			var pi: Vector3 = inner[NR][s]
			var f := float(k) / 3.0
			var p := po.lerp(pi, f)
			p.y += sin(f * PI) * thick * 0.08
			row.append(p)
		rim.append(row)
	var nb := xf.basis.orthonormalized()
	for k in range(3):
		for s in range(NS):
			var q := [rim[k][s], rim[k + 1][s], rim[k + 1][s + 1], rim[k][s + 1]]
			var dq := [float(k) / 3.0, float(k + 1) / 3.0, float(k + 1) / 3.0, float(k) / 3.0]
			for tri in [[0, 1, 2], [0, 2, 3]]:
				var p0: Vector3 = q[tri[0]]
				var p1: Vector3 = q[tri[1]]
				var p2: Vector3 = q[tri[2]]
				var fn := (p1 - p0).cross(p2 - p0)
				if fn.length_squared() < 1e-14:
					continue
				if fn.y < 0.0:
					fn = -fn
				var nw := (nb * fn.normalized()).normalized()
				var pts := [xf * p0, xf * p1, xf * p2]
				var order := [0, 1, 2]
				if (pts[1] - pts[0]).cross(pts[2] - pts[0]).dot(nw) > 0.0:
					order = [0, 2, 1]
				for o in order:
					var lp: Vector3 = q[tri[o]]
					b.add(pts[o], nw, Vector2(0.5, lp.y), Vector2(lp.x, lp.z), Color(0.5, 0.0, 0.5, 1.0), Vector3(thick, 1.0, dq[tri[o]]))
	return sh

static func _shell_rim(sh: Dictionary, az: float) -> float:
	var nz: FastNoiseLite = sh["nz"]
	return PI * 0.5 + nz.get_noise_2d(cos(az) * 2.0, sin(az) * 2.0) * float(sh["jag"]) * 2.2

static func _shell_pt(sh: Dictionary, f: float, az: float, is_inner: bool) -> Vector3:
	var nz: FastNoiseLite = sh["nz"]
	var psi := f * _shell_rim(sh, az)
	var d := Vector3(sin(psi) * cos(az), -cos(psi), sin(psi) * sin(az))
	var radii: Vector3 = sh["radii"]
	var r := 1.0 + nz.get_noise_3dv(d * 1.6) * float(sh["amp"]) * 2.0 + nz.get_noise_3dv(d * 7.0 + Vector3(9, 9, 9)) * float(sh["knob"])
	var po := d * radii * r
	if not is_inner:
		return po
	var t: float = float(sh["thick"]) * (1.0 + nz.get_noise_3dv(d * 3.0 + Vector3(3, 1, 4)) * 0.3)
	return po * maxf(1.0 - t / po.length(), 0.2)

## Point on the lining + inward normal (shell-local), f in 0..1 (pole..rim).
static func shell_inner(sh: Dictionary, f: float, az: float) -> Array:
	var p := _shell_pt(sh, f, az, true)
	var e := 0.01
	var pf := _shell_pt(sh, minf(f + e, 1.0), az, true) - _shell_pt(sh, maxf(f - e, 0.0), az, true)
	var pa := _shell_pt(sh, f, az + e, true) - _shell_pt(sh, f, az - e, true)
	var n := pf.cross(pa).normalized()
	if n.dot(-p) < 0.0:
		n = -n
	if f < 0.02:
		n = Vector3.UP
	return [p, n]

static func _grid(b: Buf, xf: Transform3D, g: Array, cen: Vector3, outward: bool, col: Color, zone: float) -> void:
	var NR := g.size() - 1
	var NS: int = (g[0] as Array).size() - 1
	# smooth normals by accumulating face normals oriented relative to centre
	var nrm := []
	for j in range(NR + 1):
		var row := []
		for s in range(NS + 1):
			row.append(Vector3.ZERO)
		nrm.append(row)
	var quads := []
	for j in range(NR):
		for s in range(NS):
			var q := [[j, s], [j + 1, s], [j + 1, s + 1], [j, s + 1]]
			for tri in [[0, 1, 2], [0, 2, 3]]:
				var a: Vector3 = g[q[tri[0]][0]][q[tri[0]][1]]
				var bb: Vector3 = g[q[tri[1]][0]][q[tri[1]][1]]
				var c: Vector3 = g[q[tri[2]][0]][q[tri[2]][1]]
				var fn := (bb - a).cross(c - a)
				if fn.length_squared() < 1e-14:
					continue
				var mid := (a + bb + c) / 3.0 - cen
				if (fn.dot(mid) < 0.0) == outward:
					fn = -fn
				for k in tri:
					nrm[q[k][0]][q[k][1]] += fn
				quads.append([q[tri[0]], q[tri[1]], q[tri[2]]])
	# seam: average first/last column
	for j in range(NR + 1):
		var sn: Vector3 = nrm[j][0] + nrm[j][NS]
		nrm[j][0] = sn
		nrm[j][NS] = sn
	var nb := xf.basis.orthonormalized()
	for tq in quads:
		var pts := []
		var ns := []
		var lps := []
		for k in range(3):
			var lp: Vector3 = g[tq[k][0]][tq[k][1]]
			lps.append(lp)
			pts.append(xf * lp)
			ns.append((nb * (nrm[tq[k][0]][tq[k][1]] as Vector3).normalized()).normalized())
		var navg: Vector3 = ns[0] + ns[1] + ns[2]
		var order := [0, 1, 2]
		if (pts[1] - pts[0]).cross(pts[2] - pts[0]).dot(navg) > 0.0:
			order = [0, 2, 1]
		for o in order:
			var lp: Vector3 = lps[o]
			b.add(pts[o], ns[o], Vector2(0.5, lp.y), Vector2(lp.x, lp.z), col, Vector3(0.1, 1.0, zone))

# ── Finalize: normalise and build ArrayMeshes ────────────────────────────────
# placement: "boulder" (min y -> -10% of height), "outcrop"/"scatter" (as built).
# Returns Array of [ArrayMesh, key, tri_count].
static func finalize(acc: Dictionary, placement: String) -> Array:
	var lo := Vector3(INF, INF, INF)
	var hi := -lo
	for key in acc:
		var b: Buf = acc[key]
		for p in b.v:
			if placement != "boulder" and p.y < 0.0:
				continue
			lo = lo.min(p); hi = hi.max(p)
	var ext := hi - lo
	var k := 1.0 / maxf(maxf(ext.x, ext.y), maxf(ext.z, 1e-4))
	var off := Vector3((lo.x + hi.x) * 0.5, 0.0, (lo.z + hi.z) * 0.5)
	if placement == "boulder":
		off.y = lo.y + ext.y * 0.10
	var out := []
	for key in acc:
		var b: Buf = acc[key]
		var v := PackedVector3Array()
		v.resize(b.v.size())
		for i in range(b.v.size()):
			v[i] = (b.v[i] - off) * k
		var uv := b.uv.duplicate()
		var uv2 := b.uv2.duplicate()
		for i in range(uv.size()):
			uv[i] = Vector2(uv[i].x, uv[i].y * k)
			uv2[i] = uv2[i] * k
		var cu := b.cu.duplicate()
		for i in range(0, cu.size(), 4):
			cu[i] *= k
		var arr := []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = v
		arr[Mesh.ARRAY_NORMAL] = b.n
		arr[Mesh.ARRAY_TEX_UV] = uv
		arr[Mesh.ARRAY_TEX_UV2] = uv2
		arr[Mesh.ARRAY_COLOR] = b.c
		arr[Mesh.ARRAY_CUSTOM0] = cu
		var m := ArrayMesh.new()
		m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr, [], {},
			Mesh.ARRAY_CUSTOM_RGBA_FLOAT << Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT)
		out.append([m, key, v.size() / 3])
	return out
