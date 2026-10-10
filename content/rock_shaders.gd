class_name RockShaders

# ═══════════════════════════════════════════════════════════════════════════
# ROCK SHADERS — object-space procedural materials for MineralRocks.
#
# Every species shader = HEAD (noise, tangent-free bump, varyings) + its own
# BODY + TAIL (ground-contact soil, output). Inputs a BODY can read:
#   p      object-space position (+ per-specimen offset), specimen ~1 unit big
#   op     raw object-space position (y = 0 is the ground line)
#   n      interpolated object-space normal      vo  object-space dir to camera
#   fr     0 rind .. 1 fracture/cut face         cut 0..1 cut / window face
#   fh     per-face hash   part  part id         depth  depth below original
#   rip    impact-point distance (or trunk-axis distance for log shapes)
# and sets: alb, rough, metal, spec, h (bump height, object units), back
# (translucency colour), emis, sss. Colours are authored in sRGB via srgb().
# Budget: <= ~3 FBM stacks per pixel.
# ═══════════════════════════════════════════════════════════════════════════

const HEAD_A := """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
"""

const HEAD_B := """
varying vec3 v_obj;
varying vec3 v_on;
varying vec4 v_col;
varying vec2 v_uv;
varying float v_sc;
varying vec2 v_ang;

void vertex() {
	v_obj = VERTEX;
	v_on = NORMAL;
	v_col = COLOR;
	v_uv = UV;
	v_ang = UV2;
	v_sc = length(MODEL_MATRIX[0].xyz);
}

vec3 srgb(vec3 c) { return pow(c, vec3(2.2)); }
float vein(float x, float w) { return 1.0 - smoothstep(0.0, w, abs(x)); }
vec3 warp3(vec3 q) {
	return vec3(noise3D(q), noise3D(q + vec3(5.2, 1.3, 7.7)), noise3D(q + vec3(2.1, 9.4, 3.3)));
}
// cellular: x = F1, y = F2
vec2 cells(vec3 q) {
	vec3 i = floor(q); vec3 f = fract(q);
	float f1 = 8.0; float f2 = 8.0;
	for (int z = -1; z <= 1; z++) for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
		vec3 g = vec3(float(x), float(y), float(z));
		vec3 o = hash3(i + g) * 0.5 + 0.5;
		float d = length(g + o - f);
		if (d < f1) { f2 = f1; f1 = d; } else if (d < f2) { f2 = d; }
	}
	return vec2(f1, f2);
}

void fragment() {
	vec3 op = v_obj;
	vec3 p = v_obj + vec3(v_col.a * 53.0, v_col.a * 17.0, v_col.a * 31.0);
	vec3 n = normalize(v_on);
	vec3 vw = normalize((INV_VIEW_MATRIX * vec4(VIEW, 0.0)).xyz);
	vec3 vo = normalize(transpose(mat3(MODEL_MATRIX)) * vw);
	float dw = fwidth(v_uv.x) * 1.2 + 0.0015;
	float edge_m = smoothstep(0.0, dw, v_uv.x);
	float fr = smoothstep(0.15, 0.45, v_col.r) * edge_m;
	float cut = smoothstep(0.7, 0.95, v_col.r) * edge_m;
	float fh = v_col.g;
	float part = v_col.b;
	float depth = max(v_uv.x, 0.0);
	float rip = v_uv.y;
	vec3 alb = vec3(0.5);
	float rough = 0.6;
	float metal = 0.0;
	float spec = 0.5;
	float h = 0.0;
	vec3 back = vec3(0.0);
	vec3 emis = vec3(0.0);
	float sss = 0.0;
"""

const TAIL := """
	// ground contact: soil film + damp darkening where the stone meets earth
	float gl = op.y + noise3D(p * 7.0) * 0.025;
	float soil = 1.0 - smoothstep(0.0, 0.06, gl);
	alb = mix(alb, mix(alb * 0.55, srgb(vec3(0.42, 0.34, 0.25)), 0.5), soil * 0.75);
	rough = mix(rough, 0.92, soil * 0.8);
	metal *= 1.0 - soil;
	ALBEDO = clamp(alb, 0.0, 1.0);
	ROUGHNESS = clamp(rough, 0.03, 1.0);
	METALLIC = metal;
	SPECULAR = spec;
	BACKLIGHT = back;
	EMISSION = emis;
	SSS_STRENGTH = sss;
	NORMAL = bump_h(NORMAL, VERTEX, h * v_sc, 1.0);
}
"""

