extends Node

var loadedWeapons: Array[Resource] = []

signal switched_weapon(res: Resource)

var currentWeapon: int = 0

func _get_weapon_holder() -> Node3D:
	return get_tree().get_nodes_in_group("Player")[0].get_node("%WeaponHolder")

# Switches the weapon to an ID, returned by the create_weapon function.
func switch_weapon(id: int) -> void:
	var holder := _get_weapon_holder()
	var w := loadedWeapons[id]
	holder.damage = w.damage
	holder.cooldown = w.cooldown
	for child in holder.get_children():
		child.queue_free()
	holder.add_child(w.modelScene.instantiate())
	holder.effects = w.effects
	holder.currentWeapon = id
	emit_signal("switched_weapon", w)

# TODO: Dict -> Resource, needed for changing meshes etc.
# Creates a weapon, and returns it's ID in the GunAPI register
func create_weapon(name: String, damage: float, cooldown: float, effects: Array, scenePath: String) -> int:
	var holder := _get_weapon_holder()
	var weapon := Weapon.new()
	weapon.name = name
	weapon.damage = damage
	weapon.cooldown = cooldown
	weapon.effects = effects
	weapon.modelScene = load(scenePath)
	loadedWeapons.append(weapon)
	holder.onCooldown[loadedWeapons.size() - 1] = false
	
	return loadedWeapons.size() - 1
