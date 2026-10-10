class_name GemInspector
extends Node

## Press E near a stone to hold it up in front of the camera: mouse turns it,
## the wheel brings it closer, E puts it back. Spots come from each baked
## hall's "inspect_spots" metadata, so only live halls can be inspected.

var player: GalleryPlayer
var hud: GalleryHud
var held: Node3D = null
var _src: Node3D = null
var _dist := 0.24
var _rot := Basis()
var _spots := {}             # hall id -> Array of [pos, stone, cut, node]
var _ready_content := false

func add_hall(id: String, node: Node3D) -> void:
	var list := []
	for sp in node.get_meta("inspect_spots", []):
		var target: Node3D = null
		var path: NodePath = sp["path"]
		if not path.is_empty() and node.has_node(path):
			target = node.get_node(path) as Node3D
		list.append([sp["pos"], sp["stone"], sp["cut"], target])
	_spots[id] = list

func remove_hall(id: String) -> void:
	if held != null and _src != null and not is_instance_valid(_src):
		toggle()
	_spots.erase(id)

func _nearest() -> Array:
	var best: Array = []
	var best_score := 1e9
	var o := player.cam.global_position
	var fwd := -player.cam.global_transform.basis.z
	for id in _spots:
		for sp in _spots[id]:
			var to: Vector3 = sp[0] - o
			var d := to.length()
			if d > 4.0 or d < 0.001:
				continue
			var ang := acos(clampf(fwd.dot(to / d), -1.0, 1.0))
			if ang > 0.35:
				continue
			var score := ang * 4.0 + d
			if score < best_score:
				best_score = score
				best = sp
	return best

func _content() -> void:
	if not _ready_content:
		_ready_content = true
		GemFactory.set_environment(0.0, 1.0)
		TreasuryKit.register()

func toggle() -> void:
	if held:
		held.queue_free()
		held = null
		if _src and is_instance_valid(_src):
			_src.visible = true
		_src = null
		hud.inspect_label.visible = false
		player.frozen = false
		return
	var sp := _nearest()
	if sp.is_empty():
		return
	_content()
	var stone: String = sp[1]
	var cut: String = sp[2]
	_src = sp[3]
	if _src:
		_src.visible = false
	held = Node3D.new()
	var g: Node3D
	if stone.begins_with("shop:"):
		g = ShopStones.piece(stone.substr(5), 0.05)
		_rot = Basis(Vector3.RIGHT, 1.3)
	else:
		g = GemFactory.make_gem(stone, cut, 0.06)
		_rot = Basis(Vector3.RIGHT, 0.55)
	g.position = Vector3(0, -0.06 * 0.86, 0)
	held.add_child(g)
	player.cam.add_child(held)
	_dist = 0.24
	player.frozen = true
	var nice := FamousGems.display_name(stone)
	if nice == stone.replace("_", " ").capitalize():
		nice = stone.trim_prefix("shop:").replace("turquoise_web", "spiderweb_turquoise").replace("_", " ").capitalize().replace("Sapph", "Sapphire")
	var extra := ""
	if GemFactory.OPTICS.has(stone) or GemFactory.extra_optics.has(stone):
		var opt: Array = GemFactory.optics_of(stone)
		extra = "   RI %.3f   dispersion %.3f" % [opt[1], opt[2]]
	hud.inspect_label.text = "%s  -  %s%s\nMouse turns the stone  -  scroll moves it closer  -  E puts it back" % [nice, GemCuts.NAMES.get(cut, cut), extra]
	hud.inspect_label.visible = true
	_apply()

func turn(rel: Vector2) -> void:
	_rot = (Basis(Vector3.UP, rel.x * 0.006) * Basis(Vector3.RIGHT, rel.y * 0.006) * _rot).orthonormalized()
	_apply()

func zoom(closer: bool) -> void:
	_dist = clampf(_dist + (-0.03 if closer else 0.03), 0.14, 0.9)
	_apply()

func _apply() -> void:
	if held:
		held.transform = Transform3D(_rot, Vector3(0, 0, -_dist))
