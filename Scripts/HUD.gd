extends Control

@onready var ReloadTimer: ProgressBar = %ReloadTimer
@onready var ReloadPoll: Timer = $ReloadPoll
@onready var WeaponHolder: Node3D = %WeaponHolder
@onready var ScoreCounter: RichTextLabel = $Score/ScoreCounter
@onready var ReasonShower: RichTextLabel = $Score/ReasonShower
@onready var ScoreIncrementShower: RichTextLabel = $Score/ScoreIncrementShower
@onready var AP: AnimationPlayer = $AnimationPlayer

var entries_to_show: Array = []

func _ready():
	GunApi.connect("started_cooldown", _change_weapon_reloadtimer)
	ScoreApi.connect("score_changed", _update_score_counter)
	_update_score_counter()


func _update_score_counter():
	var entry := ScoreApi.get_latest_ledger_entry()
	
	print("updating score counter")
	print(entry)
	
	if not entry.has("amount"):
		return
	
	# TODO: localization
	ReasonShower.text = entry.reason
	ScoreIncrementShower.text = "%s+" % entry.amount
	AP.play_backwards("Merge")
	await get_tree().create_timer(1).timeout
	AP.play("Merge")
	

func _change_weapon_reloadtimer(id: int):
	if GunApi.on_cooldown[id].time_left > 0:
		ReloadTimer.value = (GunApi.on_cooldown[id].time_left / GunApi.loaded_weapons[id].cooldown) * 100
	else:
		ReloadTimer.value = 0
	ReloadPoll.start()
	

func _on_reload_poll_timeout():
	_change_weapon_reloadtimer(WeaponHolder.current_weapon)
