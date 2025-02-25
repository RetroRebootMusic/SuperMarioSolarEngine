class_name PushRay
extends RayCast2D
## A ray to check for pushable solid bodies


## Value of target_position.x
@export var target_size_x: float
@export var movement: PMovement


func _process(_delta):
	target_position.x = target_size_x * movement.facing_direction
