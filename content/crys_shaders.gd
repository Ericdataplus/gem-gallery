class_name CrysShaders

# ═══════════════════════════════════════════════════════════════════════════
# CRYS SHADERS — materials for the raw-mineral specimens (MineralCrystals).
#
#   CRYSTAL (transparent pass, ALPHA = 1): what you see THROUGH the stone is the
#     opaque scene copy (hint_screen_texture) offset by the facet normal
#     (refraction) and blurred by milkiness, tinted by Beer-style absorption
#     along the path (thicker crystal / grazing view = deeper colour), and put
#     in EMISSION so it is not lit twice. Milky bases, veils and fractures are
#     a lit, scattering ALBEDO. Two parallax taps along the refracted ray put
#     the veils INSIDE the stone. Striations are tangent-free bump (bump_h).
#     Zoning: 1 = fluorite phantom cubes (ray-marched in face coordinates),
#     2 = watermelon tourmaline (pink core / green rind on broken ends).
#     A custom light() adds razor facet glints (bloom) and wrapped diffuse.
#   CRYSTAL_OPAQUE: same surface model for opaque crystals (black schorl).
#   ROCK: host-rock matrix / geode rind, rim agate bands and cavity lining.
#
# One ShaderMaterial per species preset (shared by every specimen); per-
# specimen variation via the instance uniform inst_var.
# ═══════════════════════════════════════════════════════════════════════════

static var _shaders := {}
static var _mats := {}

static func material(name: String, preset: Dictionary) -> ShaderMaterial:
	if _mats.has(name):
		return _mats[name]
	var kind: String = preset.get("shader", "crystal")
	var m := ShaderMaterial.new()
	m.shader = _shader(kind)
	for k in preset:
		if k == "shader" or k == "shadow":
			continue
		m.set_shader_parameter(k, preset[k])
	_mats[name] = m
	return m

static func _shader(kind: String) -> Shader:
	if _shaders.has(kind):
		return _shaders[kind]
	var sh := Shader.new()
	match kind:
		"rock":
			sh.code = ROCK_HEAD + MatGLSL.NOISE + MatGLSL.BUMP + ROCK_BODY
		"opaque":
			sh.code = "shader_type spatial;\nrender_mode blend_mix, depth_draw_opaque, cull_back;\n#define OPAQUE\n" + CRYS_UNIFORMS + MatGLSL.NOISE + MatGLSL.BUMP + CRYS_BODY
		_:
			sh.code = "shader_type spatial;\nrender_mode blend_mix, depth_draw_always, cull_back;\n" + CRYS_UNIFORMS + MatGLSL.NOISE + MatGLSL.BUMP + CRYS_BODY
	_shaders[kind] = sh
	return sh

const CRYS_UNIFORMS := """
#ifndef OPAQUE
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest, repeat_disable;
#endif
uniform vec3 base_col : source_color = vec3(0.95);
uniform vec3 tip_col : source_color = vec3(0.95);
uniform float tip_start = 0.4;
uniform float density = 1.0;
uniform float ior = 1.55;
uniform float milky_base = 0.0;
uniform float milky_len = 0.5;
uniform float milky_all = 0.0;
uniform vec3 milk_col : source_color = vec3(0.90, 0.91, 0.93);
uniform float milk_tint = 0.3;
uniform float veil_amt = 0.3;
uniform float veil_scale = 9.0;
uniform float refr = 0.5;
uniform float frost = 0.0;
uniform float stri_h = 0.0;
uniform float stri_v = 0.0;
uniform float stri_freq = 260.0;
uniform float etch = 0.06;
uniform float zone_mode = 0.0;
uniform vec3 zone_col : source_color = vec3(0.5, 0.2, 0.6);
uniform vec3 zone_col2 : source_color = vec3(0.9, 0.9, 0.9);
uniform float zone_edge = 0.7;
uniform float rough = 0.04;
uniform float glint = 40.0;
uniform float wrap = 0.4;
uniform float dirt_h = 0.015;
uniform float earth_stain = 0.0;
uniform vec3 stain_col : source_color = vec3(0.34, 0.25, 0.17);
uniform float hue_var = 0.06;
uniform float bright = 1.0;
uniform float inner = 0.18;
uniform float mottle = 0.0;
uniform float conch = 0.0;
instance uniform float inst_var = 0.5;
"""

