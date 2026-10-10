class_name RockMesh

# ═══════════════════════════════════════════════════════════════════════════
# ROCK MESH — geometry for the massive / opaque mineral specimens.
#
# One generator covers every raw-stone form in MineralRocks:
#   1. a subdivided icosphere gives evenly spread directions;
#   2. each direction gets a radius: superellipsoid (p = 2 sphere .. 4 rounded
#      block) or a "log" (stalactite / petrified trunk), FBM displacement, and
#      optional botryoidal blisters (union of spherical caps, malachite);
#   3. KNAPPING: random fracture planes (plus fixed cuts: windows, cleavage,
#      log ends, the flat bed it rests on). Each vertex is pulled radially onto
#      the nearest plane it pokes through; planes are slightly dished (conchoidal)
#      so faces read as broken stone, not CAD cuts;
#   4. normals: faces lying wholly on one fracture plane are smoothed only with
#      each other (crisp fracture edges), everything else is auto-smoothed with
#      an angle threshold (rounded rind stays soft);
#   5. per-corner data for the object-space shaders:
#        COLOR.r  0 = natural rind, 0.5 = fracture face, 1 = cut / window face
#        COLOR.g  per-face hash        COLOR.b  part id (1 = pyrite cube)
#        COLOR.a  per-specimen hash (pattern offset)
#        UV.x     SIGNED depth below the ORIGINAL (uncut) surface: bands + edge mask
#        UV.y     distance from the fracture's impact point (ripples) or, for
#                 "log" shapes, distance from the trunk axis (growth rings)
#   6. normalised: largest dimension = 1, centred on x/z, base sunk to -sink.
# Godot front faces are CLOCKWISE seen from outside: every triangle is emitted
# so (b-a)x(c-a) points into the stone.
# ═══════════════════════════════════════════════════════════════════════════

const KIND_HIDDEN := 0     # flat bed — crisp normals, shaded as rind
const KIND_FRACTURE := 1
const KIND_CUT := 2

class Build:
	var pos := PackedVector3Array()
	var nrm := PackedVector3Array()   # per-corner (3 per face)
	var col := PackedColorArray()
	var uv := PackedVector2Array()
	var uv2 := PackedVector2Array()   # log shapes: unit (y,z) direction around the trunk axis

