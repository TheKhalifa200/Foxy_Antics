extends CharacterBody2D

@export var gravity:float=800.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += delta*gravity
	move_and_slide()
