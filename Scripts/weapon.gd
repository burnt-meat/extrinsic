extends Node3D

@onready var Ray: RayCast3D = $"../Camera/Ray"
@onready var AP: AnimationPlayer = $"../AnimationPlayer"

var damage: float = 1
var cooldown: float = 1

var onCooldown: bool = false

func _process(delta):
	if Input.is_action_just_pressed("shoot") and not onCooldown:
		onCooldown = true
		get_tree().create_timer(cooldown).connect("timeout", func(): onCooldown = false)
		AP.stop()
		AP.play("shoot")
		if Ray.is_colliding() and Ray.get_collider().is_in_group("Enemy"):
			Ray.get_collider().health -= damage
