class_name RedProjectile
extends Area2D

@export var speed: float
@export var radius: int

@onready var _anim: AnimationPlayer = $AnimationPlayer

var velocity: Vector2 = Vector2.ZERO

var _exploding: bool = false


func set_velocity(direction: Vector2) -> void:
	velocity = direction.normalized() * speed


func _clear_dirt() -> void:
	var points: Array[Vector2] = []
	for i in range(-radius, radius + 1):
		for j in range(-radius, radius + 1):
			var r = Vector2(i, j)
			if r.length() <= radius:
				points.append(r + position)
	Globals.get_level().clear_dirt(points)


func _physics_process(delta: float) -> void:
	if _exploding:
		return
	position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if _exploding:
		return
	_exploding = true
	if body is FloatBox:
		body.explode()
		queue_free()
	else:
		_anim.play("explosion")
