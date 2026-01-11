class_name Player
extends CharacterBody2D

signal state_changed(new_state: State)
signal facing_changed(new_facing: float)

enum State { STANDING, MOVING, JUMPING, AIRBORNE, LIFTING, BOX_JUMPING }

@export_category("Basic Movement")
@export var speed: float
@export var acceleration: float
@export var air_acceleration: float
@export var friction: float
@export var air_friction: float
@export var jump_speed: float
@export var box_jump_speed: float
@export var end_jump_multiplier: float
@export var coyote_jump_time: float
@export var gravity: float
@export var fall_speed: float
@export var float_fall_speed: float

@export_category("Throwables")
@export var spawn_pos: Vector2
@export var box_jump_spawn_pos: Vector2
@export var box_spawn_vel: Vector2
@export var float_box: PackedScene

@onready var _sprite: PlayerSprite = %PlayerSprite
@onready var _platform_drop_timer: Timer = %PlatformDropTimer
@onready var _coyote_timer: Timer = %CoyoteJumpTimer

var _facing: float = 1.0
var _state: State = State.STANDING
var _old_vel: Vector2 = Vector2.ZERO
var _changing_level: bool = false
var _carrying: bool = false
var _about_to_lift: Node = null


func changing_level(is_going_up: bool = false) -> void:
	if is_going_up:
		_set_state(State.AIRBORNE)
		velocity.y = -jump_speed
	_old_vel = velocity
	_changing_level = true


func get_state() -> State:
	return _state


func can_interact() -> bool:
	return not _carrying and is_on_floor() and _state != State.LIFTING


func is_carrying() -> bool:
	return _carrying


func lift_float_box(box: Node) -> void:
	_set_state(State.LIFTING)
	velocity = Vector2.ZERO
	_about_to_lift = box


func _drop_down() -> void:
	_platform_drop_timer.start()
	set_collision_mask_value(4, false)


func _free_lifted_box() -> void:
	_about_to_lift.queue_free()
	_about_to_lift = null


func _end_lift_animation() -> void:
	_carrying = true
	_set_state(State.STANDING)


func _box_jump() -> void:
	var box = float_box.instantiate()
	box.position = position + Vector2(_facing * box_jump_spawn_pos.x, box_jump_spawn_pos.y)
	Globals.get_level().add_child(box)
	_carrying = false
	_set_state(State.AIRBORNE)
	velocity.y = -box_jump_speed


func _set_state(new_state: State) -> void:
	if new_state != _state:
		state_changed.emit(new_state)
		_state = new_state


func _get_input_dir() -> float:
	return (
		Input.get_action_strength("move_right")
		-Input.get_action_strength("move_left")
	)


func _get_acceleration() -> float:
	if is_on_floor():
		return acceleration
	else:
		return air_acceleration


func _get_friction() -> float:
	if is_on_floor():
		return friction
	else:
		return air_friction


func _get_fall_speed() -> float:
	if _carrying:
		return float_fall_speed
	else:
		return fall_speed


func _physics_process(delta: float) -> void:
	
	# When changing levels, we have to teleport the player and when doing so,
	# collisions with the previous level might zero out the velocity, causing
	# the player to teleport back to the previous screen so we do this.
	if _changing_level:
		velocity = _old_vel
		_changing_level = false
		return
	
	if _state != State.LIFTING and _state != State.BOX_JUMPING:
		var dir_input = _get_input_dir()
		if dir_input != 0.0:
			if _facing != dir_input:
				facing_changed.emit(dir_input)
			_facing = dir_input
		
		# Horizontal movement
		if abs(velocity.x) < speed:
			if dir_input != 0.0:
				velocity.x = clampf(
					velocity.x + dir_input * _get_acceleration() * delta,
					-speed,
					speed
				)
			elif dir_input <= 0.0 and velocity.x > 0.0:
				velocity.x = clampf(
					velocity.x - _get_friction() * delta, 0.0, speed
				)
			elif dir_input >= 0.0 and velocity.x < 0.0:
				velocity.x = clampf(
					velocity.x + _get_friction() * delta, -speed, 0.0
				)
		else:
			velocity.x -= sign(velocity.x) * _get_friction() * delta
		
		# Dropping down
		if Input.is_action_just_pressed("drop_down"):
			_drop_down()
		
		# Vertical movement
		velocity.y = clampf(velocity.y + gravity * delta, -INF, _get_fall_speed())
		if is_on_floor() and abs(velocity.x) <= 0.1:
			_set_state(State.STANDING)
		elif is_on_floor():
			_set_state(State.MOVING)
		elif not is_on_floor() and _state != State.JUMPING:
			_set_state(State.AIRBORNE)
		
		# Jumping
		if is_on_floor():
			_coyote_timer.start(coyote_jump_time)
		if !_coyote_timer.is_stopped() and Input.is_action_just_pressed("jump"):
			velocity.y = -jump_speed
			_set_state(State.JUMPING)
		if _state == State.JUMPING and velocity.y >= 0.0:
			_set_state(State.AIRBORNE)
		if _state == State.JUMPING and Input.is_action_just_released("jump"):
			velocity.y *= end_jump_multiplier
			_set_state(State.AIRBORNE)
		
		# Throwing carried box
		if _carrying:
			Globals.get_hud().set_prompt("E: throw")
			if Input.is_action_just_pressed("interact"):
				var box = float_box.instantiate()
				box.position = position + Vector2(_facing * spawn_pos.x, spawn_pos.y)
				box.velocity = Vector2(_facing * box_spawn_vel.x, box_spawn_vel.y)
				Globals.get_level().add_child(box)
				_carrying = false
				_sprite.animate_throw()
		
		# Box jumping
		if _carrying and _state == State.AIRBORNE and Input.is_action_just_pressed("jump"):
			velocity = Vector2.ZERO
			_set_state(State.BOX_JUMPING)
	
	# Call move_and_slide()
	move_and_slide()


func _on_platform_drop_timer_timeout() -> void:
	set_collision_mask_value(4, true)