# Build a specimen body. Returns a Build (raw space, not normalised) so callers
# can add extra parts (pyrite cubes) before finish().
static func body(o: Dictionary, seed_: int) -> Build:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var nz := FastNoiseLite.new()
	nz.seed = seed_
	nz.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	nz.fractal_type = FastNoiseLite.FRACTAL_FBM
	nz.fractal_octaves = o.get("noise_oct", 4)
	nz.frequency = o.get("noise_freq", 1.2)
	var amp: float = o.get("noise_amp", 0.1)
	var pexp: float = o.get("pexp", 2.0)
	var stretch: Vector3 = o.get("stretch", Vector3.ONE)
	stretch *= Vector3(rng.randf_range(0.92, 1.08), rng.randf_range(0.92, 1.08), rng.randf_range(0.92, 1.08))
	var is_log: bool = o.get("log", false)
	var log_len: float = o.get("log_len", 1.6)
	var noise_aniso: Vector3 = o.get("noise_aniso", Vector3.ONE)
	var rot := Basis.from_euler(Vector3(rng.randf() * TAU, rng.randf() * TAU, rng.randf() * TAU))
	if is_log or o.get("no_rot", false):
		rot = Basis.IDENTITY

	var ico := _icosphere(o.get("subdiv", 4))
	var dirs: PackedVector3Array = ico[0]
	var faces: PackedInt32Array = ico[1]
	var n := dirs.size()

	# botryoidal blisters
	var bumps: Array = []
	var nb: int = o.get("bumps", 0)
	var bump_side: Vector3 = o.get("bump_side", Vector3.UP)
	var bang: Vector2 = o.get("bump_ang", Vector2(0.15, 0.4))
	for k in range(nb):
		var c := Vector3(rng.randfn(), rng.randfn(), rng.randfn()).normalized()
		c = (c + bump_side * o.get("bump_bias", 1.0)).normalized()
		var a := rng.randf_range(bang.x, bang.y)
		bumps.append([c, a, a * o.get("bump_h", 0.35) * rng.randf_range(0.7, 1.2), cos(a)])

	var pos := PackedVector3Array()
	pos.resize(n)
	for i in range(n):
		var d := dirs[i]
		var r := 1.0
		if is_log:
			var rho := Vector2(d.y, d.z).length()
			r = 1.0 / pow(pow(absf(d.x) / log_len, 8.0) + pow(rho, 8.0), 1.0 / 8.0)
		elif pexp != 2.0:
			var e := rot * d
			r = 1.0 / pow(pow(absf(e.x), pexp) + pow(absf(e.y), pexp) + pow(absf(e.z), pexp), 1.0 / pexp)
		r *= 1.0 + nz.get_noise_3dv(d * noise_aniso) * amp
		var hb := 0.0
		for b in bumps:
			var cd: float = d.dot(b[0])
			if cd <= b[3]:
				continue
			var ang := acos(minf(cd, 1.0))
			if ang < b[1]:
				var t: float = ang / b[1]
				hb = maxf(hb, b[2] * sqrt(1.0 - t * t))
		r += hb
		pos[i] = d * r * stretch

	# ── planes ─────────────────────────────────────────────────────────────
	var planes: Array = []   # [normal, d, dish, centre_t, kind]
	var np_: int = o.get("planes", 0)
	var frac: Vector2 = o.get("plane_frac", Vector2(0.8, 0.95))
	var dish: float = o.get("dish", 0.15)
	var pbias: Vector3 = o.get("plane_bias", Vector3.ZERO)
	for k in range(np_):
		# fractures mostly on the exposed upper/side surface (the bed hides the rest)
		var pd := Vector3(rng.randfn(), rng.randfn(), rng.randfn()).normalized()
		pd.y = absf(pd.y) * 0.8 - 0.15
		var pn := (pd.normalized() + pbias).normalized()
		_add_plane(planes, pos, pn, rng.randf_range(frac.x, frac.y), dish * rng.randf_range(0.5, 1.4), KIND_FRACTURE, rng)
	for c in o.get("cuts", []):
		# [normal, frac, dish, kind]
		_add_plane(planes, pos, (c[0] as Vector3).normalized(), c[1], c[2], c[3], rng)
	var bed: float = o.get("bed", 0.0)
	if bed > 0.0:
		_add_plane(planes, pos, Vector3.DOWN, bed, 0.0, KIND_HIDDEN, rng)

	var ks: float = o.get("edge_soft", 0.03)
	var depth := PackedFloat32Array(); depth.resize(n)
	var rip := PackedFloat32Array(); rip.resize(n)
	var pid := PackedInt32Array(); pid.resize(n)
	for i in range(n):
		var p := pos[i]
		var best := 1.0
		var minf := INF
		var bk := -1
		var br := 0.0
		for k in range(planes.size()):
			var pl: Array = planes[k]
			var pn: Vector3 = pl[0]
			var nd := pn.dot(p)
			if nd <= 1e-4:
				continue
			var tdist := ((p - pn * nd) - (pl[3] as Vector3)).length()
			var de: float = pl[1] + pl[2] * tdist * tdist
			var f := de / nd
			if f < minf:
				minf = f
				bk = k
				br = tdist
			best = _smin(best, f, ks)
		var q := p * best
		# SIGNED: >0 removed by a cut (depth below the original surface), <0 how far
		# the nearest plane still is — so its zero crossing interpolates into a
		# clean fracture edge in the shader instead of a triangle stair-step.
		depth[i] = clampf((1.0 - minf) * p.length(), -0.5, 10.0) if bk >= 0 else -0.5
		rip[i] = br
		pid[i] = bk
		pos[i] = q
	if is_log:
		for i in range(n):
			rip[i] = Vector2(pos[i].y, pos[i].z).length()

	# ── faces, groups, normals ─────────────────────────────────────────────
	var nf := faces.size() / 3
	var crisp: bool = o.get("crisp_planes", false)
	var fnrm := PackedVector3Array(); fnrm.resize(nf)
	var grp := PackedInt32Array(); grp.resize(nf)
	var adj: Array = []
	adj.resize(n)
	for i in range(n):
		adj[i] = []
	for f in range(nf):
		var ia := faces[f * 3]; var ib := faces[f * 3 + 1]; var ic := faces[f * 3 + 2]
		var cr := (pos[ib] - pos[ia]).cross(pos[ic] - pos[ia])
		var crd := (dirs[ib] - dirs[ia]).cross(dirs[ic] - dirs[ia])
		if crd.dot(dirs[ia] + dirs[ib] + dirs[ic]) < 0.0:
			cr = -cr
		fnrm[f] = cr   # outward, area weighted
		var g := -1
		if crisp and pid[ia] >= 0 and depth[ia] > 0.0 and depth[ib] > 0.0 and depth[ic] > 0.0 and pid[ia] == pid[ib] and pid[ia] == pid[ic]:
			g = pid[ia]
		grp[f] = g
		for v in [ia, ib, ic]:
			(adj[v] as Array).append(f)
	var cos_thr := cos(deg_to_rad(o.get("smooth_deg", 34.0)))
	var shash := fmod(absf(sin(float(seed_) * 12.9898 + 4.1) * 43758.5453), 1.0)

	var out := Build.new()
	for f in range(nf):
		var fi := [faces[f * 3], faces[f * 3 + 1], faces[f * 3 + 2]]
		var fn := fnrm[f].normalized()
		var g := grp[f]
		# emit so (b-a)x(c-a) points inward (clockwise from outside)
		var order := [0, 2, 1]
		var raw := (pos[fi[1]] - pos[fi[0]]).cross(pos[fi[2]] - pos[fi[0]])
		if raw.dot(fn) < 0.0:
			order = [0, 1, 2]
		for k in order:
			var v: int = fi[k]
			var s := Vector3.ZERO
			for g2 in (adj[v] as Array):
				if grp[g2] != g:
					continue
				var on := fnrm[g2]
				if g < 0 and on.normalized().dot(fn) < cos_thr:
					continue
				s += on
			if s.length_squared() < 1e-20:
				s = fn
			var kind := 0
			var fh := 0.0
			if pid[v] >= 0:
				kind = planes[pid[v]][4]
				fh = fmod(float(pid[v]) * 0.618034 + 0.13, 1.0)
			out.pos.append(pos[v])
			out.nrm.append(s.normalized())
			out.col.append(Color(kind * 0.5, fh, 0.0, shash))
			out.uv.append(Vector2(depth[v], rip[v]))
			out.uv2.append(Vector2(pos[v].y, pos[v].z).normalized() if is_log else Vector2.ZERO)
	return out

