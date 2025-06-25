extends Node


@export var rock_scene: PackedScene = preload("res://scenes/rock.tscn")

var screen_size: Vector2


func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	for i in 3:
		spawn_rock(3)


func spawn_rock(size: int, pos=null, vel=null) -> void:
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	var r = rock_scene.instantiate()
	r.screen_size = screen_size
	call_deferred("add_child", r)
	#r.call_deferred("start", pos, vel, size)
	r.start(pos, vel, size)

func explode() -> void:
	pass
