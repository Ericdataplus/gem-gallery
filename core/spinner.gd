class_name Spinner
extends Node

## Turns every display piece (group "turntable" in the baked halls) near the
## camera. Two motions, set at bake time by Turntable.mark():
##   spin   full turns at "spin_speed" rad/s (free-standing pieces)
##   swing  sways +-"spin_swing" rad around its baked angle (boards, boxes,
##          pieces whose back is plain), so the front always faces you
## Far pieces stand still; nobody sees them.

const NEAR := 35.0

var cam: Camera3D
var _nodes: Array[Node3D] = []
var _t := 0.0

func add_hall(hall: Node) -> void:
	for n in hall.find_children("*", "Node3D", true, false):
		if n.is_in_group(Turntable.GROUP):
			var n3 := n as Node3D
			n3.set_meta("spin_base", n3.rotation.y)
			_nodes.append(n3)

func _process(delta: float) -> void:
	if cam == null:
		return
	_t += delta
	var p := cam.global_position
	var i := 0
	while i < _nodes.size():
		var n := _nodes[i]
		if not is_instance_valid(n):
			_nodes.remove_at(i)
			continue
		if n.is_visible_in_tree() and n.global_position.distance_squared_to(p) < NEAR * NEAR:
			var speed := float(n.get_meta("spin_speed", 0.5))
			var swing := float(n.get_meta("spin_swing", 0.0))
			if swing > 0.0:
				n.rotation.y = float(n.get_meta("spin_base", 0.0)) + swing * sin(_t * speed + float(i) * 0.7)
			else:
				n.rotate_y(speed * delta)
		i += 1
