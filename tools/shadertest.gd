extends Node3D

## Diagnostic: compile cost of every distinct shader in a hall, measured with
## a live camera + gallery environment (the conditions the game runs in).
func _ready() -> void:
	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0, 0, 3)
	cam.make_current()
	GalleryEnv.build(self)
	await get_tree().process_frame
	await get_tree().process_frame
	var halls := OS.get_environment("HALL").split(",")
	var codes := {}
	for hall in halls:
		var ps := ResourceLoader.load("res://baked/%s.scn" % hall, "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
		var st := ps.get_state()
		for i in range(st.get_node_count()):
			for p in range(st.get_node_property_count(i)):
				var v = st.get_node_property_value(i, p)
				if v is ShaderMaterial and (v as ShaderMaterial).shader:
					var c: String = (v as ShaderMaterial).shader.code
					codes[c.hash()] = [c, hall]
	await get_tree().process_frame
	var results := []
	var sphere := SphereMesh.new()
	for k in codes:
		var code: String = codes[k][0]
		var t0 := Time.get_ticks_msec()
		var sh := Shader.new()
		sh.code = code + "\n// probe %d\n" % randi()
		var m := ShaderMaterial.new()
		m.shader = sh
		var mi := MeshInstance3D.new()
		mi.mesh = sphere
		mi.material_override = m
		add_child(mi)
		await get_tree().process_frame
		await get_tree().process_frame
		var dt := Time.get_ticks_msec() - t0
		var first := code.split("\n")
		var tag := ""
		for line in first:
			if line.begins_with("//") or line.contains("kind") or line.contains("uniform"):
				tag = line.strip_edges().substr(0, 70)
				break
		results.append([dt, code.length(), codes[k][1], tag])
		mi.queue_free()
	results.sort_custom(func(a, b): return a[0] > b[0])
	var total := 0
	for r in results:
		total += int(r[0])
		print("SHADERTEST %5d ms  %6d chars  %-10s %s" % r)
	print("SHADERTEST total %d ms over %d shaders" % [total, results.size()])
	get_tree().quit()
