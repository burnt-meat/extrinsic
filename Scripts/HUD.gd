extends Control

@onready var ReloadTimer: ProgressBar = %ReloadTimer
@onready var ReloadPoll: Timer = $ReloadPoll
@onready var WeaponHolder: Node3D = %WeaponHolder
@onready var ScoreCounter: RichTextLabel = $Score/ScoreCounter
@onready var ReasonShower: RichTextLabel = $Score/ReasonShower
@onready var ScoreIncrementShower: RichTextLabel = $Score/ScoreIncrementShower
@onready var AP: AnimationPlayer = $AnimationPlayer
@onready var AmmoCounter: RichTextLabel = $AmmoCounter
@onready var HealthMeter: ProgressBar = %HealthMeter

func _ready():
	GunApi.connect("started_cooldown", _change_weapon_reloadtimer)
	ScoreApi.connect("score_changed", _update_score_counter)
	_update_score_counter()

func died():
	ScoreCounter.visible = false
	ReasonShower.visible = false
	ScoreIncrementShower.visible = false
	ReloadTimer.visible = false
	$CrossHair.visible = false
	AmmoCounter.visible = false
	HealthMeter.visible = false
	await get_tree().create_timer(5).timeout
	AP.play("L")
	await get_tree().create_timer(5).timeout
	get_tree().quit()


func _update_score_counter():
	var entry := ScoreApi.get_latest_ledger_entry()
	
	if not entry.has("amount"):
		return
	
	# TODO: localization
	ReasonShower.text = "[right]%s[/right]" % entry.reason.to_upper()
	ScoreIncrementShower.text = "%s+" % entry.amount
	AP.play_backwards("Merge")
	await get_tree().create_timer(1).timeout
	AP.play("Merge")
	await AP.animation_finished
	ScoreCounter.text = "%04d" % ScoreApi.score

func _change_weapon_reloadtimer(id: int):
	if GunApi.on_cooldown[id].time_left > 0:
		ReloadTimer.value = (GunApi.on_cooldown[id].time_left / GunApi.loaded_weapons[id].cooldown) * 100
	else:
		ReloadTimer.value = 0
	ReloadPoll.start()
	

func _update_health_meter(health: int):
	HealthMeter.value = health

func _on_reload_poll_timeout():
	_change_weapon_reloadtimer(WeaponHolder.current_weapon)
