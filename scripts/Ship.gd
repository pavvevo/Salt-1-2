extends RigidBody3D

@export var water_force := 1.0
@export var water_drag := 0.05

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var water_level = 0.0
var in_water = false

func _physics_process(delta):
	var depth = water_level - global_position.y
	if depth > 0:
		if !in_water:
			in_water = true
		apply_central_force(Vector3.UP * water_force * gravity * depth)
	else:
		in_water = false

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if in_water:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_drag
