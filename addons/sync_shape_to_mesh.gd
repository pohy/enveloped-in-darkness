@tool
extends Node3D

@export var mesh: MeshInstance3D = null

@export var sync: bool:
	get:
		return false
	set(value):
		_sync()

var _shape: Shape3D = null


func _ready() -> void:
	_sync()


func _sync() -> void:
	if not mesh is MeshInstance3D:
		mesh = get_parent().get_node("MeshInstance3D")

	if not mesh:
		printerr("No MeshInstance3D found")
		return

	if not "shape" in self:
		printerr("This node must be a CollisionShape3D or ShapeCast3D node")
		return

	position = mesh.position

	if mesh.mesh is BoxMesh:
		_shape = BoxShape3D.new()
		_shape.size = mesh.mesh.size
		self.shape = _shape
	elif mesh.mesh is SphereMesh:
		_shape = SphereShape3D.new()
		_shape.radius = mesh.mesh.radius
		self.shape = _shape
	elif mesh.mesh is CapsuleMesh:
		_shape = CapsuleShape3D.new()
		_shape.radius = mesh.mesh.radius
		_shape.height = mesh.mesh.height
		self.shape = _shape
	elif mesh.mesh is CylinderMesh:
		_shape = CylinderShape3D.new()
		_shape.radius = mesh.mesh.bottom_radius
		_shape.height = mesh.mesh.height
		self.shape = _shape
	# elif mesh.mesh is ConvexPolygonShape:
	# 	_shape = ConvexPolygonShape3D.new()
	# 	_shape.points = mesh.mesh.points
	# 	shape = _shape
	# elif mesh.mesh is ConcavePolygonShape:
	# 	_shape = ConcavePolygonShape3D.new()
	# 	_shape.triangles = mesh.mesh.triangles
	# 	shape = _shape
	else:
		printerr("Mesh type not supported")
