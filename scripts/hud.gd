extends CanvasLayer

signal start_game

@onready var lives_counter: Array[Node] = $MarginContainer/HBoxContainer/LivesCounter.get_children()
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var message: Label = $VBoxContainer/Message
@onready var start_button: TextureButton = $VBoxContainer/StartButton


func show_message(text: String):
	message.text = text
	message.show()
	$Timer.start()


func update_score(value: int):
	score_label.text = str(value)

func update_lives(value: int):
	for item in 3:
		lives_counter[item].visible = value > item


func game_over():
	show_message("Game Over")
	await $Timer.timeout
	start_button.show()


func _on_timer_timeout() -> void:
	message.hide()
	message.text = ""


func _on_start_button_pressed() -> void:
	start_button.hide()
	start_game.emit()
