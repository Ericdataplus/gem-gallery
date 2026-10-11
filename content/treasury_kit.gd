class_name TreasuryKit

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# TREASURY KIT — shared jeweller's toolkit for the Royal Treasury and the
# Collector's Wing: materials (velvets, pearl, platinum, rose gold, carved rock
# crystal, galaxy glitter), stone registration, gem/collet/pave placement,
# parametric surfaces and the hall layout (plinths, spots, plaques).
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

static var _m := {}

static func mats() -> Dictionary:
	if not _m.is_empty():
		return _m
	var vel := func(c: Color, rim: float) -> StandardMaterial3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		m.roughness = 1.0
		m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		m.rim_enabled = true
		m.rim = rim
		m.rim_tint = 0.6
		return m
	var metal := func(c: Color, r: float) -> StandardMaterial3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		m.metallic = 1.0
		m.roughness = r
		return m
	var plain := func(c: Color, r: float) -> StandardMaterial3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		m.roughness = r
		return m
	var pearl := StandardMaterial3D.new()
	pearl.albedo_color = Color(0.74, 0.72, 0.68)
	pearl.roughness = 0.22
	pearl.clearcoat_enabled = true
	pearl.clearcoat = 1.0
	pearl.clearcoat_roughness = 0.08
	pearl.rim_enabled = true
	pearl.rim = 0.35
	pearl.rim_tint = 0.7
	var grey_pearl := pearl.duplicate() as StandardMaterial3D
	grey_pearl.albedo_color = Color(0.62, 0.62, 0.64)
	_m = {
		"purple": vel.call(Color(0.10, 0.015, 0.16), 0.45),
		"green_velvet": vel.call(Color(0.02, 0.10, 0.06), 0.5),
		"red_velvet": vel.call(Color(0.16, 0.01, 0.015), 0.4),
		"red_felt": vel.call(Color(0.30, 0.015, 0.02), 0.3),
		"black_velvet": vel.call(Color(0.01, 0.01, 0.012), 0.3),
		"pink_velvet": vel.call(Color(0.40, 0.32, 0.34), 0.3),
		"grey_velvet": vel.call(Color(0.55, 0.55, 0.56), 0.35),
		"aubergine": vel.call(Color(0.16, 0.12, 0.15), 0.4),
		"pearl": pearl,
		"grey_pearl": grey_pearl,
		"gold": AncientTreasures.gold(),
		"platinum": metal.call(Color(0.84, 0.84, 0.86), 0.14),
		"dark_plat": metal.call(Color(0.42, 0.42, 0.45), 0.25),
		"rose_gold": metal.call(Color(0.96, 0.66, 0.54), 0.2),
		"brass": metal.call(Color(0.86, 0.66, 0.30), 0.3),
		"steel": metal.call(Color(0.75, 0.76, 0.78), 0.2),
		"cream": plain.call(Color(0.55, 0.52, 0.47), 0.9),
		"white_foam": plain.call(Color(0.55, 0.55, 0.57), 1.0),
		"black_plastic": plain.call(Color(0.02, 0.02, 0.025), 0.25),
		"bust_white": plain.call(Color(0.52, 0.50, 0.47), 0.95),
		"mahogany": plain.call(Color(0.24, 0.06, 0.04), 0.35),
		"dark_wood": plain.call(Color(0.20, 0.12, 0.07), 0.5),
		"navy_cloth": plain.call(Color(0.02, 0.03, 0.12), 1.0),
		"white_cloth": plain.call(Color(0.86, 0.86, 0.84), 1.0),
		"cream_cream": plain.call(Color(0.85, 0.78, 0.62), 0.35),
	}
	return _m

