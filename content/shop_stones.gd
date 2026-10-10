class_name ShopStones

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# SHOP STONES â€” the rock-shop side of the hobby: tumbled and polished stones,
# spheres, wands, dice, selenite sticks, trilobites, lava rock and bismuth.
# One polished-stone shader with a per-material "kind"; meshes are cached
# variants; heaps are MultiMeshes (seed per instance via custom data).
#
#   ShopStones.material(kind)                    kinds: see KINDS
#   ShopStones.heap(kind, area: Vector2, count, size: Vector2, seed) -> Node3D
#   ShopStones.tumbled_mesh(v) / sphere / wand / stick / trilobite / bismuth(...)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

const KINDS := {"malachite": 0, "lapis": 1, "selenite": 2, "rose_quartz": 3, "amazonite": 4,
	"aquamarine": 5, "green_onyx": 6, "apatite": 7, "trilobite": 8, "lava": 9, "bismuth": 10, "turquoise_web": 11, "jade_maya": 12, "obsidian": 13, "faience": 14, "carnelian": 15, "jade_tiles": 16, "shell": 17, "lapis_raw": 18, "turquoise_inlay": 19, "nemes": 20, "collar_bands": 21, "hiero_cloth": 22, "horus_bangle": 23, "gold_glyph": 24, "ermine": 25, "rainbow_obsidian": 26, "lapis_calcite": 27, "ur_mosaic": 28, "enamel_plaque": 29, "filigree": 30, "dendera": 31, "turq_mosaic": 32, "coin_silver": 33, "nephrite": 34}

static var _mats := {}
static var _meshes := {}
static var _shader: Shader

static func material(kind: String) -> ShaderMaterial:
	if _mats.has(kind):
		return _mats[kind]
	if _shader == null:
		_shader = Shader.new()
		_shader.code = HEAD + MatGLSL.NOISE + MatGLSL.BUMP + BODY
	var m := ShaderMaterial.new()
	m.shader = _shader
	m.set_shader_parameter("kind", int(KINDS.get(kind, 0)))
	_mats[kind] = m
	return m

# â”€â”€ meshes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## Tumbled stone: lumpy rounded pebble (variant 0..5), unit-ish radius.
static func tumbled_mesh(v: int) -> ArrayMesh:
	var key := "tumbled%d" % v
	if _meshes.has(key):
		return _meshes[key]
	var rng := RandomNumberGenerator.new()
	rng.seed = 900 + v
	var nz := FastNoiseLite.new()
	nz.seed = 900 + v
	nz.frequency = 0.9
	var stretch := Vector3(rng.randf_range(0.9, 1.25), rng.randf_range(0.55, 0.8), rng.randf_range(0.7, 1.0))
	var m := _deform_sphere(32, 16, func(p: Vector3) -> Vector3:
		var q := p * stretch
		return q * (1.0 + nz.get_noise_3dv(p * 1.3) * 0.18))
	_meshes[key] = m
	return m

static func sphere_mesh() -> ArrayMesh:
	if not _meshes.has("sphere"):
		_meshes["sphere"] = _deform_sphere(48, 24, func(p: Vector3) -> Vector3: return p)
	return _meshes["sphere"]

## Trilobite (Elrathia/Flexicalymene-like): segmented thorax ribs, three axial
## lobes, rounded cephalon, flat underside. Length 2 along Z.
static func trilobite_mesh() -> ArrayMesh:
	if _meshes.has("trilobite"):
		return _meshes["trilobite"]
	var m := _deform_sphere(40, 24, func(p: Vector3) -> Vector3:
		var q := Vector3(p.x * 0.62, p.y * 0.24, p.z)
		if q.y < 0.0:
			q.y *= 0.25
		else:
			var z := q.z
			var ribs := 0.035 * maxf(0.0, sin(z * 22.0)) * smoothstep(0.62, 0.3, z)
			var axial := 0.07 * exp(-pow(q.x / 0.16, 2.0))
			var head := 0.06 * smoothstep(0.45, 0.75, z)
			q.y += (ribs + axial + head) * clampf(p.y * 4.0, 0.0, 1.0)
		return q)
	_meshes["trilobite"] = m
	return m

## Double-terminated polished point (lapis "wand"): 6-sided, long along X.
static func wand_mesh() -> ArrayMesh:
	if _meshes.has("wand"):
		return _meshes["wand"]
	var mi := MeshUtils.make_revolved([Vector2(0.0, -1.0), Vector2(0.28, -0.72), Vector2(0.3, -0.6),
		Vector2(0.3, 0.6), Vector2(0.28, 0.72), Vector2(0.0, 1.0)], null, 6)
	_meshes["wand"] = mi.mesh
	return mi.mesh

## Freeform polished cabochon: rounded triangle outline, domed top, gently
## domed back (like a hand-cut spiderweb turquoise). Unit size, flat at y=0.
static func freeform_mesh() -> ArrayMesh:
	if _meshes.has("freeform"):
		return _meshes["freeform"]
	var m := _deform_sphere(64, 32, func(p: Vector3) -> Vector3:
		var th := atan2(p.z, p.x)
		var seg := TAU / 3.0
		var k := fposmod(th + PI * 0.5, seg) - seg * 0.5
		var tri := 0.55 / cos(k)
		var r := lerpf(tri, 0.75, 0.45)
		var q := Vector3(p.x * r * 1.25, p.y, p.z * r * 1.25)
		q.y *= 0.34 if p.y > 0.0 else 0.16
		return q)
	_meshes["freeform"] = m
	return m

## One polished piece (inspectable): freeform cabochon in the given kind.
static func piece(kind: String, size: float) -> Node3D:
	var mi := MeshInstance3D.new()
	mi.mesh = freeform_mesh()
	mi.material_override = material(kind)
	mi.scale = Vector3.ONE * size
	var n := Node3D.new()
	n.add_child(mi)
	return n

