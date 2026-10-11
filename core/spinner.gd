class_name Spinner
extends Node

## Turns every turntable (group "turntable" in the baked halls) near the
## camera. One loop over a short list; far ones stand still (nobody sees them).

const NEAR := 35.0

var cam: Camera3D
var _nodes: Array[Node3D] = []

func add_hall(hall: Node) -> void:
	for n in hall.find_children("*", "Node3D", true, false):
		if n.is_in_group(Turntable.GROUP):
			_nodes.append(n as Node3D)

func _process(delta: float) -> void:
	if cam == null:
		return
	var p := cam.global_position
	var i := 0
	while i < _nodes.size():
		var n := _nodes[i]
		if not is_instance_valid(n):
			_nodes.remove_at(i)
			continue
		if n.is_visible_in_tree() and n.global_position.distance_squared_to(p) < NEAR * NEAR:
			n.rotate_y(float(n.get_meta("spin_speed", 0.5)) * delta)
		i += 1