# ── carved rock crystal / amethyst: screen-refracted glass with frosted engraving
const CRYSTAL_SHADER := """
shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;
uniform vec3 tint : source_color = vec3(1.0);
uniform float engrave = 1.0;
uniform float cloud = 0.0;
uniform float scale = 30.0;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
varying vec3 v_obj;
void vertex() { v_obj = VERTEX; }
float hs(vec3 p) { return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453); }
float vn(vec3 p) {
	vec3 i = floor(p); vec3 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hs(i), hs(i + vec3(1, 0, 0)), f.x), mix(hs(i + vec3(0, 1, 0)), hs(i + vec3(1, 1, 0)), f.x), f.y),
		mix(mix(hs(i + vec3(0, 0, 1)), hs(i + vec3(1, 0, 1)), f.x), mix(hs(i + vec3(0, 1, 1)), hs(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}
void fragment() {
	float ndv = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float fres = 0.04 + 0.96 * pow(1.0 - ndv, 5.0);
	vec3 q = v_obj * scale;
	float warp = vn(q * 0.35) * 6.0;
	float s1 = abs(sin(q.x * 0.9 + warp) * cos(q.y * 0.7 - warp * 0.6) + 0.3 * sin(q.z * 1.3 + warp));
	float line = (1.0 - smoothstep(0.03, 0.12, s1)) * engrave;
	float veil = smoothstep(0.45, 0.8, vn(q * 0.18 + 3.0)) * cloud;
	vec2 off = NORMAL.xy * (0.05 * (1.0 - ndv) + 0.015);
	vec3 bg;
	bg.r = textureLod(screen_tex, SCREEN_UV - off * 1.06, 0.0).r;
	bg.g = textureLod(screen_tex, SCREEN_UV - off, 0.0).g;
	bg.b = textureLod(screen_tex, SCREEN_UV - off * 0.94, 0.0).b;
	float frost = max(line * 0.4, veil);
	EMISSION = bg * tint * (1.0 - fres) * (1.0 - frost) * (1.0 - cloud * 0.6);
	ALBEDO = tint * (frost * 0.5 + cloud * 0.35);
	ROUGHNESS = mix(0.03, 0.45, frost);
	SPECULAR = 0.75;
	ALPHA = 1.0;
}
"""

static var _crys := {}

static func crystal(tint: Color, engrave := 1.0, cloud := 0.0, scl := 30.0) -> ShaderMaterial:
	var key := "%s|%.2f|%.2f|%.1f" % [tint.to_html(), engrave, cloud, scl]
	if _crys.has(key):
		return _crys[key]
	var sh: Shader = _crys.get("__shader")
	if sh == null:
		sh = Shader.new()
		sh.code = CRYSTAL_SHADER
		_crys["__shader"] = sh
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("tint", Vector3(tint.r, tint.g, tint.b))
	m.set_shader_parameter("engrave", engrave)
	m.set_shader_parameter("cloud", cloud)
	m.set_shader_parameter("scale", scl)
	_crys[key] = m
	return m