# polynomial smooth-min: knapped edges are crisp but not stair-stepped
static func _smin(a: float, b: float, k: float) -> float:
	if k <= 0.0:
		return minf(a, b)
	var h := clampf(0.5 + 0.5 * (b - a) / k, 0.0, 1.0)
	return lerpf(b, a, h) - k * h * (1.0 - h)

static func _add_plane(planes: Array, pos: PackedVector3Array, pn: Vector3, frac: float, dish: float, kind: int, rng: RandomNumberGenerator) -> void:
	var sup := -INF
	var sp := Vector3.ZERO
	for p in pos:
		var d := pn.dot(p)
		if d > sup:
			sup = d
			sp = p
	var ct := sp - pn * pn.dot(sp)
	# impact point off-centre, toward the face rim (where a blow lands)
	ct += Vector3(rng.randfn(), rng.randfn(), rng.randfn()).normalized() * rng.randf_range(0.15, 0.5) * absf(sup)
	ct -= pn * pn.dot(ct)
	planes.append([pn, sup * frac, dish, ct, kind])

# Axis-aligned-in-`basis` box (flat-shaded), e.g. a pyrite cube. part goes to
# COLOR.b; UV.x is the coordinate ACROSS the face's striations (pyritohedral
# rule: the striation axis cycles x->y->z->x between the cube's face pairs).
static func add_box(b: Build, c: Vector3, half: Vector3, basis: Basis, part: float, shash: float) -> void:
	var ax := [basis.x.normalized(), basis.y.normalized(), basis.z.normalized()]
	for a in range(3):
		for sgn in [-1.0, 1.0]:
			var nrm: Vector3 = ax[a] * sgn
			var u: Vector3 = ax[(a + 1) % 3]
			var w: Vector3 = ax[(a + 2) % 3]
			var hu: float = half[(a + 1) % 3]
			var hw: float = half[(a + 2) % 3]
			var fc: Vector3 = c + nrm * half[a]
			var q := [fc - u * hu - w * hw, fc + u * hu - w * hw, fc + u * hu + w * hw, fc - u * hu + w * hw]
			# striations run along w -> pattern coordinate is along u
			var uvs := [-hu, hu, hu, -hu]
			var fh := fmod(float(a * 2 + int(sgn > 0.0)) * 0.618 + c.x * 3.1, 1.0)
			for tri in [[0, 1, 2], [0, 2, 3]]:
				var p0: Vector3 = q[tri[0]]; var p1: Vector3 = q[tri[1]]; var p2: Vector3 = q[tri[2]]
				var ord := [0, 1, 2]
				if (p1 - p0).cross(p2 - p0).dot(nrm) > 0.0:
					ord = [0, 2, 1]
				for k in ord:
					var vi: int = tri[k]
					b.pos.append(q[vi])
					b.nrm.append(nrm)
					b.col.append(Color(0.5, fh, part, shash))
					b.uv.append(Vector2(uvs[vi] + c.dot(u), 0.0))
					b.uv2.append(Vector2.ZERO)

