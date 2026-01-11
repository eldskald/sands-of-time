class_name RedShard
extends CharacterBody2D

@export var gravity: float
@export var fall_speed: float

@onready var _interact_area: InteractArea = %InteractArea


func _physics_process(delta: float) -> void:
	velocity.y = clampf(velocity.y + gravity * delta, -INF, fall_speed)
	_interact_area.set_collision_mask_value(1, is_on_floor())
	move_and_slide()


func _on_interact(player: Player) -> void:
	player.add_shard()
	queue_free()
