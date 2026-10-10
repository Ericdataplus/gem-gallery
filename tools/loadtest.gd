extends Node

## Diagnostic: how long does each baked hall take to load, and what is in it?
func _ready() -> void:
	if OS.get_environment("WITH_CAM") != "":
		var c := Camera3D.new()
		var root3d := Node3D.new()
		add_child(root3d)
		root3d.add_child(c)
		c.make_current()
		GalleryEnv.build(root3d)
	await get_tree().process_frame
	await get_tree().process_frame
	for id in ["specimens", "displays", "cut_gems"]:
		var path := "res://baked/%s.scn" % id
		var t0 := Time.get_ticks_usec()
		var ps := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
		var t1 := Time.get_ticks_usec()
		var node := ps.instantiate()
		var t2 := Time.get_ticks_usec()
		var meshes := {}
		var shaders := {}
		var verts := 0
		for n in node.find_children("*", "", true, false):
			var m: Mesh = null
			if n is MeshInstance3D:
				m = (n as MeshInstance3D).mesh
			elif n is MultiMeshInstance3D and (n as MultiMeshInstance3D).multimesh:
				m = (n as MultiMeshInstance3D).multimesh.mesh
			if m is ArrayMesh and not meshes.has(m):
				meshes[m] = true
				for s in range(m.get_surface_count()):
					verts += m.surface_get_array_len(s)
			if n is GeometryInstance3D and (n as GeometryInstance3D).material_override is ShaderMaterial:
				var sh := ((n as GeometryInstance3D).material_override as ShaderMaterial).shader
				if sh:
					shaders[sh] = true
		print("LOADTEST %-10s load %6d ms  instance %5d ms  meshes %4d  verts %8d  shader objects %3d" % [id, (t1 - t0) / 1000, (t2 - t1) / 1000, meshes.size(), verts, shaders.size()])
		node.free()
	get_tree().quit()
