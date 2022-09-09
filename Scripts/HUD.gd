extends Control

@onready var ReloadTimer: ProgressBar = %ReloadTimer
@onready var ReloadPoll: Timer = $ReloadPoll
@onready var WeaponHolder: Node3D = %WeaponHolder

func _ready():
	GunApi.connect("started_cooldown", _change_weapon_reloadtimer)


func _change_weapon_reloadtimer(id: int):
	if GunApi.on_cooldown[id].time_left > 0:
		ReloadTimer.value = (GunApi.on_cooldown[id].time_left / GunApi.loaded_weapons[id].cooldown) * 100
	else:
		ReloadTimer.value = 0
	ReloadPoll.start()
	

func _on_reload_poll_timeout():
	_change_weapon_reloadtimer(WeaponHolder.current_weapon)
