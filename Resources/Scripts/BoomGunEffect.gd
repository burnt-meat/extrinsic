extends GunEffect
class_name BoomGunEffect

func trigger(weapon: Node3D, Ray: RayCast3D):
	var Explosion: PackedScene = load("res://Scenes/Explosion.tscn")
	var e := Explosion.instantiate()
	e.position = Ray.get_collision_point()
	weapon.get_tree().get_current_scene().add_child(e)
