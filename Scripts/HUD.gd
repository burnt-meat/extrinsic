extends Control

@onready var ReloadTimer: ProgressBar = %ReloadTimer
@onready var ReloadPoll: Timer = $ReloadPoll
@onready var WeaponHolder: Node3D = %WeaponHolder

func _ready():
	GunApi.connect("started_cooldown", _change_weapon_reloadtimer)


func _change_weapon_reloadtimer(id: int):
	if GunApi.onCooldown[id].time_left > 0:
		ReloadTimer.value = (GunApi.onCooldown[id].time_left / GunApi.loadedWeapons[id].cooldown) * 100
	else:
		ReloadTimer.value = 0
	ReloadPoll.start()
	

func _on_reload_poll_timeout():
	_change_weapon_reloadtimer(WeaponHolder.currentWeapon)
