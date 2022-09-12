extends Node

signal score_changed

var id: int = 0

var ledger := {}

var score: int

func add_score(amount: int, reason: String):
	ledger[id] = { "amount": amount, "reason": reason }
	id += 1
	score += amount
	emit_signal("score_changed")

func get_latest_ledger_entry() -> Dictionary:
	if ledger.size() > 0:
		return ledger.values().back()
	else:
		return {}
