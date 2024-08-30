extends CharacterBody3D

@onready var world = get_tree().get_root().get_node("Main")

@onready var ocean = $"../Water"
const splash = preload("res://scenes/Splash.tscn")

@onready var standing_body = $StandingBody
@onready var crouching_body = $CrouchingBody
@onready var head_check = $HeadCheck
@onready var height_check = $HeightCheck

const walk_speed = 7.0
const run_speed = 10.0
const crouch_speed = 5.0
var friction = 20
var ground_friction = 30
var air_friction = 10

var move_speed = 5.0
const jump_power = 6
var lerp_speed = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var onground = 0

var slide_timer_max = 1.0
var slide_timer = slide_timer_max
var slide_vector = Vector2.ZERO
var slide_speed = 20.0

var direction = Vector3.ZERO
var input_dir = Vector2.ZERO
var last_velocity = Vector3.ZERO
var last_position = Vector3.ZERO

@onready var head = $Neck/Head
@onready var neck = $Neck
@onready var camera = $Neck/Head/Eyes/Camera3D
@onready var eyes = $Neck/Head/Eyes
@onready var camera_animation = $Neck/Head/Eyes/CameraAnimation

var sensetivity = 0.2
var head_height = 1.0
var free_look_tilt = -8
var land_timer = 0.0

#water
var water_level = 0.0
var water_force = -ProjectSettings.get_setting("physics/3d/default_gravity")
var in_water = false
var water_exists = true

#head bob
var bob_run = 22.0
var bob_run_intesity = 0.2
var bob_crouch = 10.0
var bob_crouch_intensity = 0.05
var bob_walk = 15.0
var bob_walk_intensity = 0.1
var bob_vector = Vector2.ZERO
var bob_index = 0.0
var bob_intensity = 0.0

#states
var is_running = false
var is_crouching = false
var is_free_looking = false
var is_sliding = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		if is_free_looking:
			neck.rotate_y(deg_to_rad(event.relative.x * -sensetivity))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(event.relative.x * -sensetivity))
		head.rotate_x(deg_to_rad(event.relative.y * -sensetivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	
	var look_vector = Input.get_vector("Look Left", "Look Right", "Look Up", "Look Down")
		
	if(look_vector != Vector2.ZERO):
		if is_free_looking:
			neck.rotate_y(deg_to_rad(look_vector.x * -sensetivity * 20))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(look_vector.x * -sensetivity  * 20))
		head.rotate_x(deg_to_rad(look_vector.y * -sensetivity  * 20))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	#view_model.rotation.y += (head.rotation.y - view_model.rotation.y) / 0.1 * delta
	#view_model.rotation.x += (head.rotation.x - view_model.rotation.x) / 0.1 * delta
	
	#basic movement
	move_speed = walk_speed
	
	is_running = true #Input.is_action_pressed("Run")
	if(is_running): move_speed = run_speed

	#crouching and sliding
	is_crouching = Input.is_action_pressed("Crouch")
	if !is_crouching: is_crouching = head_check.is_colliding() 
	if is_sliding: is_crouching = true
	
	standing_body.disabled = false
	crouching_body.disabled = true
	
	if in_water:
		is_crouching = false
	
	if is_crouching:
		standing_body.disabled = true
		crouching_body.disabled = false
		
		if input_dir != Vector2.ZERO and is_on_floor():
			if Input.is_action_just_pressed("Crouch"):
				
				var speed_magnitude = Vector2(velocity.x, velocity.z).length()
				
				if speed_magnitude > run_speed - 2.0 and speed_magnitude < run_speed + 1.0:
					is_sliding = true
					slide_timer = slide_timer_max
					slide_vector = input_dir
		
		if !is_sliding:
			if(is_on_floor()):
				head_height = -1.0
				move_speed = crouch_speed
			else:
				head_height = -0.5
				if(!height_check.is_colliding()):
					velocity.y -= gravity * delta * 5
	else:
		head_height = 0.0
		
	if(is_sliding):
		head_height = -1.0
		move_speed = (slide_timer + 0.25) * slide_speed;
		
		if(slide_timer <= 0): 
			is_sliding = false
			slide_timer = 0.0

	if(slide_timer > 0):
		slide_timer -= delta
	
	head.position.y = lerp(head.position.y, head_height, delta * 5)
	
	#free looking
	is_free_looking = Input.is_action_pressed("Freelook")
	if(is_sliding): is_free_looking = true
	if(!is_free_looking): 
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * 10.0)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * 10.0)
	else:
		if(is_sliding):
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(10.0), delta * 5.0)
		else:
			eyes.rotation.z = deg_to_rad(neck.rotation.y * free_look_tilt)

	if is_running:
		bob_intensity = bob_run_intesity
		bob_index += bob_run * delta
	elif is_crouching:
		bob_intensity = bob_crouch_intensity
		bob_index += bob_crouch * delta
	else:
		bob_intensity = bob_walk_intensity
		bob_index += bob_walk * delta
		
	if is_on_floor() and (!is_sliding) and (input_dir != Vector2.ZERO):
		bob_vector.y = sin(bob_index)
		bob_vector.x = sin(bob_index / 2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, bob_vector.y * bob_intensity, 5 * delta)
		eyes.position.x = lerp(eyes.position.x, bob_vector.x * bob_intensity, 5 * delta)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, 5 * delta)
		eyes.position.x = lerp(eyes.position.x, 0.0, 5 * delta)
		
	
	# Add the gravity.
	last_velocity = velocity
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if (Input.is_action_just_pressed("Jump")) and (onground > 0):
		onground = 0.0
		velocity.y = jump_power
		camera_animation.play("Jump")
		
		velocity.x += direction.x * move_speed * 0.25
		velocity.z += direction.z * move_speed * 0.25
		
		if(is_sliding):
			is_sliding = false
			velocity.x = direction.x * slide_speed
			velocity.z = direction.z * slide_speed
			
	if(onground < 0):
		is_sliding = false

	input_dir = Input.get_vector("Left", "Right", "Forward", "Backwards")
	var lerp_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = lerp(direction, lerp_dir, delta * lerp_speed)
	if(is_sliding): direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
	
	velocity.x = move_toward(velocity.x, direction.x * move_speed, delta * friction)
	velocity.z = move_toward(velocity.z, direction.z * move_speed, delta * friction)
	
	last_position = position
	
	#water
	if water_exists:
		if position.y <= water_level:
			if !in_water:
				velocity.y = -2
				in_water = true
				var cool_splash = splash.instantiate()
				world.add_child(cool_splash)
				cool_splash.position = position - Vector3(0.0, 1.0, 0.0)
				
			velocity.y -= water_force * delta * 1.5
		else:
			in_water = false
	
	move_and_slide()

	if is_on_floor():
		friction = ground_friction
		if(onground <= 0): 
			if(last_velocity.y < -18.0):
				camera_animation.play("Big Land")
			else:
				camera_animation.play("Land")
			
		onground = 0.2
	else:
		friction = air_friction
		onground -= delta
	
	if(ocean):	
		ocean.position.x = position.x
		ocean.position.z = position.z
		