const CRYS_BODY := """
varying vec3 v_obj;
varying float v_scale;
varying vec4 v_cu;

void vertex() {
	v_obj = VERTEX;
	v_scale = length(MODEL_MATRIX[0].xyz);
	v_cu = CUSTOM0;
}

void fragment() {
	float t = UV.x;
	float ay = UV.y;
	vec2 fu = UV2;
	float rnd = COLOR.r;
	float kind = COLOR.g;
	float zone = COLOR.b;
	float th = max(v_cu.x, 1e-3);
	float side = 1.0 - step(0.5, kind);
	vec3 N0 = NORMAL;

	// ── surface relief: striations, growth hillocks / etching ──
	float wob = noise3D(v_obj * 23.0 + rnd * 31.0);
	float sh_ = ay * stri_freq + wob * 2.5;
	float sv_ = fu.x * stri_freq * 1.3 + wob * 2.0;
	float fade_h = 1.0 - smoothstep(0.4, 1.4, fwidth(sh_));
	float fade_v = 1.0 - smoothstep(0.4, 1.4, fwidth(sv_));
	float gate = smoothstep(-0.25, 0.45, noise3D(vec3(ay * 35.0, rnd * 17.0, fu.x * 4.0)));
	float h = stri_h * side * (sin(sh_) * 0.5 + 0.5) * (0.35 + 0.65 * gate) * fade_h;
	h += stri_v * side * (sin(sv_) * 0.5 + 0.5) * fade_v;
	h += noise3D(v_obj * 150.0 + rnd * 7.0) * etch;
	if (conch > 0.0) {
		// conchoidal fracture: concentric ripple shells around per-cell impact points
		vec3 cell = floor(v_obj * 3.5);
		vec3 cp = (cell + fract(sin(cell * vec3(12.9, 78.2, 37.7) + 4.1) * 43758.5)) / 3.5;
		float rr = length(v_obj - cp);
		vec3 fc = fract(v_obj * 3.5);
		vec3 ed = min(fc, 1.0 - fc);
		float edge = smoothstep(0.0, 0.18, min(min(ed.x, ed.y), ed.z));
		h += conch * sin(rr * 140.0 + wob * 2.0) * (0.5 + 0.5 * noise3D(v_obj * 9.0)) * exp(-rr * 3.0) * edge;
	}
	NORMAL = bump_h(NORMAL, VERTEX, h * 0.0012 * v_scale, 1.0);

	vec3 N = NORMAL;
	vec3 V = VIEW;
	float ndv = clamp(dot(N, V), 0.0, 1.0);
	mat3 v2o = inverse(mat3(MODEL_MATRIX)) * mat3(INV_VIEW_MATRIX);
	vec3 Vo = normalize(v2o * V);
	vec3 No = normalize(v2o * N);
	vec3 Ro = refract(-Vo, No, 1.0 / ior);
	if (dot(Ro, Ro) < 1e-4) { Ro = -No; }
	Ro = normalize(Ro);

	// ── body colour along the c-axis + per-crystal / per-specimen drift ──
	vec3 body = mix(base_col, tip_col, smoothstep(tip_start, 1.0, t));
	float hv = (inst_var - 0.5) * hue_var * 2.0 + (rnd - 0.5) * hue_var;
	body = clamp(body * (1.0 + vec3(hv, -hv * 0.4, -hv)), 0.0, 1.0);

	if (mottle > 0.0) {
		float mo = noise3D(v_obj * 3.0 + Ro * th * 0.5) + 0.5 * noise3D(v_obj * 9.0);
		body = mix(body, milk_col, smoothstep(-0.1, 0.5, mo) * mottle);
		body = mix(body, body * body, smoothstep(0.0, -0.5, mo) * mottle);
	}
	if (zone_mode > 0.5 && zone_mode < 1.5) {
		// FLUORITE: cube-parallel colour zones, marched along the refracted ray
		// in the face frame (cotangent frame from screen derivatives).
		vec3 dp1 = dFdx(VERTEX); vec3 dp2 = dFdy(VERTEX);
		vec2 du1 = dFdx(fu); vec2 du2 = dFdy(fu);
		vec3 dp2p = cross(dp2, N0); vec3 dp1p = cross(N0, dp1);
		vec3 Tt = dp2p * du1.x + dp1p * du2.x;
		vec3 Bt = dp2p * du1.y + dp1p * du2.y;
		Tt = normalize(Tt + 1e-9); Bt = normalize(Bt + 1e-9);
		vec3 Rv = refract(-V, N0, 1.0 / ior);
		vec3 rd = vec3(dot(Rv, Tt), dot(Rv, Bt), -dot(Rv, N0));
		float acc = 0.0;
		for (int k = 0; k < 5; k++) {
			float s = th * (0.08 + 0.42 * float(k));
			vec3 q = vec3(fu, 0.0) + rd * s;
			float cheb = max(max(abs(q.x), abs(q.y)), abs(th - q.z)) / th;
			float band = smoothstep(zone_edge - 0.04, zone_edge + 0.04, cheb);
			band = max(band, smoothstep(0.03, 0.0, abs(cheb - zone_edge * 0.55)) * 0.3);
			acc += band;
		}
		acc /= 5.0;
		body = mix(base_col, zone_col, acc);
		body = clamp(body * (1.0 + vec3(hv, -hv * 0.4, -hv)), 0.0, 1.0);
	} else if (zone_mode > 1.5 && kind > 0.5 && zone > 0.5) {
		// WATERMELON: broken end shows a pink core, thin pale band, green rind
		float r = length(fu) / th;
		r += noise3D(vec3(fu * 30.0, rnd * 9.0)) * 0.06;
		vec3 c = mix(zone_col, zone_col2, smoothstep(0.66, 0.71, r));
		c = mix(c, base_col, smoothstep(0.76, 0.82, r));
		body = c;
	}

	// ── inclusions: wispy clouds + a family of planar healed fractures, sampled
	// at two depths along the refracted ray so they sit INSIDE the stone ──
	vec3 pn = normalize(fract(sin(vec3(rnd * 12.9, rnd * 78.2 + 1.3, rnd * 37.7 + 2.1)) * 43758.5) * 2.0 - 1.0);
	float veil = 0.0;
	for (int k = 0; k < 2; k++) {
		vec3 q = v_obj + Ro * th * (0.3 + 0.8 * float(k));
		float cl = smoothstep(0.1, 0.5, noise3D(q * veil_scale * 0.5 + vec3(rnd * 11.0)) + 0.45 * noise3D(q * veil_scale * 1.9));
		float pd = dot(q, pn) * veil_scale * 0.45 + rnd * 13.0;
		float sheet = 1.0 - smoothstep(0.0, 0.06, abs(fract(pd) - 0.5));
		float gate = smoothstep(0.05, 0.35, noise3D(q * veil_scale * 0.8 + vec3(3.0, rnd * 5.0, 1.0)));
		veil += cl * 0.3 + sheet * gate * 0.8;
	}
	veil = clamp(veil * 0.5, 0.0, 1.0);
	float milk = milky_all + milky_base * (1.0 - smoothstep(0.0, milky_len, t)) + veil * veil_amt;
	milk = clamp(milk, 0.0, 1.0);

	// ── staining / soil at the foot ──
	float foot = 1.0 - smoothstep(0.0, dirt_h, v_obj.y + noise3D(v_obj * 40.0) * dirt_h * 0.5);
	float stain = earth_stain * (1.0 - smoothstep(0.0, 0.45, t)) * smoothstep(-0.2, 0.3, noise3D(v_obj * 18.0 + vec3(rnd)));
	stain = clamp(max(stain, foot * 0.6), 0.0, 1.0);

	float F = 0.045 + 0.955 * pow(1.0 - ndv, 5.0);
	vec3 scatter = mix(milk_col, body, milk_tint);
#ifdef OPAQUE
	ALBEDO = mix(body, scatter, milk);
	ALBEDO = mix(ALBEDO, stain_col, stain);
	EMISSION = vec3(0.0);
#else
	// path length through the stone (relative), deeper at grazing angles
	float path = v_cu.y * (1.0 + 1.3 * (1.0 - ndv));
	vec3 T = pow(max(body, vec3(0.002)), vec3(density * path));
	vec2 off = N.xy * refr * th * v_scale / max(-VERTEX.z, 0.3);
	vec2 suv = clamp(SCREEN_UV - off, vec2(0.001), vec2(0.999));
	if (texture(depth_tex, suv).r > FRAGCOORD.z) { suv = SCREEN_UV; }   // reverse-z: occluder in front
	float lod = clamp(frost + milk * 4.5, 0.0, 7.0);
	vec3 bg = textureLod(screen_tex, suv, lod).rgb;
	vec3 trans = bg * T * bright * (1.0 - milk) * (1.0 - F);
	ALBEDO = scatter * milk + body * inner * (1.0 - milk);
	ALBEDO = mix(ALBEDO, stain_col, stain);
	EMISSION = trans * (1.0 - stain);
	ALPHA = 1.0;
#endif
	ROUGHNESS = clamp(rough + milk * 0.06 + stain * 0.5, 0.0, 1.0);
	SPECULAR = 0.5;
	METALLIC = 0.0;
}

void light() {
	float ndl = dot(NORMAL, LIGHT);
	float w = max((ndl + wrap) / (1.0 + wrap), 0.0);
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * w / PI;
	vec3 H = normalize(VIEW + LIGHT);
	float nh = max(dot(NORMAL, H), 0.0);
	float a = max(ROUGHNESS * ROUGHNESS, 0.004);
	float a2 = a * a;
	float dd = nh * nh * (a2 - 1.0) + 1.0;
	float D = a2 / (PI * dd * dd);
	float F = 0.045 + 0.955 * pow(1.0 - max(dot(VIEW, H), 0.0), 5.0);
	float g = pow(nh, 1400.0) * glint;
	SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * max(ndl, 0.0) * (D * F * 0.25 + g * F);
}
"""

