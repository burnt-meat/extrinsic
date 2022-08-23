extends Area3D

func _enter_tree():
	await get_tree().create_timer(.1).timeout
	_explode()

func _explode():
	$SFX.play()
	var space_state = get_world_3d().direct_space_state
	for object in get_overlapping_bodies():
#		var c := PhysicsRayQueryParameters3D.create(position, object.position)
#		var result = space_state.intersect_ray(c)
#		print(result)
		if object is RigidDynamicBody3D:
			object.apply_impulse((object.position - position) * 5)
		if object is CharacterBody3D:
			object.velocity = (object.position - position) * 5
	
	await get_tree().create_timer(5).timeout
	queue_free()

