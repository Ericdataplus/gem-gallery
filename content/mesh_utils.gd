class_name MeshUtils

static func make_box(size: Vector3, mat: Material) -> MeshInstance3D:
	return make_rounded_box(size, -1.0, mat)

## Micro-chamfered box — the universal "pro" upgrade. Flat-shaded 45° chamfer
## facets throw a catch-light line down every edge that a razor-sharp BoxMesh
## cannot. bevel < 0 → auto (sub-2% of the smallest side, the highlight-line
## sweet spot, not a rounded toy); bevel == 0 → plain BoxMesh fast path.
static func make_rounded_box(size: Vector3, bevel: float, mat: Material) -> MeshInstance3D:
	var mn := minf(size.x, minf(size.y, size.z))
	var b := bevel
	if b < 0.0:
		b = clampf(mn * 0.012, 0.006, 0.04)
	b = minf(b, mn * 0.45)
	var mi := MeshInstance3D.new()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	if b < 0.0008:
		var bm := BoxMesh.new(); bm.size = size; mi.mesh = bm
		return mi
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var h := size * 0.5
	var axes: Array[Vector3] = [Vector3.RIGHT, Vector3.UP, Vector3.BACK]
	var signs: Array[float] = [1.0, -1.0]
	# 6 inset faces
	for ai in range(3):
		var na: Vector3 = axes[ai]
		var ua: Vector3 = axes[(ai + 1) % 3]
		var va: Vector3 = axes[(ai + 2) % 3]
		var en := _axis_extent(h, na)
		var eu := _axis_extent(h, ua) - b
		var ev := _axis_extent(h, va) - b
		for sgn in signs:
			var c := na * (en * sgn)
			_face_quad(st, c + ua * eu + va * ev, c + ua * eu - va * ev, c - ua * eu - va * ev, c - ua * eu + va * ev, na * sgn)
	# 12 edge chamfers
	for pr in [[0, 1], [1, 2], [2, 0]]:
		var ia: int = pr[0]
		var ib: int = pr[1]
		var aa: Vector3 = axes[ia]
		var ab: Vector3 = axes[ib]
		var ac: Vector3 = axes[3 - ia - ib]
		var ea := _axis_extent(h, aa)
		var eb := _axis_extent(h, ab)
		var ec := _axis_extent(h, ac) - b
		for sa in signs:
			for sb in signs:
				var pap := aa * (sa * ea) + ab * (sb * (eb - b)) + ac * ec
				var pam := aa * (sa * ea) + ab * (sb * (eb - b)) - ac * ec
				var pbp := aa * (sa * (ea - b)) + ab * (sb * eb) + ac * ec
				var pbm := aa * (sa * (ea - b)) + ab * (sb * eb) - ac * ec
				_face_quad(st, pap, pbp, pbm, pam, (aa * sa + ab * sb).normalized())
	# 8 corner triangles
	for sx in signs:
		for sy in signs:
			for sz in signs:
				var p1 := Vector3(sx * h.x, sy * (h.y - b), sz * (h.z - b))
				var p2 := Vector3(sx * (h.x - b), sy * h.y, sz * (h.z - b))
				var p3 := Vector3(sx * (h.x - b), sy * (h.y - b), sz * h.z)
				_face_tri(st, p1, p2, p3, Vector3(sx, sy, sz).normalized())
	mi.mesh = st.commit()
	return mi

static func _axis_extent(h: Vector3, axis: Vector3) -> float:
	return absf(h.x * axis.x + h.y * axis.y + h.z * axis.z)

# Godot treats CLOCKWISE (seen from the normal side) as front-facing, so the
# emitted winding has (b-a)x(c-a) pointing AGAINST the stored outward normal.
static func _face_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, nrm: Vector3) -> void:
	if (b - a).cross(c - a).dot(nrm) > 0.0:
		var t := a; a = d; d = t
		t = b; b = c; c = t
	st.set_normal(nrm); st.add_vertex(a)
	st.set_normal(nrm); st.add_vertex(b)
	st.set_normal(nrm); st.add_vertex(c)
	st.set_normal(nrm); st.add_vertex(a)
	st.set_normal(nrm); st.add_vertex(c)
	st.set_normal(nrm); st.add_vertex(d)

