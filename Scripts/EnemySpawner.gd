extends RigidDynamicBody3D

var Player: CharacterBody3D


@onready var FishEnemy: PackedScene = preload("res://Scenes/EnemyFlying.tscn")


@export var health: float = 20:
	set(value):
		health = value
		if value <= 0:
			die()
@export var SPEED: float = 1

func _ready():
	add_to_group("Enemy")
	Player = get_tree().get_nodes_in_group("Player")[0]
	$SpawnTimer.start()

func _integrate_forces(state):
	apply_force((Player.position - position) * Vector3(1, 0, 1) * 5)

func spawnFish() -> void:
	var newFish := FishEnemy.instantiate()
	newFish.position = position
	await get_tree().create_timer(1).timeout
	get_tree().get_current_scene().get_node("Enemies").add_child(newFish)

func die():
	queue_free()


func _on_spawn_timer_timeout():
	spawnFish()
	$SpawnTimer.start()
