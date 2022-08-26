extends Node3D

@onready var SpawnTimer: Timer = $SpawnTimer
@onready var FishEnemy: PackedScene = preload("res://Scenes/EnemyFlying.tscn")
@onready var UFO: PackedScene = preload("res://Scenes/EnemySpawner.tscn")
@onready var EnemyController: Node3D = $Enemies
@onready var Sun: DirectionalLight3D = $Sun
@onready var Player: CharacterBody3D = $Player

func _process(delta):
	var ttransform := Sun.transform.looking_at(Player.position)
	print(Sun.transform.looking_at(Player.position))
	Sun.transform = Sun.transform.basis.slerp(ttransform.basis, .5)

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
	