# Normalise (largest dimension -> 1, centred x/z, min y -> -sink) and commit.
static func finish(b: Build, sink: float) -> ArrayMesh:
	var lo := Vector3(INF, INF, INF)
	var hi := -lo
	for p in b.pos:
		lo = lo.min(p)
		hi = hi.max(p)
	var ext := hi - lo
	var s := 1.0 / maxf(ext.x, maxf(ext.y, ext.z))
	var off := Vector3(-(lo.x + hi.x) * 0.5, -lo.y, -(lo.z + hi.z) * 0.5)
	var sunk := sink * ext.y * s
	var pos := PackedVector3Array(); pos.resize(b.pos.size())
	var uv := PackedVector2Array(); uv.resize(b.uv.size())
	for i in range(b.pos.size()):
		pos[i] = (b.pos[i] + off) * s - Vector3(0, sunk, 0)
		uv[i] = b.uv[i] * s
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(pos.size()):
		st.set_normal(b.nrm[i])
		st.set_color(b.col[i])
		st.set_uv(uv[i])
		st.set_uv2(b.uv2[i])
		st.add_vertex(pos[i])
	st.index()
	return st.commit()

static func _icosphere(subdiv: int) -> Array:
	var t := (1.0 + sqrt(5.0)) / 2.0
	var verts := PackedVector3Array([
		Vector3(-1, t, 0), Vector3(1, t, 0), Vector3(-1, -t, 0), Vector3(1, -t, 0),
		Vector3(0, -1, t), Vector3(0, 1, t), Vector3(0, -1, -t), Vector3(0, 1, -t),
		Vector3(t, 0, -1), Vector3(t, 0, 1), Vector3(-t, 0, -1), Vector3(-t, 0, 1)])
	for i in range(verts.size()):
		verts[i] = verts[i].normalized()
	var faces := PackedInt32Array([0,11,5, 0,5,1, 0,1,7, 0,7,10, 0,10,11, 1,5,9, 5,11,4, 11,10,2, 10,7,6, 7,1,8,
		3,9,4, 3,4,2, 3,2,6, 3,6,8, 3,8,9, 4,9,5, 2,4,11, 6,2,10, 8,6,7, 9,8,1])
	for _s in range(subdiv):
		var cache := {}
		var nf := PackedInt32Array()
		for i in range(0, faces.size(), 3):
			var a := faces[i]; var b := faces[i + 1]; var c := faces[i + 2]
			var ab := _mid(verts, cache, a, b)
			var bc := _mid(verts, cache, b, c)
			var ca := _mid(verts, cache, c, a)
			nf.append_array([a, ab, ca, b, bc, ab, c, ca, bc, ab, bc, ca])
		faces = nf
	return [verts, faces]

static func _mid(verts: PackedVector3Array, cache: Dictionary, a: int, b: int) -> int:
	var key := mini(a, b) * 100000 + maxi(a, b)
	if cache.has(key):
		return cache[key]
	verts.append(((verts[a] + verts[b]) * 0.5).normalized())
	cache[key] = verts.size() - 1
	return verts.size() - 1
