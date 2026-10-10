class_name GalleryHud
extends CanvasLayer

## Controls hint, click-to-look prompt, crosshair, the inspect caption and a
## small "streaming" note while a hall loads in the background. Every control
## ignores the mouse so it can never swallow look input.

var click_hint: Label
var inspect_label: Label
var stream_label: Label

func _ready() -> void:
	var hint := _label("WASD walk · Shift run · Space jump · Mouse look · E pick up a gem · F labels · Esc release mouse · Q quit", 16, Color(0.85, 0.85, 0.85, 0.8))
	hint.position = Vector2(16, 12)
	click_hint = _label("Click to look around  (Esc or Tab frees the mouse)", 28, Color(1, 1, 1, 0.9))
	click_hint.set_anchors_preset(Control.PRESET_CENTER)
	click_hint.position = Vector2(-330, 40)
	inspect_label = _label("", 22, Color(1, 1, 1, 0.92))
	inspect_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	inspect_label.position += Vector2(-420, -90)
	inspect_label.visible = false
	stream_label = _label("", 16, Color(0.9, 0.8, 0.55, 0.85))
	stream_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	stream_label.position += Vector2(16, -34)
	var dot := ColorRect.new()
	dot.color = Color(1, 1, 1, 0.5)
	dot.size = Vector2(4, 4)
	dot.set_anchors_preset(Control.PRESET_CENTER)
	dot.position -= Vector2(2, 2)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dot)

func _label(text: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func on_capture_changed(captured: bool) -> void:
	click_hint.visible = not captured

func set_streaming(text: String) -> void:
	stream_label.text = text
	stream_label.visible = text != ""
