extends Node3D

@onready var Ray: RayCast3D = $"../Camera/Ray"
@onready var Player: CharacterBody3D = $"../.."
@onready var Flash: Node3D = $Flash
@onready var FlashTimer: Timer = $Flash/Timer
@onready var GunSFX: AudioStreamPlayer = $GunSFX

var damage: float = 0
var cooldown: float = .1
var effects: Array[Resource] = []


var current_weapon: int
var full_auto: bool

var ammo := {}
var reloading := {}


func _ready():
	Ray.add_exception(Player)

func _process(delta):
	if Input.is_action_just_pressed("reload"):
		reload(GunApi.loaded_weapons[current_weapon].reload_time, current_weapon)
	
	if full_auto:
		if Input.is_action_pressed("shoot") and GunApi.can_shoot[current_weapon]:
			shoot()
	else:
		if Input.is_action_just_pressed("shoot") and GunApi.can_shoot[current_weapon]:
			shoot()

func reload(time: float, id: int):
	reloading[id] = true
	await get_tree().create_timer(time).timeout
	ammo[id].ammo_left = ammo[id].ammo_max
	print("reloaded " + str(id))
	reloading[id] = false

func shoot() -> void:
	if ammo[current_weapon].ammo_left <= 0 and not reloading[current_weapon]:
		reload(GunApi.loaded_weapons[current_weapon].reload_time, current_weapon)
	if ammo[current_weapon].ammo_left <= 0 or reloading[current_weapon]:
		return
	GunApi.start_cooldown(current_weapon)
	GunSFX.play()
	flash()
	for effect in effects:
		await effect.trigger(self, Ray)
	
	if not Ray.is_colliding():
		return
	
	if Ray.get_collider().is_in_group("Enemy"):
		Ray.get_collider().health -= damage
	ammo[current_weapon].ammo_left -= 1
	

func flash():
	Flash.visible = true
	FlashTimer.start()


func _on_timer_timeout():
	Flash.visible = false
