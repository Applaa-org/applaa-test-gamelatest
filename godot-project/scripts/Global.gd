extends Node

var score: int = 0
const VICTORY_SCORE: int = 5000

func add_score(points: int):
	score += points

func reset_score():
	score = 0