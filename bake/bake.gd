extends Node

# ═══════════════════════════════════════════════════════════════════════════
# BAKE — runs every hall recipe once and saves the result as a ready-to-load
# scene: res://baked/<hall>.scn, plus res://baked/manifest.res (bounds, titles,
# check-shot list, layout). The game itself never generates geometry.
#
#   godot --path . res://bake/bake.tscn --screen 1
#   BAKE_ONLY=treasury,collector   re-bake just those halls (others are kept)
#
# Needs a real renderer (not --headless): mesh data lives on the GPU side.
# ═══════════════════════════════════════════════════════════════════════════

const OUT := "res://baked/"
const MANIFEST := "res://baked/manifest.res"

func _ready() -> void:
	await get_tree().process_frame
	var t_all := Time.get_ticks_msec()
	GemFactory.set_environment(0.0, 1.0)
	TreasuryKit.register()
	var L := Halls.layout()
	var only := OS.get_environment("BAKE_ONLY")
	var wanted: Array = [] if only == "" else Array(only.split(","))
	var halls := {}
	if ResourceLoader.exists(MANIFEST):
		var old := ResourceLoader.load(MANIFEST, "", ResourceLoader.CACHE_MODE_IGNORE)
		if old != null and old.has_meta("halls"):
			halls = old.get_meta("halls")
	DirAccess.make_dir_recursive_absolute(OUT)
	for id in Halls.ORDER:
		if not wanted.is_empty() and not wanted.has(id):
			continue
		var t0 := Time.get_ticks_msec()
		var hb := HallBuilder.new()
		hb.name = id.to_pascal_case()
		add_child(hb)
		Halls.build(id, hb, L)
		var bounds := hb.finalize()
		var ps := PackedScene.new()
		var err := ps.pack(hb)
		if err != OK:
			push_error("BAKE: could not pack %s (%d)" % [id, err])
			continue
		var path: String = OUT + String(id) + ".scn"
		err = ResourceSaver.save(ps, path, ResourceSaver.FLAG_COMPRESS)
		if err != OK:
			push_error("BAKE: could not save %s (%d)" % [path, err])
			continue
		halls[id] = {"id": id, "title": Halls.TITLES.get(id, id), "scene": path, "bounds": bounds, "shots": hb.shots.duplicate(true)}
		var nodes := hb.find_children("*", "", true, false).size()
		print("BAKED %-10s %5d nodes  %6d ms  %s" % [id, nodes, Time.get_ticks_msec() - t0, path])
		remove_child(hb)
		hb.free()
		await get_tree().process_frame
	var m := Resource.new()
	m.set_meta("halls", halls)
	m.set_meta("order", Halls.ORDER)
	m.set_meta("layout", L)
	ResourceSaver.save(m, MANIFEST)
	print("BAKE DONE in %d ms" % (Time.get_ticks_msec() - t_all))
	get_tree().quit()
