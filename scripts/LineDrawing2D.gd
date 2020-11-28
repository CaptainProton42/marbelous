extends Control
class_name LineDrawing2D

signal drawing_changed

var _meshes : Array = []
var _current_drawing : Drawing = null

var _pen_down : bool = false
var _draw_timer : float = 0.0
var _old_pen_pos : Vector2 = Vector2(0.0, 0.0)

var _spent_ink : float = 0.0

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
	_exit_draw_mode()
	var corners = _current_drawing.get_corners()
	corners.append(_current_drawing.get_points()[_current_drawing.get_points().size() - 1])
	var corner_count = corners.size()

	var a = _current_drawing.get_area()
	var u = _current_drawing.get_circumference()
	var r = 4.0 * PI * a / (u*u)

	if (r > 0.8 and r < 1.2) or corner_count <= 2 or corner_count > 4:
		var circ = CollisionShape2D.new()
		circ.shape = CircleShape2D.new()
		circ.shape.radius = sqrt(_current_drawing.get_area(start_point) / PI)
		circ.position = _current_drawing.get_com(start_point)
		add_child(circ)
	elif corner_count == 3:
		var poly = CollisionPolygon2D.new()
		poly.polygon = corners
		add_child(poly)
	elif corner_count == 4:	
		var poly = CollisionPolygon2D.new()
		poly.polygon = corners
		add_child(poly)
		
func _enter_draw_mode():
	if _spent_ink < available_ink:
		_pen_down = true
		_current_drawing = Drawing.new()
		_current_drawing._line_width = line_width
		_current_drawing._line_color = line_color
		_current_drawing.connect("shape_completed", self, "_on_shape_completed")
		add_child(_current_drawing.get_mesh())

func _exit_draw_mode():
	_pen_down = false

func _process(delta):
	if _pen_down:
		if _spent_ink < available_ink:
			if _draw_timer > draw_interval:
				var cur_pen_pos : Vector2 = get_local_mouse_position()
				if cur_pen_pos.x > rect_size.x or cur_pen_pos.y > rect_size.y or cur_pen_pos.x < 0 or cur_pen_pos.y < 0:
					_current_drawing._close_shape()
					return
				_draw_timer -= draw_interval
				if (cur_pen_pos - _old_pen_pos).length() > draw_min_dist:
					_current_drawing.append_point(cur_pen_pos)
					emit_signal("drawing_changed")
				var dist_travelled = (cur_pen_pos - _old_pen_pos).length()
				_spent_ink += dist_travelled
				_old_pen_pos = cur_pen_pos
		else:
			_current_drawing._close_shape()
	_draw_timer += delta

func clear_drawing():
	_spent_ink = 0
	emit_signal("drawing_changed")

func get_remaining_ink_percentage() -> float:
	return (available_ink - _spent_ink) / available_ink * 100