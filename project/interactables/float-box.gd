class_name FloatBox
extends CharacterBody2D

@export var gravity: float
@export var fall_speed: float
@export var friction: float

@onready var _platform_collision: StaticBody2D = %PlatformCollision
@onready var _interact_area: InteractArea = %InteractArea


func _physics_process(delta: float) -> void:
	velocity.y = clampf(velocity.y + gravity * delta, -INF, fall_speed)
	if velocity.x > 0.0:
		velocity.x = clampf(velocity.x - friction * delta, 0.0, INF)
	if velocity.x < 0.0:
		velocity.x = clampf(velocity.x + friction * delta, -INF, 0.0)
	
	if not is_on_floor():
		_platform_collision.set_collision_layer_value(4, false)
		_interact_area.set_collision_mask_value(1, false)
	else:
		_platform_collision.set_collision_layer_value(4, true)
		_interact_area.set_collision_mask_value(1, true)
	move_and_slide()


func _on_interact(player: Player) -> void:
	if not player.is_carrying():
		player.lift_float_box(self)
