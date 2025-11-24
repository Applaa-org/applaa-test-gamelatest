extends Node2D

@onready var player: Player = $Player
@onready var score_label: Label = $UI/MarginContainer/ScoreLabel
@onready var camera: Camera2D = $Player/Camera2D

var distance_traveled: float = 0.0

func _ready():
	Global.reset_score()
	player.hit_obstacle.connect(_on_player_hit_obstacle)
	update_score_label()

func _physics_process(delta: float):
	# Score is based on how far the car moves forward
	if player.velocity.y < 0: # Moving "up" in 2D space
		distance_traveled += -player.velocity.y * delta * 0.1
		Global.score = int(distance_traveled)
		update_score_label()
	
	# Check for victory condition
	if Global.score >= Global.VICTORY_SCORE:
		get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")

func update_score_label():
	score_label.text = "Score: %d" % Global.score

func _on_player_hit_obstacle():
	# Wait a moment before changing scenes to let the player see what happened
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")