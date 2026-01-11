class_name HUD
extends Control

@export var _game_viewport: NodePath

@onready var _game_screen: TextureRect = %GameScreen
@onready var _level_title: Label = %LevelTitle
@onready var _prompt: Label = %Prompt
@onready var _first_text_container: CenterContainer = %FirstTextContainer
@onready var _final_text_container: CenterContainer = %FinalTextContainer
@onready var _first_text_label: Label = %FirstTextLabel
@onready var _final_text_label: Label = %FinalTextLabel

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


func set_text_box(text_1: String, text_2: String = "") -> void:
	if text_2:
		_first_text_label.text = text_1
		_final_text_label.text = text_2
		_first_text_container.show()
		_final_text_container.show()
	else:
		_final_text_label.text = text_1
		_final_text_container.show()
	get_tree().paused = true


func _on_close_button_pressed() -> void:
	_final_text_container.hide()
	_final_text_label.text = ""
	get_tree().paused = false


func _on_next_button_pressed() -> void:
	_first_text_container.hide()
	_first_text_label.text = ""


func _on_game_screen_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("click"):
		Globals.get_player().click_on(event.position)
