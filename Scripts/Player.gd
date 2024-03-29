extends CharacterBody3D

var speed := 7.0

var last_position: Vector3

var in_air: bool = false

var jump_grace_period: bool
var jumping: bool
var crouching: bool
var sliding: bool
var stop_sliding: bool

var dead: bool = false

var jump_start_height: float
var crouch_start_rotation: Vector3

@export var JUMP_VELOCITY := 7.0

@export var DEFAULT_SPEED := 6
@export var MAX_SPEED := 28.0
@export var SPEED_UP_RATE := 3

@export var sensitivity := 0.2
@export var jp_sensitivity = 0.1

@onready var Neck: Node3D = $Neck
@onready var Camera: Camera3D = $Neck/Camera
@onready var SlideRay: RayCast3D = $SlideRay
@onready var AP: AnimationPlayer = $AnimationPlayer
@onready var WeaponHolder: Node3D = %WeaponHolder
@onready var HUD: Control = $HUD

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.5


var inIFrame: bool = false

var health: float = 10.0:
	set(val):
		if inIFrame:
			pass
		else:
			if val <= 0 and not dead:
				die()
			if val < health:
				Camera.trauma = 1
				HUD._update_health_meter(val)
				inIFrame = true
				get_tree().create_timer(.5).connect("timeout", func(): inIFrame = false)
			health = val

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ScoreApi.connect("score_changed", func(): print(ScoreApi.score))
	GunApi.create_weapon("Rifle", 1, .2, 20, 1.0, true, [], "res://Scenes/Guns/Rifle.tscn")
	GunApi.create_weapon("Boom", 0, 1, 2, 5.0, false, [BoomGunEffect.new()], "res://Scenes/Guns/Boom.tscn")
	GunApi.switch_weapon(0)

func die():
	dead = true
	set_process(false)
	set_process_input(false)
	var ragdoll = load("res://Scenes/Ragdoll.tscn").instantiate()
	Neck.remove_child(Camera)
	ragdoll.add_child(Camera)
	var pos := position
	get_tree().get_current_scene().add_child(ragdoll)
	ragdoll.position = pos
	HUD.died()


func _input(event):
	if event is InputEventKey:
		match OS.get_keycode_string(event.keycode):
			"Escape":
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_:
				pass
	
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x) * sensitivity)
		Neck.rotate_x(-deg_to_rad(event.relative.y) * sensitivity)
		Neck.rotation.x = clamp(Neck.rotation.x, -PI/2, PI/2)
		
	if event is InputEventMouseButton && Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if velocity.length() > 5:
		# TODO add FOV setting
		speed += SPEED_UP_RATE * delta
		speed = clamp(speed, 0, MAX_SPEED)
	else:
		speed = DEFAULT_SPEED
	
	Camera.fov = lerp(Camera.fov, 75 + velocity.length(), 0.1)
	
	var yaw = Input.get_axis("jp_left", "jp_right")
	rotate_y(-yaw * jp_sensitivity)
	
	var pitch = Input.get_axis("jp_up", "jp_down")
	Neck.rotate_x(-pitch * jp_sensitivity)
	Neck.rotation.x = clamp(Neck.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_pressed("weapon1"):
		GunApi.switch_weapon(0)
	if Input.is_action_just_pressed("weapon2"):
		GunApi.switch_weapon(1)
	
	if Input.is_action_pressed("crouch"):
		if not crouching:
			crouch_start_rotation = rotation
		crouching = true
		if SlideRay.is_colliding() and not SlideRay.get_collider().is_in_group("Enemy") and SlideRay.get_collision_normal().y != 1 and not stop_sliding:
			sliding = true
			var f := SlideRay.get_collision_normal()
			velocity += Vector3(f.x, -15, f.z)  * .7
			
			if not in_air:
				Camera.rotation.z = lerp(Camera.rotation.z, Vector2(f.x, f.z).angle() * .1, 0.1)
				WeaponHolder.rotation.z = lerp(WeaponHolder.rotation.z, Vector2(f.x, f.z).angle(), 0.1)
		else:
			sliding = false
			Camera.rotation.z = lerp(Camera.rotation.z, 0.0, 0.1)
			WeaponHolder.rotation.z = lerp(WeaponHolder.rotation.z, 0.0, 0.1)
		Neck.position.y = 0.5
	else:
		crouching = false
		Neck.position.y = 1
		Camera.rotation.z = lerp(Camera.rotation.z, 0.0, 0.1)
		WeaponHolder.rotation.z = lerp(WeaponHolder.rotation.z, 0.0, 0.1)
	WeaponHolder.rotation.z = clamp(WeaponHolder.rotation.z, -PI/3, PI/3)
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		
		if not in_air and not jumping:
			jump_grace_period = true
			get_tree().create_timer(.3).connect("timeout", func(): jump_grace_period = false)
		
		in_air = true
	else:
		jump_grace_period = true
		if in_air:
			#var fall_size := jump_start_height - position.y
			AP.speed_scale = 1
			AP.play("hard_fall")
		in_air = false
		jumping = false
	
	if Input.is_action_just_pressed("jump") and jump_grace_period:
		if sliding:
			stop_sliding = true
		jumping = true
		jump_grace_period = false
		jump_start_height = position.y
		velocity.y = JUMP_VELOCITY
		get_tree().create_timer(.3).connect("timeout", func(): stop_sliding = false)
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed/40)
		velocity.z = move_toward(velocity.z, 0, speed/40)
	
	last_position = position
	move_and_slide()
