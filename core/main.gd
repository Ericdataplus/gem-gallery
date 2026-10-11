extends Node3D

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# GEM GALLERY — runtime entry. Nothing is generated here: halls are baked
# scenes (res://baked/, made by res://bake/bake.tscn) that stream in around the
# player. Startup = loading screen -> environment -> the halls near the
# entrance -> walk. Everything else streams in the background.
#
#   WASD walk · Shift run · Space jump · mouse look · E pick up a gem
#   F labels · Esc/Tab free the mouse (click to recapture) · Q quit
#   GALLERY_SHOT=1 [GALLERY_ONLY=prefixes]   check renders (core/shots.gd)
#   GALLERY_PROFILE=1                        print startup timings and quit
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

const MANIFEST := "res://baked/manifest.res"

var player: GalleryPlayer
var hud: GalleryHud
var streamer: HallStreamer
var inspector: GemInspector
var spinner: Spinner
var manifest: Resource
var labels_on := true
var _t0 := 0

func _tick(label: String) -> void:
	var now := Time.get_ticks_msec()
	print("PROFILE %-22s %6d ms" % [label, now - _t0])
	_t0 = now

func _ready() -> void:
	_t0 = Time.get_ticks_msec()
	print("PROFILE engine start             %6d ms" % _t0)
	set_process_input(false)
	var loading := LoadingScreen.new()
	add_child(loading)
	loading.set_progress("Opening the doors...", 0.0)
	await get_tree().process_frame
	await get_tree().process_frame
	_tick("loading screen")
	if not ResourceLoader.exists(MANIFEST):
		loading.set_progress("No baked halls yet - run res://bake/bake.tscn once.", 0.0)
		return
	manifest = ResourceLoader.load(MANIFEST)
	if OS.get_environment("ENV_LATE") == "":
		GalleryEnv.build(self)
	player = GalleryPlayer.new()
	add_child(player)
	hud = GalleryHud.new()
	add_child(hud)
	player.mouse_capture_changed.connect(hud.on_capture_changed)
	inspector = GemInspector.new()
	inspector.player = player
	inspector.hud = hud
	add_child(inspector)
	spinner = Spinner.new()
	spinner.cam = player.cam
	add_child(spinner)
	streamer = HallStreamer.new()
	add_child(streamer)
	streamer.setup(manifest, player)
	streamer.hall_added.connect(_on_hall_added)
	streamer.hall_removed.connect(inspector.remove_hall)
	_tick("environment + player")
	var shooting := OS.get_environment("GALLERY_SHOT") != ""
	var first: Array = [] if shooting else [streamer.nearest(player.position)]
	for i in range(first.size()):
		var id: String = first[i]
		loading.set_progress("Bringing in: %s" % streamer.info(id)["title"], float(i) / float(first.size()))
		await get_tree().process_frame
		_tick("  frame before " + id)
		streamer.load_now(id)
		_tick("hall " + id)
	loading.set_progress("Polishing the gems...", 1.0)
	for i in range(3):
		await get_tree().process_frame
	_tick("first frames  (WALKABLE)")
	loading.queue_free()
	streamer.active = true
	set_process_input(true)
	if OS.get_environment("GALLERY_PROFILE") != "":
		await _profile_streaming()
		get_tree().quit()
		return
	if shooting:
		GalleryShots.run(self, streamer, player, manifest)

## Profile mode: stand at the entrance while the neighbouring halls stream in,
## and report the worst frame (what you would feel as a stutter).
func _profile_streaming() -> void:
	var worst := 0
	var last := Time.get_ticks_msec()
	var t_end := last + 25000
	var quiet := 0
	while Time.get_ticks_msec() < t_end:
		await get_tree().process_frame
		var now := Time.get_ticks_msec()
		worst = maxi(worst, now - last)
		last = now
		quiet = quiet + 1 if streamer.busy() == 0 else 0
		if quiet > 60:
			break
	_tick("background streaming")
	var live := []
	for id in streamer.ids():
		if streamer.is_live(id):
			live.append(id)
	print("PROFILE worst frame while streaming %d ms; live halls: %s" % [worst, ", ".join(live)])
	print("PROFILE objects %d  draws %d" % [RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)])

func _on_hall_added(id: String, node: Node3D) -> void:
	inspector.add_hall(id, node)
	spinner.add_hall(node)
	if not labels_on:
		for lb in node.find_children("*", "Label3D", true, false):
			(lb as Label3D).visible = false

func _process(_delta: float) -> void:
	if streamer == null or hud == null:
		return
	var n := streamer.busy()
	hud.set_streaming("" if n == 0 else "Loading %d hall%s nearby..." % [n, "" if n == 1 else "s"])

func _input(event: InputEvent) -> void:
	var captured := player.is_captured()
	if event is InputEventMouseMotion and captured:
		if inspector.held:
			inspector.turn(event.relative)
		else:
			player.look(event.relative)
	elif event is InputEventMouseButton and event.pressed:
		if inspector.held and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			inspector.zoom(event.button_index == MOUSE_BUTTON_WHEEL_UP)
		elif not captured:
			player.set_captured(true)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE, KEY_TAB:
				player.set_captured(false)
			KEY_E:
				inspector.toggle()
			KEY_F:
				labels_on = not labels_on
				for lb in get_tree().get_nodes_in_group(HallBuilder.LABEL_GROUP):
					(lb as Label3D).visible = labels_on
			KEY_Q:
				get_tree().quit()
