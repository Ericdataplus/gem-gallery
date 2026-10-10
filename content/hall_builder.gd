class_name HallBuilder
extends Node3D

# ═══════════════════════════════════════════════════════════════════════════
# HALL BUILDER — the root every content generator draws into at BAKE time.
# Generators call the same two hooks the old gallery offered:
#   _label(text, pos, pixel_size)              floating billboard label
#   add_inspect_spot(pos, stone, cut, node)    a gem you can pick up with E
# finalize() turns the result into something cheap to load and draw:
# owners set (so it can be packed), small props get visibility ranges,
# spotlights fade with distance, and inspect spots / shots become metadata.
# ═══════════════════════════════════════════════════════════════════════════

const CULL_DIST := 45.0      # small props stop drawing beyond this (+4x their size)
const CULL_MAX_SIZE := 6.0   # anything bigger (floors, long tables) always draws
const LABEL_DIST := 30.0
const LABEL_GROUP := "gallery_labels"

var _spots: Array = []       # [pos, stone, cut, node]
var shots: Array = []        # [pos, look_target, name] or [pos, yaw, pitch, name]

func _label(text: String, pos: Vector3, px: float) -> void:
	var lb := Label3D.new()
	lb.text = text
	lb.font_size = 34
	lb.outline_size = 8
	lb.pixel_size = px
	lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lb.modulate = Color(0.92, 0.9, 0.86)
	lb.position = pos
	add_child(lb)

func add_inspect_spot(pos: Vector3, stone: String, cut: String, node: Node3D) -> void:
	_spots.append([pos, stone, cut, node])

func shot(pos: Vector3, look_at_point: Vector3, shot_name: String) -> void:
	shots.append([pos, look_at_point, shot_name])

## Make the hall packable and cheap. Returns its world-space bounds.
func finalize() -> AABB:
	var bounds := AABB()
	var first := true
	for n in find_children("*", "", true, false):
		n.owner = self
		if n is Label3D:
			var lb := n as Label3D
			lb.add_to_group(LABEL_GROUP, true)
			lb.visibility_range_end = LABEL_DIST
		elif n is GeometryInstance3D:
			var gi := n as GeometryInstance3D
			var box := gi.global_transform * gi.get_aabb()
			if first:
				bounds = box
				first = false
			else:
				bounds = bounds.merge(box)
			var sz := box.size
			var big := maxf(sz.x, maxf(sz.y, sz.z))
			if gi.visibility_range_end <= 0.0 and big < CULL_MAX_SIZE:
				gi.visibility_range_end = CULL_DIST + big * 4.0
				gi.visibility_range_end_margin = 3.0
		elif n is SpotLight3D or n is OmniLight3D:
			var l := n as Light3D
			l.distance_fade_enabled = true
			l.distance_fade_begin = 40.0
			l.distance_fade_length = 8.0
			l.distance_fade_shadow = 25.0
	var spots := []
	for sp in _spots:
		var node: Node = sp[3]
		spots.append({"pos": sp[0], "stone": sp[1], "cut": sp[2], "path": get_path_to(node) if node != null and is_ancestor_of(node) else NodePath()})
	set_meta("inspect_spots", spots)
	return bounds
