extends RigidBody3D

var Player: CharacterBody3D


@onready var FishEnemy: PackedScene = preload("res://Scenes/EnemyFlying.tscn")

@export var health: float = 10:
	set(value):
		health = value
		$HitSFX.play()
		if value <= 0:
			$HitSFX.play()
			ScoreApi.add_score(3, "Killed a Spawner")
			die()
@export var SPEED: float = 1

func _ready():
	add_to_group("Enemy")
	Player = get_tree().get_nodes_in_group("Player")[0]
	$SpawnTimer.start()

func _integrate_forces(state):
	if !Player:
		return
	if position.distance_to(Player.position) > 15:
		apply_force((Player.position - position) * Vector3(1, 0, 1) * SPEED)
	else:
		apply_force(-(Player.position - position) * Vector3(1, 0, 1) * SPEED)

func spawnFish() -> void:
	var newFish := FishEnemy.instantiate()
	newFish.position = position
	get_tree().get_current_scene().get_node("Enemies").add_child(newFish)

func die():
	queue_free()


func _on_spawn_timer_timeout():
	spawnFish()
	$SpawnTimer.start()
