extends RigidBody2D

signal exploded

@onready var cshape: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var screen_size: Vector2 = Vector2.ZERO
var size: int
var radius: int
var scale_factor: float = 0.2


func start(_position, _velocity, _size):
	if not sprite_2d: sprite_2d = $Sprite2D
	if not cshape: cshape = $CollisionShape2D
	
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
	
	$Explosion.scale = Vector2.ONE * size * 0.75


func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var xform: Transform2D = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screen_size.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screen_size.y + radius)
	physics_state.transform = xform


func explode() -> void:
	cshape.set_deferred("disabled", true)
	sprite_2d.hide()
	$Explosion/AnimationPlayer.play("explosion")
	$Explosion.show()
	exploded.emit(size, radius, position, linear_velocity)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
