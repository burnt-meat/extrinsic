extends Node3D

@onready var Ray: RayCast3D = $"../Camera/Ray"
@onready var AP: AnimationPlayer = $"../AnimationPlayer"
@onready var Player: CharacterBody3D = $"../.."
@onready var Flash: Sprite3D = $Flash
@onready var FlashTimer: Timer = $Flash/Timer
@onready var GunSFX: AudioStreamPlayer = $GunSFX


var damage: float = 0
var cooldown: float = .1
var effects: Array[Resource] = []

var currentWeapon: int

func _ready():
	Ray.add_exception(Player)

func _process(delta):
	if Input.is_action_just_pressed("shoot") and GunApi.canShoot[currentWeapon]:
		GunApi.startCooldown(currentWeapon)
		GunSFX.play()
		AP.stop()
		AP.play("shoot")
		flash()
		for effect in effects:
			await effect.trigger(self, Ray)
		
		if not Ray.is_colliding():
			return
		
		if Ray.get_collider().is_in_group("Enemy"):
			Ray.get_collider().health -= damage


func flash():
	Flash.visible = true
	FlashTimer.start()


func _on_timer_timeout():
	Flash.visible = false
