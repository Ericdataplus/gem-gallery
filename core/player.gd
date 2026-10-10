class_name GalleryPlayer
extends CharacterBody3D

## First-person walker. Click captures the mouse; Esc, Tab or losing window
## focus always gives it back. Never falls forever.

signal mouse_capture_changed(captured: bool)

const EYE_H := 1.65
const WALK := 4.6
const RUN := 8.5
const JUMP := 4.2
const GRAVITY := 12.0
const SPAWN := Vector3(0, 0, -2.5)

var cam: Camera3D
var yaw := PI
var pitch := -0.15
var frozen := false          # true while a gem is held up for inspection
var _bob := 0.0

func _ready() -> void:
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.32
	cap.height = 1.75
	cs.shape = cap
	cs.position.y = 0.875
	add_child(cs)
	cam = Camera3D.new()
	cam.fov = 72.0
	cam.near = 0.03
	cam.far = 400.0
	cam.position.y = EYE_H
	add_child(cam)
	cam.make_current()
	position = SPAWN
	apply_look()

func apply_look() -> void:
	rotation.y = yaw
	cam.rotation.x = pitch

## Stand at pos and look at a point (or set yaw/pitch directly).
func place(pos: Vector3, target: Variant, pitch_override := 0.0) -> void:
	position = pos
	velocity = Vector3.ZERO
	if target is Vector3:
		var d: Vector3 = ((target as Vector3) - (pos + Vector3(0, EYE_H, 0))).normalized()
		yaw = atan2(-d.x, -d.z)
		pitch = asin(d.y)
	else:
		yaw = float(target)
		pitch = pitch_override
	apply_look()

func set_captured(on: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if on else Input.MOUSE_MODE_VISIBLE
	mouse_capture_changed.emit(on)

func is_captured() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

func look(rel: Vector2) -> void:
	yaw -= rel.x * 0.0025
	pitch = clampf(pitch - rel.y * 0.0025, deg_to_rad(-85), deg_to_rad(85))
	apply_look()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		set_captured(false)

func _physics_process(delta: float) -> void:
	if frozen:
		velocity = Vector3.ZERO
		return
	var dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): dir.z -= 1
	if Input.is_key_pressed(KEY_S): dir.z += 1
	if Input.is_key_pressed(KEY_A): dir.x -= 1
	if Input.is_key_pressed(KEY_D): dir.x += 1
	dir = (transform.basis * dir).normalized() if dir != Vector3.ZERO else Vector3.ZERO
	var spd := RUN if Input.is_key_pressed(KEY_SHIFT) else WALK
	var v := velocity
	v.x = lerpf(v.x, dir.x * spd, 12.0 * delta)
	v.z = lerpf(v.z, dir.z * spd, 12.0 * delta)
	if is_on_floor():
		if Input.is_key_pressed(KEY_SPACE):
			v.y = JUMP
	else:
		v.y -= GRAVITY * delta
	velocity = v
	move_and_slide()
	if position.y < -5.0:
		position = SPAWN + Vector3(0, 0.5, 0)
		velocity = Vector3.ZERO
	var moving := Vector2(v.x, v.z).length()
	if is_on_floor() and moving > 0.3:
		_bob += delta * moving * 2.2
	cam.position.y = EYE_H + sin(_bob) * 0.035 * clampf(moving / WALK, 0.0, 1.5)
