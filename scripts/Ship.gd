extends RigidBody3D

@export var water_force := 1.0
@export var water_drag := 0.05

@onready var water = $"../Water"
@onready var player = $"../Player"

@onready var checks = $DepthChecks.get_children()

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var water_level = 0.0
var in_water = false

var drive = false
var player_inside = false

func _physics_process(delta):
	
	if player_inside:
		if Input.is_action_just_pressed("Interact"):
			drive = true
			player.drive = true
			print("driving")
	
	if drive:
		if Input.is_action_just_pressed("Interact"):
			drive = false
			player.drive = false
			print("nah")
	
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


func _on_drive_body_entered(body):
	if body.name == "Player":
		player_inside = true


func _on_drive_body_exited(body):
	if body.name == "Player":
		player_inside = false
