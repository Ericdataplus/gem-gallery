class_name GalleryShots

## Check renders. GALLERY_SHOT=1 renders every shot listed in the manifest
## into res://images/<name>.png and quits; GALLERY_ONLY=t_isc,c_ limits it to
## shots whose names start with any of those prefixes (only those halls load).

const DIR := "res://images/"

static func run(main: Node, streamer: HallStreamer, player: GalleryPlayer, manifest: Resource) -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var only := OS.get_environment("GALLERY_ONLY")
	var wanted: Array = [] if only == "" else Array(only.split(","))
	var halls: Dictionary = manifest.get_meta("halls")
	for id in manifest.get_meta("order"):
		if not halls.has(id):
			continue
		for s in halls[id]["shots"]:
			var name: String = s[s.size() - 1]
			if not wanted.is_empty() and not wanted.any(func(w): return name.begins_with(String(w))):
				continue
			await streamer.ensure(id)
			if s.size() == 3:
				player.place(s[0], s[1])
			else:
				player.place(s[0], float(s[1]), float(s[2]))
			await main.get_tree().create_timer(1.5).timeout
			main.get_viewport().get_texture().get_image().save_png(DIR + name + ".png")
			print("CAPTURED ", name)
		streamer.unpin_all()
	main.get_tree().quit()
