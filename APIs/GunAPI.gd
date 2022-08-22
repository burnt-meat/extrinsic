extends Node

var loadedWeapons: Array = []

var currentWeapon: int = 0

func _get_weapon_holder() -> Node3D:
	return get_tree().get_nodes_in_group("Player")[0].get_node("%WeaponHolder")

# Switches the weapon to an ID, returned by the create_weapon function.
func switch_weapon(id: int) -> void:
	_get_weapon_holder().damage = loadedWeapons[id].damage
	_get_weapon_holder().damage = loadedWeapons[id].cooldown

# TODO: Dict -> Resource, needed for changing meshes etc.
# Creates a weapon, and returns it's ID in the GunAPI register
func create_weapon(name: String, damage: float, cooldown: float, effects: Array) -> int:
	var weapon := {
		"name": name,
		"damage": damage,
		"cooldown": cooldown,
		"effects": effects
	}
	loadedWeapons.append(weapon)
	
	return loadedWeapons.size() - 1
