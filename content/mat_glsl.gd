class_name MatGLSL

# ═══════════════════════════════════════════════════════════════════════════
# MAT GLSL — shared shader snippets for every stone / metal / tile material.
#
#   NOISE   value-gradient noise3D + fbm (quintic fade)          [same as before]
#   BUMP    bump_h(): TANGENT-FREE bump mapping (Mikkelsen surface gradient from
#           screen derivatives of a world-space height in metres). Writes NORMAL
#           directly, so it is safe on the AI-figure GLBs that have no tangents
#           and on procedural meshes with no usable UVs.
#   AGE     age_stone(): the AC-Odyssey "lived-in stone" stack, applied by default
#           to every marble — large-scale value/hue drift, sun-bleached tops,
#           rain streaks on vertical faces, ground-up grime (height-blended into
#           crevices first), cavity dirt, edge wear, micro-roughness breakup.
#
# Everything is world-space procedural (no UVs). Costs are kept low: AGE adds
# ~6 single-octave noise taps per pixel.
# ═══════════════════════════════════════════════════════════════════════════

const NOISE := """
vec3 hash3(vec3 p) {
	p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
			 dot(p, vec3(269.5, 183.3, 246.1)),
			 dot(p, vec3(113.5, 271.9, 124.6)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}
float noise3D(vec3 p) {
	vec3 i = floor(p); vec3 f = fract(p);
	vec3 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return mix(mix(mix(dot(hash3(i), f), dot(hash3(i+vec3(1,0,0)), f-vec3(1,0,0)), u.x),
				   mix(dot(hash3(i+vec3(0,1,0)), f-vec3(0,1,0)), dot(hash3(i+vec3(1,1,0)), f-vec3(1,1,0)), u.x), u.y),
			   mix(mix(dot(hash3(i+vec3(0,0,1)), f-vec3(0,0,1)), dot(hash3(i+vec3(1,0,1)), f-vec3(1,0,1)), u.x),
				   mix(dot(hash3(i+vec3(0,1,1)), f-vec3(0,1,1)), dot(hash3(i+vec3(1,1,1)), f-vec3(1,1,1)), u.x), u.y), u.z);
}
float fbm(vec3 p, int octaves) {
	float f = 0.0; float amp = 0.5;
	for(int i = 0; i < octaves; i++) { f += amp * noise3D(p); p *= 2.01; amp *= 0.48; }
	return f;
}
float hash13(vec3 p) { return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123); }
float hash12(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123); }
"""

const BUMP := """
// Tangent-free bump: N and P in VIEW space (pass NORMAL, VERTEX), h = height in
// metres (any world-space function), k = strength multiplier.
vec3 bump_h(vec3 N, vec3 P, float h, float k) {
	vec3 dpdx = dFdx(P);
	vec3 dpdy = dFdy(P);
	float dhdx = dFdx(h);
	float dhdy = dFdy(h);
	vec3 r1 = cross(dpdy, N);
	vec3 r2 = cross(N, dpdx);
	float det = dot(dpdx, r1);
	vec3 g = sign(det) * (dhdx * r1 + dhdy * r2);
	vec3 r = abs(det) * N - k * g;
	float l = length(r);
	return l > 1e-14 ? r / l : N;
}
// Screen-space curvature estimate (1/m) from the world normal + position.
float curvature_ws(vec3 nw, vec3 pos) {
	return length(fwidth(nw)) / max(length(fwidth(pos)), 1e-4);
}
"""

const AGE := """
uniform float age_amt : hint_range(0.0, 1.0) = 1.0;   // 0 = showroom-clean stone
uniform float ground_y = 0.0;                          // world height of the ground
uniform float grime_h = 1.7;                           // how high ground grime climbs

// cav: 0 = deep crevice/pore, 1 = proud surface. edge: 0..1 convex-edge estimate.
void age_stone(inout vec3 albedo, inout float rough, vec3 pos, vec3 nw, float cav, float edge) {
	if (age_amt <= 0.001) { return; }
	float a = age_amt;
	// 1. Macro value + hue drift (block-to-block / weather exposure), very low freq.
	float m1 = noise3D(pos * 0.055 + vec3(17.0, 3.0, 5.0));
	float m2 = noise3D(pos * 0.21 + vec3(2.0, 41.0, 9.0));
	albedo *= 1.0 + (m1 * 0.16 + m2 * 0.07) * a;
	albedo *= mix(vec3(1.0), vec3(1.0, 0.96, 0.89), clamp(m2 * 1.6 + 0.35, 0.0, 1.0) * 0.35 * a);
	// 2. Sun-bleached, rain-washed tops: lighter, cooler, a touch rougher.
	float up = smoothstep(0.35, 0.95, nw.y);
	albedo = mix(albedo, min(albedo * 1.07 + vec3(0.015, 0.015, 0.02), vec3(0.93)), up * 0.55 * a);
	// 3. Rain streaks on vertical faces: noise stretched vertically along the face.
	float vert = 1.0 - abs(nw.y);
	vec2 hd = normalize(vec2(-nw.z, nw.x) + vec2(1e-4));
	float hc = dot(pos.xz, hd);
	float s1 = noise3D(vec3(hc * 5.5, pos.y * 0.30, 3.1));
	float s2 = noise3D(vec3(hc * 17.0, pos.y * 0.55, 8.7));
	float sgate = smoothstep(-0.05, 0.35, noise3D(vec3(hc * 0.7, pos.y * 0.12, 1.3)));
	float streak = clamp(smoothstep(0.02, 0.32, s1) * 0.7 + smoothstep(0.10, 0.35, s2) * 0.45, 0.0, 1.0) * sgate * vert;
	albedo = mix(albedo, albedo * vec3(0.80, 0.79, 0.77), streak * 0.40 * a);
	rough += streak * 0.06 * a;
	// 4. Ground grime: climbs from the ground, height-blended into crevices first.
	float gh = pos.y - ground_y;
	float gn = noise3D(pos * vec3(0.8, 0.25, 0.8) + vec3(5.0));
	float gm = 1.0 - smoothstep(0.0, grime_h * (0.7 + gn * 0.6 + 0.3), gh);
	gm = clamp(gm * 1.3 - cav * 0.35, 0.0, 1.0);
	albedo = mix(albedo, albedo * vec3(0.60, 0.56, 0.47), gm * 0.8 * a);
	rough = mix(rough, 0.82, gm * a);
	// 5. Cavity dirt: pores and vein hollows hold dust.
	albedo *= mix(1.0, 0.90, (1.0 - cav) * a);
	// 6. Worn / chipped convex edges: fresher, lighter, rougher stone.
	albedo = mix(albedo, min(albedo * 1.08, vec3(0.93)), edge * 0.5 * a);
	rough += edge * 0.12 * a;
	// 7. Micro roughness breakup so the sun highlight crumbles instead of gliding.
	float rn = noise3D(pos * 9.0 + vec3(3.0, 1.0, 7.0));
	float rn2 = noise3D(pos * 31.0 + vec3(9.0));
	rough += (rn * 0.09 + rn2 * 0.05) * a;
}
"""
