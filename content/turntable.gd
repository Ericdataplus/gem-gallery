class_name Turntable

# ═══════════════════════════════════════════════════════════════════════════
# TURNTABLE — a jeweller's motorised display stand. The piece slowly turns
# under fixed pin lights, so its facets sweep through the light and sparkle
# without the visitor moving. Bake time only marks the turning node (group
# "turntable" + meta "spin_speed"); core/spinner.gd turns them at runtime.
#
#   Turntable.stand(parent, pos, radius, height, speed) -> Node3D  (put the piece inside)
#   Turntable.mark(node, speed)                       make an existing node turn
#   Turntable.pin_lights(parent, target, toward, energy)  two narrow shadowless spots
# ═══════════════════════════════════════════════════════════════════════════

const GROUP := "turntable"

## Lacquered base, brass rim and a velvet disc that turns. Returns the turning
## node, whose origin sits on the disc.
static func stand(parent: Node3D, pos: Vector3, radius := 0.18, height := 0.05, speed := 0.5) -> Node3D:
	var dm: Dictionary = GalleryDisplays._mats()
	var base := MeshUtils.make_cylinder(radius * 1.1, radius * 1.18, height, dm["black"], 48)
	base.position = pos + Vector3(0, height * 0.5, 0)
	parent.add_child(base)
	var rim := MeshUtils.make_ring(radius * 1.04, radius * 1.12, 0.012, TreasuryKit.mats()["brass"], 64)
	rim.position = pos + Vector3(0, height, 0)
	parent.add_child(rim)
	var spin := Node3D.new()
	spin.name = "Turntable"
	spin.position = pos + Vector3(0, height, 0)
	parent.add_child(spin)
	_disc(spin, radius)
	mark(spin, speed)
	return spin

## Velvet disc (with a small brass stud so the motion reads) on a turning node.
static func _disc(spin: Node3D, radius: float) -> void:
	var dm: Dictionary = GalleryDisplays._mats()
	var disc := MeshUtils.make_cylinder(radius, radius, 0.012, dm["velvet"], 48)
	disc.position.y = 0.006
	spin.add_child(disc)
	var stud := MeshUtils.make_cylinder(0.008, 0.008, 0.004, TreasuryKit.mats()["brass"], 12)
	stud.position = Vector3(radius * 0.85, 0.013, 0)
	spin.add_child(stud)

## Make an existing node turn in place (for whole display pieces). Adds a
## turning velvet disc under it. swing > 0 sways +-swing radians instead of
## turning fully (boards and boxes, so their plain backs never face you).
## Moving pieces cast no shadow: a moving caster would make every shadowed
## spotlight around it redraw its shadow map each frame.
static func mark(n: Node3D, speed: float, disc_radius := 0.0, swing := 0.0, keep_shadows := false) -> void:
	n.add_to_group(GROUP, true)
	n.set_meta("spin_speed", speed)
	if swing > 0.0:
		n.set_meta("spin_swing", swing)
	if disc_radius > 0.0:
		_disc(n, disc_radius)
	if not keep_shadows:     # (sun shadows redraw every frame anyway, so floor pieces keep theirs)
		no_shadow(n)

## Mark a piece by what it is: free-standing pieces turn, flat ones sway.
static func animate(n: Node3D, flat: bool, i := 0, disc_radius := 0.0) -> void:
	if flat:
		mark(n, 0.45 + 0.05 * float(i % 3), 0.0, 0.7)
	else:
		mark(n, 0.32 + 0.05 * float(i % 3), disc_radius)

## Two narrow, shadowless jeweller's spots on the piece: a warm key from high
## on the viewer's side and a cool one from the other front corner. Moving
## facets catch both, which is what makes stones flash.
static func pin_lights(parent: Node3D, target: Vector3, toward: Vector3, energy := 4.0) -> void:
	var fwd := Vector3(toward.x, 0, toward.z).normalized()
	var side := Vector3.UP.cross(fwd)
	var specs := [[fwd * 0.9 + side * 0.8 + Vector3.UP * 1.7, Color(1.0, 0.96, 0.9), energy],
		[fwd * 1.0 - side * 0.9 + Vector3.UP * 1.2, Color(0.88, 0.93, 1.0), energy * 0.7]]
	for s in specs:
		var sl := SpotLight3D.new()
		sl.light_color = s[1]
		sl.light_energy = s[2]
		sl.spot_angle = 11.0
		sl.spot_attenuation = 0.6
		sl.shadow_enabled = false
		sl.light_specular = 1.0          # mostly glints, little extra diffuse wash
		var from: Vector3 = target + (s[0] as Vector3)
		sl.spot_range = from.distance_to(target) * 1.4
		parent.add_child(sl)
		sl.look_at_from_position(from, target, Vector3.UP)

## Gems on turntables don't cast shadows: a turning caster would force the
## shadow map under every nearby shadowed light to redraw each frame.
static func no_shadow(n: Node) -> void:
	if n is GeometryInstance3D:
		(n as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in n.get_children():
		no_shadow(c)
