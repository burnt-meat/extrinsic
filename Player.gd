extends CharacterBody3D

var SPEED := 7.0
var JUMP_VELOCITY := 4.5
var in_air: bool = false

var jump_grace_period: bool
var jumping: bool
var crouching: bool

var jump_start_height: float
var crouch_start_rotation: Vector3

@export var sensitivity := 0.09

@onready var Neck: Node3D = $Neck
@onready var Camera: Camera3D = $Neck/Camera
@onready var SlideRay: RayCast3D = $SlideRay

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventKey:
		match OS.get_keycode_string(event.keycode):
			"Escape":
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_:
				pass
	
	if event is InputEventMouseMotion:
		rotate_y(-deg2rad(event.relative.x) * sensitivity)
		Neck.rotate_x(-deg2rad(event.relative.y) * sensitivity)
		Neck.rotation.x = clamp(Neck.rotation.x, -PI/2, PI/2)
		
	if event is InputEventMouseButton && Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	if Input.is_action_pressed("crouch"):
		if not crouching:
			crouch_start_rotation = rotation
		crouching = true
		if SlideRay.is_colliding() && SlideRay.get_collision_normal() != Vector3.UP:
			var f := SlideRay.get_collision_normal().normalized()
			velocity += Vector3(f.x, -15, f.z)  * .7
			
			Camera.rotation.z = lerp(Camera.rotation.z, Vector2(f.x, f.z).angle() * .1, 0.5)
		
		$Neck.position.y = 0.5
	else:
		crouching = false
		$Neck.position.y = 1
		Camera.rotation.z = 0
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		
		if not in_air and not jumping:
			jump_grace_period = true
			get_tree().create_timer(.3).connect("timeout", func(): jump_grace_period = false)
		
		in_air = true
	else:
		jump_grace_period = true
		if in_air:
			var fall_size := jump_start_height - position.y
			if fall_size > 2:
				$AnimationPlayer.play("hard_fall")
		in_air = false
		jumping = false
	
	if Input.is_action_just_pressed("jump") and jump_grace_period:
		jumping = true
		jump_grace_period = false
		jump_start_height = position.y
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/40)
		velocity.z = move_toward(velocity.z, 0, SPEED/40)

	move_and_slide()
