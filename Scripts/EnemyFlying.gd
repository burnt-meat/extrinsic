extends RigidDynamicBody3D

var Player: CharacterBody3D

@export var health: float = 2:
	set(value):
		health = value
		if value <= 0:
			die() 
@export var SPEED: float = 1

func _ready():
	add_to_group("Enemy")
	Player = get_tree().get_nodes_in_group("Player")[0]
	

func _integrate_forces(state):
	apply_force((Player.position - position) * Vector3(1, 0, 1) * SPEED)
	
	look_at(Player.position)

func die():
	queue_free()
