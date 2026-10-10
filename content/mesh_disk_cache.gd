class_name MeshDiskCache

# ═══════════════════════════════════════════════════════════════════════════
# MESH DISK CACHE — procedural meshes are expensive to generate in GDScript
# (the mineral specimens alone take seconds), but deterministic for a given
# (id, seed) and generator source. Generate once, save as binary resources in
# user://mesh_cache/, and load them on later runs. The cache key includes an
# MD5 of the generator scripts, so editing a generator rebuilds automatically.
#
#   MeshDiskCache.fetch(key, sources: Array[String], build: Callable) -> Variant
#       build() returns the value to cache (Mesh, or Array of [Mesh, ...] rows).
# ═══════════════════════════════════════════════════════════════════════════

const DIR := "user://mesh_cache/"

static var _versions := {}
static var _disabled := false

static func _version(sources: Array) -> String:
	var k := ",".join(sources)
	if _versions.has(k):
		return _versions[k]
	var acc := ""
	for s in sources:
		acc += FileAccess.get_md5(String(s))
	var v := acc.md5_text().substr(0, 12)
	_versions[k] = v
	return v

static func fetch(key: String, sources: Array, build: Callable) -> Variant:
	if _disabled or OS.get_environment("MESH_CACHE_OFF") != "":
		return build.call()
	var path := "%s%s_%s.res" % [DIR, key.validate_filename(), _version(sources)]
	if ResourceLoader.exists(path):
		var r := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if r != null and r.has_meta("value"):
			return r.get_meta("value")
	var value: Variant = build.call()
	DirAccess.make_dir_recursive_absolute(DIR)
	var box := Resource.new()
	box.set_meta("value", value)
	var err := ResourceSaver.save(box, path, ResourceSaver.FLAG_COMPRESS)
	if err != OK:
		push_warning("MeshDiskCache: could not save %s (%d)" % [path, err])
	return value
