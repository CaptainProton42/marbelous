extends Control
class_name LineDrawing2D

signal drawing_changed
signal circle_created
signal triangle_created
signal quad_created
signal shape_failed

var _current_drawing : Drawing = null

var _pen_down : bool = false
var _draw_timer : float = 0.0
var _old_pen_pos : Vector2 = Vector2(0.0, 0.0)

export var draw_interval : float = 0.01
export var draw_min_dist : float = 1

export var line_tex : Texture
export var line_width : float = 10.0

export var available_ink : float = 3000.0

export var line_color : Color

export var audio_stream : AudioStream

func _ready():
	connect("gui_input", self, "_on_gui_input")

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			_enter_draw_mode()
		else:
			if (_pen_down):
				_current_drawing._close_shape()

func _on_shape_completed(start_point : int):
	var corners = _current_drawing.get_corners()
	corners.append(_current_drawing.get_points()[_current_drawing.get_points().size() - 1])
	var corner_count = corners.size()

	var a = _current_drawing.get_area()
	var u = _current_drawing.get_circumference()
	var r = 4.0 * PI * a / (u*u)

	if (r > 0.8 and r < 1.2) or corner_count <= 2 or corner_count > 4:
		var radius = sqrt(_current_drawing.get_area(start_point) / PI)
		var position = _current_drawing.get_com(start_point)
		emit_signal("circle_created", position, radius)
	elif corner_count == 3:
		emit_signal("triangle_created", corners)
	elif corner_count == 4:	
		emit_signal("quad_created", corners)

	_exit_draw_mode()

func _on_shape_failed():
	_exit_draw_mode()
	emit_signal("shape_failed")
		
func _enter_draw_mode():
	_pen_down = true
	_current_drawing = Drawing.new()
	_current_drawing._line_width = line_width
	_current_drawing._line_color = line_color
	_current_drawing.connect("shape_completed", self, "_on_shape_completed")
	_current_drawing.connect("shape_failed", self, "_on_shape_failed")
	add_child(_current_drawing.get_mesh())

func _exit_draw_mode():
	_pen_down = false
	clear_drawing()

func _process(delta):
	if _pen_down:
		if _draw_timer > draw_interval:
			var cur_pen_pos : Vector2 = get_local_mouse_position()
			if cur_pen_pos.x > rect_size.x or cur_pen_pos.y > rect_size.y or cur_pen_pos.x < 0 or cur_pen_pos.y < 0:
				_current_drawing._close_shape()
				return
			_draw_timer -= draw_interval
			if (cur_pen_pos - _old_pen_pos).length() > draw_min_dist:
				_current_drawing.append_point(cur_pen_pos)
			var dist_travelled = (cur_pen_pos - _old_pen_pos).length()
			_old_pen_pos = cur_pen_pos
	_draw_timer += delta

func clear_drawing():
	remove_child(_current_drawing.get_mesh())
	_current_drawing = null
