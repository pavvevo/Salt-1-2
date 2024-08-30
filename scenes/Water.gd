extends MeshInstance3D

@export var follow:Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(follow):
		position.x = follow.position.x
		position.z = follow.position.z
