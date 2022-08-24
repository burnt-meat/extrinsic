extends Node

signal score_changed

var score: int:
	set(val):
		score = val
		emit_signal("score_changed")

func add_score(amount: int, reason: String):
	score += amount
