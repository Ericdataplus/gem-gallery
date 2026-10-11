extends Node

## Diagnostic: how many moving display pieces (turning / swaying) each baked hall has.
func _ready() -> void:
	var m := ResourceLoader.load("res://baked/manifest.res")
	var total := 0
	for id in m.get_meta("order"):
		var node := (ResourceLoader.load("res://baked/%s.scn" % id) as PackedScene).instantiate()
		var spin := 0
		var sway := 0
		for n in node.find_children("*", "Node3D", true, false):
			if n.is_in_group(Turntable.GROUP):
				if float(n.get_meta("spin_swing", 0.0)) > 0.0:
					sway += 1
				else:
					spin += 1
		print("SPINCHECK %-10s turning %3d  swaying %3d" % [id, spin, sway])
		total += spin + sway
		node.free()
	print("SPINCHECK total moving pieces: %d" % total)
	get_tree().quit()
