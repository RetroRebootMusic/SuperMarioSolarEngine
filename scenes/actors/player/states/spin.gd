class_name Spin
extends PlayerState
## Spinning for the first time.


## How much the spin sends you upwards when airborne.
@export var spin_power: float = 6

## Horizontal knockback from spinning against a wall.
@export var wall_kickback_power_x: float = 1.2
## Vertical knockback from spinning against a wall (only applied when airborne.)
@export var wall_kickback_power_y: float = 1.2

## If the spin action was performed while airborne or not.
var is_airspin: bool
## If the initial spin action has finished or not.
var finished_init: bool


func _on_enter(_handover):
	is_airspin = movement.can_air_action()

	if is_airspin:
		if input.get_last_x() != sign(actor.vel.x):
			actor.vel.x *= 0.5

		actor.vel.y = -spin_power

	movement.activate_freefall_timer()
	movement.consume_coyote_timer()


func _pre_tick():
	# Gravity needs to be applied when a grounded spin is buffered.
	# (Pressing the spin actions while being a few units from the ground.)
	if not is_airspin:
		movement.apply_gravity()


func _post_tick():
	movement.apply_gravity()


func _cycle_tick():
	if is_airspin:
		movement.move_x("air", false)
	else:
		movement.move_x("ground", false)
		input.queue_consume(&"spin")

	if not actor.doll.is_playing():
		finished_init = true

	# Spinning wall bonk.
	if actor.push_ray.is_colliding() and not finished_init:
		movement.return_res_prog = movement.return_res

		actor.vel.x = wall_kickback_power_x * -movement.facing_direction

		if is_airspin:
			actor.vel.y = -wall_kickback_power_y


func _on_exit():
	if not is_airspin:
		movement.activate_grounded_spin_timer()

	finished_init = false


func _tell_switch():
	if is_airspin:
		if actor.is_on_floor():
			return &"Idle"

		if finished_init and movement.can_air_action() and input.buffered_input(&"spin"):
			return &"Twirl"

		if movement.finished_freefall_timer():
			return &"Freefall"

		if Input.is_action_just_pressed(&"down") and movement.can_air_action():
			return &"GroundPound"

		if movement.can_wallslide() and finished_init:
			return &"Wallslide"

	else:
		if not actor.doll.is_playing():
			return &"Idle"

		if input.buffered_input(&"jump"):
			return &"Spinjump"

	return &""