static func _deform_sphere(seg: int, rings: int, f: Callable) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts := []
	for r in range(rings + 1):
		var row := []
		var ph := PI * float(r) / float(rings)
		for s in range(seg + 1):
			var th := TAU * float(s % seg) / float(seg)
			var p := Vector3(sin(ph) * cos(th), cos(ph), sin(ph) * sin(th))
			row.append(f.call(p))
		pts.append(row)
	for r in range(rings):
		for s in range(seg):
			var a: Vector3 = pts[r][s]
			var b: Vector3 = pts[r + 1][s]
			var c: Vector3 = pts[r + 1][s + 1]
			var d: Vector3 = pts[r][s + 1]
			# Godot front faces: clockwise seen from outside (verified by test)
			st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
			st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)
	st.index()
	st.generate_normals()
	var m := ArrayMesh.new()
	st.commit(m)
	return m

## Bismuth hopper crystal: square stair-stepped frames spiralling inward.
static func bismuth(size: float) -> Node3D:
	var n := Node3D.new()
	var mat := material("bismuth")
	var levels := 7
	for k in range(levels):
		var s := size * (1.0 - float(k) / float(levels) * 0.82)
		var t := size * 0.07
		var y := float(k) * t * 0.9
		for side in range(4):
			var bm := MeshUtils.make_rounded_box(Vector3(s, t, t), 0.0, mat)
			var a := float(side) * PI * 0.5 + float(k) * 0.06
			bm.rotation.y = a
			bm.position = Vector3(cos(a + PI * 0.5) * s * 0.5, y + t * 0.5, -sin(a + PI * 0.5) * s * 0.5)
			n.add_child(bm)
	return n

## A heap of tumbled stones (or spheres) inside an area, settling on each other.
static func heap(kind: String, area: Vector2, count: int, size: Vector2, seed_: int, use_spheres := false) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var root := Node3D.new()
	var cell := 0.02
	var nx := maxi(1, int(area.x / cell))
	var nz := maxi(1, int(area.y / cell))
	var hf := PackedFloat32Array()
	hf.resize(nx * nz)
	hf.fill(0.0)
	var groups := {}
	for i in range(count):
		var s := rng.randf_range(size.x, size.y)
		var p := Vector2(rng.randf_range(-0.5, 0.5) * (area.x - s * 2.0), rng.randf_range(-0.5, 0.5) * (area.y - s * 2.0))
		var gx := clampi(int((p.x + area.x * 0.5) / cell), 0, nx - 1)
		var gz := clampi(int((p.y + area.y * 0.5) / cell), 0, nz - 1)
		var fr := maxi(1, int(s / cell))
		var ground := 0.0
		for zz in range(maxi(0, gz - fr), mini(nz, gz + fr + 1)):
			for xx in range(maxi(0, gx - fr), mini(nx, gx + fr + 1)):
				ground = maxf(ground, hf[zz * nx + xx])
		var v := 99 if use_spheres else rng.randi() % 6
		var hy := s if use_spheres else s * 0.62
		var basis := Basis(Vector3.UP, rng.randf() * TAU) * Basis(Vector3.RIGHT, rng.randf_range(-0.3, 0.3))
		var xf := Transform3D(basis.scaled(Vector3.ONE * s), Vector3(p.x, ground * 0.8 + hy, p.y))
		for zz in range(maxi(0, gz - fr), mini(nz, gz + fr + 1)):
			for xx in range(maxi(0, gx - fr), mini(nx, gx + fr + 1)):
				hf[zz * nx + xx] = maxf(hf[zz * nx + xx], ground * 0.8 + hy * 2.0)
		if not groups.has(v):
			groups[v] = []
		groups[v].append(xf)
	for v in groups:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_custom_data = true
		mm.mesh = sphere_mesh() if v == 99 else tumbled_mesh(v)
		var xfs: Array = groups[v]
		mm.instance_count = xfs.size()
		for i in range(xfs.size()):
			mm.set_instance_transform(i, xfs[i])
			mm.set_instance_custom_data(i, Color(rng.randf(), 0, 0, 0))
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.material_override = material(kind)
		root.add_child(mmi)
	return root