# ── galaxy quartz: dark quartz full of glittering metallic flakes (marched in object space)
const GALAXY_SHADER := """
shader_type spatial;
render_mode blend_mix, cull_back, specular_schlick_ggx;
uniform vec3 body : source_color = vec3(0.05, 0.03, 0.07);
uniform float density = 0.35;
varying vec3 v_obj;
void vertex() { v_obj = VERTEX; }
vec3 h33(vec3 p) {
	return fract(sin(vec3(dot(p, vec3(127.1, 311.7, 74.7)), dot(p, vec3(269.5, 183.3, 246.1)), dot(p, vec3(113.5, 271.9, 124.6)))) * 43758.5453);
}
void fragment() {
	mat4 inv = inverse(MODEL_MATRIX);
	vec3 cam = (inv * vec4(INV_VIEW_MATRIX[3].xyz, 1.0)).xyz;
	vec3 vd = normalize(v_obj - cam);
	vec3 nw = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 no = normalize((inv * vec4(nw, 0.0)).xyz);
	vec3 rd = refract(vd, no, 1.0 / 1.54);
	if (dot(rd, rd) < 0.01) rd = vd;
	vec3 acc = vec3(0.0);
	float trans = 1.0;
	vec3 pos = v_obj;
	vec3 hv = normalize(-rd + vec3(0.35, 0.8, 0.45));
	for (int i = 0; i < 30; i++) {
		pos += rd * 0.03;
		if (pos.y > 0.34 || pos.y < -0.7 || abs(pos.x) > 1.02 || abs(pos.z) > 0.75) break;
		vec3 c = floor(pos * 13.0);
		vec3 hh = h33(c);
		if (hh.x < density) {
			vec3 fc = (c + 0.2 + 0.6 * h33(c + 7.0)) / 13.0;
			vec3 fn = normalize(h33(c + 3.0) - 0.5);
			vec3 d = pos - fc;
			float pd = abs(dot(d, fn));
			float rr = length(d - fn * dot(d, fn));
			float rad = 0.02 + 0.03 * hh.y;
			if (pd < 0.016 && rr < rad) {
				float glint = pow(abs(dot(fn, hv)), 8.0);
				float k = hh.z * 6.0;
				vec3 col = k < 1.0 ? vec3(1.0, 0.35, 0.65) : (k < 2.0 ? vec3(0.75, 0.25, 1.0) : (k < 3.0 ? vec3(0.25, 0.55, 1.0) :
					(k < 4.0 ? vec3(0.2, 0.9, 0.8) : (k < 5.0 ? vec3(1.0, 0.75, 0.3) : vec3(1.0, 0.45, 0.25)))));
				acc += trans * col * (0.12 + 2.6 * glint);
				trans *= 0.6;
			}
		}
	}
	ALBEDO = body * 0.25;
	EMISSION = acc * 0.9 + body * 0.15 * trans;
	ROUGHNESS = 0.03;
	SPECULAR = 0.55;
}
"""

static var _gal := {}

static func galaxy(body := Color(0.05, 0.03, 0.07), density := 0.35) -> ShaderMaterial:
	var key := "%s%.2f" % [body.to_html(), density]
	if _gal.has(key):
		return _gal[key]
	var sh: Shader = _gal.get("__shader")
	if sh == null:
		sh = Shader.new()
		sh.code = GALAXY_SHADER
		_gal["__shader"] = sh
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("body", Vector3(body.r, body.g, body.b))
	m.set_shader_parameter("density", density)
	_gal[key] = m
	return m

# ── stones used by the treasury pieces ───────────────────────────────────────
static var _registered := false

