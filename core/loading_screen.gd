class_name LoadingScreen
extends CanvasLayer

## Drawn on the very first frame, before any hall exists.

var _status: Label
var _bar: ColorRect

func _ready() -> void:
	layer = 100
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.025)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var title := _centered("Gem Gallery", 56, Color(0.95, 0.88, 0.7), Vector2(-300, -110), Vector2(600, 70))
	title.name = "Title"
	_status = _centered("", 26, Color(0.85, 0.85, 0.88), Vector2(-450, -10), Vector2(900, 40))
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.12, 0.12, 0.14)
	bar_bg.set_anchors_preset(Control.PRESET_CENTER)
	bar_bg.position = Vector2(-300, 50)
	bar_bg.size = Vector2(600, 10)
	add_child(bar_bg)
	var note := _centered("The first launch on a new PC can take a minute while the graphics card prepares its shaders.",
		16, Color(0.6, 0.6, 0.64), Vector2(-450, 90), Vector2(900, 30))
	note.name = "Note"
	_bar = ColorRect.new()
	_bar.color = Color(0.85, 0.68, 0.32)
	_bar.set_anchors_preset(Control.PRESET_CENTER)
	_bar.position = Vector2(-300, 50)
	_bar.size = Vector2(0, 10)
	add_child(_bar)

func _centered(text: String, size: int, col: Color, pos: Vector2, sz: Vector2) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.set_anchors_preset(Control.PRESET_CENTER)
	l.position = pos
	l.size = sz
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func set_progress(text: String, frac: float) -> void:
	_status.text = text
	_bar.size.x = 600.0 * clampf(frac, 0.0, 1.0)
