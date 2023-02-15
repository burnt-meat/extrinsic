extends RigidBody3D

var Player: CharacterBody3D

@export var health: float = 2:
	set(value):
		health = value
		if value <= 0:
			ScoreApi.add_score(1, "Killed a fish")
			die()
@export var SPEED: float = 5

@onready var Ray: RayCast3D = $Ray

func _enter_tree():
	add_to_group("Enemy")
	Player = get_tree().get_nodes_in_group("Player")[0]

func _integrate_forces(state):
	if !Player:
		return
	look_at(Player.position)
	apply_force((Player.position - position) * Vector3(1, 0, 1) * SPEED)
	
	if not Ray.is_colliding():
		return
		
	var collider = Ray.get_collider()
	
	if not collider:
		return
	
	if collider.is_in_group("Player"):
		collider.health -=1

func die():
	queue_free()