static func register() -> void:
	if _registered:
		return
	_registered = true
	FamousGems.register()
	var o := {
		"london_topaz": [Color(0.10, 0.36, 0.80), 1.62, 0.014, 1.0],
		"rubellite": [Color(1.0, 0.12, 0.42), 1.63, 0.017, 0.95],
		"mandarin": [Color(1.0, 0.45, 0.05), 1.80, 0.027, 0.9],
		"prasiolite": [Color(0.80, 0.95, 0.78), 1.544, 0.013, 0.35],
		"mint_tourm": [Color(0.55, 0.98, 0.75), 1.63, 0.017, 0.45],
		"teal_tourm": [Color(0.05, 0.62, 0.62), 1.63, 0.017, 1.2],
		"grey_spinel": [Color(0.55, 0.58, 0.70), 1.718, 0.020, 1.2],
		"olive_tourm": [Color(0.55, 0.62, 0.12), 1.63, 0.017, 1.0],
		"heliodor": [Color(1.0, 0.86, 0.20), 1.58, 0.014, 0.6],
		"pale_heliodor": [Color(1.0, 0.97, 0.75), 1.58, 0.014, 0.3],
		"demantoid": [Color(0.45, 0.95, 0.10), 1.89, 0.057, 0.7],
		"neon_apatite": [Color(0.0, 0.75, 0.95), 1.64, 0.013, 0.9],
		"miyake_glass": [Color(0.35, 0.95, 0.75), 1.52, 0.010, 0.6],
		"blue_chalcedony": [Color(0.70, 0.78, 0.95), 1.54, 0.0, 10.5],
		"yellow_opal": [Color(0.98, 0.95, 0.45), 1.45, 0.0, 10.4],
		"pink_tourm": [Color(1.0, 0.45, 0.70), 1.63, 0.017, 0.6],
		"rhodolite": [Color(0.85, 0.12, 0.40), 1.76, 0.022, 1.0],
		"imperial_topaz": [Color(1.0, 0.55, 0.15), 1.63, 0.014, 0.8],
		"red_spinel": [Color(1.0, 0.10, 0.18), 1.718, 0.020, 0.9],
		"pink_spinel": [Color(1.0, 0.40, 0.60), 1.718, 0.020, 0.8],
		"purple_spinel": [Color(0.78, 0.40, 0.80), 1.718, 0.020, 0.9],
		"lavender_spinel": [Color(0.86, 0.66, 1.0), 1.718, 0.020, 0.5],
		"sunstone": [Color(1.0, 0.55, 0.35), 1.54, 0.012, 0.5],
		"mackay": [Color(0.08, 0.80, 0.32), 1.58, 0.014, 1.6],
		"tsavorite": [Color(0.20, 0.92, 0.25), 1.74, 0.028, 0.9],
		"sphalerite": [Color(1.0, 0.62, 0.10), 2.37, 0.156, 0.8],
		"fire_opal": [Color(1.0, 0.45, 0.08), 1.45, 0.0, 0.7],
		"hessonite": [Color(0.95, 0.40, 0.10), 1.74, 0.028, 1.1],
		"spessartite": [Color(1.0, 0.38, 0.05), 1.80, 0.027, 1.1],
		"sphene": [Color(0.85, 0.80, 0.15), 1.95, 0.051, 0.7],
		"smoky_dark": [Color(0.55, 0.40, 0.28), 1.544, 0.013, 1.2],
		"watermelon": [Color(0.95, 0.35, 0.55), 1.63, 0.017, 0.6],
		"bicolor_tanz": [Color(0.40, 0.30, 1.0), 1.69, 0.030, 0.9],
		"yellow_diamond": [Color(1.0, 0.88, 0.30), 2.417, 0.044, 0.9],
		"brown_diamond": [Color(0.70, 0.45, 0.22), 2.417, 0.044, 1.2],
		"blue_sapph_pale": [Color(0.45, 0.62, 1.0), 1.770, 0.018, 0.6],
		"cornflower": [Color(0.25, 0.42, 1.0), 1.770, 0.018, 0.75],
		"aquamarine_big": [Color(0.55, 0.92, 0.88), 1.58, 0.014, 0.35],
		"amethyst_deep": [Color(0.62, 0.15, 0.95), 1.55, 0.013, 1.0],
		"anglesite": [Color(1.0, 0.70, 0.10), 1.88, 0.044, 0.7],
		"titanite": [Color(0.75, 0.85, 0.20), 1.95, 0.051, 0.7],
	}
	for k in o:
		GemFactory.extra_optics[k] = o[k]
	var cabs := {
		"cab_sapphire": Color(0.22, 0.32, 0.85), "cab_pale_sapph": Color(0.55, 0.62, 0.90),
		"cab_amethyst": Color(0.50, 0.16, 0.62), "cab_emerald": Color(0.10, 0.55, 0.30),
		"cab_garnet": Color(0.45, 0.04, 0.08), "cab_spinel": Color(0.80, 0.14, 0.24),
		"cab_carnelian": Color(0.85, 0.35, 0.12), "cab_ruby": Color(0.78, 0.04, 0.16),
		"cab_pink": Color(0.85, 0.50, 0.66), "cab_tanzanite": Color(0.38, 0.32, 0.86),
		"cab_turquoise": Color(0.25, 0.70, 0.66), "cab_moonstone": Color(0.82, 0.86, 0.92),
	}
	for k in cabs:
		GemFactory.extra_stones[k] = [cabs[k], 1.77, 0.0, ["cabochon"], 0.0, 4]

# ── placement helpers ───────────────────────────────────────────────────────
static func d(a: float) -> Vector3:
	return Vector3(sin(a), 0.0, cos(a))

