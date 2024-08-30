extends RigidBody3D

var water_level = 0.0
var water_force = ProjectSettings.get_setting("physics/3d/default_gravity")
var in_water = false
var water_exists = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	
	if position.y < water_level:
		if !in_water:
			in_water = true
		apply_force(Vector3(0.0, water_force * 20.0, 0.0))
	
