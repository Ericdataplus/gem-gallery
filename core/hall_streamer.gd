class_name HallStreamer
extends Node3D

## Keeps only the halls near the player in the scene. Baked hall scenes load on
## worker threads (ResourceLoader threaded requests), are instanced at most one
## per frame, and are freed again when the player walks far away (the loaded
## PackedScene stays cached, so coming back is instant).

signal hall_added(id: String, node: Node3D)
signal hall_removed(id: String)

const LOAD_DIST := 40.0      # start loading when the player is this close to a hall
const UNLOAD_DIST := 70.0    # free a hall's nodes beyond this

var focus: Node3D
var active := false        # background streaming starts after the entrance halls are in
var _halls := {}             # id -> {"info": Dictionary, "state": String, "scene": PackedScene, "node": Node3D}
var _order: Array = []
var _pinned := {}            # ids that must stay loaded (screenshots)
var _tick := 0.0

func setup(manifest: Resource, focus_node: Node3D) -> void:
	focus = focus_node
	var halls: Dictionary = manifest.get_meta("halls")
	_order = manifest.get_meta("order")
	for id in _order:
		if halls.has(id):
			_halls[id] = {"info": halls[id], "state": "idle", "scene": null, "node": null}

func info(id: String) -> Dictionary:
	return _halls[id]["info"] if _halls.has(id) else {}

func ids() -> Array:
	return _halls.keys()

func distance(id: String, p: Vector3) -> float:
	var b: AABB = _halls[id]["info"]["bounds"]
	var dx := maxf(0.0, maxf(b.position.x - p.x, p.x - b.end.x))
	var dz := maxf(0.0, maxf(b.position.z - p.z, p.z - b.end.z))
	return sqrt(dx * dx + dz * dz)

## The hall closest to a position (the one you start in).
func nearest(p: Vector3) -> String:
	var best := ""
	var bd := INF
	for id in _halls:
		var d := distance(id, p)
		if d < bd:
			bd = d
			best = id
	return best

## Halls that should be live for a given position.
func wanted_at(p: Vector3) -> Array:
	var out := []
	for id in _halls:
		if distance(id, p) < LOAD_DIST or _pinned.has(id):
			out.append(id)
	return out

func is_live(id: String) -> bool:
	return _halls.has(id) and _halls[id]["state"] == "live"

func busy() -> int:
	var n := 0
	for id in _halls:
		var st: String = _halls[id]["state"]
		if st == "loading" or st == "ready" or st == "building" or st == "built":
			n += 1
	return n

## Load a hall now and wait until it is in the scene (used by screenshots).
func ensure(id: String) -> void:
	_pinned[id] = true
	_request(id)
	while not is_live(id):
		await get_tree().process_frame

func unpin_all() -> void:
	_pinned.clear()

## Load and instance a hall immediately on the main thread. Much faster than a
## threaded load (which syncs with the render thread mesh by mesh), so it is
## used for the halls around the entrance while the loading screen is up.
func load_now(id: String) -> void:
	var h: Dictionary = _halls[id]
	if h["state"] == "live":
		return
	var t0 := Time.get_ticks_msec()
	if h["scene"] == null:
		if h["state"] == "loading":
			h["scene"] = ResourceLoader.load_threaded_get(h["info"]["scene"])
		else:
			h["scene"] = ResourceLoader.load(h["info"]["scene"])
	var t1 := Time.get_ticks_msec()
	var node := (h["scene"] as PackedScene).instantiate() as Node3D
	var t2 := Time.get_ticks_msec()
	add_child(node)
	var t3 := Time.get_ticks_msec()
	h["node"] = node
	h["state"] = "live"
	hall_added.emit(id, node)
	if OS.get_environment("GALLERY_PROFILE") != "":
		print("PROFILE     %s: load %d  instantiate %d  add %d  signal %d ms" % [id, t1 - t0, t2 - t1, t3 - t2, Time.get_ticks_msec() - t3])

func _request(id: String) -> void:
	var h: Dictionary = _halls[id]
	if h["state"] != "idle":
		return
	if h["scene"] != null:
		h["state"] = "ready"
		return
	var err := ResourceLoader.load_threaded_request(h["info"]["scene"], "PackedScene", false)
	if err != OK:
		push_error("HallStreamer: cannot load %s (%d)" % [h["info"]["scene"], err])
		h["state"] = "failed"
		return
	h["state"] = "loading"
	h["t"] = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if focus == null or not active:
		return
	_tick -= delta
	if _tick <= 0.0:
		_tick = 0.25
		var p := focus.global_position
		for id in _halls:
			var h: Dictionary = _halls[id]
			var d := distance(id, p)
			if (d < LOAD_DIST or _pinned.has(id)) and h["state"] == "idle":
				_request(id)
			elif d > UNLOAD_DIST and not _pinned.has(id) and h["state"] == "live":
				hall_removed.emit(id)
				(h["node"] as Node3D).queue_free()
				h["node"] = null
				h["state"] = "idle"
	# Finish background loads. Building the node tree (where Godot sets up
	# materials and pipelines) runs on a worker thread; only attaching the
	# finished hall happens here, at most one per frame.
	var attached := false
	for id in _order:
		if not _halls.has(id):
			continue
		var h: Dictionary = _halls[id]
		match h["state"]:
			"loading":
				var st := ResourceLoader.load_threaded_get_status(h["info"]["scene"])
				if st == ResourceLoader.THREAD_LOAD_LOADED:
					h["scene"] = ResourceLoader.load_threaded_get(h["info"]["scene"])
					h["state"] = "ready"
				elif st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
					push_error("HallStreamer: failed to load %s" % h["info"]["scene"])
					h["state"] = "failed"
			"ready":
				var scene: PackedScene = h["scene"]
				h["built"] = null
				h["task"] = WorkerThreadPool.add_task(func() -> void: h["built"] = scene.instantiate())
				h["state"] = "building"
			"building":
				if WorkerThreadPool.is_task_completed(h["task"]):
					WorkerThreadPool.wait_for_task_completion(h["task"])
					h["state"] = "built"
			"built":
				if not attached:
					var node := h["built"] as Node3D
					h["built"] = null
					add_child(node)
					h["node"] = node
					h["state"] = "live"
					attached = true
					hall_added.emit(id, node)
