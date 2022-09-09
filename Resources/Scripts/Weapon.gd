extends Resource
class_name Weapon

@export var id: int
@export var name: String
@export var damage: float
@export var cooldown: float
@export var reload_time: float
@export var full_auto: bool
@export var effects: Array[Resource]
@export var model_scene: PackedScene
