class_name InteractArea
extends Area2D

signal interaction(player: Player)

@export var _prompt: String

@onready var _hud: HUD = Globals.get_hud()


func _ready() -> void:
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, false)


func _physics_process(_delta: float) -> void:
	if not get_overlapping_bodies().is_empty():
		var player = get_overlapping_bodies()[0] as Player
		if player.can_interact():
			_hud.set_prompt("E: " + _prompt)
			if Input.is_action_just_pressed("interact"):
				interaction.emit(player)
