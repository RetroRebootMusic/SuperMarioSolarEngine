class_name StopSkid
extends PlayerState
## Stopping from grounded movement at max speed.


## How long it takes to decelerate from a skid.
@export var skid_decel_time: float = 16
var skid_decel_step: float


func _on_enter(_handover):
	skid_decel_step = movement.max_speed / skid_decel_time


func _cycle_tick():
	movement.decelerate(skid_decel_step)


func _tell_switch():
	if actor.vel.x == 0:
		if input_direction == 0:
			return &"Idle"
		else:
			return &"Walk"
	elif input_direction == -movement.facing_direction:
		return &"TurnSkid"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if input.buffered_input(&"jump"):
		return &"DummyJump"

	if Input.is_action_pressed(&"down"):
		return &"Crouch"

	if Input.is_action_just_pressed(&"dive"):
		return &"AirborneDive"

	return &""
