extends Node3D

@onready var SpawnTimer: Timer = $SpawnTimer
@onready var FishEnemy: PackedScene = preload("res://Scenes/EnemyFlying.tscn")
@onready var UFO: PackedScene = preload("res://Scenes/EnemySpawner.tscn")
@onready var EnemyController: Node3D = $Enemies
@onready var Sun: DirectionalLight3D = $Sun
@onready var Player: CharacterBody3D = $Player

func spawnFish() -> void:
	var newFish := FishEnemy.instantiate()
	newFish.position = Vector3(0, 10, 0)
	EnemyController.add_child(newFish)

func spawnUFO() -> void:
	var newUFO := UFO.instantiate()
	newUFO.position = Vector3(0, 10, 0)
	EnemyController.add_child(newUFO)

func _spawnTick() -> void:
	spawnUFO()
	
