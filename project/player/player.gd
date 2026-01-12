class_name Player
extends CharacterBody2D

signal state_changed(new_state: State)
signal facing_changed(new_facing: float)

enum State {
	STANDING, MOVING, JUMPING, AIRBORNE, LIFTING, BOX_JUMPING,
	DIGGING_DOWN, DIGGING_FORWARD, DIGGING_UP,
}

@export_category("Movement")
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

@export_category("Digging")
@export var dig_range: Vector2
@export var radius: int

@export_category("Throwables")
@export var max_shards: int
@export var spawn_pos: Vector2
@export var box_jump_spawn_pos: Vector2
@export var box_spawn_vel: Vector2
@export var float_box: PackedScene
@export var red_projectile: PackedScene

@onready var _sprite: PlayerSprite = %PlayerSprite
@onready var _platform_drop_timer: Timer = %PlatformDropTimer
@onready var _coyote_timer: Timer = %CoyoteJumpTimer

@onready var _jump_sfx: AudioStreamPlayer = $JumpSFX
@onready var _throw_sfx: AudioStreamPlayer = $ThrowSFX
@onready var _box_jump_sfx: AudioStreamPlayer = $BoxJumpSFX
@onready var _dig_sfx: AudioStreamPlayer = $DigSFX
@onready var _explosion_sfx: AudioStreamPlayer = $ExplosionSFX
@onready var _box_explode_sfx: AudioStreamPlayer = $BoxAboutToExplodeSFX

var _facing: float = 1.0
var _state: State = State.STANDING
var _old_vel: Vector2 = Vector2.ZERO
var _changing_level: bool = false
var _carrying: bool = false
var _about_to_lift: Node = null
var _digging_on: Vector2 = Vector2.ZERO
var _shovel_equipped: bool = true
var _shards: int = 0


func equip_shovel() -> void:
	_shovel_equipped = true


func equip_shards() -> void:
	_shovel_equipped = false


func add_shard() -> void:
	_shards = min(_shards + 1, max_shards)
	Globals.get_hud().set_red_shards(_shards)


func changing_level(is_going_up: bool = false) -> void:
	if is_going_up:
		_set_state(State.AIRBORNE)
		velocity.y = -jump_speed
	_old_vel = velocity
	_changing_level = true


func click_on(pos: Vector2) -> void:
	if not _is_controllable():
		return
	if _shovel_equipped:
		if not is_on_floor() or _carrying:
			return
		if abs(pos.x - position.x) > dig_range.x or abs(pos.y - position.y) > dig_range.y:
			return
		var dir = pos - position
		var face = Vector2(_facing, 0.0)
		if face.dot(dir) < 0.0:
			_facing *= -1
			facing_changed.emit(_facing)
		face = Vector2(_facing, 0.0)
		var angle = dir.angle_to(face)
		if angle <= -PI / 8:
			_set_state(State.DIGGING_DOWN)
		elif angle >= PI / 8:
			_set_state(State.DIGGING_UP)
		else:
			_set_state(State.DIGGING_FORWARD)
		_digging_on = pos
		_dig_sfx.play()
	else:
		_shards = max(_shards - 1, 0)
		Globals.get_hud().set_red_shards(_shards)
		var dir = pos - position
		if Vector2(_facing, 0.0).dot(dir) < 0.0:
			_facing *= -1
			facing_changed.emit(_facing)
		var projectile = red_projectile.instantiate()
		projectile.position = position
		projectile.set_velocity(dir)
		Globals.get_level().add_child(projectile)
		_sprite.animate_throw()
		_throw_sfx.play()


func get_state() -> State:
	return _state


func can_interact() -> bool:
	return not _carrying and is_on_floor() and _is_controllable()


func is_carrying() -> bool:
	return _carrying


func lift_float_box(box: Node) -> void:
	_set_state(State.LIFTING)
	velocity = Vector2.ZERO
	_about_to_lift = box
	_box_jump_sfx.play()


func _is_controllable() -> bool:
	return not _state in [
		State.LIFTING, State.BOX_JUMPING, State.DIGGING_DOWN,
		State.DIGGING_FORWARD, State.DIGGING_UP
	]


func play_explosion() -> void:
	_explosion_sfx.play()


func play_box_about_to_explode() -> void:
	_box_explode_sfx.play()


func _drop_down() -> void:
	_platform_drop_timer.start()
	set_collision_mask_value(4, false)


func _free_lifted_box() -> void:
	_about_to_lift.queue_free()
	_about_to_lift = null


func _end_lift_animation() -> void:
	_carrying = true
	_set_state(State.STANDING)


func _dig() -> void:
	var points: Array[Vector2] = []
	for i in range(-radius, radius + 1):
		for j in range(-radius, radius + 1):
			var p = Vector2(i, j) + _digging_on
			if _digging_on.distance_to(p) <= radius:
				points.append(p)
	Globals.get_level().clear_dirt(points)


func _end_digging_animation() -> void:
	_set_state(State.STANDING)


func _box_jump() -> void:
	var box = float_box.instantiate()
	box.position = position + Vector2(_facing * box_jump_spawn_pos.x, box_jump_spawn_pos.y)
	Globals.get_level().add_child(box)
	_carrying = false
	_set_state(State.AIRBORNE)
	velocity.y = -box_jump_speed
	velocity.x = _facing * speed
	_jump_sfx.play()


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
	
	if _is_controllable():
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
			_jump_sfx.play()
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
				_throw_sfx.play()
		
		# Box jumping
		if _carrying and _state == State.AIRBORNE and Input.is_action_just_pressed("jump"):
			velocity = Vector2.ZERO
			_set_state(State.BOX_JUMPING)
			_box_jump_sfx.play()
	
	# Call move_and_slide()
	move_and_slide()


func _on_platform_drop_timer_timeout() -> void:
	set_collision_mask_value(4, true)
