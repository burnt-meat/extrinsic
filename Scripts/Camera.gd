extends Camera3D

var decay := 0.01

@export var noise: FastNoiseLite

@onready var initial_rotation := rotation

@onready var initial_position := position

var multiplier := 10

var trauma := 1.0

var time: float

func _process(delta):
	time += delta
	trauma = clamp(trauma, 0, 1)
	
	rotation.x = initial_rotation.x + noise.get_noise_1d(time) * trauma * trauma
	rotation.y = initial_rotation.y + noise.get_noise_1d(time + 1) * trauma * trauma
	rotation.z = initial_rotation.z + noise.get_noise_1d(time + 2) * trauma * trauma
	
	position.x = initial_position.x + noise.get_noise_1d(time) * trauma * trauma
	position.y = initial_position.y + noise.get_noise_1d(time - 1) * trauma * trauma
	position.z = initial_position.z + noise.get_noise_1d(time - 2) * trauma * trauma
	
	
	
	trauma -= decay
	
	noise.seed += 1
