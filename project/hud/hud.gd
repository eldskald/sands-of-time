class_name HUD
extends Control

@export var _game_viewport: NodePath

@onready var _game_screen: TextureRect = %GameScreen
@onready var _level_title: Label = %LevelTitle
@onready var _prompt: Label = %Prompt
@onready var _text_container: CenterContainer = %TextBoxContainer
@onready var _text_label: Label = %TextLabel

var _next_prompt: String = ""


func _ready() -> void:
	var screen = get_node(_game_viewport) as Viewport
	_game_screen.texture = screen.get_texture()
	_game_screen.custom_minimum_size = Globals.game_screen_size


func _physics_process(_delta: float) -> void:
	_prompt.text = _next_prompt
	_next_prompt = ""


func set_level_title(new_title: String) -> void:
	_level_title.text = new_title


func set_prompt(new_prompt: String) -> void:
	_next_prompt = new_prompt


func set_text_box(text: String) -> void:
	_text_container.show()
	_text_label.text = text
	get_tree().paused = true


func _on_close_text_button_pressed() -> void:
	_text_container.hide()
	_text_label.text = ""
	get_tree().paused = false
