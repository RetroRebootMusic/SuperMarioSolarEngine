class_name Walk
extends PlayerState
## Moving left and right on the ground.


func _cycle_tick():
	var current_frame = actor.doll.get_frame()
	var current_progress = actor.doll.get_frame_progress()

	movement.activate_coyote_timer()
	movement.move_x("ground", true)

	# Switch between the running and walking animation depending on your velocity.
	if roundf(abs(actor.vel.x)) > movement.max_speed:
		actor.doll.play("run")
		actor.doll.set_frame_and_progress(current_frame, current_progress)

		actor.vel.x = move_toward(actor.vel.x, movement.max_speed * movement.facing_direction, 0.1)
	else:
		actor.doll.play("walk")
		actor.doll.set_frame_and_progress(current_frame, current_progress)

	actor.doll.speed_scale = actor.vel.x / movement.max_speed * 2


func _on_exit():
	actor.doll.speed_scale = 1


func _tell_switch():
	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if input.buffered_input(&"jump"):
		return &"DummyJump"

	if Input.is_action_just_pressed(&"dive"):
		return &"AirborneDive"

	if input_direction != 0:
		if abs(actor.vel.x) >= movement.max_speed and input_direction != movement.facing_direction:
			return &"TurnSkid"
	else:
		if abs(actor.vel.x) >= movement.max_speed:
			return &"StopSkid"
		else:
			return &"Idle"

	if Input.is_action_pressed(&"down"):
		if movement.is_slide_slope():
			return &"ButtSlide"
		else: 
			return &"Crouch"

	if InputManager.get_x() != 0 and actor.is_on_wall():
		if actor.push_ray.is_colliding():
			return &"Push"
		else:
			return &"DryPush"

	return &""
