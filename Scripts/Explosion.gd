extends Area3D

func _enter_tree():
	await get_tree().create_timer(.1).timeout
	_explode()

func _explode():
	$SFX.play()
	var space_state = get_world_3d().direct_space_state
	
	var objects := get_overlapping_bodies()
	
	var amount_hit := 0
	for object in objects:
#		var c := PhysicsRayQueryParameters3D.create(position, object.position)
#		var result = space_state.intersect_ray(c)
#		print(result)
		if object.is_in_group("Enemy"):
			object.health -= 3
		if object is RigidBody3D:
			object.apply_impulse((object.position - position) * 5)
			ScoreApi.add_score(10, "Enemy knocked back!")
			amount_hit += 1
		if object is CharacterBody3D:
			object.velocity = (object.position - position) * 5
			ScoreApi.add_score(3, "Explosion jump!")
			amount_hit += 1
	
	if amount_hit > 5:
		ScoreApi.add_score(20, "Multi attack!")
	
	await get_tree().create_timer(5).timeout
	queue_free()