# â”€â”€ the polished-stone shader â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const HEAD := """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
uniform int kind = 0;
varying vec3 v_obj;
varying float v_seed;
void vertex() {
	v_obj = VERTEX;
	v_seed = INSTANCE_CUSTOM.x * 37.0;
}
"""

const BODY := """
vec3 srgb(vec3 c) { return pow(c, vec3(2.2)); }
float h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
// one hieroglyph-like sign per grid cell (bars, rings, ankh, bird, water, eye)
float glyph(vec2 uv, float k) {
	vec2 c = floor(uv * k);
	vec2 f = fract(uv * k) - 0.5;
	float h = h21(c);
	float m = 0.0;
	if (h < 0.18) m = step(abs(f.x), 0.07) * step(abs(f.y), 0.36);
	else if (h < 0.32) m = step(abs(length(f) - 0.22), 0.06);
	else if (h < 0.46) m = max(step(abs(f.x), 0.06) * step(f.y, 0.1) * step(-0.4, f.y), step(abs(length(f - vec2(0.0, 0.22)) - 0.12), 0.05)) + step(abs(f.y - 0.06), 0.05) * step(abs(f.x), 0.24);
	else if (h < 0.6) m = step(length((f - vec2(0.0, 0.05)) * vec2(1.0, 1.7)), 0.26) + step(abs(f.x + 0.05), 0.04) * step(f.y, -0.1) * step(-0.42, f.y);
	else if (h < 0.72) m = step(abs(f.y - 0.08 * sin(f.x * 26.0)), 0.05) * step(abs(f.x), 0.42);
	else if (h < 0.82) m = step(abs(length(f * vec2(1.0, 2.2)) - 0.26), 0.07) + step(length(f), 0.07);
	return clamp(m, 0.0, 1.0) * step(h, 0.86);
}
// â”€â”€ little silhouettes (metres, feet at y=0) for the Standard of Ur â”€â”€
float sd_box(vec2 p, vec2 c, vec2 hb) { vec2 d = abs(p - c) - hb; return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0); }
float ur_person(vec2 q) {
	float m = step(length(q - vec2(0.0, 0.088)), 0.0105);
	m = max(m, step(sd_box(q, vec2(0.0, 0.066), vec2(0.010, 0.013)), 0.0));
	float t = clamp((q.y - 0.012) / 0.044, 0.0, 1.0);
	m = max(m, step(abs(q.x), mix(0.021, 0.012, t)) * step(0.012, q.y) * step(q.y, 0.056));
	m = max(m, step(sd_box(vec2(abs(q.x), q.y), vec2(0.0065, 0.006), vec2(0.0024, 0.006)), 0.0));
	m = max(m, step(sd_box(q, vec2(0.012, 0.062), vec2(0.004, 0.012)), 0.0));
	return m;
}
float ur_animal(vec2 q) {
	float m = step(length((q - vec2(0.0, 0.046)) / vec2(0.032, 0.017)), 1.0);
	m = max(m, step(length((q - vec2(0.038, 0.064)) / vec2(0.011, 0.008)), 1.0));
	m = max(m, step(sd_box(q, vec2(0.028, 0.056), vec2(0.007, 0.008)), 0.0));
	m = max(m, step(sd_box(q, vec2(-0.024, 0.017), vec2(0.0028, 0.017)), 0.0));
	m = max(m, step(sd_box(q, vec2(-0.015, 0.017), vec2(0.0028, 0.017)), 0.0));
	m = max(m, step(sd_box(q, vec2(0.016, 0.017), vec2(0.0028, 0.017)), 0.0));
	m = max(m, step(sd_box(q, vec2(0.024, 0.017), vec2(0.0028, 0.017)), 0.0));
	m = max(m, step(sd_box(q, vec2(-0.034, 0.042), vec2(0.0025, 0.012)), 0.0));
	return m;
}
void fragment() {
	vec3 p = v_obj * 3.0 + vec3(v_seed, v_seed * 0.7, v_seed * 1.3);
	vec3 w = vec3(noise3D(p * 0.8), noise3D(p * 0.8 + 5.1), noise3D(p * 0.8 + 9.7));
	vec3 vw = normalize((INV_VIEW_MATRIX * vec4(VIEW, 0.0)).xyz);
	vec3 nw = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 alb = vec3(0.5);
	float rough = 0.08;
	float metal = 0.0;
	float spec = 0.6;
	float h = 0.0;
	float sss = 0.0;
	vec3 back = vec3(0.0);
	vec3 emis = vec3(0.0);
	if (kind == 0) {          // MALACHITE: concentric light/dark green bands
		vec3 c = vec3(0.6, 0.2, -0.4);
		float d = length((v_obj - c) * vec3(1.0, 1.6, 1.0)) * 5.0 + fbm(p * 1.2 + w * 1.5, 3) * 3.0;
		float b = 0.5 + 0.5 * sin(d * 3.1);
		float fine = 0.5 + 0.5 * sin(d * 11.0);
		alb = mix(srgb(vec3(0.02, 0.20, 0.12)), srgb(vec3(0.16, 0.62, 0.40)), smoothstep(0.25, 0.75, b));
		alb *= 0.92 + 0.1 * fine;
		rough = 0.06;
	} else if (kind == 1) {   // LAPIS: ultramarine with white calcite and pyrite flecks
		float m = fbm(p * 1.4 + w, 4);
		alb = mix(srgb(vec3(0.03, 0.06, 0.32)), srgb(vec3(0.07, 0.13, 0.48)), smoothstep(-0.3, 0.3, m));
		float cal = smoothstep(0.28, 0.42, fbm(p * 2.2 + w * 2.0 + 3.0, 3));
		alb = mix(alb, srgb(vec3(0.82, 0.84, 0.86)), cal * 0.85);
		float py = step(0.82, noise3D(floor(v_obj * 160.0) + v_seed) * 0.5 + 0.5);
		alb = mix(alb, srgb(vec3(0.85, 0.70, 0.35)), py);
		metal = py;
		rough = mix(0.10, 0.25, py);
	} else if (kind == 2) {   // SELENITE: silky white fibres along local Y, satin sheen
		float fib = noise3D(vec3(v_obj.x * 140.0, v_obj.y * 4.0, v_obj.z * 140.0) + v_seed);
		vec3 ax = normalize((MODEL_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
		float satin = pow(1.0 - abs(dot(normalize(cross(ax, nw)), vw)), 3.0);
		alb = srgb(vec3(0.80, 0.80, 0.78)) * (0.82 + 0.18 * fib);
		emis = vec3(0.05) * satin * (0.6 + 0.4 * fib);
		rough = 0.32;
		sss = 0.5;
		back = vec3(0.5);
	} else if (kind == 3) {   // ROSE QUARTZ: milky translucent pink, cloudy
		float m = fbm(p * 1.1 + w, 3);
		alb = mix(srgb(vec3(0.92, 0.66, 0.70)), srgb(vec3(0.97, 0.80, 0.82)), smoothstep(-0.3, 0.4, m));
		rough = 0.05;
		sss = 0.8;
		back = srgb(vec3(0.9, 0.55, 0.6)) * 0.6;
	} else if (kind == 4) {   // AMAZONITE: blue-green with white perthite streaks
		float m = fbm(p * 1.2 + w, 3);
		alb = mix(srgb(vec3(0.24, 0.62, 0.58)), srgb(vec3(0.42, 0.80, 0.74)), smoothstep(-0.3, 0.3, m));
		float st = smoothstep(0.55, 0.8, noise3D(vec3(v_obj.x * 6.0, v_obj.y * 40.0, v_obj.z * 6.0) + w));
		alb = mix(alb, srgb(vec3(0.86, 0.90, 0.86)), st * 0.7);
		rough = 0.10;
	} else if (kind == 5) {   // AQUAMARINE sphere: pale sea-blue glassy with veils
		float veil = smoothstep(0.35, 0.6, fbm(p * 2.0 + w, 3));
		alb = mix(srgb(vec3(0.45, 0.70, 0.78)), srgb(vec3(0.80, 0.90, 0.92)), veil * 0.6);
		rough = 0.02;
		spec = 0.75;
		sss = 0.6;
		back = srgb(vec3(0.5, 0.8, 0.9)) * 0.6;
	} else if (kind == 6) {   // GREEN ONYX: translucent banded green
		float b = 0.5 + 0.5 * sin(v_obj.y * 40.0 + fbm(p + w, 3) * 4.0);
		alb = mix(srgb(vec3(0.05, 0.42, 0.22)), srgb(vec3(0.20, 0.66, 0.42)), b);
		rough = 0.05;
		sss = 0.5;
		back = srgb(vec3(0.2, 0.7, 0.4)) * 0.5;
	} else if (kind == 7) {   // APATITE: vivid neon blue with pale fracture veins
		float m = fbm(p * 1.3 + w, 3);
		alb = mix(srgb(vec3(0.02, 0.36, 0.66)), srgb(vec3(0.10, 0.58, 0.86)), smoothstep(-0.3, 0.3, m));
		float vein = 1.0 - smoothstep(0.0, 0.03, abs(fbm(p * 1.6 + w * 2.0 + 7.0, 3)));
		alb = mix(alb, srgb(vec3(0.75, 0.85, 0.90)), vein * 0.8);
		rough = 0.06;
		sss = 0.3;
	} else if (kind == 8) {   // TRILOBITE fossil: tan stone, darker in crevices
		float m = fbm(p * 2.0 + w, 4);
		alb = srgb(vec3(0.60, 0.52, 0.40)) * (0.8 + 0.3 * m);
		float rib = 0.5 + 0.5 * sin(v_obj.z * 22.0);
		alb *= mix(0.75, 1.05, rib);
		rough = 0.85;
		spec = 0.3;
		h = noise3D(p * 8.0) * 0.002;
	} else if (kind == 9) {   // LAVA ROCK: porous charcoal basalt
		float pores = smoothstep(0.35, 0.65, noise3D(p * 9.0 + w * 2.0));
		alb = srgb(vec3(0.14, 0.13, 0.13)) * (1.0 - pores * 0.7);
		rough = 0.95;
		spec = 0.2;
		h = -pores * 0.006 + noise3D(p * 20.0) * 0.002;
	} else if (kind == 11) {  // SPIDERWEB TURQUOISE: robin's-egg blue nuggets in a dark matrix web
		vec3 q = v_obj * 2.5 + w * 0.45 + vec3(v_seed);
		vec3 qi = floor(q);
		vec3 qf = fract(q);
		float f1 = 8.0;
		float f2 = 8.0;
		for (int z = -1; z <= 1; z++) for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
			vec3 gq = vec3(float(x), float(y), float(z));
			vec3 o = hash3(qi + gq) * 0.5 + 0.5;
			float dq = length(gq + o - qf);
			if (dq < f1) { f2 = f1; f1 = dq; } else if (dq < f2) { f2 = dq; }
		}
		float edge = f2 - f1;
		// web thickness varies: broad dark rivers and hair-fine veins
		float thick = mix(0.04, 0.34, smoothstep(0.0, 0.7, fbm(p * 0.6 + 3.0, 3) + 0.3));
		float web = 1.0 - smoothstep(thick * 0.6, thick, edge);
		float fine = 1.0 - smoothstep(0.0, 0.02, abs(fbm(p * 3.5 + w * 2.0, 3)));
		web = max(web, fine * 0.85 * smoothstep(0.05, 0.25, fbm(p * 1.3 + 9.0, 2) + 0.2));
		vec3 blue = mix(srgb(vec3(0.10, 0.70, 0.76)), srgb(vec3(0.22, 0.80, 0.84)), smoothstep(-0.3, 0.4, fbm(p * 1.2, 3)));
		blue *= 0.9 + 0.15 * smoothstep(0.0, 0.5, edge);
		vec3 matrix = mix(srgb(vec3(0.035, 0.03, 0.028)), srgb(vec3(0.36, 0.26, 0.12)), smoothstep(0.62, 0.9, noise3D(p * 2.5 + w) * 0.5 + 0.5) * smoothstep(0.1, 0.3, thick));
		alb = mix(blue, matrix, web);
		rough = mix(0.06, 0.22, web);
		spec = 0.55;
		h = -web * 0.0015;
	} else if (kind == 12) {  // MAYA JADEITE: mottled apple-to-deep green, cloudy, polished
		float m = fbm(p * 1.1 + w * 1.4, 4);
		alb = mix(srgb(vec3(0.05, 0.30, 0.18)), srgb(vec3(0.30, 0.62, 0.42)), smoothstep(-0.35, 0.35, m));
		float cloud = smoothstep(0.2, 0.55, fbm(p * 2.4 + 5.0, 3));
		alb = mix(alb, srgb(vec3(0.62, 0.78, 0.66)), cloud * 0.45);
		rough = 0.12;
		sss = 0.5;
		back = srgb(vec3(0.2, 0.6, 0.35)) * 0.4;
	} else if (kind == 13) {  // OBSIDIAN: glassy black with faint sheen bands
		float band = 0.5 + 0.5 * sin(v_obj.y * 30.0 + fbm(p, 3) * 3.0);
		alb = srgb(vec3(0.02, 0.02, 0.025)) + vec3(0.006) * band;
		rough = 0.03;
		spec = 0.65;
	} else if (kind == 14) {  // EGYPTIAN FAIENCE: glossy blue-green glaze, black painted text bands
		float pool = fbm(p * 1.6 + w, 3);
		alb = mix(srgb(vec3(0.06, 0.48, 0.58)), srgb(vec3(0.18, 0.66, 0.70)), smoothstep(-0.3, 0.4, pool));
		vec3 gcell = floor(v_obj * vec3(22.0, 14.0, 22.0));
		float glyph = step(0.55, fract(sin(dot(gcell, vec3(12.9898, 78.233, 37.719))) * 43758.5453));
		float bandy = step(0.15, fract(v_obj.y * 3.5)) * step(fract(v_obj.y * 3.5), 0.75);
		float ink = glyph * bandy * step(-0.55, v_obj.y) * step(v_obj.y, 0.35);
		alb = mix(alb, srgb(vec3(0.04, 0.04, 0.05)), ink * 0.9);
		rough = mix(0.12, 0.35, ink);
	} else if (kind == 15) {  // CARNELIAN: translucent orange-red chalcedony
		float m = fbm(p * 1.3 + w, 3);
		alb = mix(srgb(vec3(0.72, 0.16, 0.04)), srgb(vec3(0.92, 0.40, 0.14)), smoothstep(-0.3, 0.4, m));
		rough = 0.06;
		sss = 0.7;
		back = srgb(vec3(0.9, 0.3, 0.1)) * 0.5;
	} else if (kind == 16) {  // JADE MOSAIC: fitted jade tesserae with dark grout
		vec3 q = v_obj * 7.0;
		vec3 qi = floor(q);
		vec3 qf = fract(q);
		float f1 = 8.0;
		float f2 = 8.0;
		vec3 best = vec3(0.0);
		for (int z = -1; z <= 1; z++) for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
			vec3 gq = vec3(float(x), float(y), float(z));
			vec3 o = hash3(qi + gq) * 0.5 + 0.5;
			float dq = length(gq + o - qf);
			if (dq < f1) { f2 = f1; f1 = dq; best = qi + gq; } else if (dq < f2) { f2 = dq; }
		}
		float grout = 1.0 - smoothstep(0.03, 0.07, f2 - f1);
		float tshade = hash3(best).x * 0.5 + 0.5;
		vec3 tile = mix(srgb(vec3(0.06, 0.32, 0.20)), srgb(vec3(0.26, 0.58, 0.40)), tshade);
		alb = mix(tile, srgb(vec3(0.10, 0.08, 0.06)), grout);
		rough = mix(0.14, 0.8, grout);
		h = -grout * 0.0015;
	} else if (kind == 17) {  // SHELL: white with a faint pearly sheen
		float m = fbm(p * 2.0, 3);
		alb = srgb(vec3(0.90, 0.88, 0.84)) * (0.92 + 0.08 * m);
		rough = 0.28;
	} else if (kind == 18) {  // RAW LAPIS: dusty grey-blue matrix, dense blue speckle, brassy pyrite, pale calcite
		float m = fbm(p * 0.9 + w * 1.5, 4);
		vec3 matrix = mix(srgb(vec3(0.30, 0.31, 0.36)), srgb(vec3(0.44, 0.45, 0.48)), noise3D(p * 6.0) * 0.5 + 0.5);
		float rich = smoothstep(-0.25, 0.2, -m);                       // zones where lazurite dominates
		float speck = smoothstep(0.42, 0.62, noise3D(p * 16.0 + w * 3.0) * 0.5 + 0.5 + rich * 0.3);
		alb = mix(matrix, srgb(vec3(0.12, 0.16, 0.50)), clamp(speck * (0.2 + 0.7 * rich), 0.0, 1.0));
		float calc = smoothstep(0.3, 0.5, fbm(p * 2.2 + 7.0, 3));
		alb = mix(alb, srgb(vec3(0.74, 0.73, 0.68)), calc * 0.6);
		float py = smoothstep(0.32, 0.5, fbm(p * 1.6 + w * 2.0 + 11.0, 3)) * (1.0 - rich);
		alb = mix(alb, srgb(vec3(0.58, 0.48, 0.26)), py * 0.85);
		metal = py * 0.7;
		rough = mix(0.7, 0.42, py);
		spec = 0.4;
		h = noise3D(p * 30.0) * 0.0015;
	} else if (kind == 19) {  // TURQUOISE INLAY: smooth sky blue-green, slightly mottled
		float m = fbm(p * 2.0 + w, 3);
		alb = mix(srgb(vec3(0.14, 0.58, 0.68)), srgb(vec3(0.30, 0.74, 0.80)), smoothstep(-0.3, 0.4, m));
		rough = 0.25;
	} else if (kind == 20) {  // NEMES: horizontal gold and blue-glass (lapis) stripes in world space
		vec3 wp = (MODEL_MATRIX * vec4(v_obj, 1.0)).xyz;
		float st = fract(wp.y * 40.0);
		float gold = step(0.5, st);
		float edge = smoothstep(0.0, 0.06, st) * smoothstep(1.0, 0.94, st) * smoothstep(0.44, 0.5, abs(st - 0.5) + 0.44);
		vec3 blue = mix(srgb(vec3(0.05, 0.08, 0.40)), srgb(vec3(0.10, 0.16, 0.55)), noise3D(p * 4.0) * 0.5 + 0.5);
		alb = mix(blue, srgb(vec3(1.0, 0.78, 0.36)), gold);
		metal = gold;
		rough = mix(0.12, 0.16, gold);
	} else if (kind == 21) {  // BROAD COLLAR: concentric rows of lapis, turquoise, carnelian, gold cells
		float r = length(v_obj.xz);
		float row = floor(r * 36.0);
		float ang = atan(v_obj.z, v_obj.x);
		float cell = fract(ang * (8.0 + row * 1.6));
		float rf = fract(r * 36.0);
		int k = int(mod(row, 5.0));
		vec3 c = srgb(vec3(0.07, 0.11, 0.48));
		if (k == 1) c = srgb(vec3(0.16, 0.56, 0.62));
		if (k == 2) c = srgb(vec3(0.62, 0.12, 0.06));
		if (k == 3) c = srgb(vec3(0.07, 0.11, 0.48));
		float goldline = max(step(0.86, rf), step(0.9, cell));
		if (k == 4) goldline = 1.0;
		alb = mix(c, srgb(vec3(1.0, 0.78, 0.36)), goldline);
		metal = goldline;
		rough = mix(0.14, 0.18, goldline);
	} else if (kind == 22) {  // LAPIS CLOTH with gold hieroglyphs (pouch)
		float weave = 0.5 + 0.5 * sin(v_obj.x * 900.0) * sin(v_obj.y * 900.0);
		vec3 blue = mix(srgb(vec3(0.10, 0.16, 0.66)), srgb(vec3(0.16, 0.24, 0.80)), fbm(p * 2.0 + w, 3) * 0.5 + 0.5) * (0.9 + 0.1 * weave);
		float gm = max(glyph(v_obj.xy, 32.0), glyph(v_obj.xy + vec2(0.37, 0.11), 13.0) * 0.0);
		float big = glyph(v_obj.xy * 0.45 + vec2(3.1, 7.7), 9.0);
		float wear = smoothstep(0.2, 0.6, noise3D(p * 9.0) * 0.5 + 0.5);
		alb = mix(blue, srgb(vec3(0.86, 0.66, 0.30)) * (0.75 + 0.25 * wear), gm);
		metal = gm * 0.8;
		rough = mix(0.9, 0.35, gm);
		spec = 0.3;
	} else if (kind == 23) {  // EYE-OF-HORUS BANGLE: lapis panels, gold bars, checker borders
		float a = atan(v_obj.z, v_obj.x) / 6.2832 + 0.5;
		float y = v_obj.y;
		vec3 lap = mix(srgb(vec3(0.06, 0.12, 0.50)), srgb(vec3(0.14, 0.24, 0.70)), fbm(p * 3.0 + w, 3) * 0.5 + 0.5);
		lap = mix(lap, srgb(vec3(0.80, 0.82, 0.86)), smoothstep(0.35, 0.55, fbm(p * 2.5 + 9.0, 3)) * 0.5);
		vec3 gold = srgb(vec3(1.0, 0.78, 0.36));
		vec3 carn = srgb(vec3(0.62, 0.14, 0.08));
		float border = step(0.026, abs(y));
		vec2 ck = floor(vec2(a * 160.0, y * 260.0));
		float chk = mod(ck.x + ck.y, 3.0);
		vec3 bc = chk < 1.0 ? gold : (chk < 2.0 ? carn : srgb(vec3(0.85, 0.85, 0.82)));
		float bars = step(fract(a * 12.0), 0.08);
		float panel = mod(floor(a * 12.0), 2.0);
		float stripes = panel * step(0.5, fract(y * 90.0)) * (1.0 - border);
		float eye = (1.0 - panel) * (1.0 - border) * step(abs(length(vec2((fract(a * 12.0) - 0.54) * 0.6, y * 2.4)) - 0.04), 0.012);
		vec3 c = lap;
		c = mix(c, gold, max(max(bars, stripes), eye));
		c = mix(c, bc, border);
		alb = c;
		metal = max(max(bars, stripes), eye) * (1.0 - border) + border * step(chk, 0.9);
		rough = mix(0.14, 0.2, metal);
	} else if (kind == 24) {  // GOLD with lapis-filled engraved glyphs
		float gm = max(glyph(v_obj.xy, 26.0), glyph(v_obj.zy, 26.0)) * 0.9;
		alb = mix(srgb(vec3(1.0, 0.78, 0.36)), srgb(vec3(0.08, 0.14, 0.55)), gm);
		metal = (1.0 - gm) * 0.8;
		rough = mix(0.42, 0.5, gm);
		h = -gm * 0.0006;
	} else if (kind == 25) {  // ERMINE: white winter stoat fur with black tail tips
		float a = atan(v_obj.z, v_obj.x);
		vec2 c = vec2(a * 3.2, v_obj.y * 26.0);
		vec2 ci = floor(c);
		c.x += mod(ci.y, 2.0) * 0.5;
		ci = floor(c);
		vec2 f = fract(c) - 0.5;
		float tuft = smoothstep(0.24, 0.14, length(vec2(f.x * 2.6, (f.y + 0.05) * 1.1))) * step(h21(ci + 7.0), 0.75);
		float strands = noise3D(v_obj * vec3(260.0, 90.0, 260.0)) * 0.5 + 0.5;
		alb = mix(srgb(vec3(0.78, 0.76, 0.72)), srgb(vec3(0.62, 0.60, 0.56)), strands * 0.5);
		alb = mix(alb, srgb(vec3(0.03, 0.025, 0.02)), tuft);
		rough = 0.95;
		spec = 0.25;
		h = strands * 0.0012;
	} else if (kind == 26) {  // RAINBOW OBSIDIAN: black glass with concentric thin-film rainbow bands
		vec3 c0 = vec3(-0.15, 0.2, 0.7);
		float d = length((v_obj - c0) * vec3(1.0, 1.25, 0.55)) * 5.0 + fbm(p * 0.35 + w * 0.6, 3) * 0.9;
		float band = fract(d);
		vec3 rb = 0.5 + 0.5 * cos(6.2832 * (d * 0.29 + vec3(0.0, 0.33, 0.67)));
		float sheen = smoothstep(0.0, 0.35, band) * smoothstep(1.0, 0.55, band);
		float sh2 = smoothstep(0.3, 0.5, band) * smoothstep(0.75, 0.55, band);
		alb = srgb(vec3(0.012, 0.011, 0.016)) + srgb(rb) * 0.12 * sh2 * (0.5 + 0.5 * dot(nw, vw));
		rough = 0.04;
		spec = 0.6;
	} else if (kind == 27) {  // LAPIS with golden calcite patches and pyrite (carved vases)
		float m = fbm(p * 1.1 + w, 4);
		alb = mix(srgb(vec3(0.025, 0.05, 0.26)), srgb(vec3(0.07, 0.12, 0.44)), smoothstep(-0.3, 0.3, m));
		float vein = abs(fbm(p * 1.6 + w * 2.2 + 11.0, 4));
		float cal = smoothstep(0.34, 0.5, fbm(p * 0.9 + w * 1.8 + 3.0, 4)) + (1.0 - smoothstep(0.0, 0.015, vein)) * 0.3;
		alb = mix(alb, srgb(vec3(0.66, 0.56, 0.38)), clamp(cal, 0.0, 1.0) * 0.8);
		float py = step(0.84, noise3D(floor(v_obj * 260.0)) * 0.5 + 0.5);
		alb = mix(alb, srgb(vec3(0.9, 0.74, 0.36)), py);
		metal = py;
		rough = mix(0.10, 0.25, py);
	} else if (kind == 28) {  // STANDARD OF UR: lapis tesserae, shell figures, red limestone, bitumen
		vec2 u = v_obj.xy;
		float H = 0.435;
		float y = u.y + H * 0.5;
		float bw = 0.024;
		float regH = (H - 4.0 * bw) / 3.0;
		float yy = y - bw;
		float reg = clamp(floor(yy / (regH + bw)), 0.0, 2.0);
		float ly = yy - reg * (regH + bw);
		bool border = (y < bw) || (y > H - bw) || (ly > regH);
		vec2 tq = u * 75.0;
		vec2 ti = floor(tq);
		vec2 tf = fract(tq);
		float f1 = 8.0;
		float f2 = 8.0;
		vec2 best = ti;
		for (int yo = -1; yo <= 1; yo++) for (int xo = -1; xo <= 1; xo++) {
			vec2 g = vec2(float(xo), float(yo));
			vec2 o = vec2(h21(ti + g), h21(ti + g + 17.0)) * 0.8 + 0.1;
			float dq = length(g + o - tf);
			if (dq < f1) { f2 = f1; f1 = dq; best = ti + g; } else if (dq < f2) { f2 = dq; }
		}
		vec3 lap = mix(srgb(vec3(0.03, 0.06, 0.34)), srgb(vec3(0.09, 0.16, 0.56)), h21(best));
		lap = mix(lap, srgb(vec3(0.70, 0.74, 0.82)), step(0.94, h21(best + 3.1)) * 0.6);
		float grout = 1.0 - smoothstep(0.05, 0.12, f2 - f1);
		vec3 bit = srgb(vec3(0.06, 0.045, 0.03));
		vec3 shellc = srgb(vec3(0.86, 0.79, 0.64)) * (0.9 + 0.1 * h21(floor(u * 160.0)));
		vec3 redc = srgb(vec3(0.55, 0.16, 0.09));
		vec3 col = mix(lap, bit, grout);
		float sh = 0.0;
		if (border) {
			float by = (y < bw) ? y : ((y > H - bw) ? y - (H - bw) : ly - regH);
			float edge = clamp(step(by, 0.0045) + step(bw - 0.0045, by), 0.0, 1.0);
			float dx = fract(u.x / (bw * 0.75)) - 0.5;
			float dy = (by - 0.0045) / (bw - 0.009) - 0.5;
			float dia = step(abs(dx) + abs(dy), 0.45);
			vec3 dc = mod(floor(u.x / (bw * 0.75)), 2.0) < 1.0 ? redc : shellc;
			col = mix(col, dc, dia * (1.0 - edge));
			col = mix(col, shellc, edge);
			sh = edge;
		} else {
			float fw = (reg < 0.5) ? 0.17 : 0.085;
			float cx = floor(u.x / fw);
			vec2 q = vec2((fract(u.x / fw) - 0.5) * fw, ly - 0.004);
			float hh = h21(vec2(cx, reg));
			float fig = 0.0;
			float red = 0.0;
			if (reg < 0.5) {
				fig = ur_animal(q - vec2(0.035, 0.0));
				vec2 cq = q - vec2(-0.045, 0.0);
				float wheel = step(length(cq - vec2(0.0, 0.024)), 0.022);
				float hub = step(length(cq - vec2(0.0, 0.024)), 0.006);
				float body = step(sd_box(cq, vec2(0.004, 0.062), vec2(0.022, 0.022)), 0.0);
				red = max(body * (1.0 - step(abs(fract((cq.x + cq.y) * 90.0) - 0.5), 0.12)), hub);
				fig = max(fig, max(wheel, body));
				fig = max(fig, ur_person((q - vec2(-0.05, 0.05)) * 1.25));
			} else if (reg < 1.5) {
				fig = (hh < 0.5) ? ur_person(q * vec2(1.0, 0.95)) : ur_animal(q * 1.05);
				red = (hh < 0.5) ? step(abs(q.y - 0.07), 0.003) * fig : 0.0;
			} else {
				fig = ur_person(q * vec2(1.0, 0.9));
				red = step(sd_box(q, vec2(0.0, 0.03), vec2(0.02, 0.003)), 0.0) * fig;
			}
			float fringe = step(0.5, fract(q.y * 260.0)) * step(0.012, q.y) * step(q.y, 0.05) * 0.35;
			col = mix(col, shellc * (1.0 - fringe), fig);
			col = mix(col, redc, red);
			sh = fig;
		}
		alb = col;
		rough = mix(0.35, 0.5, sh);
		spec = 0.4;
		h = -grout * 0.0008 * (1.0 - sh);
	} else if (kind == 29) {  // BYZANTINE ENAMEL PLAQUE: gold field, cloisonne king, red inscription
		vec2 u = v_obj.xy;
		float head = step(length(u - vec2(0.0, 0.118)), 0.014);
		float halo = step(abs(length(u - vec2(0.0, 0.12)) - 0.021), 0.004);
		float t = clamp((0.104 - u.y) / 0.08, 0.0, 1.0);
		float robe = step(abs(u.x), mix(0.016, 0.034, t)) * step(0.024, u.y) * step(u.y, 0.104);
		float scroll = step(sd_box(u, vec2(0.0, 0.072), vec2(0.036, 0.005)), 0.0);
		float folds = step(0.6, fract(u.x * 90.0 + u.y * 20.0));
		float letters = step(sd_box(u, vec2(0.0, 0.158), vec2(0.045, 0.009)), 0.0) * step(0.45, h21(floor(u * vec2(170.0, 60.0))));
		vec3 c = srgb(vec3(1.0, 0.78, 0.40));
		c = mix(c, mix(srgb(vec3(0.05, 0.40, 0.25)), srgb(vec3(0.06, 0.18, 0.50)), folds), robe);
		c = mix(c, srgb(vec3(0.92, 0.88, 0.80)), scroll);
		c = mix(c, srgb(vec3(0.90, 0.70, 0.58)), head);
		c = mix(c, srgb(vec3(0.60, 0.05, 0.05)), max(halo, letters));
		float enam = max(max(robe, scroll), max(max(head, halo), letters));
		alb = c;
		metal = 1.0 - enam;
		rough = mix(0.18, 0.08, enam);
	} else if (kind == 30) {  // FILIGREE GOLD: granulation beads and twisted-wire scrolls
		vec3 q = v_obj * 240.0;
		vec3 f = fract(q) - 0.5;
		float bead = smoothstep(0.42, 0.0, length(f));
		float wire = 1.0 - smoothstep(0.0, 0.18, abs(sin(v_obj.x * 120.0 + sin(v_obj.y * 140.0) * 2.0 + v_obj.z * 90.0)));
		float relief = max(bead * 0.7, wire);
		alb = srgb(vec3(1.0, 0.77, 0.36)) * mix(0.55, 1.0, relief);
		metal = 1.0;
		rough = mix(0.38, 0.2, relief);
		h = relief * 0.0005;
	} else if (kind == 31) {  // DENDERA RELIEF: painted blue sandstone, Eye of Horus moon disc, glyph columns
		vec2 u = v_obj.xy;
		vec3 stone = srgb(vec3(0.78, 0.70, 0.58)) * (0.85 + 0.15 * fbm(p * 2.0, 3));
		vec3 blue = srgb(vec3(0.10, 0.58, 0.86)) * (0.9 + 0.1 * fbm(p * 3.0, 3));
		vec3 dark = srgb(vec3(0.06, 0.16, 0.48));
		vec2 dc = u - vec2(-0.08, 0.12);
		float disc = step(length(dc), 0.27);
		float crescent = step(length(dc - vec2(0.0, -0.02)), 0.31) * (1.0 - step(length(dc - vec2(0.0, 0.02)), 0.29)) * step(dc.y, -0.05);
		float stand = step(abs(u.x + 0.08), 0.035 + 0.02 * step(u.y, -0.45)) * step(-0.5, u.y) * step(u.y, -0.16);
		vec2 e = (dc - vec2(0.03, 0.06)) / vec2(0.17, 0.06);
		float eye = step(length(e), 1.0);
		float pupil = step(length(dc - vec2(0.05, 0.06)), 0.045);
		float brow = step(abs(dc.y - 0.15 + 0.15 * dc.x * dc.x * 4.0), 0.022) * step(abs(dc.x), 0.2);
		float tear = step(abs(dc.x - 0.04), 0.012) * step(-0.15, dc.y) * step(dc.y, 0.0);
		float spiral = step(abs(length(dc - vec2(-0.16, -0.14)) - 0.02), 0.005);
		float lines = max(brow, step(abs(length(e) - 1.0), 0.08));
		float gl = glyph(u * 1.0 + vec2(5.0), 14.0) * step(0.3, abs(u.x - 0.25)) * step(u.y, -0.2) * (1.0 - stand);
		float figure = step(length((u - vec2(0.3, 0.0)) / vec2(0.05, 0.2)), 1.0);
		vec3 c = blue;
		c = mix(c, stone, max(max(disc, crescent), max(stand, figure)));
		c = mix(c, blue, eye * (1.0 - pupil) * step(0.0, dc.y - 0.0) * 0.0);
		c = mix(c, srgb(vec3(0.9, 0.86, 0.78)), eye);
		c = mix(c, dark, max(lines, max(tear, spiral)));
		c = mix(c, srgb(vec3(0.03, 0.03, 0.03)), pupil);
		c = mix(c, mix(stone, dark, step(0.5, h21(floor(u * 60.0)))), gl);
		float flake = step(0.72, fbm(p * 5.0 + 3.0, 3) * 0.5 + 0.5) * (1.0 - disc);
		c = mix(c, stone, flake);
		alb = c;
		rough = 0.85;
		spec = 0.25;
		h = (max(disc, max(stand, figure)) - max(lines, gl) * 0.5) * 0.004;
	} else if (kind == 32) {  // TURQUOISE MOSAIC (Moche): irregular turquoise tiles in gold-brown grout
		vec3 q = v_obj * 60.0;
		vec3 qi = floor(q);
		vec3 qf = fract(q);
		float f1 = 8.0;
		float f2 = 8.0;
		vec3 best = qi;
		for (int z = -1; z <= 1; z++) for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
			vec3 g = vec3(float(x), float(y), float(z));
			vec3 o = hash3(qi + g) * 0.4 + 0.5;
			float dq = length(g + o - qf);
			if (dq < f1) { f2 = f1; f1 = dq; best = qi + g; } else if (dq < f2) { f2 = dq; }
		}
		float tshade = hash3(best).x * 0.5 + 0.5;
		vec3 tile = mix(srgb(vec3(0.20, 0.55, 0.52)), srgb(vec3(0.45, 0.78, 0.72)), tshade);
		float grout = 1.0 - smoothstep(0.04, 0.1, f2 - f1);
		alb = mix(tile, srgb(vec3(0.55, 0.42, 0.20)), grout);
		metal = grout * 0.6;
		rough = mix(0.35, 0.4, grout);
		h = -grout * 0.0006;
	} else if (kind == 33) {  // ROMAN SILVER COIN: tarnished silver, worn relief, verdigris patches
		float r = length(v_obj.xz);
		float face = smoothstep(0.03, 0.06, v_obj.y);
		float bust = step(length((v_obj.xz - vec2(0.05, 0.05)) / vec2(0.42, 0.5)), 1.0);
		float rim = step(0.78, r) * step(r, 0.9);
		float legend = rim * step(0.5, h21(floor(vec2(atan(v_obj.z, v_obj.x) * 18.0, r * 8.0) + v_seed)));
		float relief = max(bust * (0.6 + 0.4 * fbm(p * 4.0 + v_seed, 3)), legend) * face;
		float verd = smoothstep(0.1, 0.45, fbm(p * 1.8 + vec3(v_seed * 3.0), 4)) * (1.0 - relief * 0.6);
		alb = mix(srgb(vec3(0.62, 0.62, 0.62)), srgb(vec3(0.22, 0.48, 0.42)), verd);
		alb *= 0.8 + 0.2 * relief;
		metal = 1.0 - verd;
		rough = mix(0.34, 0.8, verd);
		h = relief * 0.002;
	} else if (kind == 34) {  // NEPHRITE: spinach-green jade with black chromite specks
		float m = fbm(p * 1.4 + w, 4);
		alb = mix(srgb(vec3(0.05, 0.17, 0.05)), srgb(vec3(0.13, 0.28, 0.09)), smoothstep(-0.4, 0.4, m));
		float sp = step(0.86, noise3D(floor(v_obj * 70.0) + 3.0) * 0.5 + 0.5);
		alb = mix(alb, srgb(vec3(0.02, 0.03, 0.02)), sp);
		rough = 0.12;
		sss = 0.15;
		back = srgb(vec3(0.1, 0.3, 0.08)) * 0.2;
	} else {                  // BISMUTH: iridescent oxide film over silver metal
		float t = dot(nw, vw) * 1.6 + fbm(p * 1.5, 3) * 0.9 + v_obj.y * 4.0;
		vec3 film = 0.5 + 0.5 * cos(6.2832 * (t + vec3(0.0, 0.33, 0.67)));
		alb = mix(srgb(vec3(0.8, 0.8, 0.82)), film, 0.85);
		metal = 1.0;
		rough = 0.18;
	}
	ALBEDO = clamp(alb, 0.0, 1.0);
	ROUGHNESS = rough;
	METALLIC = metal;
	SPECULAR = spec;
	SSS_STRENGTH = sss;
	BACKLIGHT = back;
	EMISSION = emis;
	if (h != 0.0) {
		NORMAL = bump_h(NORMAL, VERTEX, h, 1.0);
	}
}
"""
