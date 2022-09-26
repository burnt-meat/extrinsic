# it works, DON'T TOUCH IT
# PLEASE

extends Node

var loaded_weapons: Array[Resource] = []

var on_cooldown := {}
var can_shoot := {}

signal switched_weapon(res: Resource, id: int)
signal started_cooldown(id: int)

var currentWeapon: int = 0

func _get_weapon_holder() -> Node3D:
	return get_tree().get_nodes_in_group("Player")[0].get_node("%WeaponHolder")

# Switches the weapon to an ID, returned by the create_weapon function.
func switch_weapon(id: int) -> void:
	var holder := _get_weapon_holder()
	var w := loaded_weapons[id]
	holder.damage = w.damage
	holder.cooldown = w.cooldown
	for child in holder.get_children():
		if child.is_in_group("model"):
			child.queue_free()
	var gun_model = w.model_scene.instantiate()
	gun_model.add_to_group("model")
	holder.add_child(gun_model)
	holder.effects = w.effects
	holder.full_auto = w.full_auto
	holder.current_weapon = id
	emit_signal("switched_weapon", w, id)

# Starts a cooldown on a weapon
func start_cooldown(id: int):
	var w := loaded_weapons[id]
	can_shoot[w.id] = false
	var t := get_tree().create_timer(w.cooldown)
	t.connect("timeout", func(): can_shoot[w.id] = true)
	on_cooldown[w.id] = t
	emit_signal("started_cooldown", id)


# Creates a weapon, and returns it's ID in the GunAPI register
func create_weapon(p_name: String, damage: float, cooldown: float, mag_size: int, reload_time: float, full_auto: bool, effects: Array, scene_path: String) -> int:
	var holder := _get_weapon_holder()
	var weapon := Weapon.new()
	weapon.name = p_name
	weapon.damage = damage
	weapon.cooldown = cooldown
	weapon.effects = effects
	weapon.model_scene = load(scene_path)
	weapon.full_auto = full_auto
	weapon.id = loaded_weapons.size()
	weapon.reload_time = reload_time
	on_cooldown[weapon.id] = Timer.new()
	can_shoot[weapon.id] = true
	holder.ammo[weapon.id] = { "ammo_left": mag_size, "ammo_max": mag_size }
	holder.reloading[weapon.id] = false
	loaded_weapons.append(weapon)
	
	return weapon.id
