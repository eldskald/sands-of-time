class_name Main
extends Node

@onready var _level_container = %LevelContainer
@onready var _game_screen = %GameScreen
@onready var _hud = %HUD


func _ready() -> void:
	_game_screen.size = Globals.game_screen_size
	Globals.load_first_level()


func change_level(scene: PackedScene) -> void:
	for child in _level_container.get_children():
		child.queue_free()
	var new = scene.instantiate()
	_level_container.add_child(new)
	_hud.set_level_title(new.get_title())