static func _face_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, nrm: Vector3) -> void:
	if (b - a).cross(c - a).dot(nrm) > 0.0:
		var t := b; b = c; c = t
	st.set_normal(nrm); st.add_vertex(a)
	st.set_normal(nrm); st.add_vertex(b)
	st.set_normal(nrm); st.add_vertex(c)

## Revolve a 2D profile (x = radius, y = height) around Y into one ArrayMesh —
## the shared lathe for mouldings, coping, rings and drums. A CLOSED profile
## (first point repeated last) yields a hollow ring with real inner/outer/top/
## bottom faces, which a solid CylinderMesh can never be. Cylindrical UVs so
## tangents generate for the clearcoat marbles.
static func make_revolved(profile: Array, mat: Material, segs: int = 96) -> MeshInstance3D:
	# Profiles are traced counter-clockwise in the (radius, height) plane, so a
	# segment's outward normal there is (dy, -dr). Normals are set per segment:
	# smooth around the revolution, crisp at every moulding corner.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n_prof := profile.size() - 1
	for i in range(n_prof):
		var p0: Vector2 = profile[i]
		var p1: Vector2 = profile[i + 1]
		var seg := p1 - p0
		if seg.length_squared() < 1e-12:
			continue
		var n2 := Vector2(seg.y, -seg.x).normalized()
		var v0 := float(i) / float(n_prof)
		var v1 := float(i + 1) / float(n_prof)
		for j in range(segs):
			var a0 := float(j) / float(segs) * TAU
			var a1 := float(j + 1) / float(segs) * TAU
			var u0 := float(j) / float(segs)
			var u1 := float(j + 1) / float(segs)
			var na0 := Vector3(cos(a0) * n2.x, n2.y, sin(a0) * n2.x)
			var na1 := Vector3(cos(a1) * n2.x, n2.y, sin(a1) * n2.x)
			var v00 := Vector3(cos(a0) * p0.x, p0.y, sin(a0) * p0.x)
			var v10 := Vector3(cos(a1) * p0.x, p0.y, sin(a1) * p0.x)
			var v01 := Vector3(cos(a0) * p1.x, p1.y, sin(a0) * p1.x)
			var v11 := Vector3(cos(a1) * p1.x, p1.y, sin(a1) * p1.x)
			st.set_normal(na0); st.set_uv(Vector2(u0, v0)); st.add_vertex(v00)
			st.set_normal(na1); st.set_uv(Vector2(u1, v0)); st.add_vertex(v10)
			st.set_normal(na0); st.set_uv(Vector2(u0, v1)); st.add_vertex(v01)
			st.set_normal(na1); st.set_uv(Vector2(u1, v0)); st.add_vertex(v10)
			st.set_normal(na1); st.set_uv(Vector2(u1, v1)); st.add_vertex(v11)
			st.set_normal(na0); st.set_uv(Vector2(u0, v1)); st.add_vertex(v01)
	st.generate_tangents()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return mi

## Hollow ring of rectangular section (a torus with square cross-section):
## inner radius r_in, outer r_out, height h, centred on y=0.
static func make_ring(r_in: float, r_out: float, h: float, mat: Material, segs: int = 96) -> MeshInstance3D:
	var hh := h / 2.0
	return make_revolved([
		Vector2(r_in, -hh), Vector2(r_out, -hh), Vector2(r_out, hh), Vector2(r_in, hh), Vector2(r_in, -hh),
	], mat, segs)