## Basis with y = n (crown up), x = along (girdle long axis), right-handed.
static func frame(n: Vector3, along: Vector3) -> Basis:
	var nn := n.normalized()
	var x := along - nn * along.dot(nn)
	if x.length() < 1e-4:
		x = nn.cross(Vector3.UP if absf(nn.y) < 0.9 else Vector3.RIGHT)
	x = x.normalized()
	return Basis(x, nn, x.cross(nn))

static func gem(items: Array, stone: String, cut: String, pos: Vector3, n: Vector3, along: Vector3, size: float) -> void:
	var lift := 0.08 if cut == "cabochon" else 0.02
	items.append([stone, cut, Transform3D(frame(n, along).scaled(Vector3.ONE * size), pos + n.normalized() * size * lift)])

static var _collet: Mesh
static var _box_collet: Mesh

## Metal cup under a stone. sx/sz squash the round cup to the stone's outline;
## box = true for step cuts.
static func collet(xfs: Array, pos: Vector3, n: Vector3, along: Vector3, size: float, sx := 1.0, sz := 1.0, box := false) -> void:
	var b := frame(n, along) * Basis.from_scale(Vector3(size * sx, size, size * sz))
	xfs.append([box, Transform3D(b, pos - n.normalized() * size * 0.1)])

static func collet_node(xfs: Array, mat: Material) -> Node3D:
	if _collet == null:
		_collet = MeshUtils.make_revolved([Vector2(0.0, -0.4), Vector2(1.0, -0.4), Vector2(1.12, -0.15), Vector2(1.12, 0.08),
			Vector2(1.0, 0.08), Vector2(0.92, -0.1), Vector2(0.0, -0.1)], null, 24).mesh
		_box_collet = MeshUtils.make_rounded_box(Vector3(2.2, 0.5, 2.2), 0.08, null).mesh
	var n := Node3D.new()
	var r := []
	var bx := []
	for it in xfs:
		if it[0]:
			bx.append(it[1])
		else:
			r.append(it[1])
	if not r.is_empty():
		n.add_child(GalleryDisplays._mm(_collet, r, mat))
	if not bx.is_empty():
		n.add_child(GalleryDisplays._mm(_box_collet, bx, mat))
	return n

static func balls(xfs: Array, mat: Material) -> MultiMeshInstance3D:
	return GalleryDisplays._mm(ShopStones.sphere_mesh(), xfs, mat)

static func ball(xfs: Array, pos: Vector3, r: float) -> void:
	xfs.append(Transform3D(Basis().scaled(Vector3.ONE * r), pos))

## Catmull-Rom through control points.
static func spline(ctrl: Array, n: int) -> PackedVector3Array:
	var out := PackedVector3Array()
	var m := ctrl.size()
	for i in range(n + 1):
		var t := float(i) / float(n) * float(m - 1)
		var k := clampi(int(t), 0, m - 2)
		var u := t - float(k)
		var p0: Vector3 = ctrl[maxi(k - 1, 0)]
		var p1: Vector3 = ctrl[k]
		var p2: Vector3 = ctrl[k + 1]
		var p3: Vector3 = ctrl[mini(k + 2, m - 1)]
		var u2 := u * u
		var u3 := u2 * u
		out.append(0.5 * ((2.0 * p1) + (-p0 + p2) * u + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * u2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * u3))
	return out

## Grid surface f(u, v): u around (wraps when wrap), v from top (0) to bottom (1).
## Outward-facing when u runs like theta with x = cos, z = sin.
static func surface(f: Callable, nu: int, nv: int, mat: Material, wrap := true) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts := []
	for r in range(nv + 1):
		var row := []
		for s in range(nu + 1):
			var u := float(s % nu) / float(nu) if wrap else float(s) / float(nu)
			row.append(f.call(u, float(r) / float(nv)))
		pts.append(row)
	for r in range(nv):
		for s in range(nu):
			var a: Vector3 = pts[r][s]
			var b: Vector3 = pts[r + 1][s]
			var c: Vector3 = pts[r + 1][s + 1]
			var e: Vector3 = pts[r][s + 1]
			st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
			st.add_vertex(a); st.add_vertex(c); st.add_vertex(e)
	st.index()
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	return mi

