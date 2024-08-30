extends Node3D

@onready var splash = $GPUParticles3D

func _ready():
	splash.emitting = true

func _on_timer_timeout():
	queue_free()