const ROCK_HEAD := """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
uniform vec3 col_a : source_color = vec3(0.45, 0.42, 0.38);
uniform vec3 col_b : source_color = vec3(0.30, 0.28, 0.25);
uniform float noise_scale = 5.0;
uniform float mottle = 1.0;
uniform float strata = 0.0;
uniform float strata_freq = 60.0;
uniform vec3 vein_col : source_color = vec3(0.9, 0.9, 0.88);
uniform float vein_amt = 0.0;
uniform float vein_scale = 3.0;
uniform float vein_w = 0.035;
uniform vec3 speck_col : source_color = vec3(0.1, 0.1, 0.1);
uniform float speck_amt = 0.0;
uniform float speck_scale = 90.0;
uniform float speck_metal = 0.0;
uniform vec3 rim_a : source_color = vec3(0.55, 0.57, 0.60);
uniform vec3 rim_b : source_color = vec3(0.85, 0.86, 0.86);
uniform vec3 rim_out : source_color = vec3(0.30, 0.33, 0.28);
uniform float band_freq = 7.0;
uniform vec3 lining_col : source_color = vec3(0.2, 0.15, 0.25);
uniform float lining_rough = 0.5;
uniform float rough_a = 0.85;
uniform float bump_amt = 1.0;
uniform float pits = 0.0;
uniform float dirt_h = 0.06;
uniform vec3 earth_col : source_color = vec3(0.40, 0.31, 0.22);
instance uniform float inst_var = 0.5;
varying vec3 v_obj;
varying float v_scale;
varying vec4 v_cu;
"""