static func make_cylinder(bottom_r: float, top_r: float, height: float, mat: Material, segs: int = 20) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = bottom_r
	mesh.top_radius = top_r
	mesh.height = height
	mesh.radial_segments = segs
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return mi

static func make_sphere(radius: float, mat: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return mi

static func make_mesh(mesh: Mesh, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return mi

## Collapse a built prototype (one column, one brazier, …) into a set of
## MultiMeshInstance3D — ONE per distinct mesh part — instanced at every
## `placement` transform. N identical multi-part props then cost ~(#parts)
## draw calls instead of N×(#parts). Each part keeps its own material and
## cast_shadow. `source` is NOT freed (caller owns it); its own root transform
## is ignored so placements position the whole prop. `placements` is an
## Array[Transform3D]. Returns Array[MultiMeshInstance3D] to add to the scene.
static func multimesh_from_node(source: Node3D, placements: Array) -> Array:
	var parts: Array = []
	_harvest_parts(source, Transform3D.IDENTITY, parts, true)
	var out: Array = []
	for part in parts:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = part["mesh"]
		mm.instance_count = placements.size()
		for i in range(placements.size()):
			mm.set_instance_transform(i, (placements[i] as Transform3D) * (part["xform"] as Transform3D))
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		if part["mat"] != null:
			mmi.material_override = part["mat"]
		mmi.cast_shadow = part["shadow"]
		out.append(mmi)
	return out

## Flatten a multi-part prototype into ONE ArrayMesh per distinct material with
## every child transform baked in, so a 40-node capital costs 2-3 draw calls.
## Children carrying meta `no_bake` (shared meshes under a non-uniform scale,
## whose normals a bake would skew) are returned separately with their
## accumulated transform for the caller to instance as-is.
## Returns {"baked": [{mesh, mat, shadow}], "loose": [{mesh, mat, xform, shadow}]}.
static func bake_node(source: Node3D) -> Dictionary:
	var parts: Array = []
	var loose: Array = []
	_harvest_bakeable(source, Transform3D.IDENTITY, parts, loose, true)
	var buckets := {}
	var order: Array = []
	for part in parts:
		var mat: Material = part["mat"]
		var key := mat.get_instance_id() if mat != null else 0
		if not buckets.has(key):
			buckets[key] = {"st": null, "mat": mat, "shadow": part["shadow"]}
			order.append(key)
		var b: Dictionary = buckets[key]
		if b["st"] == null:
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			b["st"] = st
		var mesh: Mesh = part["mesh"]
		for s in range(mesh.get_surface_count()):
			# Mixing indexed (BoxMesh/CylinderMesh) and non-indexed surfaces in one
			# SurfaceTool drops geometry — flatten each surface first.
			var flat := SurfaceTool.new()
			flat.create_from(mesh, s)
			flat.deindex()
			(b["st"] as SurfaceTool).append_from(flat.commit(), 0, part["xform"])
	var baked: Array = []
	for key in order:
		var b: Dictionary = buckets[key]
		baked.append({"mesh": (b["st"] as SurfaceTool).commit(), "mat": b["mat"], "shadow": b["shadow"]})
	return {"baked": baked, "loose": loose}

static func _harvest_bakeable(node: Node, accum: Transform3D, out: Array, loose: Array, is_root: bool) -> void:
	var here := accum
	if not is_root and node is Node3D:
		here = accum * (node as Node3D).transform
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mi := node as MeshInstance3D
		var rec := {"mesh": mi.mesh, "mat": mi.material_override, "xform": here, "shadow": mi.cast_shadow}
		if mi.has_meta("no_bake"):
			loose.append(rec)
		else:
			out.append(rec)
	for c in node.get_children():
		_harvest_bakeable(c, here, out, loose, false)

static func _harvest_parts(node: Node, accum: Transform3D, out: Array, is_root: bool) -> void:
	var here := accum
	if not is_root and node is Node3D:
		here = accum * (node as Node3D).transform
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mi := node as MeshInstance3D
		out.append({
			"mesh": mi.mesh,
			"mat": mi.material_override,
			"xform": here,
			"shadow": mi.cast_shadow,
		})
	for c in node.get_children():
		_harvest_parts(c, here, out, false)

# ═══════════════════════════════════════════════════════════════════════════
# SWEEP / DRAPE PRIMITIVES — gravity curves, chains, and tapered tubes that
# power censers, hanging lamps, festoons, menorah arms, banner hems.
# ═══════════════════════════════════════════════════════════════════════════

## Sample a hanging curve from a to b that sags by `sag` at its middle
## (parabolic approximation — visually identical to a true catenary at prop scale).
static func catenary(a: Vector3, b: Vector3, sag: float, samples: int) -> PackedVector3Array:
	var pts := PackedVector3Array()
	for i in range(samples + 1):
		var t := float(i) / float(samples)
		var p := a.lerp(b, t)
		p.y -= 4.0 * sag * t * (1.0 - t)
		pts.append(p)
	return pts

## A tapering tube swept along an arbitrary point list (one ArrayMesh, one node).
static func sweep_tube(parent: Node3D, points, r0: float, r1: float, mat: Material) -> void:
	var n: int = points.size()
	if n < 2:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(n - 1):
		var ra := lerpf(r0, r1, float(i) / float(n - 1))
		var rb := lerpf(r0, r1, float(i + 1) / float(n - 1))
		_tube_segment(st, points[i], points[i + 1], ra, rb)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)

## Interlocked chain: a cached TorusMesh link at each segment midpoint, the ring
## plane following the chain, alternate links rotated 90° to interlock. ONE MultiMesh.
static func chain_links(parent: Node3D, points, link_r: float, link_thick: float, mat: Material) -> void:
	var n: int = points.size()
	if n < 2:
		return
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(link_r - link_thick, 0.001)
	torus.outer_radius = link_r + link_thick
	torus.rings = 8
	torus.ring_segments = 6
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = torus
	mm.instance_count = n - 1
	for i in range(n - 1):
		var p0: Vector3 = points[i]
		var p1: Vector3 = points[i + 1]
		var mid: Vector3 = (p0 + p1) * 0.5
		var dir: Vector3 = p1 - p0
		if dir.length() < 0.0001:
			dir = Vector3.UP
		dir = dir.normalized()
		var up := Vector3.UP if absf(dir.dot(Vector3.UP)) < 0.9 else Vector3.FORWARD
		var zax := dir.cross(up).normalized()
		var yax := zax.cross(dir).normalized()
		var basis := Basis(dir, yax, zax)        # ring plane contains the chain dir
		if i % 2 == 1:
			basis = basis.rotated(dir, PI / 2.0)  # interlock alternate links
		mm.set_instance_transform(i, Transform3D(basis, mid))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = mat
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mmi)

static func _tube_segment(st: SurfaceTool, p0: Vector3, p1: Vector3, r0: float, r1: float) -> void:
	var axis := p1 - p0
	var l := axis.length()
	if l < 0.0001:
		return
	var dir := axis / l
	var up := Vector3.UP if absf(dir.dot(Vector3.UP)) < 0.95 else Vector3.RIGHT
	var bx := up.cross(dir).normalized()
	var bz := dir.cross(bx).normalized()
	var rings := 7
	for i in range(rings):
		var a0 := float(i) / float(rings) * TAU
		var a1 := float(i + 1) / float(rings) * TAU
		var n0 := bx * cos(a0) + bz * sin(a0)
		var n1 := bx * cos(a1) + bz * sin(a1)
		st.add_vertex(p0 + n0 * r0); st.add_vertex(p1 + n0 * r1); st.add_vertex(p0 + n1 * r0)
		st.add_vertex(p0 + n1 * r0); st.add_vertex(p1 + n0 * r1); st.add_vertex(p1 + n1 * r1)
