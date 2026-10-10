class_name GalleryEnv

## The neutral studio void: dark backdrop, Filmic tonemapping tuned for an OLED
## (saturated stones stay saturated), a warm key and a cool fill, plus one big
## floor with collision under every hall.
static func build(parent: Node) -> void:
	var win := parent.get_window()
	if DisplayServer.window_is_hdr_output_supported(win.get_window_id()):
		DisplayServer.window_request_hdr_output(true, win.get_window_id())
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.035, 0.036, 0.042)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.57, 0.62)
	env.ambient_light_energy = 0.8
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_white = 6.0
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.12
	env.adjustment_contrast = 1.05
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_hdr_threshold = 1.1
	env.ssao_enabled = true
	env.ssao_radius = 1.2
	env.ssr_enabled = true
	env.fog_enabled = true
	env.fog_light_color = Color(0.05, 0.05, 0.06)
	env.fog_density = 0.012
	var we := WorldEnvironment.new()
	we.environment = env
	parent.add_child(we)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-52, -35, 0)
	key.light_color = Color(1.0, 0.95, 0.88)
	key.light_energy = 2.0
	key.shadow_enabled = true
	key.light_angular_distance = 0.6
	key.directional_shadow_max_distance = 60.0
	parent.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-25, 150, 0)
	fill.light_color = Color(0.70, 0.80, 1.0)
	fill.light_energy = 0.45
	parent.add_child(fill)
	# one floor under everything, a hair below the hall floors (no z-fighting)
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.16, 0.16, 0.17)
	floor_mat.roughness = 0.85
	var fl := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(600.0, 600.0)
	fl.mesh = pm
	fl.position = Vector3(0, -0.03, 120.0)
	fl.material_override = floor_mat
	parent.add_child(fl)
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(600.0, 1.0, 600.0)
	cs.shape = box
	cs.position = Vector3(0, -0.5, 120.0)
	body.add_child(cs)
	parent.add_child(body)
