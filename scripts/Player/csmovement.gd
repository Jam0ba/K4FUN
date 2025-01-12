extends CharacterBody3D

@onready var camera: Camera3D = %Camera3D
@onready var foot_steps = $FootSteps

#MOVEMENT
var mouse_sens: float = 0.0005
var friction: float = 6
var accel: float = 6
var accel_air: float = 60
var top_speed_ground: float = 8
var top_speed_air: float = 0.8
var lin_friction_speed: float = 0.2
var jump_force: float = 7
var projected_speed: float = 0
var grounded_prev: bool = true
var grounded: bool = true
var is_ducking : bool = false
var wish_dir: Vector3 = Vector3.ZERO
var input_dir
var mouse_input
#-----------------------------------------

@onready var health_manager = %HealthManager
@onready var weapon_manager = %Weapon_Holder
@onready var ani_player = %AniPlayer




var dead : bool = false
var is_crouch : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 16

func _ready()  -> void:
	camera.visible = is_multiplayer_authority()
	mouse_input = Vector2.ZERO
	health_manager.died.connect(kill)
	

func _process(_delta : float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	weapon_manager.attack(Input.is_action_just_pressed("shoot"), Input.is_action_pressed("shoot"))
	if Input.is_action_pressed("run") and is_on_floor():
		accel = 10
		camera.fov = lerp(camera.fov, 74.0, 10.0 * _delta)
	if Input.is_action_just_released("run") or !is_on_floor():
		accel = 6
		camera.fov = 75
	#if Input.is_action_pressed("run"):
		#accel = 50
		#camera.fov = 100
	#if Input.is_action_just_released("run") or !is_on_floor() or !is_crouch:
		#accel = 6
		#camera.fov = 75
	if velocity.length() != 0 and is_on_floor():
		if !foot_steps.playing:
			foot_steps.pitch_scale = randf_range(0.92, 1)
			foot_steps.play()
	else:
		foot_steps.stop()

func _physics_process(delta : float)  -> void:
	if !dead:
		if !is_multiplayer_authority():
			return
		grounded_prev = grounded
		# Get the input direction and handle the movement/deceleration.
		projected_speed = (velocity * Vector3(1, 0, 1)).dot(wish_dir)
		
		# Add the gravity.
		if not is_on_floor():
			grounded = false
			air_move(delta)
		if is_on_floor():
			if velocity.y > 10:
				grounded = false
				air_move(delta)
			else:
				grounded = true
				ground_move(delta)
		move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if !dead:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				self.rotate_y(-event.relative.x * mouse_sens)
				camera.rotate_x(-event.relative.y * mouse_sens)
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
				mouse_input = event.relative
		if event.is_action_pressed("KEY_1"):
			weapon_manager.switch_to_weapon_slot(0)
		if event.is_action_pressed("KEY_2"):
			weapon_manager.switch_to_weapon_slot(1)
		if event.is_action_pressed("KEY_3"):
			weapon_manager.switch_to_weapon_slot(2)
		if event.is_action_pressed("weapon_switch"):
			weapon_manager.switch_to_previous_weapon()

#MOVEMENT HANDL
func clip_velocity(normal: Vector3, overbounce: float, _delta) -> void:
	var correction_amount: float = 0
	var correction_dir: Vector3 = Vector3.ZERO
	var move_vector: Vector3 = get_velocity().normalized()
	
	correction_amount = move_vector.dot(normal) * overbounce
	
	correction_dir = normal * correction_amount
	velocity -= correction_dir
	# this is only here cause I have the gravity too high by default
	# with a gravity so high, I use this to account for it and allow surfing
	velocity.y -= correction_dir.y * (gravity % 2)
func apply_friction(delta) -> void:
	var speed_scalar: float = 0
	var friction_curve: float = 0
	var speed_loss: float = 0
	var current_speed: float = 0
	
	# using projected velocity will lead to no friction being applied in certain scenarios
	# like if wish_dir is perpendicular
	# if wish_dir is obtuse from movement it would create negative friction and fling players
	current_speed = velocity.length()
	
	if(current_speed < 0.1):
		velocity = Vector3.ZERO
		return
	
	friction_curve = clampf(current_speed, lin_friction_speed, INF)
	speed_loss = friction_curve * friction * delta
	speed_scalar = clampf(current_speed - speed_loss, 0, INF)
	speed_scalar /= clampf(current_speed, 1, INF)
	
	velocity *= speed_scalar
func apply_acceleration(acceleration: float, top_speed: float, delta) -> void:
	var speed_remaining: float = 0
	var accel_final: float = 0
	
	speed_remaining = (top_speed * wish_dir.length()) - projected_speed
	
	if speed_remaining <= 0:
		return
	
	accel_final = acceleration * delta * top_speed 
	
	clampf(accel_final, 0, speed_remaining)
	
	velocity.x += accel_final * wish_dir.x
	velocity.z += accel_final * wish_dir.z
	
func air_move(delta) -> void:
	apply_acceleration(accel_air, top_speed_air, delta)
	
	clip_velocity(get_wall_normal(), 2, delta)
	clip_velocity(get_floor_normal(), 2, delta)
	
	velocity.y -= gravity * delta
func ground_move(delta) -> void:
	floor_snap_length = 0.4
	apply_acceleration(accel, top_speed_ground, delta)
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
	
	if grounded == grounded_prev:
		apply_friction(delta)
	
	if is_on_wall:
		clip_velocity(get_wall_normal(), 1, delta)
#MOVEMENT HANDL

func kill():
	dead = true

func hurt(damage_data : DamageData) -> void:
	health_manager.hurt(damage_data)
