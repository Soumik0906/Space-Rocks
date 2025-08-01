extends Node

@onready var player: RigidBody2D = $Player

var rock_scene: PackedScene = preload("res://scenes/rock.tscn")
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")

var screen_size: Vector2
var level: int = 0
var score: int = 0
var playing: bool = false


func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size


func _process(delta: float) -> void:
	if not playing:
		return
	
	if get_tree().get_nodes_in_group("rocks").is_empty():
		new_level()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
		var message: Label = $HUD/VBoxContainer/Message
		if get_tree().paused:
			message.text = "Paused"
			message.show()
		else:
			message.text = ""
			message.hide()


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
	r.exploded.connect(self._on_rock_exploded)


func _on_rock_exploded(size, radius, pos, vel):
	if size <= 1: 
		return
	
	for offset in [-1, 1]:
		var dir = player.position.direction_to(pos).orthogonal() * offset
		var new_pos = pos + dir * radius
		var new_vel = dir * vel.length() * 1.1
		spawn_rock(size - 1, new_pos, new_vel)


func new_game() -> void:
	get_tree().call_group("rocks", "queue_free")
	level = 0
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Player.reset()
	await $HUD/Timer.timeout
	playing = true


func new_level() -> void:
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in level:
		spawn_rock(3)
	$EnemyTimer.start(randf_range(5, 10))


func game_over():
	playing = false
	$HUD.game_over()


func _on_enemy_timer_timeout() -> void:
	var e = enemy_scene.instantiate()
	add_child(e)
	e.target = $Player
	$EnemyTimer.start(randf_range(20, 40))