const ROCK_BODY := """
void vertex() {
	v_obj = VERTEX;
	v_scale = length(MODEL_MATRIX[0].xyz);
	v_cu = CUSTOM0;
}

void fragment() {
	float zone = COLOR.b;
	vec3 p = v_obj * noise_scale + vec3(inst_var * 13.0);
	float n = fbm(p, 4) * 0.5 + 0.5;
	float nf = noise3D(v_obj * noise_scale * 6.0);
	float st = strata * sin(v_obj.y * strata_freq + n * 4.0 + v_obj.x * 3.0);
	vec3 c = mix(col_a, col_b, clamp(smoothstep(0.35, 0.65, n) * mottle + st * 0.5, 0.0, 1.0));
	c *= 0.9 + 0.2 * nf;
	float vn = abs(fbm(v_obj * vein_scale + vec3(7.0, 2.0, inst_var * 5.0), 3));
	float vein = (1.0 - smoothstep(0.0, vein_w, vn)) * vein_amt;
	c = mix(c, vein_col, vein);
	float sk = noise3D(v_obj * speck_scale + vec3(inst_var * 7.0));
	float speck = smoothstep(0.60 - speck_amt * 3.0, 0.64 - speck_amt * 3.0, sk);
	c = mix(c, speck_col, speck);
	float rough = rough_a - vein * 0.2;
	float metal = speck * speck_metal;
	float hgt = n * 0.012 + nf * 0.002 - vein * 0.002;

	if (zone < 0.25 && pits > 0.0) {
		// weathered basalt skin: knobbly, pitted (vesicles), dull
		float kn = fbm(v_obj * 14.0 + vec3(2.0), 3);
		float pit = smoothstep(0.22, 0.42, noise3D(v_obj * 30.0 + vec3(5.0, inst_var, 1.0))) * pits;
		hgt += kn * 0.012 * pits - pit * 0.006;
		c *= (1.0 - pit * 0.45) * (0.85 + kn * 0.5);
		rough = 0.95;
	}
	if (zone > 0.25 && zone < 0.75) {
		// broken rim: basalt rind -> thin wavy chalcedony layer of varying width -> crystal bases
		float d = v_cu.z + noise3D(v_obj * 6.0) * 0.10 + noise3D(v_obj * 21.0) * 0.03;
		float ch0 = 0.50 + noise3D(v_obj * 2.5 + vec3(9.0)) * 0.16;
		float ch1 = ch0 + 0.13 + noise3D(v_obj * 3.5 + vec3(2.0)) * 0.10;
		float inch = smoothstep(ch0 - 0.015, ch0 + 0.015, d) * (1.0 - smoothstep(ch1 - 0.015, ch1 + 0.015, d));
		float bands = sin((d - ch0) * band_freq * 30.0 + n * 5.0) * 0.5 + 0.5;
		vec3 chal = mix(rim_a, rim_b, 0.3 + bands * 0.45);
		vec3 rind = rim_out * (0.75 + 0.5 * n) * (0.9 + 0.2 * nf);
		c = mix(rind, chal, inch);
		c = mix(c, lining_col * 1.25, smoothstep(ch1, ch1 + 0.06, d));
		rough = mix(0.9, 0.4, inch);
		hgt = nf * 0.002 * (1.0 - inch);
	} else if (zone >= 0.75) {
		c = lining_col * (0.65 + 0.5 * n);
		rough = lining_rough;
		hgt = nf * 0.003;
	}
	// soil at the foot
	float foot = 1.0 - smoothstep(0.0, dirt_h, v_obj.y + (n - 0.5) * dirt_h);
	c = mix(c, earth_col, foot * 0.75);
	rough = mix(rough, 0.92, foot);

	NORMAL = bump_h(NORMAL, VERTEX, hgt * v_scale * bump_amt, 1.0);
	ALBEDO = c;
	ROUGHNESS = clamp(rough + (nf - 0.0) * 0.06, 0.05, 1.0);
	METALLIC = metal;
	SPECULAR = 0.45;
	AO = mix(0.75, 1.0, n);
	AO_LIGHT_AFFECT = 0.3;
}
"""
