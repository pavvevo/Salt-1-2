extends RayCast3D

@onready var crosshair = $"../Crosshair"
@onready var prompt = $Prompt

@export var crosshair_basic = Texture2D
@export var crosshair_hover = Texture2D

func _process(delta):
	interact()
	
func interact():
	crosshair.texture = crosshair_basic
	prompt.text = ""
	if is_colliding():
		var other = get_collider()	
		if other is Interactable:
			prompt.text = other.get_prompt()
			crosshair.texture = crosshair_hover
			if Input.is_action_just_pressed(other.prompt_key):
				other.interact(owner)
