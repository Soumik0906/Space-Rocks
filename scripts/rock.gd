extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cshape: CollisionShape2D = $CollisionShape2D

var screen_size: Vector2 = Vector2.ZERO
var size: int
var radius: int
var scale_factor: float = 0.2


func start(_position, _velocity, _size):
	position = _position
	size = _size
	mass = 1.5 * size
	sprite_2d.scale = Vector2.ONE * scale_factor * size
	radius = int(sprite_2d.texture.get_size().x / 2 * sprite_2d.scale.x)
	
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = radius
	cshape.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)


func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var xform: Transform2D = physics_state.transform
	xform.origin.x += wrapf(xform.origin.x, 0 - radius, screen_size.x + radius)
	xform.origin.y += wrapf(xform.origin.y, 0 - radius, screen_size.y + radius)
	physics_state.transform = xform
