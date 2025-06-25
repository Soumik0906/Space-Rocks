extends RigidBody2D

@onready var cshape: CollisionShape2D = $CollisionShape2D
@onready var gun_cooldown: Timer = $GunCooldown

@export var engine_power: int = 500
@export var spin_power: int = 8000
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
@export var fire_rate: float = 0.25

enum { INIT, ALIVE, INVULNERABLE, DEAD }
var state = INIT
var thrust: Vector2 = Vector2.ZERO
var rotation_dir: float = 0.0
var screen_size: Vector2
var can_shoot: bool = true


func _ready() -> void:
	change_state(ALIVE)
	screen_size = get_viewport_rect().size
	gun_cooldown.wait_time = fire_rate

func change_state(new_state) -> void:
	match new_state:
		INIT:
			cshape.set_deferred("disabled", true)
		ALIVE:
			cshape.set_deferred("disabled", false)
		INVULNERABLE:
			cshape.set_deferred("disabled", true)
		DEAD:
			cshape.set_deferred("disabled", true)
	state = new_state


func _process(delta: float) -> void:
	get_input()


func get_input() -> void:
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()


func _physics_process(delta: float) -> void:
	constant_force = thrust
	constant_torque = rotation_dir * spin_power


func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screen_size.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screen_size.y)
	physics_state.transform = xform


func shoot() -> void:
	if state == INVULNERABLE:
		return
	can_shoot = false
	gun_cooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)


func _on_gun_cooldown_timeout() -> void:
	can_shoot = true