static var _mats := {}
static var _uber: Shader

## ONE shader for every rock species: each BODY sits in its own branch picked
## by the `rock_kind` uniform. Godot recompiles every distinct material shader
## on each launch (~0.4 s apiece), so fourteen near-identical shaders cost
## seconds at startup; one uber shader compiles once.
static func uber_shader() -> Shader:
	if _uber == null:
		var keys := BODIES.keys()
		var chain := ""
		for i in range(keys.size()):
			chain += ("\tif (rock_kind == %d) {\n" if i == 0 else "\t} else if (rock_kind == %d) {\n") % i
			chain += BODIES[keys[i]] + "\n"
		chain += "\t}\n"
		_uber = Shader.new()
		_uber.code = HEAD_A + "uniform int rock_kind = 0;\n" + MatGLSL.NOISE + MatGLSL.BUMP + HEAD_B + chain + TAIL
	return _uber

static func material(key: String) -> ShaderMaterial:
	if _mats.has(key):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = uber_shader()
	m.set_shader_parameter("rock_kind", BODIES.keys().find(key))
	_mats[key] = m
	return m

const BODIES := {
# ── NEPHRITE JADE (British Columbia): deep spinach/forest green, darker and
# lighter mottling, pale fibrous flecks, thin brown-black seams, waxy lustre.
"nephrite": """
	// Reference: raw BC nephrite boulder — mottled spinach-to-leaf green, fine
	// dense pale speckle (felted tremolite), lighter jade-green patches, thin
	// dark seams along fractures, greasy/waxy lustre, glowing thin edges.
	vec3 w = warp3(p * 1.5);
	float m = fbm(p * 2.2 + w * 1.4, 4);
	float m2 = fbm(p * 6.5 + w * 2.0 + vec3(7.0), 3);
	vec3 deep = srgb(vec3(0.07, 0.15, 0.09));
	vec3 mid = srgb(vec3(0.18, 0.32, 0.20));
	vec3 lite = srgb(vec3(0.36, 0.50, 0.36));
	// blotchy mottling at two scales: dark spinach islands in leaf-green
	float m3 = noise3D(p * 14.0 + w * 2.5);
	float mot = m + m2 * 0.55 + m3 * 0.28;
	alb = mix(deep, mid, smoothstep(-0.25, 0.05, mot));
	alb = mix(alb, lite, smoothstep(0.12, 0.45, mot) * 0.85);
	// pale, cloudy jade patches (the milky light-green zones in the photo)
	float cloud = smoothstep(0.18, 0.5, m2) * smoothstep(-0.1, 0.3, m);
	alb = mix(alb, srgb(vec3(0.50, 0.64, 0.50)), cloud * 0.45);
	// fine dense speckle: small, many, soft-edged; clustered in pale zones
	float zone = smoothstep(-0.2, 0.3, m);
	vec3 fw = warp3(p * 30.0);
	float fn = noise3D(p * 150.0 + fw * 1.4);
	float fleck = smoothstep(0.40 - zone * 0.08, 0.52 - zone * 0.08, fn) * (0.35 + 0.65 * zone);
	// fibrous pale streaks: stretched speckle along a wandering grain
	float fib = smoothstep(0.30, 0.48, noise3D(p * vec3(40.0, 140.0, 40.0) + w * 3.0)) * zone;
	alb = mix(alb, srgb(vec3(0.74, 0.82, 0.70)), max(fleck * 0.6, fib * 0.35));
	// thin dark seams along healed fractures
	float vn = fbm(p * vec3(1.0, 2.6, 1.3) + w * 0.9 + vec3(11.0), 3);
	float s1 = vein(vn, 0.012) * smoothstep(-0.15, 0.25, noise3D(p * 2.2 + vec3(3.0)));
	float s2 = vein(noise3D(p * vec3(3.0, 6.0, 3.5) + w * 1.6), 0.009) * smoothstep(0.05, -0.25, m);
	float seam = max(s1, s2);
	alb = mix(alb, srgb(vec3(0.12, 0.09, 0.05)), seam * 0.85);
	// unbroken rind only slightly duller (the reference is almost all fracture)
	float rind = 1.0 - fr;
	alb = mix(alb, alb * vec3(0.95, 0.92, 0.82), rind * 0.25);
	rough = mix(0.36, 0.48, rind) + m * 0.05 + seam * 0.12 + fleck * 0.05;
	spec = 0.55;
	h = (noise3D(p * 9.0 + w) * 0.004 + noise3D(p * 60.0) * 0.0008) * (0.5 + rind);
	back = srgb(vec3(0.16, 0.34, 0.16)) * 0.45;
	sss = 0.18;
""",

# ── JADEITE (Hpakant, Myanmar): river boulder in an ochre-brown weathered
# skin, one polished "window" showing apple-green and white mottled jade.
"jadeite": """
	vec3 w = warp3(p * 1.6);
	float m = fbm(p * 2.2 + w * 1.4, 4);
	vec3 skin = mix(srgb(vec3(0.52, 0.40, 0.24)), srgb(vec3(0.38, 0.29, 0.18)), smoothstep(-0.2, 0.3, m));
	skin = mix(skin, srgb(vec3(0.62, 0.55, 0.40)), smoothstep(0.25, 0.5, noise3D(p * 9.0 + w)) * 0.5);
	float m2 = fbm(p * 5.0 + w * 2.0 + vec3(4.0), 3);
	vec3 body = mix(srgb(vec3(0.82, 0.85, 0.78)), srgb(vec3(0.46, 0.68, 0.38)), smoothstep(-0.12, 0.10, m + m2 * 0.6));
	body = mix(body, srgb(vec3(0.14, 0.44, 0.18)), smoothstep(0.12, 0.35, m + m2 * 0.3));
	float grain = noise3D(p * 70.0);
	body *= 0.94 + grain * 0.12;
	float win = smoothstep(0.004, 0.025, depth) * cut;
	alb = mix(skin, body, win);
	rough = mix(0.72 + grain * 0.1, 0.16, win);
	h = (1.0 - win) * (noise3D(p * 18.0 + w) * 0.006 + noise3D(p * 55.0) * 0.002);
	back = srgb(vec3(0.25, 0.45, 0.20)) * 0.6 * win;
	sss = 0.3 * win;
""",

# ── MALACHITE (Katanga, DR Congo): botryoidal dark-green blisters with a silky
# sheen; broken faces show sharp concentric light/dark green banding that follows
# the bubbles (distance below the original surface).
"malachite": """
	vec3 w = warp3(p * 3.0);
	float b = depth * 70.0 + w.x * 0.8 + noise3D(p * 12.0) * 0.35;
	float bi = floor(b);
	float bf = fract(b);
	float t = hash13(vec3(bi, 3.0, 7.0));
	vec3 band = mix(srgb(vec3(0.02, 0.20, 0.10)), srgb(vec3(0.22, 0.56, 0.36)), t * t);
	band = mix(band, srgb(vec3(0.01, 0.12, 0.06)), vein(bf - 0.5, 0.06) * 0.7 * step(0.5, hash13(vec3(bi, 1.0, 2.0))));
	float fib = noise3D(vec3(p.x, p.y, p.z) * 140.0);
	vec3 crust = mix(srgb(vec3(0.02, 0.14, 0.08)), srgb(vec3(0.06, 0.28, 0.15)), smoothstep(-0.3, 0.4, w.y));
	crust *= 0.9 + 0.15 * fib;
	alb = mix(crust, band, fr);
	rough = mix(0.42 + 0.1 * fib, 0.38, fr);
	h = noise3D(p * 30.0) * 0.0015 + fr * (bf * 0.0006);
	sss = 0.0;
""",

# ── LAPIS LAZULI (Sar-i Sang, Badakhshan): deep ultramarine lazurite with
# brassy pyrite flecks and white calcite patches in grey matrix.
"lapis": """
	vec3 w = warp3(p * 2.0);
	float m = fbm(p * 3.2 + w * 1.5, 4);
	vec3 calc = mix(srgb(vec3(0.80, 0.80, 0.77)), srgb(vec3(0.52, 0.53, 0.53)), smoothstep(-0.3, 0.1, w.z));
	vec3 laz = mix(srgb(vec3(0.07, 0.13, 0.52)), srgb(vec3(0.03, 0.06, 0.34)), smoothstep(0.1, 0.45, m));
	float blue = smoothstep(-0.32, -0.16, m);
	float g = noise3D(p * 45.0);
	alb = mix(calc * (0.92 + 0.12 * g), laz * (0.9 + 0.2 * g), blue);
	float py = smoothstep(0.40, 0.47, noise3D(p * 60.0 + vec3(9.0))) * (0.4 + 0.6 * blue);
	alb = mix(alb, srgb(vec3(0.86, 0.72, 0.42)), py);
	metal = py;
	float rind = 1.0 - fr;
	alb = mix(alb, alb * 0.8 + srgb(vec3(0.10, 0.10, 0.10)), rind * 0.45);
	rough = mix(0.45, 0.82, rind) - py * 0.2 + g * 0.06;
	h = noise3D(p * 18.0) * 0.004 * (0.3 + rind) - py * 0.001;
""",

# ── SODALITE (Bahia, Brazil): royal blue with white veins and grey patches.
"sodalite": """
	vec3 w = warp3(p * 1.8);
	float m = fbm(p * 2.6 + w * 1.2, 4);
	vec3 blue = mix(srgb(vec3(0.10, 0.17, 0.50)), srgb(vec3(0.05, 0.09, 0.33)), smoothstep(-0.2, 0.35, m));
	float vn = fbm(p * 1.8 + w * 1.1 + vec3(4.0), 3);
	float vwid = 0.006 + 0.02 * smoothstep(-0.2, 0.4, noise3D(p * 3.0 + vec3(1.0)));
	float white = vein(vn, vwid) * 0.8 + smoothstep(0.30, 0.48, noise3D(p * 7.0 + w * 2.5)) * 0.7;
	white = clamp(white, 0.0, 1.0);
	alb = mix(blue, mix(srgb(vec3(0.82, 0.83, 0.85)), srgb(vec3(0.55, 0.58, 0.64)), smoothstep(0.0, 0.4, w.x)), white * 0.85);
	float rind = 1.0 - fr;
	alb = mix(alb, alb * 0.82 + srgb(vec3(0.08)), rind * 0.4);
	rough = mix(0.42, 0.8, rind) + white * 0.08;
	h = noise3D(p * 20.0) * 0.003 * (0.3 + rind) - white * 0.001;
""",

# ── TURQUOISE (Kingman, Arizona): sky blue-green nugget, spiderweb of brown-
# black matrix, chalky-to-waxy lustre.
"turquoise": """
	vec3 w = warp3(p * 2.2);
	vec2 c = cells(p * 9.0 + w * 1.1);
	float web = (1.0 - smoothstep(0.02, 0.06, c.y - c.x)) * smoothstep(-0.4, 0.0, w.z);
	float m = fbm(p * 3.0 + w, 3);
	vec3 tq = mix(srgb(vec3(0.34, 0.72, 0.74)), srgb(vec3(0.42, 0.70, 0.58)), smoothstep(-0.2, 0.3, m));
	tq = mix(tq, srgb(vec3(0.62, 0.82, 0.80)), smoothstep(0.2, 0.45, m) * 0.6);
	float pit = smoothstep(0.38, 0.5, noise3D(p * 16.0 + vec3(3.0)));
	vec3 mat = mix(srgb(vec3(0.18, 0.12, 0.08)), srgb(vec3(0.40, 0.28, 0.16)), smoothstep(-0.2, 0.3, w.x));
	float mm = clamp(web + pit, 0.0, 1.0);
	alb = mix(tq, mat, mm * 0.9);
	rough = mix(0.42 + m * 0.1, 0.8, mm);
	h = -mm * 0.004 + noise3D(p * 30.0) * 0.001;
""",

# ── OBSIDIAN (Glass Buttes, Oregon): black glass with conchoidal ripple rings,
# near-mirror lustre, faint grey flow-band sheen; matte grey cortex.
"obsidian": """
	vec3 w = warp3(p * 1.4);
	float flow = sin((dot(p, vec3(0.3, 1.0, 0.2)) * 26.0 + w.x * 3.0) );
	vec3 glass = srgb(vec3(0.035, 0.033, 0.036)) + srgb(vec3(0.05, 0.048, 0.045)) * smoothstep(0.6, 1.0, flow) * 0.6;
	float sheen = pow(1.0 - abs(dot(n, vo)), 3.0) * smoothstep(0.3, 1.0, flow);
	glass += srgb(vec3(0.10, 0.09, 0.08)) * sheen * 0.4;
	float rg = sin(rip * 70.0 + noise3D(p * 5.0) * 4.0 + noise3D(p * 17.0)) * exp(-rip * 2.5) * smoothstep(-0.2, 0.3, noise3D(p * 3.0 + vec3(8.0)));
	vec3 cortex = mix(srgb(vec3(0.34, 0.31, 0.28)), srgb(vec3(0.22, 0.20, 0.18)), smoothstep(-0.3, 0.3, w.y));
	float pore = noise3D(p * 40.0);
	alb = mix(cortex * (0.9 + pore * 0.2), glass, fr);
	rough = mix(0.88, 0.04 + abs(rg) * 0.03, fr);
	spec = mix(0.4, 0.55, fr);
	h = fr * rg * 0.0010 + (1.0 - fr) * (pore * 0.004 + noise3D(p * 12.0) * 0.005);
""",

# ── LABRADORITE (Madagascar): dark grey feldspar; on cleavage faces a view-
# dependent schiller of blue / teal / gold patches with lamellar twin striping.
"labradorite": """
	const vec3 L = vec3(0.24, 0.94, 0.24);
	vec3 w = warp3(p * 1.5);
	float m = fbm(p * 2.8 + w, 3);
	vec3 base = mix(srgb(vec3(0.17, 0.18, 0.18)), srgb(vec3(0.28, 0.29, 0.27)), smoothstep(-0.3, 0.3, m));
	float crys = noise3D(p * 26.0);
	base *= 0.88 + crys * 0.25;
	float face = mix(0.25, 1.0, smoothstep(0.6, 0.92, abs(dot(n, normalize(L)))));
	float look = pow(abs(dot(vo, normalize(L))), 2.0);
	float patchm = smoothstep(-0.25, 0.15, noise3D(p * 2.6 + w * 0.8));
	float hue = noise3D(p * 1.8 + vec3(7.0)) * 1.2 + dot(vo, normalize(L)) * 0.35;
	vec3 blue = srgb(vec3(0.12, 0.38, 0.95));
	vec3 teal = srgb(vec3(0.10, 0.70, 0.62));
	vec3 gold = srgb(vec3(0.95, 0.70, 0.16));
	vec3 fl = mix(blue, teal, smoothstep(-0.1, 0.2, hue));
	fl = mix(fl, gold, smoothstep(0.25, 0.5, hue));
	float stripes = 0.85 + 0.15 * sin(dot(op, vec3(0.9, 0.0, -0.4)) * 90.0 + w.y * 6.0);
	float sch = face * look * patchm * stripes * fr;
	alb = mix(base, fl, clamp(sch * 1.2, 0.0, 0.9));
	emis = fl * sch * 0.25;
	rough = mix(0.75, 0.30 - sch * 0.12, fr);
	h = noise3D(p * 14.0) * 0.004 * (1.0 - fr) + crys * 0.0006;
""",

# ── PYRITE (Navajún, La Rioja): mirror-bright brassy cubes with striated faces
# in soft grey marl.
"pyrite": """
	vec3 w = warp3(p * 2.0);
	float isc = step(0.5, part);
	float str = sin(v_uv.x * 420.0 + noise3D(p * 9.0) * 1.2);
	float tarn = smoothstep(0.15, 0.55, noise3D(p * 4.0 + w));
	vec3 brass = mix(srgb(vec3(0.86, 0.76, 0.48)), srgb(vec3(0.62, 0.48, 0.30)), tarn * 0.5);
	float mg = fbm(p * 5.0 + w, 3);
	vec3 marl = mix(srgb(vec3(0.40, 0.39, 0.37)), srgb(vec3(0.27, 0.26, 0.25)), smoothstep(-0.2, 0.3, mg));
	alb = mix(marl, brass, isc);
	metal = isc;
	rough = mix(0.88 + mg * 0.1, 0.16 + tarn * 0.12 + (str * 0.5 + 0.5) * 0.06, isc);
	h = mix(noise3D(p * 25.0) * 0.004 + mg * 0.006, str * 0.00004, isc);
""",

# ── AGATE NODULE (Rio Grande do Sul, Brazil): dull pitted grey-brown rind;
# broken face shows a white skin, concentric grey-blue / white / tan bands
# following the nodule wall, and a sparkling quartz-crystal core.
"agate": """
	vec3 w = warp3(p * 2.5);
	float pore = noise3D(p * 30.0);
	vec3 rindc = mix(srgb(vec3(0.50, 0.45, 0.38)), srgb(vec3(0.36, 0.32, 0.27)), smoothstep(-0.3, 0.3, w.x));
	float b = depth * 55.0 + noise3D(p * 9.0) * 0.6 + w.y * 0.3;
	float bi = floor(b);
	float t = hash13(vec3(bi, 5.0, 1.0));
	vec3 band = mix(srgb(vec3(0.55, 0.60, 0.66)), srgb(vec3(0.86, 0.87, 0.86)), smoothstep(0.35, 0.6, t));
	band = mix(band, srgb(vec3(0.62, 0.45, 0.32)), step(0.85, t));
	band = mix(band, srgb(vec3(0.40, 0.46, 0.56)), step(t, 0.15));
	band *= 0.92 + 0.1 * sin(fract(b) * 6.2832);
	band = mix(srgb(vec3(0.88, 0.87, 0.84)), band, smoothstep(0.012, 0.02, depth));
	float core = smoothstep(0.30, 0.34, depth + w.z * 0.03);
	float dr = noise3D(p * 90.0);
	vec3 quartz = srgb(vec3(0.80, 0.82, 0.84)) * (0.7 + 0.5 * dr);
	band = mix(band, quartz, core);
	alb = mix(rindc * (0.9 + pore * 0.2), band, fr);
	rough = mix(0.88, mix(0.28, 0.12 + dr * 0.3, core), fr);
	h = (1.0 - fr) * (pore * 0.006 + noise3D(p * 9.0) * 0.008) + fr * core * dr * 0.002;
	back = band * 0.15 * fr;
""",

# ── PETRIFIED WOOD (Holbrook, Arizona): ridged grey-brown bark; broken log ends
# of red/ochre/purple jasper with faint growth rings, a pale core and radial
# shrinkage cracks.
"petrified": """
	vec3 w = warp3(p * 1.6);
	vec2 ca = normalize(v_ang + vec2(1e-5));
	float bk = noise3D(vec3(p.x * 2.0, p.y * 22.0, p.z * 22.0));
	vec3 bark = mix(srgb(vec3(0.38, 0.35, 0.33)), srgb(vec3(0.47, 0.32, 0.25)), smoothstep(-0.2, 0.4, w.x));
	bark = mix(bark, srgb(vec3(0.62, 0.60, 0.56)), smoothstep(0.2, 0.5, noise3D(p * 5.0 + w)) * 0.5);
	bark = mix(bark, srgb(vec3(0.32, 0.27, 0.24)), smoothstep(0.1, 0.4, bk) * 0.6);
	float rr = rip * 60.0 + w.y * 2.0 + noise3D(p * 8.0) * 0.8;
	float ring = 0.5 + 0.5 * sin(rr * 6.2832);
	float m = fbm(p * 3.0 + w * 1.5, 3);
	vec3 jas = mix(srgb(vec3(0.64, 0.24, 0.14)), srgb(vec3(0.84, 0.58, 0.28)), smoothstep(-0.25, 0.2, m));
	jas = mix(jas, srgb(vec3(0.42, 0.24, 0.30)), smoothstep(0.25, 0.5, m) * 0.8);
	jas *= 0.86 + ring * 0.18;
	float pale = 1.0 - smoothstep(0.03, 0.12, rip + w.z * 0.03);
	jas = mix(jas, srgb(vec3(0.82, 0.78, 0.70)), pale * 0.85);
	float crack = vein(noise3D(vec3(ca * 7.0, rip * 2.5 + 1.7)), 0.03) * smoothstep(0.02, 0.1, rip);
	jas = mix(jas, srgb(vec3(0.12, 0.10, 0.10)), crack * 0.8);
	float rim = 1.0 - smoothstep(0.0, 0.025, depth);
	jas = mix(jas, bark * 0.8, rim * 0.6);
	alb = mix(bark * (0.9 + bk * 0.2), jas, fr);
	rough = mix(0.86, 0.32 + crack * 0.4, fr);
	h = (1.0 - fr) * (bk * 0.012 + noise3D(p * 30.0) * 0.002) + fr * (-crack * 0.002 + ring * 0.0004);
""",

# ── RHODOCHROSITE (Capillitas, Argentina): stalactite section in a crusty pink
# rind; its broken ends show concentric rose / deep-rose / pale-pink bands.
"rhodochrosite": """
	vec3 w = warp3(p * 2.2);
	float rr = rip * 55.0 + w.x * 1.2 + noise3D(p * 10.0) * 0.5;
	float bi = floor(rr);
	float t = hash13(vec3(bi, 2.0, 9.0));
	vec3 band = mix(srgb(vec3(0.86, 0.42, 0.50)), srgb(vec3(0.68, 0.22, 0.34)), smoothstep(0.4, 0.8, t));
	band = mix(band, srgb(vec3(0.96, 0.82, 0.80)), step(0.82, t));
	band *= 0.94 + 0.08 * sin(fract(rr) * 6.2832);
	float cr = noise3D(p * 26.0);
	vec3 crust = mix(srgb(vec3(0.74, 0.50, 0.50)), srgb(vec3(0.58, 0.40, 0.36)), smoothstep(-0.2, 0.3, w.y));
	alb = mix(crust * (0.9 + cr * 0.2), band, fr);
	rough = mix(0.72, 0.28, fr);
	h = (1.0 - fr) * (cr * 0.005 + noise3D(p * 8.0) * 0.006);
	back = band * 0.25 * fr;
	sss = 0.2 * fr;
""",

# ── TIGER'S EYE (Northern Cape, South Africa): layered golden-brown fibrous
# quartz with dark ironstone seams; the fibre bands shimmer (chatoyancy) and
# swap light/dark as the view moves.
"tigers_eye": """
	const vec3 F = vec3(0.0, 1.0, 0.0);
	vec3 w = warp3(p * 1.4);
	float layer = dot(p, F) * 34.0 + w.x * 2.0 + noise3D(p * 4.0) * 0.8;
	float li = floor(layer);
	float t = hash13(vec3(li, 4.0, 2.0));
	float dark = step(0.80, t);
	vec3 fdir = normalize(F + vec3(w.y, 0.0, w.z) * 0.35 + vec3(sin(li * 2.3), 0.0, cos(li * 1.7)) * 0.25);
	vec3 rv = reflect(-vo, n);
	float cy = pow(1.0 - abs(dot(rv, fdir)), 6.0);
	float sgn = mod(li, 2.0);
	cy = mix(cy, 1.0 - cy, sgn * 0.35);
	vec3 gold = mix(srgb(vec3(0.36, 0.22, 0.08)), srgb(vec3(0.80, 0.58, 0.24)), clamp(cy, 0.0, 1.0));
	gold *= 0.9 + 0.12 * noise3D(vec3(p.x * 120.0, p.y * 6.0, p.z * 120.0));
	vec3 iron = mix(srgb(vec3(0.20, 0.12, 0.08)), srgb(vec3(0.16, 0.16, 0.20)), smoothstep(-0.2, 0.3, w.z));
	vec3 face = mix(gold, iron, dark);
	vec3 rindc = mix(srgb(vec3(0.36, 0.24, 0.14)), srgb(vec3(0.26, 0.18, 0.12)), smoothstep(-0.3, 0.3, w.y));
	alb = mix(rindc, face, fr);
	rough = mix(0.82, mix(0.30, 0.55, dark), fr);
	h = (1.0 - fr) * noise3D(p * 16.0) * 0.006 + fr * (fract(layer) * 0.0008);
""",

# ── HEMATITE "KIDNEY ORE" (Cumbria, England): botryoidal steel-grey to black
# metallic lobes with rusty red earthy crevices; broken faces show radiating
# fibres and growth bands.
"hematite": """
	vec3 w = warp3(p * 2.5);
	float rust = smoothstep(0.15, 0.45, noise3D(p * 5.0 + w));
	float b = depth * 60.0 + w.y * 0.6;
	float bands = 0.5 + 0.5 * sin(b * 6.2832);
	float fib = noise3D(vec3(depth * 3.0, fh * 40.0 + p.x * 90.0, p.z * 90.0));
	vec3 steel = mix(srgb(vec3(0.30, 0.30, 0.32)), srgb(vec3(0.20, 0.19, 0.20)), smoothstep(-0.2, 0.3, w.x));
	vec3 inner = mix(srgb(vec3(0.28, 0.26, 0.27)), srgb(vec3(0.40, 0.38, 0.38)), bands * 0.6 + fib * 0.3);
	vec3 ochre = srgb(vec3(0.46, 0.18, 0.10));
	vec3 c = mix(steel, inner, fr);
	alb = mix(c, ochre, rust * 0.85);
	metal = (1.0 - rust) * mix(0.85, 0.7, fr);
	rough = mix(mix(0.22, 0.4, fr), 0.85, rust);
	h = noise3D(p * 24.0) * 0.0015 + rust * noise3D(p * 60.0) * 0.002 + fr * fib * 0.0008;
""",
}