static func prof_at(prof: Array, v: float) -> Vector2:
	var f := clampf(v, 0.0, 1.0) * float(prof.size() - 1)
	var i := clampi(int(f), 0, prof.size() - 2)
	return (prof[i] as Vector2).lerp(prof[i + 1], f - float(i))

## Lathe a profile listed TOP to BOTTOM; m(theta, v) multiplies the radius.
static func lathe(prof: Array, mat: Material, nu := 64, m: Callable = Callable(), nv := 0) -> MeshInstance3D:
	var rows := nv if nv > 0 else (prof.size() - 1) * 4
	return surface(func(u: float, v: float) -> Vector3:
		var p := prof_at(prof, v)
		var th := u * TAU
		var r: float = p.x * (float(m.call(th, v)) if m.is_valid() else 1.0)
		return Vector3(cos(th) * r, p.y, sin(th) * r), nu, rows, mat)

## Flat plate from a 2D outline, placed with its face along n at origin o.
static func plate(parent: Node3D, poly: PackedVector2Array, thick: float, mat: Material, o: Vector3, ax: Vector3, ay: Vector3) -> MeshInstance3D:
	var mi := AncientTreasures._extrude(poly, thick, mat)
	mi.transform = Transform3D(Basis(ax, ay, ax.cross(ay)), o)
	parent.add_child(mi)
	return mi

static func scaled_poly(pts: Array, s: float, off := Vector2.ZERO) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append((p as Vector2) * s + off)
	return out

## Pave a 2D outline (in a plane o + x*ax + y*ay, facing n) with small stones on a
## hex grid. skip = [[Vector2 centre, radius], ...] keeps holes for bigger stones.
static func pave(items: Array, poly: PackedVector2Array, o: Vector3, ax: Vector3, ay: Vector3, spacing: float, size: float,
		skip: Array = [], stone := "diamond", cut := "round", mask: Callable = Callable()) -> void:
	var n := ax.cross(ay).normalized()
	var mn := Vector2(1e9, 1e9)
	var mx := Vector2(-1e9, -1e9)
	for p in poly:
		mn = mn.min(p)
		mx = mx.max(p)
	var row := 0
	var y := mn.y + spacing * 0.6
	while y < mx.y:
		var x := mn.x + spacing * (0.6 + 0.5 * float(row % 2))
		while x < mx.x:
			var q := Vector2(x, y)
			var ok := Geometry2D.is_point_in_polygon(q, poly)
			if ok:
				for k in range(6):
					var a := float(k) / 6.0 * TAU
					if not Geometry2D.is_point_in_polygon(q + Vector2(cos(a), sin(a)) * size * 1.05, poly):
						ok = false
						break
			if ok:
				for sk in skip:
					if q.distance_to(sk[0]) < float(sk[1]) + size:
						ok = false
						break
			if ok and mask.is_valid() and not mask.call(q):
				ok = false
			if ok:
				gem(items, stone, cut, o + ax * x + ay * y, n, ax, size)
			x += spacing
		y += spacing * 0.866
		row += 1

## Ring of small stones around a centre on a plane.
static func halo(items: Array, c: Vector3, ax: Vector3, ay: Vector3, radius: float, size: float, stone := "diamond", cut := "round", count := 0, sy := 1.0) -> void:
	var n := ax.cross(ay).normalized()
	var k := count if count > 0 else maxi(6, int(TAU * radius / (size * 2.3)))
	for i in range(k):
		var a := float(i) / float(k) * TAU
		gem(items, stone, cut, c + (ax * cos(a) + ay * sin(a) * sy) * radius, n, ax * cos(a) + ay * sin(a), size)

