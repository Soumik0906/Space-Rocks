extends Area2D

@export var speed: int = 150
@export var rotation_speed: int = 120
@export var health: int = 3
@export var bullet_spread: float = 0.2

var bullet_scene: PackedScene = preload("res://scenes/enemy_bullet.tscn")
var follow = PathFollow2D.new()
var target = null


func _ready() -> void:
	$Sprite2D.frame = randi() % 3
	var path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()]
	path.add_child(follow)
	follow.loop = false


func _physics_process(delta: float) -> void:
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta
	position = follow.global_position
	if follow.progress_ratio >= 1:
		queue_free()


func shoot() -> void:
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread))
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(global_position, dir)


func _on_gun_cool_down_timeout() -> void:
	#shoot()
	shoot_pulse(3, 0.15)


func shoot_pulse(n: int, delay: float) -> void:
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout


func take_damage(amount: float) -> void:
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()


func explode() -> void:
	speed = 0
	$GunCoolDown.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("rocks"):
		return
	explode()
