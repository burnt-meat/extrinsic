extends Node

var loadedWeapons: Array[Resource] = []

var onCooldown := {}
var canShoot := {}

signal switched_weapon(res: Resource, id: int)
signal started_cooldown(id: int)

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
		if child.is_in_group("model"):
			child.queue_free()
	var gun_model = w.modelScene.instantiate()
	gun_model.add_to_group("model")
	holder.add_child(gun_model)
	holder.effects = w.effects
	holder.currentWeapon = id
	emit_signal("switched_weapon", w)

# Starts a cooldown on a weapon
func startCooldown(id: int):
	var w := loadedWeapons[id]
	canShoot[w.id] = false
	var t := get_tree().create_timer(w.cooldown)
	t.connect("timeout", func(): canShoot[w.id] = true)
	onCooldown[w.id] = t
	emit_signal("started_cooldown", id)


# Creates a weapon, and returns it's ID in the GunAPI register
func create_weapon(name: String, damage: float, cooldown: float, effects: Array, scenePath: String) -> int:
	var holder := _get_weapon_holder()
	var weapon := Weapon.new()
	weapon.name = name
	weapon.damage = damage
	weapon.cooldown = cooldown
	weapon.effects = effects
	weapon.modelScene = load(scenePath)
	weapon.modelScene
	weapon.id = loadedWeapons.size()
	onCooldown[weapon.id] = Timer.new()
	canShoot[weapon.id] = true
	loadedWeapons.append(weapon)
	
	return weapon.id
