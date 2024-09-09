extends RigidBody3D

@export var water_force := 1.0
@export var water_drag := 0.05

@export var boat_speed = 75.0
var pole_direction = 0.0

@onready var water = $"../Water"
@onready var player = $"../Player"

@onready var checks = $DepthChecks.get_children()

@onready var sail_open = $Sail/SailOpen
var sail_bounce = 0.0
var sail_material = false

@onready var pole = $Pole
@onready var pole_depth_check = $Pole/PoleShape/PoleDepthCheck
var cursor = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var water_level = 0.0
var in_water = false

var sail = false
var drive = false
var player_inside = false

var mouse_movement = 0.0
var pole_lerp_rotation = 0.0
var player_angle = 0.0

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.get_relative().x

func _physics_process(delta):	
	if !sail_material:
		sail_material = sail_open.get_surface_override_material(0)
	
	if drive:
		if Input.is_action_pressed("Jump"):
			change_drive()
		
		var pole_change = mouse_movement * 7.5
		pole_lerp_rotation += deg_to_rad(pole_change)
		pole_lerp_rotation = clamp(pole_lerp_rotation, -75, 75)
		pole.rotation.z = lerp_angle(pole.rotation.z, deg_to_rad(pole_lerp_rotation), 10 * delta)
		
		var distance = pole.global_position.distance_to(player.global_position)
		if distance > 4.0:
			drive = false
			player.drive = false
		
		var pole_depth = water.get_height(pole_depth_check.global_position) - pole_depth_check.global_position.y
			
		if pole_depth > 0:
			var force_to_apply = pole_change * pole.basis.x
			force_to_apply.x = 0.0
			force_to_apply.z = 0.0
			apply_torque(force_to_apply)

	mouse_movement = 0.0
	
	if sail:
		if sail_material:
			sail_bounce = lerp(sail_bounce, 1.0, delta * 12.0)
			sail_material.set_shader_parameter("bounce", sail_bounce)

		var boat_force = basis.z * boat_speed
		apply_central_force(boat_force)
	else:
		if sail_material:
			sail_bounce = lerp(sail_bounce, 0.1, delta * 7.0)
			sail_material.set_shader_parameter("bounce", sail_bounce)

	if water:
		in_water = false
		for c in checks:
			var depth = water.get_height(c.global_position) - c.global_position.y
			if depth > 0:
				if !in_water:
					in_water = true
				apply_force(Vector3.UP * water_force * gravity * depth, c.global_position - global_position)
			

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if in_water:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_drag

func _on_sail_interacted(body):
	sail = !sail

func _on_pole_interacted(body):
	change_drive()
	
func change_drive():
	if !drive and !player.is_on_floor():
		return
	
	drive = !drive
	player.drive = drive
	
	if drive:
		player.reparent(self)
	else:
		player.reparent(get_tree().get_root())
		player.rotation.x = 0.0
		player.rotation.z = 0.0
