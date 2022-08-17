extends Node3D


@onready var Ray: RayCast3D = $"../Camera/Ray"
@onready var AP: AnimationPlayer = $"../AnimationPlayer"

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		AP.stop()
		AP.play("shoot")
		if Ray.is_colliding() and Ray.get_collider().is_in_group("Enemy"):
			Ray.get_collider().queue_free()