# ── hall layout: plinths on both sides of an aisle, spot-lit, with plaques ──
## list entries: [key, title, subtitle, note, Vector3(width, top, depth)]
static func hall(g: Node3D, start: Vector3, list: Array, title: String, maker: Callable, carpet_col: Color) -> float:
	var spacing := 3.4
	var per_side := int(ceil(float(list.size()) / 2.0))
	var length := float(per_side) * spacing + 3.0
	var dm: Dictionary = GalleryDisplays._mats()
	GalleryDisplays._box(g, Vector3(7.0, 0.02, length), start + Vector3(0, -0.01, length * 0.5 - 1.0), dm["black"], true)
	var carpet := StandardMaterial3D.new()
	carpet.albedo_color = carpet_col
	carpet.roughness = 1.0
	GalleryDisplays._box(g, Vector3(1.8, 0.01, length - 1.0), start + Vector3(0, 0.005, length * 0.5 - 1.0), carpet)
	g._label(title, start + Vector3(0, 2.7, -0.4), 0.004)
	var trim: Material = mats()["brass"]
	for i in range(list.size()):
		var e: Array = list[i]
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := start.z + 1.6 + float(i / 2) * spacing
		var base := Vector3(start.x + side * 2.3, 0, z)
		var pl: Vector3 = e[4]
		var top := pl.y
		GalleryDisplays._box(g, Vector3(pl.z, top, pl.x), base + Vector3(0, top * 0.5, 0), dm["black"], true)
		GalleryDisplays._box(g, Vector3(pl.z + 0.02, 0.025, pl.x + 0.02), base + Vector3(0, top - 0.012, 0), trim)
		GalleryDisplays._box(g, Vector3(pl.z - 0.04, 0.012, pl.x - 0.04), base + Vector3(0, top + 0.006, 0), dm["velvet"])
		var holder := Node3D.new()
		holder.position = base + Vector3(0, top + 0.012, 0)
		holder.rotation.y = -side * PI * 0.5
		g.add_child(holder)
		maker.call(String(e[0]), holder)
		GalleryDisplays._spot(g, base + Vector3(-side * 1.5, 2.9, -0.6), holder.position + Vector3(0, 0.22, 0), 4.0, 22.0)
		var fill := SpotLight3D.new()
		fill.light_energy = 2.0
		fill.spot_angle = 26.0
		fill.spot_range = 4.0
		fill.light_color = Color(0.92, 0.95, 1.0)
		g.add_child(fill)
		fill.look_at_from_position(base + Vector3(-side * 1.2, 2.0, 0.9), holder.position + Vector3(0, 0.2, 0), Vector3.UP)
		var lb := Label3D.new()
		lb.text = "%s\n%s\n%s" % [e[1], e[2], e[3]]
		lb.font_size = 24
		lb.pixel_size = 0.0012
		lb.outline_size = 6
		lb.width = 640.0
		lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lb.modulate = Color(0.95, 0.9, 0.78)
		lb.position = base + Vector3(-side * (pl.z * 0.5 + 0.01), top * 0.68, 0)
		lb.rotation.y = -side * PI * 0.5
		g.add_child(lb)
	return length

## Gem box: plastic tray with a foam insert, tilted toward the aisle on a little
## stand. Children of the returned node sit on the foam (y up, +z toward viewer).
static func gem_box(h: Node3D, size: Vector2, frame_mat: Material, insert_mat: Material, tilt := 0.45) -> Node3D:
	var lift := size.y * 0.5 * sin(tilt) + 0.03
	var b := Node3D.new()
	b.position = Vector3(0, lift, 0.0)
	b.rotation.x = tilt
	h.add_child(b)
	var fr := MeshUtils.make_rounded_box(Vector3(size.x, 0.03, size.y), 0.008, frame_mat)
	fr.position.y = -0.015
	b.add_child(fr)
	var ins := MeshUtils.make_rounded_box(Vector3(size.x - 0.04, 0.006, size.y - 0.04), 0.002, insert_mat)
	ins.position.y = 0.002
	b.add_child(ins)
	var top := Node3D.new()
	top.position.y = 0.005
	b.add_child(top)
	var st := MeshUtils.make_rounded_box(Vector3(size.x * 0.6, lift * 2.0, 0.03), 0.004, frame_mat)
	st.position = Vector3(0, lift, -size.y * 0.3)
	h.add_child(st)
	return top