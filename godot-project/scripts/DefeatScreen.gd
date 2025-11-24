extends Control

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel

func _ready():
	score_label.text = "Final Score: %d" % Global.score
	$MarginContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$MarginContainer/VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	$MarginContainer/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)

func _on_restart_pressed():
	Global.reset_score()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_pressed():
	Global.reset_score()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()