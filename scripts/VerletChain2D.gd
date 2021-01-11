extends Node2D

# Verlet integration chain.

signal updated

export var polygon: PoolVector2Array = []
export var gravity: Vector2 = Vector2(0.0, 500.0)
export var drag: float = 0.99
export var tautness: float = 0.0

var _vertices: Array = []
var _links: Array = []
var _constraints: Array = []

func get_vertices() -> PoolVector2Array:
	var p: PoolVector2Array = PoolVector2Array()
	p.resize(_vertices.size())
	for i in range(_vertices.size()):
		p[i] = _vertices[i].p
	return p

class Vertex:
	var p: Vector2
	var pl: Vector2
	var fixed: bool = false

	func _init(pos: Vector2):
		p = pos
		pl = pos

class Link:
	var v1: Vertex
	var v2: Vertex
	var length: float = 0.0

	func _init(p_v1: Vertex, p_v2: Vertex):
		v1 = p_v1
		v2 = p_v2
		length = (v1.p - v2.p).length()

func _ready() -> void:
	for i in range(polygon.size()):
		_vertices.append(Vertex.new(polygon[i]))

	for i in range(_vertices.size() - 1):
		_links.append(Link.new(_vertices[i], _vertices[i+1]))

	_vertices[0].fixed = true
	_vertices.back().fixed = true

func _physics_process(delta: float) -> void:
	var delta2: float = delta * delta

	# Simulation
	for i in range(_vertices.size()):
		var v: Vertex = _vertices[i]
		var dp: Vector2 = (v.p - v.pl) * drag
		v.pl = v.p
		v.p += dp
		if not v.fixed:
			v.p += gravity * delta2

	# Segment constraints
	for i in range(_links.size()):
		var l: Link = _links[i]
		var dp: Vector2 = l.v2.p - l.v1.p
		var ll: float = dp.length()
		var fr: float = (1.0 - pow(tautness, 16.0)) * l.length - ll
		dp = dp.normalized() * fr * drag
		if l.v2.fixed and not l.v1.fixed:
			l.v1.p -= dp
		elif l.v1.fixed and not l.v2.fixed:
			l.v2.p += dp
		else:
			l.v1.p -= 0.5 * dp
			l.v2.p += 0.5 * dp

	emit_signal("updated")
	update()

func _draw():
	for i in range(_links.size()):
		var l = _links[i]
		draw_line(l.v1.p, l.v2.p, Color(1.0, 1.0, 1.0), 3.0)
